import math
from typing import Optional

import torch
import torch.nn as nn

try:
    from ..quant.qat_layers import QConv1x1INT, QConv1dINT, set_default_backend  # type: ignore
    from ..quant.cpp_backend import QConv1dINT as QConv1dINT_CPP  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    QConv1x1INT = None
    QConv1dINT = None
    QConv1dINT_CPP = None
    set_default_backend = None


class _Pointwise1x1(nn.Module):
    """Shared helper for 1x1 projections with optional QLinear backend."""

    def __init__(self, in_ch: int, out_ch: int, *, bias: bool = True, use_q: bool = False, backend: Optional[str] = None, quant_bits: int = 8):
        super().__init__()
        self._use_q = bool(use_q and QConv1x1INT is not None)
        if self._use_q:
            if backend and set_default_backend is not None:
                set_default_backend(backend)
            self.qconv = QConv1x1INT(in_ch, out_ch, bias=bias, a_bits=quant_bits, w_bits=quant_bits, backend=backend)  # type: ignore[call-arg]
        else:
            self.conv = nn.Conv1d(in_ch, out_ch, kernel_size=1, bias=bias)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        if self._use_q:
            return self.qconv(x)
        return self.conv(x)


class _QuantConv1d(nn.Module):
    """Conv1d wrapper that uses quantized backend when enabled."""

    def __init__(self, in_ch: int, out_ch: int, *, kernel_size: int, stride: int = 1, padding: int = 0,
                 bias: bool = True, use_q: bool = False, backend: Optional[str] = None, quant_bits: int = 8):
        super().__init__()
        self._use_q = bool(use_q and ((QConv1dINT is not None) or (QConv1x1INT is not None)))
        if self._use_q:
            if backend and set_default_backend is not None:
                set_default_backend(backend)
            be = (backend or "python").lower() if backend is not None else "python"
            if be == "cpp" and QConv1dINT_CPP is not None:
                self.qconv = QConv1dINT_CPP(in_ch, out_ch, kernel_size=kernel_size, stride=stride,
                                            padding=padding, bias=bias, a_bits=quant_bits, w_bits=quant_bits)
            elif QConv1dINT is not None:
                self.qconv = QConv1dINT(in_ch, out_ch, kernel_size=kernel_size, stride=stride,
                                        padding=padding, bias=bias, a_bits=quant_bits, w_bits=quant_bits)
            else:
                # Fallback: if generic conv not available, degrade to 1x1 (not ideal but avoids crash)
                self.qconv = QConv1x1INT(in_ch, out_ch, bias=bias, a_bits=quant_bits, w_bits=quant_bits, backend=backend)  # type: ignore
        else:
            self.conv = nn.Conv1d(in_ch, out_ch, kernel_size=kernel_size, stride=stride, padding=padding, bias=bias)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        if self._use_q:
            return self.qconv(x)
        return self.conv(x)

class ModelArgs:
    def __init__(
        self,
        d_model: int = 128,
        n_layer: int = 4,
        seq_len: int = 96,
        d_state: int = 16,
        expand: int = 2,
        dt_rank: str | int = "auto",
        d_conv: int = 4,
        pad_multiple: int = 1,
        conv_bias: bool = True,
        bias: bool = False,
        num_channels: int = 64,
        patch_len: int = 16,
        stride: int = 4,
        forecast_len: int = 96,
        reduction_ratio: int = 8,
        verbose: bool = False,
        # args-based knobs
        pe_on: bool = True,
        pe_scale: float = 1.0,
        gate_off: bool = False,
        agg_pool: str = "",
        # hw/quant toggles (explicit)
        use_dwconv: bool = False,
        q_block_linear: bool = False,
        q_backbone_linear: bool = False,
        quantize_all: bool = False,
        quant_backend: Optional[str] = None,
        quant_bits: int = 8,
    ) -> None:
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

        if self.dt_rank == "auto":
            self.dt_rank = math.ceil(self.d_model / 16)
        if self.forecast_len % self.pad_multiple != 0:
            self.forecast_len += (
                self.pad_multiple - self.forecast_len % self.pad_multiple
            )
        # store knobs
        self.pe_on = bool(pe_on)
        self.pe_scale = float(pe_scale)
        self.gate_off = bool(gate_off)
        self.agg_pool = str(agg_pool).lower()
        # explicit toggles
        self.use_dwconv = bool(use_dwconv)
        self.q_block_linear = bool(q_block_linear)
        self.q_backbone_linear = bool(q_backbone_linear)
        self.quantize_all = bool(quantize_all)
        self.quant_backend = quant_backend
        self.quant_bits = int(quant_bits)


class RMSNorm(nn.Module):
    def __init__(self, d_model: int, eps: float = 1e-5):
        super().__init__()
        self.eps = eps
        self.weight = nn.Parameter(torch.ones(d_model))

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        var = x.pow(2).mean(dim=-1, keepdim=True)
        x = x * torch.rsqrt(var + self.eps)
        return x * self.weight


class SelectiveScanIC(nn.Module):
    """
    Input-conditioned SSM (Mamba-style approximation):
    lam_t = sigmoid(dt_proj(u_t)) in (0,1)
    s_t = lam_t ⊙ s_{t-1} + (1 - lam_t) ⊙ u_t
    y_t = s_t
    dt_proj is quantizable Linear.
    """

    def __init__(self, dim: int, LinearImpl=nn.Linear):
        super().__init__()
        # replace linear with pointwise conv1d
        self.dt_proj = nn.Conv1d(dim, dim, kernel_size=1, bias=True)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: [B,K,D]
        B, K, D = x.shape
        s = torch.zeros(B, D, device=x.device, dtype=x.dtype)
        # compute dt_proj via 1x1 conv over channels for all steps
        xp = x.permute(0, 2, 1)                  # (B, D, K)
        lam_all = torch.sigmoid(self.dt_proj(xp)).permute(0, 2, 1)  # (B, K, D)
        ys = torch.empty(B, K, D, device=x.device, dtype=x.dtype)
        for t in range(K):
            u = x[:, t, :]
            lam = lam_all[:, t, :]
            s = lam * s + (1.0 - lam) * u
            ys[:, t, :] = s
        return ys


class SlimMambaBlock(nn.Module):
    """
    Minimal SSM-only block (hardware-friendly, Mamba-like):
    RMSNorm -> in_proj(D->2*inner) -> split(u,z)
           -> [optional DWConv1d on u] -> SiLU(u) -> SelectiveScanIC(u)
           -> gate g = SiLU(z)
           -> y = out_proj( ssm(u) ⊙ g ) -> +res
    No channel fusion/gating path, per your request.
    """

    def __init__(self, args: ModelArgs) -> None:
        super().__init__()
        self.args = args
        D = args.d_model
        inner = args.d_inner

        # explicit toggles from args
        use_q_block = bool(self.args.q_block_linear or self.args.quantize_all)
        use_dw = bool(self.args.use_dwconv)
        self.use_gate = not bool(self.args.gate_off)

        # ensure odd kernel if used
        k = max(1, int(args.d_conv))
        if k % 2 == 0:
            k += 1

        self.norm = RMSNorm(D)
        # pointwise conv1d instead of linear
        self.in_proj = _Pointwise1x1(
            D,
            2 * inner,
            bias=args.bias,
            use_q=use_q_block,
            backend=args.quant_backend,
            quant_bits=args.quant_bits,
        )
        if use_dw:
            pad = k // 2
            self.dw_conv = nn.Conv1d(inner, inner, kernel_size=k, padding=pad, groups=inner, bias=args.conv_bias)
        else:
            self.dw_conv = None
        self.act = nn.SiLU()
        # dt_proj inside SSM as conv1d
        self.ssm = SelectiveScanIC(inner, LinearImpl=nn.Linear)  # type: ignore
        self.out_proj = _Pointwise1x1(
            inner,
            D,
            bias=args.bias,
            use_q=use_q_block,
            backend=args.quant_backend,
            quant_bits=args.quant_bits,
        )

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: [B,K,D]
        h = self.norm(x)
        hp = h.permute(0, 2, 1)            # (B, D, K)
        uvp = self.in_proj(hp)             # (B, 2*inner, K)
        uv = uvp.permute(0, 2, 1)          # (B, K, 2*inner)
        inner = self.args.d_inner
        u, z = uv[..., :inner], uv[..., inner:]
        if self.dw_conv is not None:
            up = u.permute(0, 2, 1)
            up = self.dw_conv(up)
            u = up.permute(0, 2, 1)
        u = self.act(u)
        s = self.ssm(u)
        if self.use_gate:
            g = self.act(z)
            s = s * g
        sp = s.permute(0, 2, 1)
        yp = self.out_proj(sp)             # (B, D, K)
        y = yp.permute(0, 2, 1)
        return x + y


class CMambaSlim(nn.Module):
    def __init__(self, args: ModelArgs):
        super().__init__()
        self.args = args
        # Using Conv1d projections; no linear in backbone
        # Aggregation and PE toggles (args-based)
        self.agg_pool = self.args.agg_pool  # "avg" | "max" | ""
        self.pe_on = bool(self.args.pe_on)
        self.pe_scale = float(self.args.pe_scale)
        self.patch_embedding = _QuantConv1d(
            in_ch=args.num_channels,
            out_ch=args.d_model,
            kernel_size=args.patch_len,
            stride=args.stride,
            bias=True,
            use_q=bool(args.q_backbone_linear or args.quantize_all),
            backend=args.quant_backend,
            quant_bits=args.quant_bits,
        )
        self.blocks = nn.ModuleList([SlimMambaBlock(args) for _ in range(args.n_layer)])
        self.norm_f = RMSNorm(args.d_model)
        # cache positional encoding to avoid recomputation on every forward
        if self.pe_on:
            pe = self._build_sincos(args.num_patches, args.d_model)
            self.register_buffer("pe_buf", pe, persistent=False)
        # Heads as Conv1d
        self.output_layer_flat = nn.Conv1d(
            in_channels=args.d_model,
            out_channels=args.num_channels * args.forecast_len,
            kernel_size=args.num_patches,
            bias=True,
        )
        self.output_layer_pool = _Pointwise1x1(
            args.d_model,
            args.num_channels * args.forecast_len,
            bias=True,
            use_q=bool(args.q_backbone_linear or args.quantize_all),
            backend=args.quant_backend,
            quant_bits=args.quant_bits,
        )

    @staticmethod
    def _build_sincos(n: int, d: int, device=None, dtype=None) -> torch.Tensor:
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

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: [B, C, K]
        B, C, L = x.shape
        # conv patch embedding
        x = self.patch_embedding(x)          # (B, d_model, num_patches)
        x = x.permute(0, 2, 1)               # (B, num_patches, d_model)
        if self.pe_on:
            # use cached pe, cast to runtime device/dtype
            pe = self.pe_buf.to(device=x.device, dtype=x.dtype)
            x = x + self.pe_scale * pe.unsqueeze(0) # type: ignore
        for blk in self.blocks:
            x = blk(x)
        x = self.norm_f(x)
        if self.agg_pool == "avg":
            x_agg = x.mean(dim=1)            # (B, d_model)
            y = self.output_layer_pool(x_agg.unsqueeze(-1))  # (B, C*F, 1)
        elif self.agg_pool == "max":
            x_agg, _ = x.max(dim=1)
            y = self.output_layer_pool(x_agg.unsqueeze(-1))
        else:
            xp = x.permute(0, 2, 1)          # (B, d_model, num_patches)
            y = self.output_layer_flat(xp)   # (B, C*F, 1)
        y = y.reshape(B, self.args.num_channels, self.args.forecast_len)
        return y
