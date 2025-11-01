# Cmamba 硬件重构实施脚手架与最小可运行骨架（Markdown 指南）

本文件提供可执行的重构脚手架计划，包含：目录结构、最小 FP32 推理骨架（代码片段）、统一 IO 与量化封装占位、以及运行与验证指引。代码仍以内联代码块形式提供，方便逐步落地到对应文件。

---

## 1. 里程碑与交付

- 里程碑 A：目录搭建与最小 FP32 推理骨架（保证 I/O 形状正确）
- 里程碑 B：.pt ⇄ .npz 导入/导出闭环打通
- 里程碑 C：接入 FakeQuant（LSQ）与 C++ 量化扩展（行为对齐）
- 里程碑 D：导出 FPGA 包（npz/bin + specs）并联调 ZCU102
- 里程碑 E：训练脚本迁移，与推理共享同一前向实现

---

## 2. 目标目录结构（建议）

```bash
core/
  infer/
    __init__.py
    args.py
    blocks.py
    cmamba.py
    io.py
    quant_wrappers.py
    export_weights.py
  train/
    __init__.py
    datasets/
      frames_lazy.py
      npz_xy.py
    loops.py
    train_regression.py
    model_registry.py
quant/
  __init__.py
  ops.py
  csrc/
    quant_cpu.cpp
  build_and_use.py
export/
  pack_fpga.py
  specs.md
data/
  test_data.npz
```

说明：先以最小 FP32 路径落地 `core/infer` 下的 `args.py`、`cmamba.py`、`io.py`、`quant_wrappers.py`。量化与训练相关文件先保留占位或稍后迁移。

---

## 3. 最小 FP32 推理骨架（与 old 行为对齐的外形）

注意：此骨架保证输入/输出形状与关键算子位置编码逻辑对齐，内部 Mamba Block 可先用恒等或占位，后续再从 old 迁移真实实现。

文件：`core/infer/args.py`

```python
import math

class ModelArgs:
    def __init__(self, d_model=128, n_layer=4, seq_len=96, d_state=16, expand=2,
                 dt_rank='auto', d_conv=4, pad_multiple=8, conv_bias=True, bias=False,
                 num_channels=24, patch_len=16, stride=8, forecast_len=96,
                 reduction_ratio=8, verbose=False):
        self.d_model = d_model
        self.n_layer = n_layer
        self.seq_len = seq_len
        self.d_state = d_state
        self.v = verbose
        self.expand = expand
        self.dt_rank = dt_rank
        self.d_conv = d_conv
        self.pad_multiple = pad_multiple
        self.conv_bias = conv_bias
        self.bias = bias
        self.num_channels = num_channels
        self.patch_len = patch_len
        self.stride = stride
        self.forecast_len = forecast_len
        self.reduction_ratio = reduction_ratio

        self.num_patches = (self.seq_len - self.patch_len) // self.stride + 1
        self.d_inner = int(self.expand * self.d_model)

        if self.dt_rank == 'auto':
            self.dt_rank = math.ceil(self.d_model / 16)
        if self.forecast_len % self.pad_multiple != 0:
            self.forecast_len += (self.pad_multiple - self.forecast_len % self.pad_multiple)
```

文件：`core/infer/blocks.py`（占位：RMSNorm 与空 Mamba Block，确保可运行）

```python
import torch
import torch.nn as nn

class RMSNorm(nn.Module):
    def __init__(self, d_model: int, eps: float = 1e-6):
        super().__init__()
        self.eps = eps
        self.weight = nn.Parameter(torch.ones(d_model))
    def forward(self, x):
        # x: [B, K, D]
        var = x.pow(2).mean(dim=-1, keepdim=True)
        x = x * torch.rsqrt(var + self.eps)
        return x * self.weight

class IdentityBlock(nn.Module):
    def __init__(self):
        super().__init__()
    def forward(self, x):
        return x
```

文件：`core/infer/cmamba.py`（最小前向，含 patch、pos-encoding、输出层）

```python
import math
import torch
import torch.nn as nn
from .args import ModelArgs
from .blocks import RMSNorm, IdentityBlock

class CMamba(nn.Module):
    def __init__(self, args: ModelArgs, quant_mode: str = "fp32"):
        super().__init__()
        self.args = args
        self.patch_embedding = nn.Linear(args.patch_len * args.num_channels, args.d_model)
        # 可替换为真实 MambaBlock 列表；此处先用恒等占位
        self.blocks = nn.ModuleList([IdentityBlock() for _ in range(args.n_layer)])
        self.norm_f = RMSNorm(args.d_model)
        self.output_layer = nn.Linear(args.d_model * args.num_patches,
                                      args.num_channels * args.forecast_len)

    @staticmethod
    def _build_sincos(n: int, d: int, device=None, dtype=None):
        if device is None:
            device = torch.device("cpu")
        if dtype is None:
            dtype = torch.float32
        pos = torch.arange(n, device=device, dtype=dtype).unsqueeze(1)
        sin_cols = (d + 1) // 2
        cos_cols = d // 2
        denom = (d / 2.0)
        sin_i = torch.arange(sin_cols, device=device, dtype=dtype)
        cos_i = torch.arange(cos_cols, device=device, dtype=dtype)
        sin_div = torch.exp(-math.log(10000.0) * sin_i / denom).unsqueeze(0)
        cos_div = torch.exp(-math.log(10000.0) * cos_i / denom).unsqueeze(0)
        sin_part = torch.sin(pos * sin_div)
        cos_part = torch.cos(pos * cos_div)
        pe = torch.zeros(n, d, device=device, dtype=dtype)
        pe[:, 0::2] = sin_part
        if cos_cols > 0:
            pe[:, 1::2] = cos_part
        return pe

    def forward(self, x):
        # x: [B, V, L]
        B, V, L = x.shape
        P, S = self.args.patch_len, self.args.stride
        # patch: [B,V,L] -> [B,K,V*P]
        x = x.unfold(2, P, S).contiguous().permute(0,2,1,3).reshape(B, -1, V*P)
        # embed: [B,K,V*P] -> [B,K,D]
        x = self.patch_embedding(x)
        # pos enc
        pe = self._build_sincos(n=x.size(1), d=self.args.d_model, device=x.device, dtype=x.dtype)
        x = x + pe.unsqueeze(0)
        # blocks
        for blk in self.blocks:
            x = x + blk(x)
        x = self.norm_f(x)
        # head
        x = x.reshape(B, -1)
        y = self.output_layer(x).reshape(B, self.args.num_channels, self.args.forecast_len)
        return y

def build_model(args: ModelArgs, quant_mode: str = "fp32") -> nn.Module:
    # 量化包装后续接入；此处返回纯 FP32 骨架
    return CMamba(args, quant_mode=quant_mode)
```

文件：`core/infer/io.py`（统一数据与权重装载，.pt 优先，.npz 兼容）

```python
from pathlib import Path
import numpy as np
import torch

def load_npz_input(path: str) -> torch.Tensor:
    arr = np.load(path)
    key = 'x' if 'x' in arr else list(arr.keys())[0]
    x = torch.from_numpy(arr[key])
    assert x.ndim == 3, f"expect [B,V,L], got {x.shape}"
    return x.float()

def load_weights(model: torch.nn.Module, path: str):
    p = Path(path)
    if p.suffix == '.pt':
        sd = torch.load(p, map_location='cpu')
        if 'model' in sd and isinstance(sd['model'], dict):
            sd = sd['model']
        model.load_state_dict(sd, strict=False)
        return
    if p.suffix == '.npz':
        npz = np.load(p)
        # 简单逐层赋值（名称需与导出规范一致），未匹配项忽略
        sd = model.state_dict()
        for k in sd.keys():
            if k in npz:
                t = torch.from_numpy(npz[k]).to(sd[k].dtype)
                if tuple(t.shape) == tuple(sd[k].shape):
                    sd[k].copy_(t)
        model.load_state_dict(sd, strict=False)
        return
    raise ValueError(f"Unsupported weight file: {path}")
```

文件：`core/infer/quant_wrappers.py`（占位：后续接 FakeQuant/C++）

```python
import torch.nn as nn

def wrap_linear(linear: nn.Linear, mode: str = 'fp32') -> nn.Module:
    # TODO: 在 fakeq 模式包上 LSQQuantizer；在 cppq 模式替换为 C++ 后端
    return linear
```

可选脚本：`run_infer.py`（放根目录或 scripts/，用于快速验证 I/O 与形状）

```python
import torch
from core.infer.args import ModelArgs
from core.infer.cmamba import build_model
from core.infer.io import load_weights, load_npz_input

if __name__ == '__main__':
    args = ModelArgs(d_model=128, n_layer=1, seq_len=96, d_state=16,
                     num_channels=24, patch_len=16, stride=8, forecast_len=96)
    model = build_model(args, quant_mode='fp32').eval()
    # 可选加载权重：load_weights(model, 'weights.pt' or 'weights.npz')
    x = load_npz_input('data/test_data.npz')  # 形状 [B,V,L]
    with torch.no_grad():
        y = model(x)
    print('input:', tuple(x.shape), 'output:', tuple(y.shape))
```

---

## 4. 量化与导出对接（后续接入）

- 伪量化（FakeQuant, LSQ）：将 `old/models/Quantization/quantization.py` 迁移为 `quant/ops.py`，并在 `quant_wrappers.py` 按 `mode` 包装 `nn.Linear`。
- C++ 量化扩展：迁移 `old/models/Quantization/quant_cpu.cpp` → `quant/csrc/quant_cpu.cpp`，并通过 `quant/build_and_use.py` 构建加载；在 `quant/ops.py` 提供 Python API。
- 导出：实现 `export/pack_fpga.py`，将权重（FP32/INT8）与 scale/zp、模型超参导出为 `export/cmamba_fpga.npz`。

---

## 5. 运行与验证

- 先准备 `data/test_data.npz`（包含键 `x`，形状 `[B,V,L]`，float32）。
- 运行最小推理：
  - `python run_infer.py`
  - 期望输出：`input: (B,V,L) output: (B,V,forecast_len)`，与 `args` 一致。
- 后续接入真实 Mamba Block 与量化后，使用固定输入比较 MAE/Max 误差，确保与 old 行为对齐。

---

## 6. 注意事项

- 位置编码 `_build_sincos` 需与 old 的实现完全一致（奇偶维处理）。
- 推理路径不包含训练增强（如 ChannelMixup）；训练侧保留，不影响推理接口。
- 权重与数据的 .npz 命名在导入/导出两端需保持一致，便于硬件消费与回灌验证。
