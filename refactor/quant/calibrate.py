from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Tuple

import torch


@dataclass
class CalibStats:
    act_min: float
    act_max: float


def collect_activation_stats(model: torch.nn.Module, loader) -> Dict[str, CalibStats]:
    stats: Dict[str, CalibStats] = {}

    def hook_fn(name):
        def _hook(_, __, out):
            t = out.detach().float()
            mn = float(t.min())
            mx = float(t.max())
            if name not in stats:
                stats[name] = CalibStats(mn, mx)
            else:
                s = stats[name]
                stats[name] = CalibStats(min(s.act_min, mn), max(s.act_max, mx))
        return _hook

    handles = []
    for n, m in model.named_modules():
        if isinstance(m, (torch.nn.Linear,)):
            handles.append(m.register_forward_hook(hook_fn(n)))

    model.eval()
    with torch.no_grad():
        for xb, _ in loader:
            _ = model(xb.float())

    for h in handles:
        h.remove()

    return stats


def minmax_to_scale_zp(minv: float, maxv: float, qmin: int, qmax: int) -> Tuple[float, int]:
    # affine quantization (per-tensor): x_q = clamp(round(x/s + zp), qmin, qmax)
    minv = float(minv)
    maxv = float(maxv)
    if maxv == minv:
        scale = 1.0
        zp = 0
    else:
        scale = (maxv - minv) / float(qmax - qmin)
        zp = int(round(qmin - minv / scale))
    return float(scale), int(zp)

