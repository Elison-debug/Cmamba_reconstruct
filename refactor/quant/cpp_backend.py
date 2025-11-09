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
        dev = x.device
        x_cpu = x.contiguous().to(torch.float32).cpu()
        sc = float(scale.item()) if torch.is_tensor(scale) else float(scale)
        zp_i = int(zp.item()) if torch.is_tensor(zp) else int(zp)
        xq = m.quant_per_tensor_asym(x_cpu, sc, zp_i, int(qmin), int(qmax))  # type: ignore # CPU
        xhat = m.dequant_per_tensor_asym(xq, sc, zp_i) # type: ignore # CPU
        return xhat.to(device=dev, dtype=x.dtype)

    @staticmethod
    def backward(ctx, gO):
        return gO, None, None, None, None


class QuantPerChannelSymSTE(torch.autograd.Function):
    @staticmethod
    def forward(ctx, w, scale, ch_axis, qmin, qmax):
        m = get_cpp_quant()
        dev = w.device
        w_cpu = w.contiguous().to(torch.float32).cpu()
        scale_cpu = scale.detach().to(torch.float32).contiguous().cpu() if torch.is_tensor(scale) else torch.tensor(scale, dtype=torch.float32)
        wq = m.quant_per_channel_sym(w_cpu, scale_cpu, int(ch_axis), int(qmin), int(qmax))  # type: ignore # CPU
        shape = [1] * w.dim(); shape[int(ch_axis)] = -1
        w_hat_cpu = (wq.to(torch.float32) * scale_cpu.view(shape))
        return w_hat_cpu.to(device=dev, dtype=w.dtype)

    @staticmethod
    def backward(ctx, gO):
        return gO, None, None, None, None

class QuantPerTensorAsym16STE(torch.autograd.Function):
    @staticmethod
    def forward(ctx, x, scale, zp, qmin, qmax):
        m = get_cpp_quant()
        dev = x.device
        x_cpu = x.contiguous().to(torch.float32).cpu()
        sc = float(scale.item()) if torch.is_tensor(scale) else float(scale)
        zp_i = int(zp.item()) if torch.is_tensor(zp) else int(zp)
        xq = m.quant_per_tensor_asym16(x_cpu, sc, zp_i, int(qmin), int(qmax))  # type: ignore # CPU
        xhat = m.dequant_per_tensor_asym16(xq, sc, zp_i)  # type: ignore # CPU
        return xhat.to(device=dev, dtype=x.dtype)

    @staticmethod
    def backward(ctx, gO):
        return gO, None, None, None, None

class QuantPerChannelSym16STE(torch.autograd.Function):
    @staticmethod
    def forward(ctx, w, scale, ch_axis, qmin, qmax):
        m = get_cpp_quant()
        dev = w.device
        w_cpu = w.contiguous().to(torch.float32).cpu()
        scale_cpu = scale.detach().to(torch.float32).contiguous().cpu() if torch.is_tensor(scale) else torch.tensor(scale, dtype=torch.float32)
        wq = m.quant_per_channel_sym16(w_cpu, scale_cpu, int(ch_axis), int(qmin), int(qmax))  # type: ignore # CPU
        shape = [1] * w.dim(); shape[int(ch_axis)] = -1
        w_hat_cpu = (wq.to(torch.float32) * scale_cpu.view(shape))
        return w_hat_cpu.to(device=dev, dtype=w.dtype)

    @staticmethod
    def backward(ctx, gO):
        return gO, None, None, None, None


class QConv1x1INT(torch.nn.Module):
    def __init__(self, in_f, out_f, bias=True, a_bits=8, w_bits=8, ch_axis=0):
        super().__init__()
        if a_bits not in (8, 16) or w_bits not in (8, 16):
            raise ValueError(f"Unsupported bit-width (a_bits={a_bits}, w_bits={w_bits}); supported: 8, 16")
        self.conv = torch.nn.Conv1d(in_f, out_f, kernel_size=1, bias=bias)
        # Per-channel activation scale along input channel axis (C)
        # Match Python LSQ per-channel activation quantization behavior
        self.a_scale = torch.nn.Parameter(torch.ones(in_f, dtype=torch.float32))
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
        # INT8: per-tensor asymmetric activations (scale + zp); INT16: per-channel symmetric
        qmin_a_sym, qmax_a_sym = self._qrange(self.a_bits, symmetric=True)
        qmin_a_asym, qmax_a_asym = self._qrange(self.a_bits, symmetric=False)
        qmin_w, qmax_w = self._qrange(self.w_bits, symmetric=True)
        # Dispatch by bit-width
        if self.a_bits == 8:
            # Per‑tensor asymmetric activations (calibrated via min/max into scale+zp)
            sc = torch.as_tensor(self.a_scale.mean(), dtype=torch.float32, device='cpu') if torch.is_tensor(self.a_scale) else torch.tensor(float(self.a_scale))  # type: ignore
            zp = torch.as_tensor(self.a_zp, dtype=torch.float32, device='cpu') if torch.is_tensor(self.a_zp) else torch.tensor(float(self.a_zp))  # type: ignore
            x_hat = QuantPerTensorAsymSTE.apply(x, sc, zp, qmin_a_asym, qmax_a_asym)
        elif self.a_bits == 16:
            x_hat = QuantPerChannelSym16STE.apply(x, self.a_scale.abs() + 1e-8, 1, qmin_a_sym, qmax_a_sym)
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


class QConv1dINT(torch.nn.Module):
    """
    Quantized Conv1d with arbitrary kernel/stride using C++ kernels for quant/dequant.
    Activations: per-channel symmetric (axis=1). Weights: per-out-channel symmetric (axis=0).
    """
    def __init__(self, in_f, out_f, kernel_size=1, stride=1, padding=0, dilation=1, groups=1,
                 bias=True, a_bits=8, w_bits=8, ch_axis=0):
        super().__init__()
        if a_bits not in (8, 16) or w_bits not in (8, 16):
            raise ValueError(f"Unsupported bit-width (a_bits={a_bits}, w_bits={w_bits}); supported: 8, 16")
        self.conv = torch.nn.Conv1d(in_f, out_f, kernel_size=kernel_size, stride=stride,
                                    padding=padding, dilation=dilation, groups=groups, bias=bias)
        self.a_scale = torch.nn.Parameter(torch.ones(in_f, dtype=torch.float32))
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
        qmin_a, qmax_a = self._qrange(self.a_bits, symmetric=True)
        qmin_w, qmax_w = self._qrange(self.w_bits, symmetric=True)
        # Activation per-channel on axis=1
        if self.a_bits == 8:
            x_hat = QuantPerChannelSymSTE.apply(x, self.a_scale.abs() + 1e-8, 1, qmin_a, qmax_a)
        elif self.a_bits == 16:
            x_hat = QuantPerChannelSym16STE.apply(x, self.a_scale.abs() + 1e-8, 1, qmin_a, qmax_a)
        else:
            raise ValueError(f"Unsupported activation bits: {self.a_bits}")
        # Weight per-out-channel on axis=0
        w = self.conv.weight
        if self.w_bits == 8:
            w_hat = QuantPerChannelSymSTE.apply(w, self.w_scale.abs() + 1e-8, self.ch_axis, qmin_w, qmax_w)
        elif self.w_bits == 16:
            w_hat = QuantPerChannelSym16STE.apply(w, self.w_scale.abs() + 1e-8, self.ch_axis, qmin_w, qmax_w)
        else:
            raise ValueError(f"Unsupported weight bits: {self.w_bits}")
        x_hat_t = cast(torch.Tensor, x_hat)
        w_hat_t = cast(torch.Tensor, w_hat)
        bias_t = cast(_Opt[torch.Tensor], self.conv.bias)
        return F.conv1d(input=x_hat_t, weight=w_hat_t, bias=bias_t,
                        stride=self.conv.stride, padding=self.conv.padding,
                        dilation=self.conv.dilation, groups=self.conv.groups)
