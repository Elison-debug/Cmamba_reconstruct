# Simple-CMamba 项目精简重构方案（硬件友好）

目标：以“硬件先行”的视角精简与重构全仓，输出一套训练→量化→导出→C++推理→RTL 对齐的最小可行闭环，实现更稳定、可复现、易落地 ZCU102 的工程骨架。以下方案不修改现有文件，供迁移/重构参考。

---

## 1) 重构目标与基本原则

- 约束算子集合：仅保留 Linear、DepthwiseConv1d、SiLU（或近似）、Add、RMSNorm（可选/可近似）、Reshape/Unfold、Quantize/Dequantize。
- 固定数据形状：`seq_len=12`、`forecast_len=1`、`patch_len=8`、`stride=4`、`proj_dim<=64`、`d_model<=96`、`n_layer<=3`。
- 单一路径确定性：关闭 AMP/TF32，固定随机，训练与导出阶段禁用增强与 Dropout；量化舍入与饱和策略全局统一。
- 中间格式统一：权重/尺度/布局用单一 JSON(+npy/bin) 描述，C++ 与 RTL 共用。
- 分层边界清晰：PyTorch（训练/QAT/PTQ） ↔ C++（标定/推理参考） ↔ RTL（逐层映射）接口稳定。

---

## 2) 重构目录结构

```text
refactor/
  core/                    # 极简 PyTorch 核心（训练/导出）
    cmamba_slim.py         # 线性堆叠的精简 CMamba（n_layer 个 MambaBlock）
    mamba_regressor.py     # 回归头，输入投影 + 主干 + 输出头
    losses.py              # EPE/Huber 等
    train.py               # 极简训练脚本（无 W&B/复杂日志）
    test.py                # 极简验证（无绘图，纯数值）
  quant/
    qat_layers.py          # QLinearINT8/QConv1dINT8（激活 per‑tensor, 权重 per‑channel）
    calibrate.py           # PTQ 标定（统计 scale/zp）
    spec.py                # 量化规范（round/saturate/bitwidth）
  export/
    pack.py                # 打包权重/尺度/元数据 → JSON + npy/bin
    schema.json            # 导出 JSON Schema
  runtime_cpp/
    ref_infer.hpp/.cpp     # 单线程 C++ 推理参考（与 RTL 位一致）
    reference_quant_int8.hpp# ties-to-even 舍入 + 饱和
    io_utils.hpp           # 读取导出文件，准备权重/尺度
    main_demo.cpp          # 读入 npy/bin → 前向 → dump 中间结果
  vectors/
    gen_vectors.py         # 输入/权重/中间张量 dump（npz/npy）
  tests/
    test_bitexact.py       # Python 端 bit-exact 验证（C++/PyTorch/RTL）
  docs/
    hardware_contract.md   # 数字契约（布局/尺度/位宽/舍入/饱和）
```

---

## 3) 模型结构精简（CMambaSlim）

- 仅线性堆叠 `n_layer` 个 MambaBlock，每个 block 含：
  - `RMSNorm → in_proj (d_model→2*d_inner) → depthwise Conv1d(groups=d_inner) → SiLU → SSM selective_scan → gating(res) → out_proj (d_inner→d_model)`；
  - 块级残差：`x + Block(x)`。
- 删去“块外的 PatchMamba 的重复堆叠”，避免 `n_layer×n_layer` 膨胀。
- 位置编码可省略或改为固定 sincos（仅在软件端保留，对 RTL 不强制）。
- 回归任务固定 `forecast_len=1`，`pad_multiple=1`，去除额外时间维压缩。

接口草图（核心前向保持与现仓一致的 `(B,C,K)` → `(B,2)` 流）：

```python
# refactor/core/mamba_regressor.py（示意）
class MambaRegressor(nn.Module):
    def __init__(self, Din, K, proj_dim=64, d_model=96, n_layer=3, patch_len=8, stride=4):
        self.proj = nn.Linear(Din, proj_dim)
        args = Args(d_model=d_model, n_layer=n_layer, seq_len=K, num_channels=proj_dim,
                    patch_len=patch_len, stride=stride, forecast_len=1, pad_multiple=1)
        self.backbone = CMambaSlim(args)
        self.head = nn.Linear(proj_dim, 2)
    def forward(self, x):  # (B,K,D)
        x = self.proj(x)                # (B,K,C)
        y = self.backbone(x.permute(0,2,1))
        y = y.squeeze(-1) if y.dim()==3 else y
        return self.head(y)             # (B,2)
```

---

## 4) 量化与数值规范（统一“数字契约”）

- 舍入：全局使用“最近偶数（ties‑to‑even）”。
- 饱和：超界即夹到 `qmin/qmax`。
- 精度：`int8×int8→int32` 累加，层间以 `scale_acc→scale_out` 重定标（右移或乘法+舍入+饱和）。
- 激活：per‑tensor 非对称（`scale_a, zp_a`）；
- 权重：per‑channel 对称（`scale_w[c]`，`zp=0`），矩阵布局固定 row‑major；
- 归一化：训练时可用 LN/RMSNorm；导出时优先通过 QAT 折叠进邻接线性层（scale/bias 合并），硬件侧省略（线性仿射代替）。

量化规范集中在：`refactor/quant/spec.py` 与 `runtime_cpp/reference_quant_int8.hpp`，两端共用同一版本规则。

---

## 5) 训练/评估最小管线

- 训练（refactor/core/train.py）
  - 数据：复用现有 `datasets/frames_lazy.py` 
  - 优化：AdamW + Cosine/ConstThenCosine；
  - Loss：EPE 的 Huber（SmoothL1），支持 tail 加权；
  - 开关：默认关闭 AMP/TF32；
  - 日志：纯文本/CSV，无外部依赖。

- 评估（refactor/core/eval.py）
  - 输出均值/中位数/P80/P90；
  - 可选 dump 中间张量（供 bit‑exact 对齐）。

---

## 6) QAT/PTQ 接入策略

- 第一阶段：仅量化输入投影 `proj` 与输出头 `head`，最小化精度损失；
- 第二阶段：逐层替换 `in_proj/out_proj/patch` 为 `QLinearINT8`，depthwise conv 用 per‑channel 对称；
- 第三阶段：如需，SSM 内部向量‑矩阵乘也可按块拆解为 INT8 路径（建议先保持浮点，逐步替换以降低风险）。

QAT 训练收敛后冻结 `a_scale/zp/w_scale`；PTQ 则离线标定（支持 P99/P99.9，或 PoT 限制）。

---

## 7) 导出与中间格式（JSON+NPY/ BIN）

统一导出 Schema（`refactor/export/schema.json`）：

```json
{
  "version": 1,
  "model": {
    "seq_len": 12, "proj_dim": 64, "d_model": 96, "n_layer": 3,
    "patch_len": 8, "stride": 4, "forecast_len": 1
  },
  "quant": {
    "rounding": "ties_to_even", "saturate": true,
    "act": {"scheme": "per_tensor_asym", "bits": 8},
    "weight": {"scheme": "per_channel_sym", "bits": 8, "axis": 0}
  },
  "layers": [
    {"type": "linear", "name": "proj", "in": 2100, "out": 64,
     "W": "proj_W.npy", "B": "proj_B.npy",
     "act_scale": 0.03125, "act_zp": 3, "w_scale": "proj_WS.npy"},
    {"type": "cmamba_slim", "name": "backbone", "params": "backbone.json"},
    {"type": "linear", "name": "head", "in": 64, "out": 2,
     "W": "head_W.npy", "B": "head_B.npy",
     "act_scale": 0.03125, "act_zp": 0, "w_scale": "head_WS.npy"}
  ]
}
```

说明：

- 大层（如 `cmamba_slim`）再拆为子结构 JSON；
- 所有权重/尺度文件路径相对当前 JSON；
- 必要时提供二进制打包（连续内存布局，方便 DMA/AXI）。

---

## 8) C++ 推理参考（位一致、可移植）

- 单线程、顺序、CPU 参考实现：`runtime_cpp/ref_infer.cpp`；
- 关键接口：

```cpp
// 加载导出 JSON/NPY，构建权重与尺度
bool LoadExport(const std::string& json_path, ModelIR& ir);
// 前向：输入 (C,K) float → 内部量化 → 结果 (2) float
void Forward(const ModelIR& ir, const float* x_ck, float* y_out);
// 中间节点 dump（可选）：用于与 RTL 对齐
```

- 量化 API：见 `reference_quant_int8.hpp`，ties‑to‑even 舍入与饱和固定，实现与 RTL 共用；
- 线性层：int8×int8→int32，带 per‑channel 重定标；
- depthwise Conv1d：逐通道滑窗 MAC，权重 per‑channel；
- selective_scan：保持浮点或使用定点（建议分阶段）。

---

## 9) FPGA（ZCU102）映射建议

- 并行因子：对 `proj_dim`/`d_model` 选定 8/16 为并行粒度，折中 DSP 占用与频率；
- 存储：权重常量放 BRAM/URAM；逐通道尺度小向量放 BRAM；
- 数据流：以时间步为主序（K 方向），SSM 状态寄存器 `x[d_in, n]` 保持在片上；
- Depthwise Conv1d：环形缓冲 + 逐通道 MAC，复用 DSP；
- 重定标：优先使用 PoT 约束，右移替乘法；
- 固定接口：AXI‑Stream 输入 `(C,K)`，AXI‑Lite 控制，AXI‑MM 权重加载。

---

## 10) 数据/布局一致性清单（软件↔C++↔RTL）

- 张量布局：`(B,C,K)`，patch 展开顺序严格定义为“时间滑窗，patch 内先 C 后 P”；
- 量化：激活 per‑tensor 非对称、权重 per‑channel 对称；ties‑to‑even 舍入；饱和开启；
- 累加位宽：`int32`；
- 归一化：训练端可用，导出端尽量折叠进入线性层；
- 随机性：导出/对齐阶段禁用 Mixup，关闭 AMP/TF32；
- 校验：相同输入在 PyTorch/C++/RTL 逐层中间值允许 ≤1 LSB 偏差（舍入界面）。

---

## 11) 迁移路线图（两周节奏示例）

第 1 周：

- 完成 `core/` 与 `quant/` 的最小可训模型与 QAT/PTQ；
- 固化 `spec.py` 与 `reference_quant_int8.hpp`；
- 在 Python 端完成导出 `export/pack.py` 与 schema；

第 2 周：

- 实现 `runtime_cpp/` 推理参考与中间值 dump；
- `vectors/` 生成对齐样例，完成 `tests/test_bitexact.py`；
- 根据 DSP/BRAM 占用做 d_model/proj_dim/n_layer 微调，给出 RTL 任务书与接口；

可选第 3 周：

- selective_scan 定点化（或保持浮点，硬件先用单精度核验证）；
- PoT 约束与 LUT‑SiLU 近似，进一步压资源与时延。

---

## 12) 立即可执行的落地清单

- 复制本文档中的结构，新增 `refactor/` 目录；
- 从现仓模型抄取并简化成 `CMambaSlim + MambaRegressor`；
- 接入 `QLinearINT8` 替换 `proj/head` 两端，验证精度；
- 写 `export/pack.py` 与 `runtime_cpp/ref_infer.cpp` 骨架，先支持 `proj/head`，再逐步覆盖 backbone；
- 用 10 个样本生成 `vectors/`，做 Python↔C++ bit‑exact 校验；
- 与 RTL 对齐 JSON/头文件字段，进入模块级映射。

---

如需，我可以基于该结构，补充最小可运行的 `core/train.py` 与 `runtime_cpp/main_demo.cpp` 模板，便于直接起步。
