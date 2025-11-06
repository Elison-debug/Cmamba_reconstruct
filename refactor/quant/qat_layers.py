import torch
import torch.nn as nn

from .spec import CH_AXIS

# module-level default backend, override via set_default_backend()
_DEFAULT_BACKEND = "python"

def set_default_backend(backend: str):
    global _DEFAULT_BACKEND
    be = str(backend).lower().strip()
    if be not in ("python", "cpp"):
        raise ValueError("backend must be 'python' or 'cpp'")
    _DEFAULT_BACKEND = be


def _get_cpp_qlinear():
    try:
        from .cpp_backend import QConv1x1INT as QCpp
        return QCpp
    except Exception:
        return None


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
        # Safely materialize tensors for arithmetic (no legacy fallbacks)
        s = self.scale if isinstance(self.scale, torch.Tensor) else torch.as_tensor(self.scale)
        z = self.zero_point if isinstance(self.zero_point, torch.Tensor) else torch.as_tensor(self.zero_point)
        s = s.to(device=x.device, dtype=x.dtype)
        z = z.to(device=x.device, dtype=x.dtype)
        # Enforce expected shapes strictly
        if self.per_channel:
            # Expect per-channel scale along ch_axis
            ca = self.ch_axis if (0 <= self.ch_axis < x.dim()) else 1
            nchan = int(x.size(ca))
            if s.numel() != nchan:
                raise RuntimeError(f"LSQQuantizer: per-channel scale numel={s.numel()} mismatch channels={nchan} @axis={ca}")
            s = s.view(nchan)
            shape = [1] * x.dim(); shape[ca] = -1
            s = s.view(shape)
            if not symmetric:
                if z.numel() not in (1, nchan):
                    raise RuntimeError(f"LSQQuantizer: zero_point numel={z.numel()} invalid for per-channel asymmetric")
                if z.numel() == nchan:
                    z = z.view(nchan).view(shape)
        else:
            # Per-tensor: expect scalar scale (and scalar zp if used)
            if s.numel() != 1:
                raise RuntimeError(f"LSQQuantizer: per-tensor scale must be scalar, got numel={s.numel()}")
            if not symmetric and z.numel() != 1:
                raise RuntimeError(f"LSQQuantizer: per-tensor zero_point must be scalar, got numel={z.numel()}")
        qmin = -(1 << (self.bits - 1)) if symmetric else 0
        qmax = (1 << (self.bits - 1)) - 1 if symmetric else (1 << self.bits) - 1
        if symmetric:
            x_int = self._round_ste(self._clamp_ste(x / s, qmin, qmax))
            x_hat = x_int * s # type: ignore[operator]
        else:
            # Asymmetric per-tensor: use zero-point during quant/dequant
            x_int = self._round_ste(self._clamp_ste(x / s + z, qmin, qmax))
            x_hat = (x_int - z) * s # type: ignore[operator]
        return x_hat


class QConv1x1INT(nn.Module):
    """
    统一入口：根据 backend 参数选择 C++ 量化实现或 Python LSQ 伪量化（Conv1d 1x1）。
    backend: 'cpp' | 'python'（默认 python）。
    """

    def __init__(self, in_f, out_f, bias=True, a_bits=8, w_bits=8, *, backend: str | None = None):
        super().__init__()
        be = _DEFAULT_BACKEND if backend is None else str(backend).lower()
        if be == "cpp":
            QCpp = _get_cpp_qlinear()
            if QCpp is None:
                raise RuntimeError("CPP quant backend not available or failed to load")
            self.impl = QCpp(in_f, out_f, bias=bias, a_bits=a_bits, w_bits=w_bits, ch_axis=CH_AXIS)
            self._use_cpp = True
            return
        # Python LSQ fake-quant (Conv1d 1x1)
        self.conv = nn.Conv1d(in_f, out_f, kernel_size=1, bias=bias)
        # Per-channel activation quantization (channel axis=1 for NCHW-like (B,C,K))
        self.qa = LSQQuantizer(bits=a_bits, per_channel=True, ch_axis=1, symmetric=True, learn_scale=True)
        self.qw = LSQQuantizer(bits=w_bits, per_channel=True, ch_axis=CH_AXIS, symmetric=True, learn_scale=True)
        # Ensure scales exist up-front so load_state_dict can load them
        try:
            if getattr(self.qa, "scale", None) is None:
                # per-channel activation scale vector length = input channels (axis=1)
                self.qa.scale = nn.Parameter(torch.ones(in_f, dtype=torch.float32))  # type: ignore[attr-defined]
            if getattr(self.qw, "scale", None) is None:
                # per-channel weight scale as 1D vector (out_f,)
                self.qw.scale = nn.Parameter(torch.ones(out_f, dtype=torch.float32))  # type: ignore[attr-defined]
        except Exception:
            pass
        self._use_cpp = False

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        if getattr(self, "_use_cpp", False):
            return self.impl(x)
        xq = self.qa(x, symmetric=True)
        wq = self.qw(self.conv.weight, symmetric=True)
        return torch.nn.functional.conv1d(xq, wq, self.conv.bias, stride=1, padding=0, groups=1)

# No legacy aliases; project uses QConv1x1INT explicitly.
