from typing import Optional

import torch
import torch.nn as nn

from .mamba_slim import MambaSlim, ModelArgs, MambaOrigin

try:
    # Use quantized 1x1 Conv implementation explicitly
    from ..quant.qat_layers import QConv1x1INT, set_default_backend  # type: ignore
except Exception:  # pragma: no cover - optional dependency
    QConv1x1INT = None
    set_default_backend = None


class _Pointwise1x1(nn.Module):
    """Apply either Conv1d(1x1) or quantized Conv1d(1x1) depending on quant toggle."""

    def __init__(self, in_ch: int, out_ch: int, *, bias: bool = True, use_q: bool = False, backend: Optional[str] = None, quant_bits: int = 8):
        super().__init__()
        self._use_q = bool(use_q and QConv1x1INT is not None)
        if self._use_q:
            if backend and set_default_backend is not None:
                set_default_backend(backend)
            # Use explicit name 'qconv' for quantized conv
            self.qconv = QConv1x1INT(in_ch, out_ch, bias=bias, a_bits=quant_bits, w_bits=quant_bits, backend=backend)  # type: ignore[call-arg]
        else:
            self.conv = nn.Conv1d(in_ch, out_ch, kernel_size=1, bias=bias)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        if self._use_q:
            return self.qconv(x)
        return self.conv(x)


class MambaRegressor(nn.Module):
    def __init__(
        self,
        Din: int,
        K: int,
        proj_dim: int = 64,
        d_model: int = 96,
        n_layer: int = 3,
        patch_len: int = 8,
        stride: int = 4,
        *,
        pe_off: bool = False,
        pe_scale: float = 1.0,
        gate_off: bool = False,
        agg_pool: str = "",
        use_dwconv: bool = False,
        quantize_all: bool = False,
        q_proj: bool = False,
        q_head: bool = False,
        q_block_linear: bool = False,
        q_backbone_linear: bool = False,
        quant_backend: Optional[str] = None,
        quant_bits: int = 8,
    ) -> None:
        super().__init__()
        self.Din = Din
        self.K = K
        # resolve quant toggles
        q_proj_res = bool(quantize_all or q_proj)
        q_head_res = bool(quantize_all or q_head)
        q_block = bool(quantize_all or q_block_linear)
        q_backbone = bool(quantize_all or q_backbone_linear)
        if quant_backend and set_default_backend is not None:
            set_default_backend(quant_backend)
        # Conv1d projection across channels per time-step
        self.proj = _Pointwise1x1(Din, proj_dim, bias=True, use_q=q_proj_res, backend=quant_backend, quant_bits=quant_bits)

        args = ModelArgs(
            d_model=d_model,
            n_layer=n_layer,
            seq_len=K,
            num_channels=proj_dim,
            patch_len=patch_len,
            stride=stride,
            forecast_len=1,
            pad_multiple=1,
            pe_on=(not pe_off),
            pe_scale=pe_scale,
            gate_off=gate_off,
            agg_pool=agg_pool,
            use_dwconv=use_dwconv,
            quantize_all=quantize_all,
            q_block_linear=q_block,
            q_backbone_linear=q_backbone,
            quant_backend=quant_backend,
            quant_bits=quant_bits,
        )
        self.backbone = MambaSlim(args)
        # self.backbone = MambaOrigin(args)
        self.head = _Pointwise1x1(proj_dim, 2, bias=True, use_q=q_head_res, backend=quant_backend, quant_bits=quant_bits)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: (B, K, Din)
        x = x.permute(0, 2, 1)            # (B, Din, K)
        x = self.proj(x)                  # (B, C, K)
        y = self.backbone(x)              # (B, C, 1)
        out = self.head(y).squeeze(-1)    # (B, 2)
        return out

    # For API compatibility with stateful models; here it is a no‑op.
    def reset_state(self) -> None:
        return None
