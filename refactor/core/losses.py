import torch
import torch.nn as nn


class HuberEPE(nn.Module):
    def __init__(self, delta: float = 1.0):
        super().__init__()
        self.delta = float(delta)

    def forward(self, pred: torch.Tensor, target: torch.Tensor) -> torch.Tensor:
        # pred/target: (B,2)
        diff = pred - target
        abs_diff = diff.abs()
        mask = abs_diff <= self.delta
        loss = torch.where(
            mask, 0.5 * diff.pow(2), self.delta * (abs_diff - 0.5 * self.delta)
        )
        return loss.mean()

