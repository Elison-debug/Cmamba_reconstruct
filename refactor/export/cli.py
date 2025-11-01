import argparse
import os
import torch

from refactor.core.mamba_regressor import MambaRegressor
from .pack import export_minimal


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--out", type=str, required=True)
    p.add_argument("--ckpt", type=str, default="refactor_last.pt")
    p.add_argument("--Din", type=int, default=int(os.environ.get("DIN", 2100)))
    p.add_argument("--K", type=int, default=int(os.environ.get("K", 12)))
    p.add_argument("--proj_dim", type=int, default=64)
    p.add_argument("--d_model", type=int, default=96)
    p.add_argument("--n_layer", type=int, default=3)
    p.add_argument("--patch_len", type=int, default=8)
    p.add_argument("--stride", type=int, default=4)
    args = p.parse_args()

    m = MambaRegressor(
        Din=args.Din,
        K=args.K,
        proj_dim=args.proj_dim,
        d_model=args.d_model,
        n_layer=args.n_layer,
        patch_len=args.patch_len,
        stride=args.stride,
    )
    if os.path.exists(args.ckpt):
        ckpt = torch.load(args.ckpt, map_location="cpu")
        sd = ckpt.get("state_dict", ckpt)
        m.load_state_dict(sd, strict=False)
    path = export_minimal(m, args.out)
    print({"export": path})


if __name__ == "__main__":
    main()

