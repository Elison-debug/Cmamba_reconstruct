import os
import torch
import torch.nn as nn
from .cmamba_slim import CMambaSlim, ModelArgs
from ..quant.qat_layers import QLinearINT8


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
    ) -> None:
        super().__init__()
        self.Din = Din
        self.K = K
        use_q = bool(int(os.environ.get("Q_PROJ_HEAD", "0")))
        self.proj = QLinearINT8(Din, proj_dim) if use_q else nn.Linear(Din, proj_dim)

        args = ModelArgs(
            d_model=d_model,
            n_layer=n_layer,
            seq_len=K,
            num_channels=proj_dim,
            patch_len=patch_len,
            stride=stride,
            forecast_len=1,
            pad_multiple=1,
        )
        self.backbone = CMambaSlim(args)
        self.head = QLinearINT8(proj_dim, 2) if use_q else nn.Linear(proj_dim, 2)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x: (B, K, Din)
        x = self.proj(x)  # (B,K,C)
        y = self.backbone(x.permute(0, 2, 1))  # (B,C,1)
        if y.dim() == 3:
            y = y.squeeze(-1)
        return self.head(y)  # (B,2)
