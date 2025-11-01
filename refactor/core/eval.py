import os
import argparse
import torch
from torch.utils.data import DataLoader

from .train import evaluate, TrainConfig, build_datasets, set_seed


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--eval_root", type=str, required=True)
    p.add_argument("--Din", type=int, default=int(os.environ.get("DIN", 2100)))
    p.add_argument("--K", type=int, default=int(os.environ.get("K", 12)))
    p.add_argument("--proj_dim", type=int, default=64)
    p.add_argument("--d_model", type=int, default=96)
    p.add_argument("--n_layer", type=int, default=3)
    p.add_argument("--patch_len", type=int, default=8)
    p.add_argument("--stride", type=int, default=4)
    p.add_argument("--batch_size", type=int, default=64)
    p.add_argument("--ckpt", type=str, default="refactor_last.pt")
    p.add_argument("--quant_backend", type=str, choices=["cpp", "python"], default=os.environ.get("QUANT_BACKEND", "cpp"))
    p.add_argument("--quantize_all", action="store_true")
    p.add_argument("--use_dwconv", action="store_true")
    args = p.parse_args()

    set_seed(42)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    cfg = TrainConfig(
        Din=args.Din,
        K=args.K,
        proj_dim=args.proj_dim,
        d_model=args.d_model,
        n_layer=args.n_layer,
        patch_len=args.patch_len,
        stride=args.stride,
        batch_size=args.batch_size,
        train_root=args.eval_root,
        eval_root=None,
    )
    ds, _ = build_datasets(cfg)
    dl = DataLoader(ds, batch_size=cfg.batch_size, shuffle=False, num_workers=4)

    # Set backend before import
    os.environ["QUANT_BACKEND"] = args.quant_backend
    if args.quantize_all:
        os.environ["QUANTIZE_ALL"] = "1"
    if args.use_dwconv:
        os.environ["USE_DWCONV"] = "1"
    from .mamba_regressor import MambaRegressor  # delayed import

    model = MambaRegressor(
        Din=cfg.Din,
        K=cfg.K,
        proj_dim=cfg.proj_dim,
        d_model=cfg.d_model,
        n_layer=cfg.n_layer,
        patch_len=cfg.patch_len,
        stride=cfg.stride,
    ).to(device)

    if os.path.exists(args.ckpt):
        ckpt = torch.load(args.ckpt, map_location="cpu")
        sd = ckpt.get("state_dict", ckpt)
        model.load_state_dict(sd, strict=False)

    loss_fn = torch.nn.SmoothL1Loss()
    ev_loss, stats = evaluate(model, dl, device, loss_fn) #type: ignore
    print({"eval_loss": ev_loss, **stats})


if __name__ == "__main__":
    main()
