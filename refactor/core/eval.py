import os
import argparse
from pathlib import Path
import numpy as np
import torch
from torch.utils.data import DataLoader
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap, PowerNorm

from .train import evaluate, TrainConfig, set_seed
from .losses import HuberEPE

def make_truncated_cmap(base='turbo', lo=0.10, hi=0.95, n=256):
    #从 base cmap 截取对比更强的区间，提升可辨识度。
    base_cmap = plt.get_cmap(base)
    return LinearSegmentedColormap.from_list(
        f'{base}_trunc_{lo}_{hi}', base_cmap(np.linspace(lo, hi, n))
    )

def main():
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
    p.add_argument("--ckpt", type=str, default="refactor_last.pt")
    p.add_argument("--quant_backend", type=str, choices=["cpp", "python"], default="python")
    p.add_argument("--quantize_all", type=bool, default= False)
    p.add_argument("--use_dwconv", action="store_true")
    p.add_argument("--workers", type=int, default=4)
    p.add_argument("--prefetch", type=int, default=4)
    p.add_argument("--mmap_off", action="store_true")
    p.add_argument("--target", type=str, default="eval", choices=["auto","train","eval","test"], help="which indices to use")
    # fine-grained quant toggles (env-based)
    p.add_argument("--q_proj_head", type=bool, default= False)
    p.add_argument("--q_block_linear", type=bool, default= False)
    p.add_argument("--q_backbone_linear", type=bool, default= False)
    p.add_argument("--progress", action="store_true")
    p.add_argument("--no_progress", action="store_true")
    p.add_argument("--preload", action="store_true", help="preload all arrays into RAM (set workers=0/1)")
    # SSM/PE/AGG knobs
    p.add_argument("--pe_off", action="store_true")
    p.add_argument("--pe_scale", type=float, default=1.0)
    p.add_argument("--gate_off", action="store_true")
    p.add_argument("--agg_pool", type=str, default="", choices=["", "avg", "max"])
    p.add_argument("--break_thresh", type=float, default=0.05, help="break true line when jump exceeds this distance (m)")
    p.add_argument("--out_dir", type=str, default="./eval_out")
    p.add_argument("--save_csv", action="store_true")
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
                print("eval_dims_from_ckpt: True" ,dims)
            else:
                print("eval_dims_from_ckpt: False")
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
        feat_root=args.feat_root,
        mmap=not bool(args.mmap_off),
    )
    # 构建数据集（仅从 feat_root 读取 json/npy）
    from refactor.datasets.frames_lazy import FramesLazyDataset
    ds = FramesLazyDataset(root=args.feat_root, seq_len=cfg.K, predict="current", mmap=cfg.mmap, target=args.target, in_memory=bool(args.preload))
    dl = DataLoader(
        ds,
        batch_size=cfg.batch_size,
        shuffle=False,
        num_workers=int(args.workers),
        pin_memory=True,
        persistent_workers=(int(args.workers) > 0),
        prefetch_factor=(args.prefetch if int(args.workers) > 0 else None),
    )
    print(
        "eval_samples: " + str(len(ds)) +
        " K: " + str(cfg.K) +
        " Din: " + str(cfg.Din) +
        " device: " + str(device)
    )

    # Set backend before import
    os.environ["QUANT_BACKEND"] = args.quant_backend
    # no env toggles for model config; pass explicitly to constructor
    from .mamba_regressor import MambaRegressor  # delayed import

    # Read arch toggles from ckpt if available to avoid mismatch with training
    arch = {}
    if ckpt_obj is not None and isinstance(ckpt_obj, dict):
        arch = ckpt_obj.get("arch", {}) or {}
    pe_off = bool(arch.get("pe_off", args.pe_off))
    pe_scale = float(arch.get("pe_scale", args.pe_scale))
    gate_off = bool(arch.get("gate_off", args.gate_off))
    agg_pool = str(arch.get("agg_pool", args.agg_pool))
    use_dwconv = bool(arch.get("use_dwconv", args.use_dwconv))

    model = MambaRegressor(
        Din=cfg.Din,
        K=cfg.K,
        proj_dim=cfg.proj_dim,
        d_model=cfg.d_model,
        n_layer=cfg.n_layer,
        patch_len=cfg.patch_len,
        stride=cfg.stride,
        pe_off=pe_off,
        pe_scale=pe_scale,
        gate_off=gate_off,
        agg_pool=agg_pool,
        use_dwconv=use_dwconv,
        # Quantization toggles from CLI
        quantize_all=bool(args.quantize_all),
        q_proj_head=bool(args.q_proj_head),
        q_block_linear=bool(args.q_block_linear),
        q_backbone_linear=bool(args.q_backbone_linear),
        quant_backend=str(args.quant_backend),
    ).to(device)

    if ckpt_obj is not None:
        sd = ckpt_obj.get("state_dict", ckpt_obj)
        model.load_state_dict(sd, strict=False)

    loss_fn = HuberEPE(delta=1.0)
    show = (args.progress or (not args.no_progress))
    ev_loss, stats = evaluate(model, dl, device, loss_fn, show_progress=show) #type: ignore
    print(f"eval_loss: {ev_loss}, stats: {stats}")

    # Full-dataset prediction pass for plots and detailed outputs
    Path(args.out_dir).mkdir(parents=True, exist_ok=True)
    model.eval()
    y_true_list = []
    y_pred_list = []
    with torch.no_grad():
        for xb, yb in dl:
            xb = xb.to(device, non_blocking=True).float()
            yb = yb.squeeze(1).to(device, non_blocking=True).float()
            pred = model(xb)
            y_true_list.append(yb.detach().cpu().numpy())
            y_pred_list.append(pred.detach().cpu().numpy())
    if y_true_list:
        y_true = np.concatenate(y_true_list, axis=0)
        y_pred = np.concatenate(y_pred_list, axis=0)
        err = np.sqrt(np.sum((y_pred - y_true) ** 2, axis=1))
        mean = float(err.mean()); median = float(np.median(err))
        p80 = float(np.percentile(err, 80)); p90 = float(np.percentile(err, 90))

        # Save npz
        np.savez(os.path.join(args.out_dir, 'val_preds.npz'), y_true=y_true, y_pred=y_pred, err=err,
                 mean=np.float32(mean), median=np.float32(median), p80=np.float32(p80), p90=np.float32(p90))
        # Optional CSV
        if args.save_csv:
            import csv
            with open(os.path.join(args.out_dir, 'pred_vs_true.csv'), 'w', newline='') as f:
                w = csv.writer(f); w.writerow(['y_true_x','y_true_y','y_pred_x','y_pred_y','err_m'])
                for (yt, yp, e_) in zip(y_true, y_pred, err):
                    w.writerow([yt[0], yt[1], yp[0], yp[1], e_])

        # Plots: CDF zoom, CDF full, error hist, trajectory
        e_sorted = np.sort(err); ycdf = np.arange(1, len(e_sorted) + 1) / len(e_sorted)
        plt.figure(figsize=(5,4), dpi=160)
        plt.plot(e_sorted, ycdf); plt.xlim(0, 0.5); plt.xticks(np.arange(0, 0.51, 0.05))
        plt.grid(True, linestyle='--', linewidth=0.5); plt.xlabel('Position error (m)'); plt.ylabel('CDF'); plt.title('Error CDF (0-0.5 m)')
        plt.tight_layout(); plt.savefig(os.path.join(args.out_dir, 'cdf_zoom.png')); plt.close()

        plt.figure(figsize=(5,4), dpi=160)
        plt.plot(e_sorted, ycdf)
        xticks = list(np.arange(0, 0.41, 0.10)) + list(np.arange(0, 2.1, 0.2))
        plt.xticks(xticks); plt.grid(True, linestyle='--', linewidth=0.5)
        plt.xlabel('Position error (m)'); plt.ylabel('CDF'); plt.title('Error CDF')
        plt.tight_layout(); plt.savefig(os.path.join(args.out_dir, 'cdf.png')); plt.close()

        plt.figure(figsize=(5,4), dpi=160)
        plt.hist(err, bins=50); plt.grid(True, linestyle='--', linewidth=0.5)
        plt.xlabel('Position error (m)'); plt.ylabel('Count'); plt.title('Error histogram')
        plt.tight_layout(); plt.savefig(os.path.join(args.out_dir, 'err_hist.png')); plt.close()


        #cmap = make_truncated_cmap(base='turbo', lo=0.10, hi=0.95)

        # True vs Predicted trajectory plot (SVG hybrid output) with broken true line across grids
        plt.figure(figsize=(7.5, 6.5))
        plt.title('True vs Predicted Positions')
        # ---- True trajectory (vector), break on large spatial jumps ----
        thr = float(max(0.0, args.break_thresh))
        if len(y_true) > 1:
            start = 0
            for i in range(1, len(y_true)):
                if np.linalg.norm(y_true[i] - y_true[i-1]) > thr:
                    if i - start > 1:
                        plt.plot(y_true[start:i,0], y_true[start:i,1], color='blue', linewidth=0.4, label='True Trajectory' if start == 0 else None, zorder=3)
                    start = i
            if len(y_true) - start > 1:
                plt.plot(y_true[start:,0], y_true[start:,1], color='blue', linewidth=0.4, label=None if start > 0 else 'True Trajectory', zorder=3)

        # ---- Predicted points (rasterized) ----
        sc = plt.scatter(y_pred[:,0], y_pred[:,1], c=err, cmap='plasma', s=0.7, alpha=0.65, edgecolors='none', rasterized=True, zorder=2)
        #sc = plt.scatter(y_pred[:,0], y_pred[:,1], c=np.arange(len(y_pred)), cmap=cmap, s=0.3, alpha=0.65, edgecolors='none', rasterized=True, zorder=2)
        cb = plt.colorbar(sc); cb.set_label('Frame index')
        plt.xlabel('X'); plt.ylabel('Y'); plt.grid(True, linestyle='--', linewidth=0.2); plt.axis('equal'); plt.legend()
        # ---- Export SVG (vector + raster mix) ----
        plt.tight_layout(); plt.savefig(os.path.join(args.out_dir, 'pred_vs_true.svg'),bbox_inches='tight',pad_inches=0.01,dpi=300); plt.close()


if __name__ == "__main__":
    main()
