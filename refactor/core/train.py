import os
import random
from dataclasses import dataclass
from typing import Dict, List, Optional
import numpy as np
import torch
from torch.utils.data import DataLoader, Subset
import csv

from .losses import HuberEPE
from ..datasets.samplers import GridPureBatchSampler


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
    num_workers: int = 2
    mmap: bool = True
    # 新布局：仅提供 feature 根目录（其下包含子目录 npy 与 json）
    feat_root: Optional[str] = None
    seed: int = 42


def set_seed(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False


def build_datasets(cfg: TrainConfig):
    from refactor.datasets.frames_lazy import FramesLazyDataset

    assert cfg.feat_root is not None, "cfg.feat_root must be provided (features root containing npy/ and json/)"
    # 使用统一特征根目录，按 JSON 中角色划分
    train_ds = FramesLazyDataset(root=cfg.feat_root, seq_len=cfg.K, predict="current", mmap=cfg.mmap, target="train")
    eval_ds = FramesLazyDataset(root=cfg.feat_root, seq_len=cfg.K, predict="current", mmap=cfg.mmap, target="eval")
    return train_ds, eval_ds


def _maybe_tqdm(it, total=None, desc=None, enabled=True):
    if not enabled:
        return it
    try:
        from tqdm import tqdm  # type: ignore
        return tqdm(it, total=total, desc=desc, ncols=100)
    except Exception:
        return it


def seed_worker(worker_id: int):
    """Top-level worker init for Windows spawn mode (picklable).
    Uses torch.initial_seed to derive per-worker seed deterministically.
    """
    worker_seed = torch.initial_seed() % (2**32)
    np.random.seed(worker_seed)
    random.seed(worker_seed)


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
    # 新布局：仅提供 features 根目录（包含子目录 npy 与 json）
    p.add_argument("--feat_root", type=str, default="./data/features/logo")
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
    p.add_argument("--prefetch", type=int, default=4)
    p.add_argument("--mmap_off", action="store_true")
    p.add_argument("--preload", action="store_true", help="preload all arrays into RAM (set workers=0/1)")
    p.add_argument("--out_dir", type=str, default=os.environ.get("OUT_DIR", "./ckpt_refactor/logo"))
    p.add_argument("--resume", type=str, default="")
    p.add_argument("--best_metric", type=str, choices=["eval_loss", "epe_mean"], default="epe_mean")
    p.add_argument("--workers", type=int, default=4)
    p.add_argument("--amp", action="store_true")
    # backbone knob kept (depthwise conv is hardware friendly)
    p.add_argument("--use_dwconv", action="store_true")
    p.add_argument("--seed", type=int, default=42)
    # SSM/PE/AGG knobs
    p.add_argument("--pe_off", action="store_true")
    p.add_argument("--pe_scale", type=float, default=1.0)
    p.add_argument("--gate_off", action="store_true")
    p.add_argument("--agg_pool", type=str, default="", choices=["", "avg", "max"])
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
        feat_root=args.feat_root,
        mmap=not bool(args.mmap_off),
        seed=args.seed,
    )

    set_seed(cfg.seed)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    from .mamba_regressor import MambaRegressor  # type: ignore

    # 构建数据集（可选预加载）
    from refactor.datasets.frames_lazy import FramesLazyDataset
    assert cfg.feat_root is not None
    train_ds = FramesLazyDataset(root=cfg.feat_root, seq_len=cfg.K, predict="current", mmap=not bool(args.mmap_off), in_memory=bool(args.preload), target="train")
    eval_ds = FramesLazyDataset(root=cfg.feat_root, seq_len=cfg.K, predict="current", mmap=not bool(args.mmap_off), in_memory=bool(args.preload), target="eval")
    print({
        "train_samples": len(train_ds),
        "eval_samples": (0 if eval_ds is None else len(eval_ds)),
        "K": cfg.K,
        "Din": cfg.Din,
    })
    nw = int(args.workers)
    pin = True
    # Grid‑pure batching: ensure each batch contains samples from a single grid/file
    train_batch_sampler = GridPureBatchSampler(
        train_ds,
        batch_size=cfg.batch_size,
        drop_last=False,
        shuffle_files=True,
        shuffle_within=True,
        seed=cfg.seed,
    )
    train_loader = DataLoader(
        train_ds,
        batch_sampler=train_batch_sampler,
        num_workers=nw,
        pin_memory=pin,
        persistent_workers=(nw > 0),
        prefetch_factor=(args.prefetch if nw > 0 else None),
        worker_init_fn=seed_worker if nw > 0 else None,
    )
    eval_loader = (
        DataLoader(
            eval_ds,
            batch_size=cfg.batch_size,
            shuffle=False,
            num_workers=nw,
            pin_memory=pin,
            persistent_workers=(nw > 0),
            prefetch_factor=(args.prefetch if nw > 0 else None),
            worker_init_fn=seed_worker if nw > 0 else None,
        ) if eval_ds is not None else None
    )

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
        use_dwconv=args.use_dwconv,
        # Training‑time quantization is disabled for hardware‑friendly inference prep
        quantize_all=False,
        q_proj_head=False,
        q_block_linear=False,
        q_backbone_linear=False,
        quant_backend=None,
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
        use_amp = bool(args.amp and torch.cuda.is_available())
        scaler = None
        autocast_cm = None # type: ignore
        if use_amp:
            try:
                scaler = torch.amp.GradScaler("cuda")  # type: ignore[attr-defined]

                def autocast_cm(): # type: ignore
                    return torch.amp.autocast("cuda")  # type: ignore[attr-defined]

            except Exception:
                scaler = torch.cuda.amp.GradScaler()

                def autocast_cm():
                    return torch.cuda.amp.autocast()

        for epoch in range(cfg.epochs):
            print(f"==== Epoch {epoch+1}/{cfg.epochs} ====")
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
                if use_amp and scaler is not None and autocast_cm is not None:
                    with autocast_cm():
                        pred = model(xb)
                        loss = criterion(pred, yb)
                    scaler.scale(loss).backward()
                    scaler.step(optim)
                    scaler.update()
                else:
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
                    it.set_postfix({"loss": f"{(total/max(1,n)):.4f}", "epe": f"{run_epe:.4f}", "lr": f"{cur_lr:.2e}"})# type: ignore
            tr_loss = total / max(1, n)
            if eval_loader is not None:
                ev_loss, stats = evaluate(model, eval_loader, device, criterion, show_progress=True)  # type: ignore
            else:
                ev_loss, stats = float("nan"), {"epe_mean": float("nan"), "epe_median": float("nan"), "epe_p80": float("nan"), "epe_p90": float("nan"), "mae_x": float("nan"), "mae_y": float("nan")}
            row = {"epoch": epoch + 1, "train_loss": tr_loss, "eval_loss": ev_loss}
            row.update(stats)
            print({"epoch: " + row["epoch"]})
            print({"epe_mean: " + f"{row['epe_mean']:.6f}" + " epe_median: " + f"{row['epe_median']:.6f}" + " epe_p80: " + f"{row['epe_p80']:.6f}"})
            print({"mae_x: " f"{row['mae_x']:.6f}" + " mae_y: " + f"{row['mae_y']:.6f}"})
            w.writerow(row)

            # save last and best
            last_path = os.path.join(args.out_dir, "last.pt")
            arch = {
                "use_dwconv": bool(args.use_dwconv),
                "pe_off": bool(args.pe_off),
                "pe_scale": float(args.pe_scale),
                "gate_off": bool(args.gate_off),
                "agg_pool": str(args.agg_pool),
            }
            torch.save({
                "state_dict": model.state_dict(),
                "cfg": vars(cfg),
                "arch": arch,
                "epoch": epoch + 1,
            }, last_path)
            metric_val = row.get(args.best_metric, None)
            if metric_val is not None and isinstance(metric_val, (int, float)) and not (metric_val != metric_val) and metric_val < best_val:
                best_val = metric_val
                torch.save({
                    "state_dict": model.state_dict(),
                    "cfg": vars(cfg),
                    "arch": arch,
                    "epoch": epoch + 1,
                    "best_metric": args.best_metric,
                    "best_val": best_val,
                }, best_path)
                print({"best_update": args.best_metric, "value": f"{best_val:.6f}", "path": best_path})

    # Save a root copy with arch info for downstream eval/test auto-config
    torch.save({"state_dict": model.state_dict(), "cfg": vars(cfg), "arch": arch}, "refactor_last.pt")


if __name__ == "__main__":
    main()
