import os
import torch
import torch.nn as nn

from .spec import CH_AXIS


def _load_cpp_backend():
    try:
        from .cpp_backend import get_cpp_quant, QLinearINT8 as QCpp
        return get_cpp_quant(), QCpp
    except Exception:
        return None, None


class LSQQuantizer(nn.Module):
    def __init__(self, bits=8, per_channel=False, ch_axis=0, symmetric=True, learn_scale=True):
        super().__init__()
        self.bits = bits
        self.per_channel = per_channel
        self.symmetric = symmetric
        self.ch_axis = ch_axis
        self.learn_scale = learn_scale
        self.register_parameter("scale", None)
        self.register_buffer("zero_point", torch.zeros(1))

    def _init_params(self, x: torch.Tensor):
        with torch.no_grad():
            if self.per_channel:
                dims = [i for i in range(x.dim()) if i != self.ch_axis]
                s = x.detach().abs().mean(dim=dims, keepdim=True) * 2.0
            else:
                s = x.detach().abs().mean() * 2.0
            if self.learn_scale:
                self.scale = nn.Parameter(s.clamp(min=1e-8))
            else:
                self.register_buffer("scale", s.clamp(min=1e-8))

    @staticmethod
    def _round_ste(x):
        class RoundSTE(torch.autograd.Function):
            @staticmethod
            def forward(ctx, inp):
                return torch.round(inp)

            @staticmethod
            def backward(ctx, g):
                return g

        return RoundSTE.apply(x)

    @staticmethod
    def _clamp_ste(x, lo, hi):
        class ClampSTE(torch.autograd.Function):
            @staticmethod
            def forward(ctx, inp, lo, hi):
                return torch.clamp(inp, lo, hi)

            @staticmethod
            def backward(ctx, g, *args):
                return g, None, None

        return ClampSTE.apply(x, lo, hi)

    def forward(self, x: torch.Tensor, symmetric=True):
        if self.scale is None:
            self._init_params(x)
        qmin = -(1 << (self.bits - 1)) if symmetric else 0
        qmax = (1 << (self.bits - 1)) - 1 if symmetric else (1 << self.bits) - 1
        if symmetric:
            x_int = self._round_ste(self._clamp_ste(x / self.scale, qmin, qmax))
            x_hat = x_int * self.scale #type: ignore
        else:
            x_int = self._round_ste(self._clamp_ste(x / self.scale, qmin, qmax))
            x_hat = x_int * self.scale #type: ignore
        return x_hat


class QLinearINT8(nn.Module):
    """
    Prefer native C++ STE impl from old/ if available; otherwise, fall back to LSQ-based fake-quant.
    """

    def __init__(self, in_f, out_f, bias=True, a_bits=8, w_bits=8):
        super().__init__()
        backend = os.environ.get("QUANT_BACKEND", "cpp").lower()
        quant_mod, cpp_q = _load_cpp_backend()
        if backend == "cpp" and cpp_q is not None:
            self.impl = cpp_q(in_f, out_f, bias=bias, a_bits=a_bits, w_bits=w_bits, ch_axis=CH_AXIS)
            self._use_cpp = True
        else:
            self.lin = nn.Linear(in_f, out_f, bias=bias)
            self.qa = LSQQuantizer(bits=a_bits, per_channel=False, symmetric=False, learn_scale=True)
            self.qw = LSQQuantizer(bits=w_bits, per_channel=True, ch_axis=CH_AXIS, symmetric=True, learn_scale=True)
            self._use_cpp = False

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        if getattr(self, "_use_cpp", False):
            return self.impl(x)
        xq = self.qa(x, symmetric=False)
        wq = self.qw(self.lin.weight, symmetric=True)
        return torch.nn.functional.linear(xq, wq, self.lin.bias)
