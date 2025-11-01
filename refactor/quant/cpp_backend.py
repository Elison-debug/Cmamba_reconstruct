import os
from pathlib import Path
from typing import Tuple, Optional

import torch
from torch.utils.cpp_extension import load


def _resolve_quant_src() -> Path:
    # Prefer old implementation if present
    here = Path(__file__).resolve().parent
    old_src = (here.parent.parent / "old" / "models" / "Quantization" / "quant_cpu.cpp").resolve()
    if old_src.exists():
        return old_src
    alt_old = Path("old/models/Quantization/quant_cpu.cpp").resolve()
    if alt_old.exists():
        return alt_old
    # As fallback, allow colocated csrc
    local = (here / "csrc" / "quant_cpu.cpp").resolve()
    if local.exists():
        return local
    raise FileNotFoundError("quant_cpu.cpp not found in expected locations")


_CACHED = None


def get_cpp_quant():
    global _CACHED
    if _CACHED is not None:
        return _CACHED
    src = _resolve_quant_src()
    mod = load(name="quant_cpu", sources=[str(src)], verbose=False)
    _CACHED = mod
    return mod


class QuantPerTensorAsymSTE(torch.autograd.Function):
    @staticmethod
    def forward(ctx, x, scale, zp, qmin, qmax):
        m = get_cpp_quant()
        xq = m.quant_per_tensor_asym(x.contiguous(), float(scale), int(zp), int(qmin), int(qmax))  # type: ignore
        xhat = m.dequant_per_tensor_asym(xq, float(scale), int(zp))  # type: ignore
        return xhat

    @staticmethod
    def backward(ctx, gO):
        return gO, None, None, None, None


class QuantPerChannelSymSTE(torch.autograd.Function):
    @staticmethod
    def forward(ctx, w, scale, ch_axis, qmin, qmax):
        m = get_cpp_quant()
        wq = m.quant_per_channel_sym(w.contiguous(), scale.contiguous(), int(ch_axis), int(qmin), int(qmax))  # type: ignore
        shape = [1] * w.dim()
        shape[ch_axis] = -1
        w_hat = (wq.to(torch.float32) * scale.view(shape))
        return w_hat

    @staticmethod
    def backward(ctx, gO):
        return gO, None, None, None, None


class QLinearINT8(torch.nn.Module):
    def __init__(self, in_f, out_f, bias=True, a_bits=8, w_bits=8, ch_axis=0):
        super().__init__()
        self.lin = torch.nn.Linear(in_f, out_f, bias=bias)
        self.a_scale = torch.nn.Parameter(torch.tensor(0.1, dtype=torch.float32))
        self.a_zp = torch.nn.Parameter(torch.tensor(0.0, dtype=torch.float32))
        self.w_scale = torch.nn.Parameter(torch.ones(out_f, dtype=torch.float32))
        self.a_bits, self.w_bits = a_bits, w_bits
        self.ch_axis = ch_axis

    @staticmethod
    def _qrange(bits, symmetric):
        if symmetric:
            return -(1 << (bits - 1)), (1 << (bits - 1)) - 1
        else:
            return 0, (1 << bits) - 1

    def forward(self, x):
        qmin_a, qmax_a = self._qrange(self.a_bits, symmetric=False)
        x_hat = QuantPerTensorAsymSTE.apply(x, self.a_scale.abs() + 1e-8, self.a_zp, qmin_a, qmax_a)
        qmin_w, qmax_w = self._qrange(self.w_bits, symmetric=True)
        w = self.lin.weight
        w_hat = QuantPerChannelSymSTE.apply(w, self.w_scale.abs() + 1e-8, self.ch_axis, qmin_w, qmax_w)
        return torch.nn.functional.linear(x_hat, w_hat, self.lin.bias)# type: ignore

