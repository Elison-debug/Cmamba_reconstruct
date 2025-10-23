# CMamba → ZCU102 评估与改造建议（不改动现有文件）

本文从训练/推理稳定性、量化一致性（C++/Verilog）、Zynq ZCU102 资源约束三方面评估当前 simple-CMamba 项目，并给出不侵入现有代码的改造建议与可直接复制的代码片段。目标：在软件端用 C++ 实现与硬件 RTL 一致的量化路径，保证 Verilog 行为与软件推理严格对齐，便于后续在 ZCU102 上实现与验证。

---

## 1) 现状与潜在问题（训练/推理）

- 深度堆叠风险（层数放大）
  - 结构 `CMamba → [CMambaBlock × n_layer]`，而 `CMambaBlock` 内部又含 `PatchMamba → [MambaBlock × n_layer]`，实际 MambaBlock 数量为 `n_layer × n_layer`（默认 4×4=16）。相比预期“线性堆叠 n_layer 次”，计算参数与时延都显著增大，部署代价偏高。
  - 建议：训练与部署采用“单层内只含一个 MambaBlock；外层线性堆叠 n_layer 次”的等效改造（见第 3 节“结构收敛方案”）。

- 位置编码与补齐（forecast_len padding）
  - 训练构造使用 `pad_multiple=8`，包裹回归器时强制 `forecast_len=1` 并设置 `pad_multiple=1` 来避免时间维被扩展；评估端通过 `mean(dim=-1)` 进行压缩。此逻辑在硬件侧需保持一致，否则会出现时间维对齐差异。

- 随机增强对可复现性的影响
  - `ChannelMixup` 在训练阶段引入随机置换与高斯噪声；评估阶段虽不启用，但若导出(QAT/PTQ)时未显式关闭或未设定固定随机种子，可能造成标定/比对不稳定。

- 归一化与量化的耦合
  - 训练端使用 `LayerNorm`（输入）+ `RMSNorm`（块内），硬件侧实现成本高。若希望硬件端固定点实现简化且可复现，建议将“输入特征归一化”固定为“使用数据集 train 均值/方差”的线性仿射（冻结参数），Mamba 内部归一化可在软件端保留、硬件端用近似线性缩放替代（见第 4 节）。

- 数据流水与内存布局
  - 训练使用通道优先 `(B, C, K)`，Patch 展开后再线性层。硬件建议保持相同布局与 patch 次序（unfold → reshape → Linear），并显式定义 patch 顺序与打包方式，避免软件/RTL 在“行主/列主、patch 拼接顺序、对齐字节”上产生歧义。

- AMP/TF32 与确定性
  - 训练与评估脚本启用了 AMP/TF32；若用于量化标定或位一致性对比，建议在标定/导出阶段关闭 AMP，强制 `float32`，并设置 `torch.use_deterministic_algorithms(True)` 确保结果可复现。

---

## 2) 量化一致性（C++ ↔ RTL）建议

当前仓库已包含 CPU C++ 扩展（`models/Quantization/quant_cpu.cpp` + `build_and_use.py`），支持：

- 激活：per‑tensor 非对称 INT8；
- 权重：per‑channel 对称 INT8；
- 反向采用 STE（直通估计）；

为确保与 Verilog 位级一致，建议：

- 明确舍入与饱和策略
  - 决定并固化 rounding：推荐“最近偶数（ties-to-even）”或“向零/远离零”。硬件 RTL 哪种就统一到哪种。建议在 C++ 里显式实现 ties-to-even，避免 `nearbyint` 的平台差异。
  - 所有量化路径统一饱和策略为“超出范围即饱和到 `qmin/qmax`”。

- 标定与尺度冻结（与硬件一致）
  - 激活 per‑tensor：尺度可选 `S = max(|x|)/127` 或百分位（如 P99.9/127），并在推理时冻结（常数）。零点 `ZP` 来自 min/max 或均值法，冻结。
  - 权重 per‑channel：尺度使用 `max(|W_c|)/127` 或 LSQ 学习后导出为常数向量。硬件侧逐通道缩放，累加使用 `int32`。

- 精度路径固定
  - `int8 × int8 → int32` 累加，输出按 `S_acc→S_out` 进行一次整形重定标（右移或乘法+舍入+饱和），并明确溢出处理。

- 布局/对齐
  - 明确张量布局（NCHW 类似到 `(B,C,K)`）、权重矩阵打包顺序（行优先/列优先）、逐通道尺度在内存中的索引关系，生成同一份头文件/JSON 给 C++ 与 RTL 共用。

下面给出可直接替换到你们“软件位对齐参考实现”的 C++ 片段（不修改现有文件，作为备选）——显式 ties-to-even 舍入与饱和：

```cpp
// 文件：reference_quant_int8.hpp  （新建，供软件/仿真共用）
#pragma once
#include <cstdint>
#include <cmath>
#include <type_traits>

// 显式最近偶数（ties-to-even）
static inline int64_t round_ties_to_even(double v) {
    double fl = std::floor(v);
    double fr = v - fl; // [0,1)
    if (fr > 0.5) return (int64_t)std::ceil(v);
    if (fr < 0.5) return (int64_t)fl;
    // fr == 0.5，取偶
    int64_t lo = (int64_t)fl;
    return (lo % 2 == 0) ? lo : (lo + 1);
}

template<typename T>
static inline T sat(T x, T lo, T hi) {
    return x < lo ? lo : (x > hi ? hi : x);
}

// per-tensor asymmetric: x_q = clamp(round(x/s + zp), qmin, qmax)
static inline int8_t q_per_tensor_asym(float x, double s, int64_t zp, int64_t qmin, int64_t qmax) {
    double v = (double)x / s + (double)zp;
    int64_t qi = round_ties_to_even(v);
    qi = sat<int64_t>(qi, qmin, qmax);
    return (int8_t)qi;
}

// dequant: x_hat = (x_q - zp) * s
static inline float deq_per_tensor_asym(int8_t xq, double s, int64_t zp) {
    return (float)(((int32_t)xq - (int32_t)zp) * s);
}

// per-channel symmetric (zp=0): w_q = clamp(round(w/s[c]), qmin, qmax)
static inline int8_t q_per_channel_sym(float w, double s_c, int64_t qmin, int64_t qmax) {
    int64_t qi = round_ties_to_even((double)w / s_c);
    qi = sat<int64_t>(qi, qmin, qmax);
    return (int8_t)qi;
}
```

配套 Python 端调用（演示如何与现有扩展保持一致的行为并做单元比对）：

```python
# 文件：quant_ref_check.py  （新建脚本，离线位一致性校验）
import numpy as np
import torch
from torch.utils.cpp_extension import load

# 现有扩展（models/Quantization/build_and_use.py 的思路）
quant = load(name='quant_cpu', sources=['models/Quantization/quant_cpu.cpp'], verbose=False)

def ref_round_ties_to_even(v: np.ndarray) -> np.ndarray:
    fl = np.floor(v)
    fr = v - fl
    out = np.where(fr>0.5, np.ceil(v), np.where(fr<0.5, fl, fl + (fl.astype(np.int64)&1==1)))
    return out.astype(np.int64)

def ref_q_per_tensor_asym(x: np.ndarray, s: float, zp: int, qmin: int, qmax: int) -> np.ndarray:
    v = x / s + zp
    qi = ref_round_ties_to_even(v)
    qi = np.clip(qi, qmin, qmax)
    return qi.astype(np.int8)

def test_once(N=1000):
    x = np.random.uniform(-3,3,size=(N,)).astype(np.float32)
    s, zp, qmin, qmax = 0.05, 3, 0, 255
    # cpp
    tq = quant.quant_per_tensor_asym(torch.from_numpy(x), float(s), int(zp), qmin, qmax)
    # ref
    rq = ref_q_per_tensor_asym(x, s, zp, qmin, qmax)
    assert np.array_equal(tq.numpy(), rq), 'mismatch to ties-to-even reference'
    print('OK')

if __name__ == '__main__':
    test_once()
```

> 备注：若硬件采用“向零”或“远离零”舍入，上述参考实现只需替换 rounding 函数，并据此调整 Python 校验。

---

## 3) 结构收敛方案（保持精度，降低硬件复杂度）

目标：将实际 MambaBlock 数量从 `n_layer × n_layer` 收敛到 `n_layer`，减少参数/运算；并在“通道注意/归一化”的开销与收益之间取得平衡，便于 ZCU102 上实现。

- 建议的逻辑结构（参考实现片段，作为新文件备选，用于后续实验）：

```python
# 文件：models_ref/cmamba_slim.py  （新建参考，不改现有文件）
import math, torch
import torch.nn as nn
import torch.nn.functional as F
from einops import rearrange, repeat, einsum

class Args:
    def __init__(self, d_model=128, n_layer=4, seq_len=96, d_state=16, expand=2,
                 dt_rank='auto', d_conv=4, conv_bias=True, bias=False,
                 num_channels=64, patch_len=8, stride=4, forecast_len=1,
                 sigma=0.0, reduction_ratio=4, pad_multiple=1):
        self.d_model=d_model; self.n_layer=n_layer; self.seq_len=seq_len
        self.d_state=d_state; self.expand=expand; self.dt_rank=dt_rank
        self.d_conv=d_conv; self.conv_bias=conv_bias; self.bias=bias
        self.num_channels=num_channels; self.patch_len=patch_len; self.stride=stride
        self.forecast_len=forecast_len; self.sigma=sigma; self.reduction_ratio=reduction_ratio
        self.pad_multiple=pad_multiple
        self.num_patches=(seq_len - patch_len)//stride + 1
        self.d_inner=int(expand*d_model)
        if self.dt_rank=='auto': self.dt_rank=math.ceil(d_model/16)

class RMSNorm(nn.Module):
    def __init__(self, d, eps=1e-5):
        super().__init__(); self.eps=eps; self.w=nn.Parameter(torch.ones(d))
    def forward(self, x):
        return x * torch.rsqrt(x.pow(2).mean(-1, keepdim=True)+self.eps) * self.w

class MambaBlock(nn.Module):
    def __init__(self, a: Args):
        super().__init__(); self.a=a
        self.norm_in = RMSNorm(a.d_model)
        self.in_proj = nn.Linear(a.d_model, a.d_inner*2, bias=a.bias)
        self.conv1d  = nn.Conv1d(a.d_inner, a.d_inner, kernel_size=a.d_conv,
                                 groups=a.d_inner, padding=a.d_conv-1, bias=a.conv_bias)
        self.x_proj  = nn.Linear(a.d_inner, a.dt_rank + a.d_state*2, bias=False)
        self.dt_proj = nn.Linear(a.dt_rank, a.d_inner, bias=True)
        A = repeat(torch.arange(1, a.d_state+1), 'n -> d n', d=a.d_inner)
        self.A_log = nn.Parameter(torch.log(A)); self.D = nn.Parameter(torch.ones(a.d_inner))
        self.out_proj=nn.Linear(a.d_inner, a.d_model, bias=a.bias)
    def forward(self, x):
        b,l,d = x.shape
        x,res = self.in_proj(self.norm_in(x)).chunk(2, dim=-1)
        x = rearrange(x,'b l d-> b d l'); x = self.conv1d(x)[:,:,:l]; x = rearrange(x,'b d l-> b l d')
        x = F.silu(x); y = self._ssm(x); y = y * F.silu(res); return self.out_proj(y)
    def _ssm(self, u):
        a=self.a; (din,n)=self.A_log.shape
        A = -torch.exp(self.A_log.float()); D=self.D.float()
        x_dbl = self.x_proj(u); delta,B,C = x_dbl.split([a.dt_rank,n,n], dim=-1)
        delta = F.softplus(self.dt_proj(delta))
        z = einsum(delta, A, 'b l d, d n -> b l d n'); deltaA = torch.exp(z)
        deltaB_u = einsum(delta,B,u,'b l d, b l n, b l d -> b l d n')
        x = torch.zeros((u.size(0), din, n), device=u.device); ys=[]
        for i in range(u.size(1)):
            x = deltaA[:,i]*x + deltaB_u[:,i]; y = einsum(x, C[:,i,:], 'b d n, b n -> b d'); ys.append(y)
        y = torch.stack(ys, dim=1); return y + u*D

class CMambaSlim(nn.Module):
    def __init__(self, a: Args):
        super().__init__(); self.a=a
        self.patch = nn.Linear(a.patch_len*a.num_channels, a.d_model)
        self.blocks = nn.ModuleList([MambaBlock(a) for _ in range(a.n_layer)])
        self.norm = RMSNorm(a.d_model)
        self.out  = nn.Linear(a.d_model*a.num_patches, a.num_channels*a.forecast_len)
    def forward(self, x): # (B,C,K)
        B,C,K = x.shape; P,S = self.a.patch_len, self.a.stride
        x = x.unfold(2,P,S).contiguous().permute(0,2,1,3).reshape(B,-1,C*P)
        x = self.patch(x)
        for blk in self.blocks: x = x + blk(x)
        x = self.norm(x).reshape(B,-1); y = self.out(x); return y.view(B, self.a.num_channels, self.a.forecast_len)
```

要点：

- 仅保留线性堆叠 `n_layer` 个 MambaBlock（每个 block 自带短残差），通道注意可选（若保留，建议上移到输入/输出两端，减少硬件热区复杂度）。
- pad_multiple 固定为 1，forecast_len=1，完全契合回归任务。
- 若要逐步靠近硬件，实现上可先把 `Conv1d(groups=d_inner)` 替换为简单的滑动窗口加法/乘法，再单元级映射到 PE 阵列。

---

## 4) 量化接入策略（QAT/PTQ）

仓库已有 QAT 组件：`models/Quantization/QLinearINT8`（激活 per‑tensor 非对称、权重 per‑channel 对称），建议如下接入路径用于软件端“位对齐基准”：

- 回归器两端（输入投影/输出头）先量化

```python
# 文件：models_ref/mamba_regressor_qat.py  （新建参考，不改现有文件）
import torch.nn as nn, torch.nn.functional as F
from models.training.cmamba import CMamba, ModelArgs
from models.Quantization.build_and_use import QLinearINT8

class MambaRegressorQAT(nn.Module):
    def __init__(self, Din:int, K:int, proj_dim:int=64, d_model:int=128, n_layer:int=4, patch_len:int=8, stride:int=4, sigma:float=0.0):
        super().__init__(); self.Din=Din; self.K=K
        self.input_affine = nn.Identity()  # 可改为用 train 均值/方差的固定仿射
        self.proj = QLinearINT8(Din, proj_dim)   # ← 激活/权重量化
        args = ModelArgs(d_model=d_model, n_layer=n_layer, seq_len=K, num_channels=proj_dim,
                         patch_len=patch_len, stride=stride, forecast_len=1, pad_multiple=1, sigma=sigma)
        self.backbone = CMamba(args)
        self.head = QLinearINT8(proj_dim, 2)     # ← 输出头量化
    def forward(self, x):
        B,K,D = x.shape
        if K!=self.K:
            x = x[:, -self.K:, :] if K>self.K else F.pad(x, (0,0,self.K-K,0))
        x = self.input_affine(x)
        x = self.proj(x)            # (B,K,C) 量化线性
        x = F.layer_norm(x, (x.shape[-1],))  # 如需硬件友好，可替换为固定仿射
        y = self.backbone(x.permute(0,2,1))  # (B,C,1)
        if y.dim()==3: y = y.mean(dim=-1)
        return self.head(y)
```

- 中间层逐步量化（可选）：
  - `patch_embedding / in_proj / out_proj / conv1d` 等可分阶段替换为 `QLinearINT8` 或采用 INT8 卷积（权重 per‑channel，对称），逐步评估精度影响。
  - 卷积 depthwise 的量化在 RTL 端落地较友好（逐通道独立），建议每通道各自尺度；硬件实现采用共享移位/乘法器复用，节省 DSP。

- 标定/导出
  - QAT：训练收敛后冻结 `a_scale/zp/w_scale`，导出常数。
  - PTQ：选取代表性标定集，离线统计尺度并写入；支持 power‑of‑two 约束以简化硬件（右移替乘法）。
  - 建议导出统一描述文件（JSON/npz）与 C 头文件：包含每一层的权重、bias、scale、zp、布局元数据，供 C++/RTL 共享。

---

## 5) 导出与对齐验证（软件↔RTL）

- 确定性设置（导出/对齐阶段）
  - 关闭 AMP/TF32：`torch.backends.cuda.matmul.allow_tf32=False; torch.backends.cudnn.allow_tf32=False`
  - 固定随机：`torch.manual_seed(...)` 并 `torch.use_deterministic_algorithms(True)`
  - 关闭训练态随机增强：确保 `model.eval()` 且 `sigma=0`

- 导出步骤建议
  1. 使用未量化模型生成浮点基线输出 `y_float`。
  2. 用 C++ 量化（或 QAT 模型）生成 `y_int8_ref`（CPU 端）。
  3. 将相同参数/尺度写入 Verilog 仿真，得到 `y_rtl`。
  4. 比对误差：`max_abs_diff`、`ULP` 统计，以及关键中间节点（如 `proj` 输出、每一层 MambaBlock 的 `out_proj` 前后）。

- 打包导出模板（Python，写 npy + 头文件）：

```python
# 文件：export_qparams.py  （新建参考）
import json, numpy as np, torch

def save_linear_int8(prefix, lin: torch.nn.Linear, w_scale: torch.Tensor, a_scale: float, a_zp: float):
    w = lin.weight.detach().cpu().numpy().astype(np.float32)
    b = (lin.bias.detach().cpu().numpy().astype(np.float32) if lin.bias is not None else None)
    np.save(prefix+"_W.npy", w);  (b is not None) and np.save(prefix+"_B.npy", b)
    np.save(prefix+"_WS.npy", w_scale.detach().cpu().numpy().astype(np.float32))
    meta = dict(a_scale=float(a_scale), a_zp=float(a_zp), layout="row_major")
    with open(prefix+".json", "w") as f: json.dump(meta, f, indent=2)
```

---

## 6) 针对 ZCU102 的参数与资源建议

- 参数初值（便于上板）
  - `proj_dim`：64（必要时 48/32）
  - `d_model`：96（必要时 64）
  - `n_layer`：2~3（先 2）
  - `d_state`：8
  - `patch_len/stride`：8/4（保证 `num_patches = (K-P)//S+1` 可被并行因子整除）
  - `K (seq_len)`：12（已采用）

- 代价估算（粗略）
  - Patch 投影：`num_patches × (C*P × d_model)` MAC
  - 每层 Mamba：`in_proj/out_proj` 全连接 + depthwise conv（开销 ~ `d_inner × K`）+ SSM 扫描（`K × d_inner × d_state`）
  - 总体资源主要消耗在 d_inner（= expand×d_model）与 num_patches 上；优先降低 expand 或 d_model。

- 实现建议
  - SSM selective_scan 采用逐时刻流式：维护 `x[d_in, n]` 状态寄存器，输入一帧更新一次；非常适合 FPGA 流水化。
  - depthwise Conv1d 可用环形缓冲 + 逐通道 MAC 实现；
  - 全连接使用权重常量 BRAM + DSP 复用，batch=1/小批量流式推理。

---

## 7) 数据与布局一致性清单（软件/RTL 必须统一）

- 张量布局：`(B, C, K)`；patch 展开顺序：时间维从左到右，patch 内 `(C 连续, 再 P)`。
- 量化：激活（per‑tensor 非对称 INT8）、权重（per‑channel 对称 INT8），舍入与饱和策略明确且统一。
- 累加精度：`int32`，重定标后饱和到下一层输入范围。
- 归一化：输入使用 train 均值/方差（固定），内部 RMSNorm 可在硬件端用线性缩放近似或省略（若 QAT 已吸收）。
- AMP/TF32：标定/导出/对齐阶段全部关闭。

---

## 8) 直接可用的最小改造清单（不改现有文件，供试验）

1) 用 `models_ref/mamba_regressor_qat.py` 替代评估回归器，先只量化输入/输出两端，验证误差：
   - 期望软件端 bit‑exact 稳定；
   - 若精度良好，再向中间层推进量化。

2) 用 `models_ref/cmamba_slim.py` 做“瘦身”模型的训练/验证，观察精度‑代价折中；

3) 用 `reference_quant_int8.hpp` 和 `quant_ref_check.py` 固化舍入与饱和策略，并与 `quant_cpu.cpp` 行为对齐；

4) 导出统一的权重/尺度文件与 JSON 供 RTL 使用；

5) 在评估脚本中添加“确定性导出”开关（仅本地实验使用，不提交改动）：关闭 AMP、固定随机、关闭 mixup。

---

## 9) 后续可选工作

- 将 `LayerNorm/RMSNorm` 融入前后线性层的缩放/偏置（通过 QAT 学习吸收），硬件端省略归一化；
- 将激活尺度约束为 2 的幂（PoT），硬件端用移位代乘，进一步节省 DSP；
- 增加 online 校验脚本：在关键节点 dump 中间张量（int8、int32、反量化 float），用同一组向量在 Verilog 仿真与 Python 端逐层对比；
- 若上板需要，可将 `quant_cpu.cpp` 拆成独立静态库，并提供 C 接口给 Vitis HLS/C++ 仿真共用。

---

以上建议与代码片段均为“新增文件”形态，不改动原工程文件；可按需复制到本地进行实验与对齐。若需要，我可以继续：

- 增加一键导出脚本（将模型权重/尺度整理成 npz+头文件）；
- 在不影响现有代码的前提下，写一个最小 demo 入口，自动跑“浮点→量化 C++→导出→比对”。
