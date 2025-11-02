import os
import argparse
import time
from pathlib import Path
import numpy as np
import torch
from torch.utils.data import DataLoader
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from tqdm import tqdm

from ..train import TrainConfig, set_seed
from ...datasets.frames_lazy import FramesLazyDataset
import glob


def euclid_err(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    return np.sqrt(np.sum((a - b) ** 2, axis=1))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--eval_root", type=str, required=True)
    p.add_argument("--ckpt", type=str, default="best_epe_mean.pt")
    p.add_argument("--out_dir", type=str, default="./test_out")

    # model dims (will be overridden by ckpt if present)
    p.add_argument("--Din", type=int, default=int(os.environ.get("DIN", 2100)))
    p.add_argument("--K", type=int, default=int(os.environ.get("K", 12)))
    p.add_argument("--proj_dim", type=int, default=64)
    p.add_argument("--d_model", type=int, default=96)
    p.add_argument("--n_layer", type=int, default=3)
    p.add_argument("--patch_len", type=int, default=8)
    p.add_argument("--stride", type=int, default=4)

    p.add_argument("--batch_size", type=int, default=64)
    p.add_argument("--workers", type=int, default=4)
    p.add_argument("--amp", action="store_true")
    p.add_argument("--dont_save_csv", action="store_true")
    p.add_argument("--target", type=str, default="auto", choices=["auto","train","eval"], help="which indices to use if present in JSON")

    # quantization toggles
    p.add_argument("--quant_backend", type=str, choices=["cpp", "python"], default=os.environ.get("QUANT_BACKEND", "python"))
    p.add_argument("--quantize_all", action="store_true")
    p.add_argument("--use_dwconv", action="store_true")

    # live histogram
    p.add_argument("--live_bins", type=int, default=100)
    p.add_argument("--live_max_err", type=float, default=1.0)
    p.add_argument("--live_every", type=int, default=1)
    # SSM/PE/AGG knobs
    p.add_argument("--pe_off", action="store_true")
    p.add_argument("--pe_scale", type=float, default=1.0)
    p.add_argument("--gate_off", action="store_true")
    p.add_argument("--agg_pool", type=str, default="", choices=["", "avg", "max"])
    args = p.parse_args()

    set_seed(42)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    Path(args.out_dir).mkdir(parents=True, exist_ok=True)

    # dims from ckpt
    dims = {"Din": args.Din, "K": args.K, "proj_dim": args.proj_dim, "d_model": args.d_model,
            "n_layer": args.n_layer, "patch_len": args.patch_len, "stride": args.stride}
    ckpt_obj = None
    if os.path.exists(args.ckpt):
        try:
            ckpt_obj = torch.load(args.ckpt, map_location="cpu")
            ck_cfg = ckpt_obj.get("cfg", None)
            if isinstance(ck_cfg, dict):
                for k in dims.keys():
                    if k in ck_cfg:
                        dims[k] = int(ck_cfg[k]) if isinstance(ck_cfg[k], (int,)) else ck_cfg[k]
                print({"eval_dims_from_ckpt": True, **dims})
        except Exception as e:
            print({"ckpt_load": f"warn: {e}"})

    cfg = TrainConfig(
        Din=int(dims["Din"]), K=int(dims["K"]), proj_dim=int(dims["proj_dim"]), d_model=int(dims["d_model"]),
        n_layer=int(dims["n_layer"]), patch_len=int(dims["patch_len"]), stride=int(dims["stride"]),
        batch_size=args.batch_size, train_root=args.eval_root, eval_root=None,
    )
    # backend toggles
    os.environ["QUANT_BACKEND"] = args.quant_backend
    if args.quantize_all: os.environ["QUANTIZE_ALL"] = "1"
    if args.use_dwconv: os.environ["USE_DWCONV"] = "1"
    from ..mamba_regressor import MambaRegressor

    # helper to evaluate a single directory and save plots under a sub-outdir
    def eval_dir(dir_path: str, out_dir: str):
        ds_cfg = TrainConfig(Din=cfg.Din, K=cfg.K, proj_dim=cfg.proj_dim, d_model=cfg.d_model,
                             n_layer=cfg.n_layer, patch_len=cfg.patch_len, stride=cfg.stride,
                             batch_size=args.batch_size, train_root=dir_path, eval_root=None)
        # Build dataset directly to honor --target selection
        ds = FramesLazyDataset(root=dir_path, seq_len=cfg.K, predict="current", mmap=True, target=args.target)
        dl = DataLoader(ds, batch_size=args.batch_size, shuffle=False, num_workers=args.workers, pin_memory=True,
                        persistent_workers=(args.workers>0), prefetch_factor=(2 if args.workers>0 else None))
        Path(out_dir).mkdir(parents=True, exist_ok=True)
        print({"eval_samples": len(ds), "root": dir_path, "out": out_dir, "device": str(device)})

        model = MambaRegressor(Din=cfg.Din, K=cfg.K, proj_dim=cfg.proj_dim, d_model=cfg.d_model,
                               n_layer=cfg.n_layer, patch_len=cfg.patch_len, stride=cfg.stride,
                               pe_off=args.pe_off, pe_scale=args.pe_scale, gate_off=args.gate_off, agg_pool=args.agg_pool).to(device)
        if ckpt_obj is not None:
            sd = ckpt_obj.get("state_dict", ckpt_obj)
            model.load_state_dict(sd, strict=False)
        model.eval()

        nbins = int(args.live_bins)
        emax = float(args.live_max_err)
        bins = np.linspace(0.0, emax, nbins + 1)
        counts = np.zeros(nbins, dtype=np.int64)

        def _update_hist(vals: np.ndarray):
            hist, _ = np.histogram(vals, bins=bins)
            counts[:] += hist

        def _approx_percentile(p: float) -> float:
            target = p / 100.0 * counts.sum()
            csum = np.cumsum(counts)
            idx = np.searchsorted(csum, target)
            if idx <= 0: return float(bins[1])
            if idx >= nbins: return float(bins[-1])
            left_c = csum[idx-1]; right_c = csum[idx]
            frac = 0.0 if right_c == left_c else (target - left_c) / (right_c - left_c)
            return float(bins[idx] + frac * (bins[idx+1] - bins[idx]))

        y_true, y_pred = [], []
        run_mean, run_n, run_max = 0.0, 0, 0.0
        ema_batch, ema_alpha = None, 0.2
        from contextlib import nullcontext
        def Autocast():
            return torch.cuda.amp.autocast() if (args.amp and torch.cuda.is_available()) else nullcontext()

        t0 = time.perf_counter()
        with torch.inference_mode():
            pbar = tqdm(enumerate(dl, 1), total=len(dl), ncols=130, desc=f"eval:{os.path.basename(dir_path)}")
            for i, (xb, yb) in pbar:
                xb = xb.to(device, non_blocking=True).float()
                yb = yb.squeeze(1).to(device, non_blocking=True).float()
                with Autocast():
                    yhat = model(xb)
                err_gpu = torch.linalg.vector_norm(yhat - yb, ord=2, dim=1)
                err = err_gpu.detach().cpu().numpy()

                y_true.append(yb.detach().cpu().numpy())
                y_pred.append(yhat.detach().cpu().numpy())

                bcnt = int(err.size)
                if bcnt > 0:
                    bsum = float(err.sum())
                    run_n += bcnt
                    run_mean += (bsum - bcnt * run_mean) / run_n
                    run_max = max(run_max, float(np.max(err)))
                    _update_hist(err)
                    bmean = float(err.mean())
                    ema_batch = bmean if (ema_batch is None) else (ema_alpha * bmean + (1 - ema_alpha) * ema_batch)

                if i % max(1, int(args.live_every)) == 0:
                    p50 = _approx_percentile(50.0) if run_n > 0 else 0.0
                    p80 = _approx_percentile(80.0) if run_n > 0 else 0.0
                    elapsed = max(1e-6, time.perf_counter() - t0)
                    ips = run_n / elapsed
                    pbar.set_postfix(batch=f"{(ema_batch or 0.0):.3f}", mean=f"{run_mean:.3f}", p50=f"{p50:.3f}", p80=f"{p80:.3f}", max=f"{run_max:.2f}", ips=f"{ips:.1f}")

        y_true_a = np.concatenate(y_true, axis=0)
        y_pred_a = np.concatenate(y_pred, axis=0)
        err = euclid_err(y_pred_a, y_true_a)
        mean = float(err.mean()); median = float(np.median(err))
        p80 = float(np.percentile(err, 80)); p90 = float(np.percentile(err, 90))
        print(f"[STATS:{os.path.basename(dir_path)}] N={len(err)}  mean={mean:.4f} m  median={median:.4f} m  P80={p80:.4f} m  P90={p90:.4f} m")

        e_sorted = np.sort(err)
        ycdf = np.arange(1, len(e_sorted) + 1) / len(e_sorted)
        plt.figure(figsize=(5,4), dpi=160)
        plt.plot(e_sorted, ycdf); plt.xlim(0, 0.5); plt.xticks(np.arange(0, 0.51, 0.05))
        plt.grid(True, linestyle='--', linewidth=0.5); plt.xlabel('Position error (m)'); plt.ylabel('CDF'); plt.title('Error CDF (0-0.5 m)')
        plt.tight_layout(); plt.savefig(os.path.join(out_dir, 'cdf_zoom.png')); plt.close()

        plt.figure(figsize=(5,4), dpi=160)
        plt.plot(e_sorted, ycdf)
        xticks = list(np.arange(0, 0.41, 0.10)) + list(np.arange(0, 2.1, 0.2))
        plt.xticks(xticks); plt.grid(True, linestyle='--', linewidth=0.5)
        plt.xlabel('Position error (m)'); plt.ylabel('CDF'); plt.title('Error CDF')
        plt.tight_layout(); plt.savefig(os.path.join(out_dir, 'cdf.png')); plt.close()

        plt.figure(figsize=(5,4), dpi=160)
        plt.hist(err, bins=50); plt.grid(True, linestyle='--', linewidth=0.5)
        plt.xlabel('Position error (m)'); plt.ylabel('Count'); plt.title('Error histogram')
        plt.tight_layout(); plt.savefig(os.path.join(out_dir, 'err_hist.png')); plt.close()

        # True vs Predicted trajectory plot (always saved)
        plt.figure(figsize=(6,5), dpi=160)
        plt.title('True vs Predicted Positions')
        plt.plot(y_true_a[:,0], y_true_a[:,1], 'b-', linewidth=1.5, label='True Trajectory')
        sc = plt.scatter(y_pred_a[:,0], y_pred_a[:,1], c=np.arange(len(y_pred_a)), cmap='plasma', s=2, alpha=0.8, label='Predicted')
        cb = plt.colorbar(sc); cb.set_label('Frame index')
        plt.xlabel('X'); plt.ylabel('Y'); plt.grid(True, linestyle='--', linewidth=0.5); plt.axis('equal'); plt.legend()
        plt.tight_layout(); plt.savefig(os.path.join(out_dir, 'pred_vs_true.png')); plt.close()

        np.savez(os.path.join(out_dir, 'val_preds.npz'), y_true=y_true_a, y_pred=y_pred_a, err=err,
                 mean=np.float32(mean), median=np.float32(median), p80=np.float32(p80), p90=np.float32(p90))
        if not args.dont_save_csv:
            import csv
            with open(os.path.join(out_dir, 'pred_vs_true.csv'), 'w', newline='') as f:
                w = csv.writer(f); w.writerow(['y_true_x','y_true_y','y_pred_x','y_pred_y','err_m'])
                for (yt, yp, e_) in zip(y_true_a, y_pred_a, err):
                    w.writerow([yt[0], yt[1], yp[0], yp[1], e_])

        md = ["| Metric | Value (m) |", "|--------|-----------|",
              f"| Mean   | {mean:.4f} |", f"| Median | {median:.4f} |",
              f"| P80    | {p80:.4f} |", f"| P90    | {p90:.4f} |",
              f"| Max    | {err.max():.4f} |"]
        print("\n[SUMMARY]" , os.path.basename(dir_path), "\n" + "\n".join(md) + "\n")
        print(f"[OK] saved plots & stats under {out_dir}")
        return {
            "name": os.path.basename(dir_path),
            "count": int(len(err)),
            "mean": float(mean),
            "median": float(median),
            "p80": float(p80),
            "p90": float(p90),
            "out_dir": out_dir,
        }

    # mode A: per-subdir (if subdirs with .feats.npy exist)
    subdirs = [d.path for d in os.scandir(args.eval_root) if d.is_dir() and any(fn.lower().endswith('.feats.npy') for fn in os.listdir(d.path))]
    summary: list[dict] = []
    if subdirs:
        print({"grids": len(subdirs), "mode": "per-subdir"})
        for sd in sorted(subdirs):
            out_sub = os.path.join(args.out_dir, os.path.basename(sd))
            rec = eval_dir(sd, out_sub)
            summary.append(rec)
        # after all, write ranking
        summary.sort(key=lambda r: r["mean"])  # ascending mean error
        txt = os.path.join(args.out_dir, "eval_out.txt")
        csv_path = os.path.join(args.out_dir, "eval_summary.csv")
        with open(txt, "w", encoding="utf-8") as f:
            f.write("# Mean error ranking (per grid)\n")
            f.write("rank,name,count,mean,median,p80,p90,out_dir\n")
            for i, r in enumerate(summary, 1):
                f.write(f"{i},{r['name']},{r['count']},{r['mean']:.6f},{r['median']:.6f},{r['p80']:.6f},{r['p90']:.6f},{r['out_dir']}\n")
        with open(csv_path, "w", encoding="utf-8") as f:
            f.write("rank,name,count,mean,median,p80,p90,out_dir\n")
            for i, r in enumerate(summary, 1):
                f.write(f"{i},{r['name']},{r['count']},{r['mean']:.6f},{r['median']:.6f},{r['p80']:.6f},{r['p90']:.6f},{r['out_dir']}\n")
        print({"summary": txt, "csv": csv_path})
        return

    # mode B: per-file (all .feats.npy under one folder) — create one output folder per file stem
    npz_files = sorted([p for p in glob.glob(os.path.join(args.eval_root, '*.feats.npy'))])
    if npz_files:
        print({"files": len(npz_files), "mode": "per-file"})
        # build a common model once to reduce overhead? Keep per-file new model to mirror old exact behavior
        for f in npz_files:
            stem = os.path.splitext(os.path.basename(f))[0]
            out_sub = os.path.join(args.out_dir, stem)
            # dataset for single file with correct stats root (parent of eval_root)
            ds = FramesLazyDataset.from_filelist([f], seq_len=cfg.K, predict="current", mmap=True, stats_root=Path(args.eval_root).parent, target=args.target)
            dl = DataLoader(ds, batch_size=args.batch_size, shuffle=False, num_workers=args.workers, pin_memory=True,
                            persistent_workers=(args.workers>0), prefetch_factor=(2 if args.workers>0 else None))
            Path(out_sub).mkdir(parents=True, exist_ok=True)
            print({"eval_samples": len(ds), "file": os.path.basename(f), "out": out_sub, "device": str(device)})

            model = MambaRegressor(Din=cfg.Din, K=cfg.K, proj_dim=cfg.proj_dim, d_model=cfg.d_model,
                                   n_layer=cfg.n_layer, patch_len=cfg.patch_len, stride=cfg.stride,
                                   pe_off=args.pe_off, pe_scale=args.pe_scale, gate_off=args.gate_off, agg_pool=args.agg_pool).to(device)
            if ckpt_obj is not None:
                sd = ckpt_obj.get("state_dict", ckpt_obj)
                model.load_state_dict(sd, strict=False)
            model.eval()

            nbins = int(args.live_bins)
            emax = float(args.live_max_err)
            bins = np.linspace(0.0, emax, nbins + 1)
            counts = np.zeros(nbins, dtype=np.int64)
            def _update_hist(vals: np.ndarray):
                hist, _ = np.histogram(vals, bins=bins)
                counts[:] += hist
            def _approx_percentile(p: float) -> float:
                target = p / 100.0 * counts.sum()
                csum = np.cumsum(counts)
                idx = np.searchsorted(csum, target)
                if idx <= 0: return float(bins[1])
                if idx >= nbins: return float(bins[-1])
                left_c = csum[idx-1]; right_c = csum[idx]
                frac = 0.0 if right_c == left_c else (target - left_c) / (right_c - left_c)
                return float(bins[idx] + frac * (bins[idx+1] - bins[idx]))

            y_true, y_pred = [], []
            run_mean, run_n, run_max = 0.0, 0, 0.0
            ema_batch, ema_alpha = None, 0.2
            from contextlib import nullcontext
            def Autocast():
                return torch.cuda.amp.autocast() if (args.amp and torch.cuda.is_available()) else nullcontext()
            t0 = time.perf_counter()
            with torch.inference_mode():
                pbar = tqdm(enumerate(dl, 1), total=len(dl), ncols=130, desc=f"eval:{stem}")
                for i, (xb, yb) in pbar:
                    xb = xb.to(device, non_blocking=True).float()
                    yb = yb.squeeze(1).to(device, non_blocking=True).float()
                    with Autocast():
                        yhat = model(xb)
                    err_gpu = torch.linalg.vector_norm(yhat - yb, ord=2, dim=1)
                    err = err_gpu.detach().cpu().numpy()
                    y_true.append(yb.detach().cpu().numpy())
                    y_pred.append(yhat.detach().cpu().numpy())
                    bcnt = int(err.size)
                    if bcnt > 0:
                        bsum = float(err.sum())
                        run_n += bcnt
                        run_mean += (bsum - bcnt * run_mean) / run_n
                        run_max = max(run_max, float(np.max(err)))
                        _update_hist(err)
                        bmean = float(err.mean())
                        ema_batch = bmean if (ema_batch is None) else (ema_alpha * bmean + (1 - ema_alpha) * ema_batch)
                    if i % max(1, int(args.live_every)) == 0:
                        p50 = _approx_percentile(50.0) if run_n > 0 else 0.0
                        p80 = _approx_percentile(80.0) if run_n > 0 else 0.0
                        elapsed = max(1e-6, time.perf_counter() - t0)
                        ips = run_n / elapsed
                        pbar.set_postfix(batch=f"{(ema_batch or 0.0):.3f}", mean=f"{run_mean:.3f}", p50=f"{p50:.3f}", p80=f"{p80:.3f}", max=f"{run_max:.2f}", ips=f"{ips:.1f}")

            y_true_a = np.concatenate(y_true, axis=0)
            y_pred_a = np.concatenate(y_pred, axis=0)
            err = euclid_err(y_pred_a, y_true_a)
            mean = float(err.mean()); median = float(np.median(err))
            p80 = float(np.percentile(err, 80)); p90 = float(np.percentile(err, 90))
            print(f"[STATS:{stem}] N={len(err)}  mean={mean:.4f} m  median={median:.4f} m  P80={p80:.4f} m  P90={p90:.4f} m")

            e_sorted = np.sort(err)
            ycdf = np.arange(1, len(e_sorted) + 1) / len(e_sorted)
            plt.figure(figsize=(5,4), dpi=160)
            plt.plot(e_sorted, ycdf); plt.xlim(0, 0.5); plt.xticks(np.arange(0, 0.51, 0.05))
            plt.grid(True, linestyle='--', linewidth=0.5); plt.xlabel('Position error (m)'); plt.ylabel('CDF'); plt.title('Error CDF (0-0.5 m)')
            plt.tight_layout(); plt.savefig(os.path.join(out_sub, 'cdf_zoom.png')); plt.close()

            plt.figure(figsize=(5,4), dpi=160)
            plt.plot(e_sorted, ycdf)
            xticks = list(np.arange(0, 0.41, 0.10)) + list(np.arange(0, 2.1, 0.2))
            plt.xticks(xticks); plt.grid(True, linestyle='--', linewidth=0.5)
            plt.xlabel('Position error (m)'); plt.ylabel('CDF'); plt.title('Error CDF')
            plt.tight_layout(); plt.savefig(os.path.join(out_sub, 'cdf.png')); plt.close()

            plt.figure(figsize=(5,4), dpi=160)
            plt.hist(err, bins=50); plt.grid(True, linestyle='--', linewidth=0.5)
            plt.xlabel('Position error (m)'); plt.ylabel('Count'); plt.title('Error histogram')
            plt.tight_layout(); plt.savefig(os.path.join(out_sub, 'err_hist.png')); plt.close()

            np.savez(os.path.join(out_sub, 'val_preds.feats.npy'), y_true=y_true_a, y_pred=y_pred_a, err=err,
                     mean=np.float32(mean), median=np.float32(median), p80=np.float32(p80), p90=np.float32(p90))
            if not args.dont_save_csv:
                import csv
                with open(os.path.join(out_sub, 'pred_vs_true.csv'), 'w', newline='') as f:
                    w = csv.writer(f); w.writerow(['y_true_x','y_true_y','y_pred_x','y_pred_y','err_m'])
                    for (yt, yp, e_) in zip(y_true_a, y_pred_a, err):
                        w.writerow([yt[0], yt[1], yp[0], yp[1], e_])
            summary.append({
                "name": stem,
                "count": int(len(err)),
                "mean": float(mean),
                "median": float(median),
                "p80": float(p80),
                "p90": float(p90),
                "out_dir": out_sub,
            })
        # write ranking summary
        summary.sort(key=lambda r: r["mean"])  # ascending
        txt = os.path.join(args.out_dir, "eval_out.txt")
        csv_path = os.path.join(args.out_dir, "eval_summary.csv")
        with open(txt, "w", encoding="utf-8") as f:
            f.write("# Mean error ranking (per file)\n")
            f.write("rank,name,count,mean,median,p80,p90,out_dir\n")
            for i, r in enumerate(summary, 1):
                f.write(f"{i},{r['name']},{r['count']},{r['mean']:.6f},{r['median']:.6f},{r['p80']:.6f},{r['p90']:.6f},{r['out_dir']}\n")
        with open(csv_path, "w", encoding="utf-8") as f:
            f.write("rank,name,count,mean,median,p80,p90,out_dir\n")
            for i, r in enumerate(summary, 1):
                f.write(f"{i},{r['name']},{r['count']},{r['mean']:.6f},{r['median']:.6f},{r['p80']:.6f},{r['p90']:.6f},{r['out_dir']}\n")
        print({"summary": txt, "csv": csv_path})
        return

    # fallback: no subdirs and no files matched, evaluate root (should not happen)
    eval_dir(args.eval_root, args.out_dir)


if __name__ == "__main__":
    main()
