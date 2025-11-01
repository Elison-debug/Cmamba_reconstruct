import os
import argparse
import torch
from torch.utils.data import DataLoader

from .train import evaluate, TrainConfig, build_datasets, set_seed
from .losses import HuberEPE


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
    p.add_argument("--quant_backend", type=str, choices=["cpp", "python"], default=os.environ.get("QUANT_BACKEND", "python"))
    p.add_argument("--quantize_all", action="store_true")
    p.add_argument("--use_dwconv", action="store_true")
    p.add_argument("--workers", type=int, default=4)
    p.add_argument("--prefetch", type=int, default=4)
    p.add_argument("--mmap_off", action="store_true")
    # fine-grained quant toggles (env-based)
    p.add_argument("--q_proj_head", action="store_true")
    p.add_argument("--q_block_linear", action="store_true")
    p.add_argument("--q_backbone_linear", action="store_true")
    p.add_argument("--progress", action="store_true")
    p.add_argument("--no_progress", action="store_true")
    # SSM/PE/AGG knobs
    p.add_argument("--pe_off", action="store_true")
    p.add_argument("--pe_scale", type=float, default=1.0)
    p.add_argument("--gate_off", action="store_true")
    p.add_argument("--agg_pool", type=str, default="", choices=["", "avg", "max"])
    args = p.parse_args()

    set_seed(42)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # Prefer checkpoint dims to avoid size mismatch
    dims = {
        "Din": args.Din,
        "K": args.K,
        "proj_dim": args.proj_dim,
        "d_model": args.d_model,
        "n_layer": args.n_layer,
        "patch_len": args.patch_len,
        "stride": args.stride,
    }
    ckpt_obj = None
    if os.path.exists(args.ckpt):
        try:
            ckpt_obj = torch.load(args.ckpt, map_location="cpu")
            ck_cfg = ckpt_obj.get("cfg", None)
            if isinstance(ck_cfg, dict):
                for k in list(dims.keys()):
                    if k in ck_cfg:
                        dims[k] = int(ck_cfg[k]) if isinstance(ck_cfg[k], (int,)) else ck_cfg[k]
                print({"eval_dims_from_ckpt": True, **dims})
            else:
                print({"eval_dims_from_ckpt": False})
        except Exception as e:
            print({"ckpt_load": f"warn: {e}"})

    cfg = TrainConfig(
        Din=int(dims["Din"]),
        K=int(dims["K"]),
        proj_dim=int(dims["proj_dim"]),
        d_model=int(dims["d_model"]),
        n_layer=int(dims["n_layer"]),
        patch_len=int(dims["patch_len"]),
        stride=int(dims["stride"]),
        batch_size=args.batch_size,
        train_root=args.eval_root,
        eval_root=None,
        mmap=not bool(args.mmap_off),
    )
    ds, _ = build_datasets(cfg)
    dl = DataLoader(
        ds,
        batch_size=cfg.batch_size,
        shuffle=False,
        num_workers=int(args.workers),
        pin_memory=True,
        persistent_workers=(int(args.workers) > 0),
        prefetch_factor=(args.prefetch if int(args.workers) > 0 else None),
    )
    print({
        "eval_samples": len(ds),
        "K": cfg.K,
        "Din": cfg.Din,
        "device": str(device),
    })

    # Set backend before import
    os.environ["QUANT_BACKEND"] = args.quant_backend
    # no env toggles for model config; pass explicitly to constructor
    from .mamba_regressor import MambaRegressor  # delayed import

    model = MambaRegressor(
        Din=cfg.Din,
        K=cfg.K,
        proj_dim=cfg.proj_dim,
        d_model=cfg.d_model,
        n_layer=cfg.n_layer,
        patch_len=cfg.patch_len,
        stride=cfg.stride,
        pe_off=args.pe_off,
        pe_scale=args.pe_scale,
        gate_off=args.gate_off,
        agg_pool=args.agg_pool,
        quantize_all=args.quantize_all,
        q_proj_head=args.q_proj_head,
        q_block_linear=args.q_block_linear,
        q_backbone_linear=args.q_backbone_linear,
        use_dwconv=args.use_dwconv,
        quant_backend=args.quant_backend,
    ).to(device)

    if ckpt_obj is not None:
        sd = ckpt_obj.get("state_dict", ckpt_obj)
        model.load_state_dict(sd, strict=False)

    loss_fn = HuberEPE(delta=1.0)
    show = (args.progress or (not args.no_progress))
    ev_loss, stats = evaluate(model, dl, device, loss_fn, show_progress=show) #type: ignore
    print({"eval_loss": ev_loss, **stats})


if __name__ == "__main__":
    main()
