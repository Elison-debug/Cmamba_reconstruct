import os
from pathlib import Path
from typing import Tuple, Optional

import torch
from torch.utils.cpp_extension import load
import torch.nn.functional as F
from typing import Optional as _Opt, cast


def _resolve_quant_src() -> Path:
    # Prefer colocated csrc (refactor-owned)
    here = Path(__file__).resolve().parent
    local = (here / "csrc" / "quant_cpu.cpp").resolve()
    if local.exists():
        return local
    raise FileNotFoundError("quant_cpu.cpp not found under refactor/quant/csrc")


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

class QuantPerTensorAsym16STE(torch.autograd.Function):
    @staticmethod
    def forward(ctx, x, scale, zp, qmin, qmax):
        m = get_cpp_quant()
        xq = m.quant_per_tensor_asym16(x.contiguous(), float(scale), int(zp), int(qmin), int(qmax))  # type: ignore
        xhat = m.dequant_per_tensor_asym16(xq, float(scale), int(zp))  # type: ignore
        return xhat

    @staticmethod
    def backward(ctx, gO):
        return gO, None, None, None, None

class QuantPerChannelSym16STE(torch.autograd.Function):
    @staticmethod
    def forward(ctx, w, scale, ch_axis, qmin, qmax):
        m = get_cpp_quant()
        wq = m.quant_per_channel_sym16(w.contiguous(), scale.contiguous(), int(ch_axis), int(qmin), int(qmax))  # type: ignore
        shape = [1] * w.dim()
        shape[ch_axis] = -1
        w_hat = (wq.to(torch.float32) * scale.view(shape))
        return w_hat

    @staticmethod
    def backward(ctx, gO):
        return gO, None, None, None, None


class QConv1x1INT(torch.nn.Module):
    def __init__(self, in_f, out_f, bias=True, a_bits=8, w_bits=8, ch_axis=0):
        super().__init__()
        if a_bits not in (8, 16) or w_bits not in (8, 16):
            raise ValueError(f"Unsupported bit-width (a_bits={a_bits}, w_bits={w_bits}); supported: 8, 16")
        self.conv = torch.nn.Conv1d(in_f, out_f, kernel_size=1, bias=bias)
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
        # Use symmetric activation quant to preserve sign (hardware-friendly)
        qmin_a, qmax_a = self._qrange(self.a_bits, symmetric=True)
        qmin_w, qmax_w = self._qrange(self.w_bits, symmetric=True)
        # Dispatch by bit-width
        if self.a_bits == 8:
            x_hat = QuantPerTensorAsymSTE.apply(x, self.a_scale.abs() + 1e-8, self.a_zp, qmin_a, qmax_a)
        elif self.a_bits == 16:
            x_hat = QuantPerTensorAsym16STE.apply(x, self.a_scale.abs() + 1e-8, self.a_zp, qmin_a, qmax_a)
        else:
            raise ValueError(f"Unsupported activation bits: {self.a_bits}")
        w = self.conv.weight
        if self.w_bits == 8:
            w_hat = QuantPerChannelSymSTE.apply(w, self.w_scale.abs() + 1e-8, self.ch_axis, qmin_w, qmax_w)
        elif self.w_bits == 16:
            w_hat = QuantPerChannelSym16STE.apply(w, self.w_scale.abs() + 1e-8, self.ch_axis, qmin_w, qmax_w)
        else:
            raise ValueError(f"Unsupported weight bits: {self.w_bits}")
        # Help static type checkers with precise types
        x_hat_t = cast(torch.Tensor, x_hat)
        w_hat_t = cast(torch.Tensor, w_hat)
        bias_t = cast(_Opt[torch.Tensor], self.conv.bias)
        return F.conv1d(input=x_hat_t, weight=w_hat_t, bias=bias_t, stride=1, padding=0, groups=1)

# No legacy aliases; project uses QConv1x1INT explicitly.
