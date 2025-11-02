import os
import torch
import torch.nn as nn
from .cmamba_slim import CMambaSlim, ModelArgs


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
    ) -> None:
        super().__init__()
        self.Din = Din
        self.K = K
        # Conv1d projection across channels per time-step
        self.proj = nn.Conv1d(Din, proj_dim, kernel_size=1, bias=True)

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
        )
        self.backbone = CMambaSlim(args)
        self.head = nn.Conv1d(proj_dim, 2, kernel_size=1, bias=True)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: (B, K, Din)
        x = x.permute(0, 2, 1)            # (B, Din, K)
        x = self.proj(x)                  # (B, C, K)
        y = self.backbone(x)              # (B, C, 1)
        out = self.head(y).squeeze(-1)    # (B, 2)
        return out
