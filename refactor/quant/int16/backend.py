import os
from pathlib import Path
import torch
from torch.utils.cpp_extension import load

_CACHED = None

def _resolve_src() -> Path:
    here = Path(__file__).resolve().parent
    src = (here / "csrc" / "int16_conv.cpp").resolve()
    if not src.exists():
        raise FileNotFoundError("int16_conv.cpp not found under refactor/quant/int16/csrc")
    return src

def get_int16_mod():
    global _CACHED
    if _CACHED is not None:
        return _CACHED
    src = _resolve_src()
    mod = load(name="int16_conv_q88", sources=[str(src)], verbose=False)
    _CACHED = mod
    return mod

def to_q88_int16(x: torch.Tensor) -> torch.Tensor:
    # round to nearest even, saturate to int16 range
    t = torch.round(x * 256.0)
    t.clamp_(-32768.0, 32767.0)
    return t.to(torch.int16)

def from_q88_int16(xq: torch.Tensor) -> torch.Tensor:
    return xq.to(torch.float32) / 256.0

def _rne_rshift_q88_int(x: torch.Tensor, shift: int = 8) -> torch.Tensor:
    if shift <= 0:
        return x
    x64 = x.to(torch.int64)
    sgn = torch.where(x64 < 0, -1, 1)
    mag = torch.where(x64 < 0, -x64, x64)
    q = mag >> shift
    r = mag & ((1 << shift) - 1)
    half = (1 << (shift - 1))
    tie = (r == half)
    gt = (r > half)
    inc = torch.where(gt | (tie & ((q & 1) == 1)), torch.ones_like(q), torch.zeros_like(q))
    q = q + inc
    res = torch.where(sgn < 0, -q, q)
    return res

class Int16Conv1x1Q88(torch.nn.Module):
    """Hardware-style 1x1 Conv in Q8.8 integer domain.
    weight/bias are stored as int16 Q8.8; input is quantized to int16 Q8.8; output returned as float32.
    """
    def __init__(self, in_ch: int, out_ch: int, bias: bool = True):
        super().__init__()
        self.in_ch = in_ch
        self.out_ch = out_ch
        self.w_q = torch.nn.Parameter(torch.zeros(out_ch, in_ch, 1, dtype=torch.int16), requires_grad=False)
        self.b_q = torch.nn.Parameter(torch.zeros(out_ch, dtype=torch.int16), requires_grad=False)

    def load_float_weight(self, w: torch.Tensor, b: torch.Tensor | None):
        with torch.no_grad():
            self.w_q.data = to_q88_int16(w.detach())  # type: ignore
            if b is not None:
                self.b_q.data = to_q88_int16(b.detach().view(-1))  # type: ignore
            else:
                self.b_q.data.zero_()

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        m = get_int16_mod()
        x_q = to_q88_int16(x)
        y_q = m.conv1x1_q88(x_q.contiguous(), self.w_q.contiguous(), self.b_q.contiguous()) # type: ignore
        return from_q88_int16(y_q)


class Int16Conv1dKxQ88(torch.nn.Module):
    def __init__(self, in_ch: int, out_ch: int, kernel: int, stride: int = 1, bias: bool = True):
        super().__init__()
        self.in_ch = in_ch
        self.out_ch = out_ch
        self.kernel = int(kernel)
        self.stride = int(stride)
        self.w_q = torch.nn.Parameter(torch.zeros(out_ch, in_ch, self.kernel, dtype=torch.int16), requires_grad=False)
        self.b_q = torch.nn.Parameter(torch.zeros(out_ch, dtype=torch.int16), requires_grad=False)

    def load_float_weight(self, w: torch.Tensor, b: torch.Tensor | None):
        with torch.no_grad():
            self.w_q.data = to_q88_int16(w.detach())  # type: ignore
            if b is not None:
                self.b_q.data = to_q88_int16(b.detach().view(-1))  # type: ignore
            else:
                self.b_q.data.zero_()

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        m = get_int16_mod()
        x_q = to_q88_int16(x)
        y_q = m.conv1d_k_q88(x_q.contiguous(), self.w_q.contiguous(), self.b_q.contiguous(), int(self.stride)) # type: ignore
        return from_q88_int16(y_q)


# LUTs for sigmoid/SiLU in Q8.8
class _Q88LUT:
    def __init__(self, fn, x_min: float = -8.0, x_max: float = 8.0):
        self.x_min = float(x_min)
        self.x_max = float(x_max)
        n = int(round((x_max - x_min) * 256))
        xs = torch.linspace(x_min, x_max, steps=n + 1, dtype=torch.float32)
        ys = fn(xs)
        self.table = to_q88_int16(ys)

    def lookup(self, x_q: torch.Tensor) -> torch.Tensor:
        x_f = from_q88_int16(x_q)
        x_c = x_f.clamp(self.x_min, self.x_max)
        idx = torch.round((x_c - self.x_min) * 256.0).to(torch.long)
        return self.table.to(x_q.device)[idx]


class Int16SigmoidLUT(torch.nn.Module):
    def __init__(self, x_min: float = -8.0, x_max: float = 8.0):
        super().__init__()
        self.lut = _Q88LUT(torch.sigmoid, x_min=x_min, x_max=x_max)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x_q = to_q88_int16(x)
        y_q = self.lut.lookup(x_q)
        return from_q88_int16(y_q)


class Int16SiLULUT(torch.nn.Module):
    def __init__(self, x_min: float = -8.0, x_max: float = 8.0):
        super().__init__()
        self.sig = _Q88LUT(torch.sigmoid, x_min=x_min, x_max=x_max)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x_q = to_q88_int16(x)
        s_q = self.sig.lookup(x_q)
        prod = (x_q.to(torch.int32) * s_q.to(torch.int32)).to(torch.int64)
        y_q = _rne_rshift_q88_int(prod, 8).to(torch.int16)
        return from_q88_int16(y_q)
