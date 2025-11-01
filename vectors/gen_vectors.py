import os
import argparse
from pathlib import Path
import numpy as np
import torch


def save_npy(path: Path, arr: np.ndarray):
    path.parent.mkdir(parents=True, exist_ok=True)
    np.save(path, arr)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--layer", type=str, choices=["proj", "head"], required=True)
    p.add_argument("--export_dir", type=str, required=True, help="Directory containing export.json")
    p.add_argument("--ckpt", type=str, default="refactor_last.pt")
    p.add_argument("--eval_root", type=str, required=True)
    p.add_argument("--Din", type=int, default=int(os.environ.get("DIN", 2100)))
    p.add_argument("--K", type=int, default=int(os.environ.get("K", 12)))
    p.add_argument("--proj_dim", type=int, default=64)
    p.add_argument("--d_model", type=int, default=96)
    p.add_argument("--n_layer", type=int, default=3)
    p.add_argument("--patch_len", type=int, default=8)
    p.add_argument("--stride", type=int, default=4)
    p.add_argument("--quant_backend", type=str, choices=["cpp", "python"], default=os.environ.get("QUANT_BACKEND", "cpp"))
    p.add_argument("--sample", type=int, default=0)
    p.add_argument("--t_index", type=int, default=0, help="Which time index for proj input (0..K-1)")
    p.add_argument("--out_dir", type=str, default=None)
    args = p.parse_args()

    os.environ["QUANT_BACKEND"] = args.quant_backend

    from refactor.core.train import TrainConfig
    from refactor.core.mamba_regressor import MambaRegressor
    from refactor.datasets.frames_lazy import FramesLazyDataset

    cfg = TrainConfig(
        Din=args.Din,
        K=args.K,
        proj_dim=args.proj_dim,
        d_model=args.d_model,
        n_layer=args.n_layer,
        patch_len=args.patch_len,
        stride=args.stride,
        batch_size=1,
        train_root=args.eval_root,
        eval_root=None,
    )

    ds = FramesLazyDataset(root=cfg.train_root, seq_len=cfg.K, predict="current")
    xb, yb = ds[args.sample]
    xb = xb.unsqueeze(0).float()  # (1,K,Din)

    model = MambaRegressor(
        Din=cfg.Din,
        K=cfg.K,
        proj_dim=cfg.proj_dim,
        d_model=cfg.d_model,
        n_layer=cfg.n_layer,
        patch_len=cfg.patch_len,
        stride=cfg.stride,
    )
    if Path(args.ckpt).exists():
        ckpt = torch.load(args.ckpt, map_location="cpu")
        sd = ckpt.get("state_dict", ckpt)
        model.load_state_dict(sd, strict=False)
    model.eval()

    capture = {"x_in": None, "y_ref": None}

    def hook_in(module, inp, out):
        x = inp[0].detach().cpu()
        capture["_in_full"] = x

    def hook_out(module, inp, out):
        y = out.detach().cpu()
        capture["_out_full"] = y

    if args.layer == "proj":
        h1 = model.proj.register_forward_pre_hook(hook_in)
        h2 = model.proj.register_forward_hook(hook_out)
        with torch.no_grad():
            _ = model(xb)
        h1.remove(); h2.remove()
        xin = capture["_in_full"][0]  # (K,Din)
        t = int(max(0, min(args.t_index, xin.size(0)-1)))
        x_vec = xin[t]  # (Din)
        # reference output via the module
        with torch.no_grad():
            y_vec = model.proj(x_vec.unsqueeze(0)).squeeze(0).cpu()
    else:  # head
        h1 = model.head.register_forward_pre_hook(hook_in)
        h2 = model.head.register_forward_hook(hook_out)
        with torch.no_grad():
            _ = model(xb)
        h1.remove(); h2.remove()
        xh = capture["_in_full"][0]  # (C)
        x_vec = xh
        with torch.no_grad():
            y_vec = model.head(x_vec.unsqueeze(0)).squeeze(0).cpu()

    export_dir = Path(args.export_dir)
    out_dir = Path(args.out_dir) if args.out_dir is not None else (export_dir / "vectors")
    x_path = out_dir / f"{args.layer}_x_in.npy"
    y_path = out_dir / f"{args.layer}_y_ref.npy"
    save_npy(x_path, x_vec.numpy())
    save_npy(y_path, y_vec.numpy())
    print({"x_in": str(x_path), "y_ref": str(y_path), "layer": args.layer})


if __name__ == "__main__":
    main()
