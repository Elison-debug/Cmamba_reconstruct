import argparse
import os
import sys
from pathlib import Path

# Ensure project root is on sys.path when running as a script
ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import torch

from refactor.core.mamba_regressor import MambaRegressor


def _mb(nbytes: int) -> float:
    return nbytes / (1024.0 * 1024.0)


def _load_dims_from_ckpt(ckpt_path: str):
    if not ckpt_path or not os.path.exists(ckpt_path):
        return None, None
    ckpt = torch.load(ckpt_path, map_location="cpu")
    cfg = ckpt.get("cfg", None) if isinstance(ckpt, dict) else None
    arch = ckpt.get("arch", None) if isinstance(ckpt, dict) else None
    return cfg, arch


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--ckpt", type=str, default="", help="checkpoint with state_dict/cfg/arch")
    p.add_argument("--out", type=str, default="model_full.pt", help="output path for torch.save(model)")
    # fallback dims if ckpt has no cfg
    p.add_argument("--Din", type=int, default=2100)
    p.add_argument("--K", type=int, default=12)
    p.add_argument("--proj_dim", type=int, default=64)
    p.add_argument("--d_model", type=int, default=96)
    p.add_argument("--n_layer", type=int, default=3)
    p.add_argument("--patch_len", type=int, default=8)
    p.add_argument("--stride", type=int, default=4)
    # optional arch knobs (used only if present in ckpt)
    p.add_argument("--pe_off", action="store_true")
    p.add_argument("--pe_scale", type=float, default=1.0)
    p.add_argument("--gate_off", action="store_true")
    p.add_argument("--agg_pool", type=str, default="", choices=["", "avg", "max"])
    p.add_argument("--use_dwconv", action="store_true")
    p.add_argument("--save_full", action="store_true", help="actually write torch.save(model) to disk")
    args = p.parse_args()

    cfg, arch = _load_dims_from_ckpt(args.ckpt)
    if isinstance(cfg, dict):
        Din = int(cfg.get("Din", args.Din))
        K = int(cfg.get("K", args.K))
        proj_dim = int(cfg.get("proj_dim", args.proj_dim))
        d_model = int(cfg.get("d_model", args.d_model))
        n_layer = int(cfg.get("n_layer", args.n_layer))
        patch_len = int(cfg.get("patch_len", args.patch_len))
        stride = int(cfg.get("stride", args.stride))
    else:
        Din, K = args.Din, args.K
        proj_dim, d_model = args.proj_dim, args.d_model
        n_layer, patch_len, stride = args.n_layer, args.patch_len, args.stride

    # use arch flags from ckpt if present
    pe_off = bool(arch.get("pe_off", args.pe_off)) if isinstance(arch, dict) else bool(args.pe_off)
    pe_scale = float(arch.get("pe_scale", args.pe_scale)) if isinstance(arch, dict) else float(args.pe_scale)
    gate_off = bool(arch.get("gate_off", args.gate_off)) if isinstance(arch, dict) else bool(args.gate_off)
    agg_pool = str(arch.get("agg_pool", args.agg_pool)) if isinstance(arch, dict) else str(args.agg_pool)
    use_dwconv = bool(arch.get("use_dwconv", args.use_dwconv)) if isinstance(arch, dict) else bool(args.use_dwconv)

    model = MambaRegressor(
        Din=Din,
        K=K,
        proj_dim=proj_dim,
        d_model=d_model,
        n_layer=n_layer,
        patch_len=patch_len,
        stride=stride,
        pe_off=pe_off,
        pe_scale=pe_scale,
        gate_off=gate_off,
        agg_pool=agg_pool,
        use_dwconv=use_dwconv,
    )

    if args.ckpt and os.path.exists(args.ckpt):
        sd = torch.load(args.ckpt, map_location="cpu")
        sd = sd.get("state_dict", sd) if isinstance(sd, dict) else sd
        model.load_state_dict(sd, strict=False)

    model = model.cpu()

    # parameter count
    n_params = sum(p.numel() for p in model.parameters())

    # compute size by saving to disk
    out_path = Path(args.out)
    if args.save_full:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        torch.save(model, str(out_path))
        file_size = out_path.stat().st_size
        print({
            "params": int(n_params),
            "torchsave_path": str(out_path),
            "file_size_bytes": int(file_size),
            "file_size_mb": round(_mb(file_size), 3),
        })
    else:
        # save to a temp buffer to estimate size without writing to disk
        import io
        buf = io.BytesIO()
        torch.save(model, buf)
        file_size = buf.getbuffer().nbytes
        print({
            "params": int(n_params),
            "torchsave_path": None,
            "file_size_bytes": int(file_size),
            "file_size_mb": round(_mb(file_size), 3),
            "note": "use --save_full to write to disk",
        })


if __name__ == "__main__":
    main()
