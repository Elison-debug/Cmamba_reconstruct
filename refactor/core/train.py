import os
import random
from dataclasses import dataclass
from typing import Optional

import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader
import csv

from .losses import HuberEPE


@dataclass
class TrainConfig:
    Din: int = 2100
    K: int = 12
    proj_dim: int = 64
    d_model: int = 96
    n_layer: int = 3
    patch_len: int = 8
    stride: int = 4

    batch_size: int = 64
    lr: float = 1e-3
    epochs: int = 5
    seed: int = 42
    num_workers: int = 2
    train_root: Optional[str] = None
    eval_root: Optional[str] = None


def set_seed(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False


def build_datasets(cfg: TrainConfig):
    from refactor.datasets.frames_lazy import FramesLazyDataset

    assert cfg.train_root is not None, "cfg.train_root must be provided"
    train_ds = FramesLazyDataset(root=cfg.train_root, seq_len=cfg.K, predict="current")
    eval_ds = None
    if cfg.eval_root:
        eval_ds = FramesLazyDataset(root=cfg.eval_root, seq_len=cfg.K, predict="current")
    return train_ds, eval_ds


def _maybe_tqdm(it, total=None, desc=None, enabled=True):
    if not enabled:
        return it
    try:
        from tqdm import tqdm  # type: ignore
        return tqdm(it, total=total, desc=desc, ncols=100)
    except Exception:
        return it


def train_one_epoch(model, loader, optim, device, criterion, show_progress: bool = True):
    model.train()
    total = 0.0
    n = 0
    it = _maybe_tqdm(loader, total=len(loader), desc="train", enabled=show_progress and hasattr(loader, "__len__"))
    seen = 0
    run_epe = 0.0
    for step, (xb, yb) in enumerate(it, 1):
        xb = xb.to(device).float()  # (B,K,Din)
        yb = yb.squeeze(1).to(device).float()  # (B,2)
        optim.zero_grad(set_to_none=True)
        pred = model(xb)
        loss = criterion(pred, yb)
        loss.backward()
        optim.step()
        total += loss.item() * xb.size(0)
        n += xb.size(0)
        # running EPE (mean Euclidean error) during training
        with torch.no_grad():
            epe_batch = torch.linalg.norm((pred - yb), dim=1).mean().item()
        seen += xb.size(0)
        run_epe = (run_epe * (seen - xb.size(0)) + epe_batch * xb.size(0)) / max(1, seen)
        if show_progress and not hasattr(it, "set_postfix") and step % 50 == 0:
            print(f"  [train] step={step} loss={loss.item():.4f} epe={run_epe:.4f}")
        elif show_progress and hasattr(it, "set_postfix"):
            it.set_postfix({"loss": f"{loss.item():.4f}", "epe": f"{run_epe:.4f}"})
    return total / max(1, n)


@torch.no_grad()
def evaluate(model, loader, device, criterion, show_progress: bool = False):
    if loader is None:
        return None
    model.eval()
    total = 0.0
    n = 0
    all_err = []
    it = _maybe_tqdm(loader, total=len(loader), desc="eval", enabled=show_progress and hasattr(loader, "__len__"))
    # running metrics
    run_cnt = 0
    run_epe = 0.0
    run_mae_x = 0.0
    run_mae_y = 0.0
    for xb, yb in it:
        xb = xb.to(device).float()
        yb = yb.squeeze(1).to(device).float()
        pred = model(xb)
        loss = criterion(pred, yb)
        all_err.append((pred - yb).detach().cpu())
        total += loss.item() * xb.size(0)
        n += xb.size(0)
        # update running means for real-time display
        err = (pred - yb).detach()
        epe_b = torch.linalg.norm(err, dim=1).mean().item()
        mae_x_b = err[:, 0].abs().mean().item()
        mae_y_b = err[:, 1].abs().mean().item()
        bsz = xb.size(0)
        run_epe = (run_epe * run_cnt + epe_b * bsz) / max(1, run_cnt + bsz)
        run_mae_x = (run_mae_x * run_cnt + mae_x_b * bsz) / max(1, run_cnt + bsz)
        run_mae_y = (run_mae_y * run_cnt + mae_y_b * bsz) / max(1, run_cnt + bsz)
        run_cnt += bsz
        if show_progress and hasattr(it, "set_postfix"):
            it.set_postfix({"epe": f"{run_epe:.4f}", "mae_x": f"{run_mae_x:.4f}", "mae_y": f"{run_mae_y:.4f}"})
    if all_err:
        E = torch.cat(all_err, dim=0)  # (N,2)
        dist = torch.linalg.norm(E, dim=1)
        m = float(dist.mean())
        med = float(dist.median())
        p80 = float(dist.kthvalue(max(1, int(0.8 * len(dist))))[0])
        p90 = float(dist.kthvalue(max(1, int(0.9 * len(dist))))[0])
        mae_x = float(E[:, 0].abs().mean())
        mae_y = float(E[:, 1].abs().mean())
    else:
        m = med = p80 = p90 = 0.0
        mae_x = mae_y = 0.0
    return total / max(1, n), {"epe_mean": m, "epe_median": med, "epe_p80": p80, "epe_p90": p90, "mae_x": mae_x, "mae_y": mae_y}


def main():
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--train_root", type=str, default=os.environ.get("TRAIN_ROOT"))
    p.add_argument("--eval_root", type=str, default=os.environ.get("EVAL_ROOT"))
    p.add_argument("--Din", type=int, default=int(os.environ.get("DIN", 2100)))
    p.add_argument("--K", type=int, default=int(os.environ.get("K", 12)))
    p.add_argument("--proj_dim", type=int, default=64)
    p.add_argument("--d_model", type=int, default=96)
    p.add_argument("--n_layer", type=int, default=3)
    p.add_argument("--patch_len", type=int, default=8)
    p.add_argument("--stride", type=int, default=4)
    p.add_argument("--batch_size", type=int, default=64)
    p.add_argument("--epochs", type=int, default=5)
    p.add_argument("--lr", type=float, default=1e-3)
    p.add_argument("--min_lr", type=float, default=1e-6)
    p.add_argument("--lr_schedule", type=str, choices=["cosine", "constant"], default="cosine")
    p.add_argument("--progress", action="store_true")
    p.add_argument("--no_progress", action="store_true")
    p.add_argument("--quant_backend", type=str, choices=["cpp", "python"], default=os.environ.get("QUANT_BACKEND", "python"))
    p.add_argument("--out_dir", type=str, default=os.environ.get("OUT_DIR", "./ckpt_refactor"))
    p.add_argument("--resume", type=str, default="")
    p.add_argument("--best_metric", type=str, choices=["eval_loss", "epe_mean"], default="epe_mean")
    p.add_argument("--workers", type=int, default=4)
    p.add_argument("--amp", action="store_true")
    p.add_argument("--quantize_all", action="store_true")
    p.add_argument("--use_dwconv", action="store_true")
    args = p.parse_args()

    # parse CLI first to set env for quant backend
    cfg = TrainConfig(
        Din=args.Din,
        K=args.K,
        proj_dim=args.proj_dim,
        d_model=args.d_model,
        n_layer=args.n_layer,
        patch_len=args.patch_len,
        stride=args.stride,
        batch_size=args.batch_size,
        epochs=args.epochs,
        lr=args.lr,
        train_root=args.train_root,
        eval_root=args.eval_root,
    )

    set_seed(cfg.seed)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # Delay import so QUANT_BACKEND env can take effect
    os.environ["QUANT_BACKEND"] = args.quant_backend
    if args.quantize_all:
        os.environ["QUANTIZE_ALL"] = "1"
    if args.use_dwconv:
        os.environ["USE_DWCONV"] = "1"
    from .mamba_regressor import MambaRegressor  # type: ignore

    train_ds, eval_ds = build_datasets(cfg)
    print({
        "train_samples": len(train_ds),
        "eval_samples": (0 if eval_ds is None else len(eval_ds)),
        "K": cfg.K,
        "Din": cfg.Din,
    })
    nw = int(args.workers)
    pin = True
    train_loader = DataLoader(
        train_ds,
        batch_size=cfg.batch_size,
        shuffle=True,
        num_workers=nw,
        pin_memory=pin,
        persistent_workers=(nw > 0),
        prefetch_factor=(2 if nw > 0 else None),
    )
    eval_loader = (
        DataLoader(
            eval_ds,
            batch_size=cfg.batch_size,
            shuffle=False,
            num_workers=nw,
            pin_memory=pin,
            persistent_workers=(nw > 0),
            prefetch_factor=(2 if nw > 0 else None),
        )
        if eval_ds is not None
        else None
    )

    model = MambaRegressor(
        Din=cfg.Din,
        K=cfg.K,
        proj_dim=cfg.proj_dim,
        d_model=cfg.d_model,
        n_layer=cfg.n_layer,
        patch_len=cfg.patch_len,
        stride=cfg.stride,
    ).to(device)
    n_params = sum(p.numel() for p in model.parameters())
    print({"model_params": int(n_params), "device": str(device)})

    optim = torch.optim.AdamW(model.parameters(), lr=cfg.lr, weight_decay=float(os.environ.get("WEIGHT_DECAY", "0.0")))
    criterion = HuberEPE(delta=1.0)

    # optional resume (model-only)
    if args.resume and os.path.exists(args.resume):
        ckpt = torch.load(args.resume, map_location="cpu")
        sd = ckpt.get("state_dict", ckpt)
        try:
            model.load_state_dict(sd, strict=False)
            print({"resume": args.resume, "status": "ok"})
        except Exception as e:
            print({"resume": args.resume, "status": f"failed: {e}"})

    os.makedirs(args.out_dir, exist_ok=True)
    log_path = os.path.join(args.out_dir, "train_log.csv")
    best_path = os.path.join(args.out_dir, f"best_{args.best_metric}.pt")
    best_val = float("inf")

    # CSV logger
    with open(log_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "epoch",
                "train_loss",
                "eval_loss",
                "epe_mean",
                "epe_median",
                "epe_p80",
                "epe_p90",
                "mae_x",
                "mae_y",
            ],
        )
        w.writeheader()
        show = (args.progress or (not args.no_progress))
        # prepare scheduler after knowing loader length
        total_steps = cfg.epochs * max(1, len(train_loader))
        if args.lr_schedule == "cosine":
            scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optim, T_max=total_steps, eta_min=args.min_lr)
        else:
            scheduler = None
        for epoch in range(cfg.epochs):
            print(f"==== Epoch {epoch+1}/{cfg.epochs} ====")
            if args.amp and torch.cuda.is_available():
                scaler = torch.cuda.amp.GradScaler()
                model.train()
                total = 0.0
                n = 0
                it = _maybe_tqdm(train_loader, total=len(train_loader), desc="train", enabled=show)
                seen = 0
                run_epe = 0.0
                for step, (xb, yb) in enumerate(it, 1):
                    xb = xb.to(device, non_blocking=True).float()
                    yb = yb.squeeze(1).to(device, non_blocking=True).float()
                    optim.zero_grad(set_to_none=True)
                    with torch.cuda.amp.autocast():
                        pred = model(xb)
                        loss = criterion(pred, yb)
                    scaler.scale(loss).backward()
                    scaler.step(optim)
                    scaler.update()
                    if scheduler is not None:
                        scheduler.step()
                    total += loss.item() * xb.size(0)
                    n += xb.size(0)
                    with torch.no_grad():
                        epe_batch = torch.linalg.norm((pred - yb), dim=1).mean().item()
                    seen += xb.size(0)
                    run_epe = (run_epe * (seen - xb.size(0)) + epe_batch * xb.size(0)) / max(1, seen)
                    if show and hasattr(it, "set_postfix"):
                        cur_lr = optim.param_groups[0]["lr"]
                        it.set_postfix({"loss": f"{(total/max(1,n)):.4f}", "epe": f"{run_epe:.4f}", "lr": f"{cur_lr:.2e}"})
                tr_loss = total / max(1, n)
            else:
                # non-AMP path with optional scheduler per batch
                model.train()
                total = 0.0
                n = 0
                it = _maybe_tqdm(train_loader, total=len(train_loader), desc="train", enabled=show)
                seen = 0
                run_epe = 0.0
                for step, (xb, yb) in enumerate(it, 1):
                    xb = xb.to(device, non_blocking=True).float()
                    yb = yb.squeeze(1).to(device, non_blocking=True).float()
                    optim.zero_grad(set_to_none=True)
                    pred = model(xb)
                    loss = criterion(pred, yb)
                    loss.backward()
                    optim.step()
                    if scheduler is not None:
                        scheduler.step()
                    total += loss.item() * xb.size(0)
                    n += xb.size(0)
                    with torch.no_grad():
                        epe_batch = torch.linalg.norm((pred - yb), dim=1).mean().item()
                    seen += xb.size(0)
                    run_epe = (run_epe * (seen - xb.size(0)) + epe_batch * xb.size(0)) / max(1, seen)
                    if show and hasattr(it, "set_postfix"):
                        cur_lr = optim.param_groups[0]["lr"]
                        it.set_postfix({"loss": f"{(total/max(1,n)):.4f}", "epe": f"{run_epe:.4f}", "lr": f"{cur_lr:.2e}"})
                tr_loss = total / max(1, n)
            ev_loss, stats = evaluate(model, eval_loader, device, criterion, show_progress=True)  # type: ignore
            row = {"epoch": epoch + 1, "train_loss": tr_loss, "eval_loss": ev_loss}
            row.update(stats)
            print({"epoch": row["epoch"], "train_loss": f"{row['train_loss']:.6f}", "eval_loss": f"{row['eval_loss']:.6f}"})
            print({"epe_mean": f"{row['epe_mean']:.6f}", "epe_median": f"{row['epe_median']:.6f}", "epe_p80": f"{row['epe_p80']:.6f}", "epe_p90": f"{row['epe_p90']:.6f}"})
            print({"mae_x": f"{row['mae_x']:.6f}", "mae_y": f"{row['mae_y']:.6f}"})
            w.writerow(row)

            # save last and best
            last_path = os.path.join(args.out_dir, "last.pt")
            torch.save({"state_dict": model.state_dict(), "cfg": vars(cfg), "epoch": epoch + 1}, last_path)
            metric_val = row.get(args.best_metric, None)
            if metric_val is not None and metric_val < best_val:
                best_val = metric_val
                torch.save({
                    "state_dict": model.state_dict(),
                    "cfg": vars(cfg),
                    "epoch": epoch + 1,
                    "best_metric": args.best_metric,
                    "best_val": best_val,
                }, best_path)
                print({"best_update": args.best_metric, "value": f"{best_val:.6f}", "path": best_path})

    # save quick copy at project root
    torch.save({"state_dict": model.state_dict(), "cfg": vars(cfg)}, "refactor_last.pt")


if __name__ == "__main__":
    main()
