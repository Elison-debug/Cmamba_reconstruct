import os
import argparse
import time
from pathlib import Path
import json
import numpy as np
import torch
from torch.utils.data import DataLoader
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from tqdm import tqdm
from .heatmap import plot_error_heatmaps
from ..eval import make_truncated_cmap
from ..train import TrainConfig, set_seed
from ...datasets.frames_lazy import FramesLazyDataset
import glob


def euclid_err(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    return np.sqrt(np.sum((a - b) ** 2, axis=1))

cmap = make_truncated_cmap(base='turbo', lo=0.10, hi=0.95)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--feat_root", type=str, default="./data/features/logo")
    p.add_argument("--ckpt", type=str, default="ckpt_refactor/logo/best_epe_mean.pt")
    p.add_argument("--out_dir", type=str, default="./test_out")
    p.add_argument("--break_thresh", type=float, default=0.05, help="break true line when jump exceeds this distance (m)")
    p.add_argument("--batch_size", type=int, default=64)
    p.add_argument("--workers", type=int, default=4)
    p.add_argument("--dont_save_csv", action="store_true")
    p.add_argument("--target", type=str, default="eval", choices=["auto","train","eval","test"], help="which indices to use if present in JSON")
    p.add_argument("--preload", action="store_true", help="preload all arrays into RAM (set workers=0/1)")
    # Diagnostic Mapping Parameters
    p.add_argument("--live_bins", type=int, default=100)
    p.add_argument("--live_max_err", type=float, default=1.0)
    p.add_argument("--live_every", type=int, default=1)
    args = p.parse_args()

    set_seed(42)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    Path(args.out_dir).mkdir(parents=True, exist_ok=True)

    # Read dims from ckpt cfg if present
    dims = {"Din": None, "K": None, "proj_dim": None, "d_model": None,
            "n_layer": None, "patch_len": None, "stride": None}
    ckpt_obj = None
    if os.path.exists(args.ckpt):
        try:
            ckpt_obj = torch.load(args.ckpt, map_location="cpu")
            ck_cfg = ckpt_obj.get("cfg", None)
            if isinstance(ck_cfg, dict):
                for k in dims.keys():
                    if k in ck_cfg:
                        dims[k] = int(ck_cfg[k]) if isinstance(ck_cfg[k], (int,)) else ck_cfg[k] # type: ignore
                print({"test_dims_from_ckpt": True, **dims})
        except Exception as e:
            print({"ckpt_load": f"warn: {e}"})

    # The ckpt must exist; otherwise, the model dimension cannot be determined.
    if not all(v is not None for v in dims.values()):
        raise RuntimeError("Checkpoint is required and must contain cfg with dims (Din,K,proj_dim,d_model,n_layer,patch_len,stride)")
    assert dims["Din"] and dims["K"] and dims["proj_dim"] and dims["d_model"] and dims["n_layer"] and dims["patch_len"] and dims["stride"] is not None
    try:
        cfg = TrainConfig(
            Din=int(dims["Din"]), K=int(dims["K"]), proj_dim=int(dims["proj_dim"]), d_model=int(dims["d_model"]),
            n_layer=int(dims["n_layer"]), patch_len=int(dims["patch_len"]), stride=int(dims["stride"]),
            batch_size=args.batch_size, feat_root=args.feat_root,
        )
    except Exception as e:
            print({"cfg_load": f"warn: {e}"})
    # backend toggles (will prefer ckpt arch if present)
    from ..mamba_regressor import MambaRegressor

    # Build per-file evaluation using a shared dataset + per-file subsets
    summary: list[dict] = []
    js = Path(args.feat_root) / 'json'
    json_files = sorted(js.glob('*.json'))
    if json_files:
        print({"files": len(json_files), "mode": "per-file"})
        stats_root = Path(args.feat_root)
        ds_all = FramesLazyDataset(root=args.feat_root, seq_len=cfg.K, predict="current", mmap=True, stats_root=stats_root, target=args.target, in_memory=bool(args.preload))
        base_to_fi = { ds_all.entries[i]["base"]: i for i in range(len(ds_all.entries)) }
        for jp in json_files:
            stem = jp.stem
            if stem not in base_to_fi:
                continue
            out_sub = os.path.join(args.out_dir, stem)
            fi_target = int(base_to_fi[stem])
            sel_idx = [k for k,(fi,_,_) in enumerate(ds_all.index) if fi == fi_target]
            if not sel_idx:
                continue
            from torch.utils.data import Subset
            ds = Subset(ds_all, sel_idx)
            dl = DataLoader(ds, batch_size=args.batch_size, shuffle=False, num_workers=args.workers, pin_memory=True,
                            persistent_workers=(args.workers>0), prefetch_factor=(2 if args.workers>0 else None))
            Path(out_sub).mkdir(parents=True, exist_ok=True)
            print({"eval_samples": len(sel_idx), "file": stem, "out": out_sub, "device": str(device)})

            # Read arch toggles from ckpt to avoid mismatch
            arch = {}
            if ckpt_obj is not None and isinstance(ckpt_obj, dict):
                arch = ckpt_obj.get("arch", {}) or {}
            # Resolve effective quant config from ckpt arch (preferred)
            eff_quant_backend = str(arch.get("quant_backend", "python"))
            eff_quantize_all = bool(arch.get("quantize_all", False))
            eff_q_proj = bool(arch.get("q_proj"))
            eff_q_head = bool(arch.get("q_head"))
            eff_q_block_linear = bool(arch.get("q_block_linear", False))
            eff_q_backbone_linear = bool(arch.get("q_backbone_linear", False))
            eff_quant_bits = int(arch.get("quant_bits", 16))
            eff_quant_mode = str(arch.get("quant_mode", "dynamic"))
            quant_cfg = {
                "quant_backend": eff_quant_backend,
                "quantize_all": eff_quantize_all,
                "q_proj": eff_q_proj,
                "q_head": eff_q_head,
                "q_block_linear": eff_q_block_linear,
                "q_backbone_linear": eff_q_backbone_linear,
                "quant_bits": eff_quant_bits,
                "quant_mode": eff_quant_mode,
            }
            print({"quant_cfg": quant_cfg})
            os.environ["QUANT_BACKEND"] = eff_quant_backend

            # 其他结构开关也从 ckpt.arch 读取
            pe_off = bool(arch.get("pe_off", False))
            pe_scale = float(arch.get("pe_scale", 1.0))
            gate_off = bool(arch.get("gate_off", False))
            agg_pool = str(arch.get("agg_pool", ""))
            use_dwconv = bool(arch.get("use_dwconv", False))

            model = MambaRegressor(Din=cfg.Din, K=cfg.K, proj_dim=cfg.proj_dim, d_model=cfg.d_model,
                                   n_layer=cfg.n_layer, patch_len=cfg.patch_len, stride=cfg.stride,
                                   pe_off=pe_off, pe_scale=pe_scale, gate_off=gate_off, agg_pool=agg_pool,
                                   use_dwconv=use_dwconv,
                                   quantize_all=eff_quantize_all, q_proj=eff_q_proj, q_head=eff_q_head,
                                   q_block_linear=eff_q_block_linear, q_backbone_linear=eff_q_backbone_linear,
                                   quant_backend=eff_quant_backend, quant_bits=eff_quant_bits).to(device)
            # Diagnostic: pointwise kind and ckpt load status
            def _pointwise_kind(mod):
                try:
                    return "QConv1x1INT" if hasattr(mod, "qconv") else "Conv1d"
                except Exception:
                    return "unknown"
            print({
                "model_pointwise": {
                    "proj": _pointwise_kind(getattr(model, "proj", None)),
                    "head": _pointwise_kind(getattr(model, "head", None)),
                },
                "use_dwconv": bool(use_dwconv),
            })
            if ckpt_obj is not None:
                # 直接按导出结果加载（不做键名迁移）
                sd = ckpt_obj.get("state_dict", ckpt_obj)
                r = model.load_state_dict(sd, strict=False)
                try:
                    miss = list(getattr(r, "missing_keys", []))
                    unexp = list(getattr(r, "unexpected_keys", []))
                    print({
                        "ckpt_load": {"missing": len(miss), "unexpected": len(unexp),
                                       "missing_samp": miss[:5], "unexpected_samp": unexp[:5]}
                    })
                except Exception:
                    pass
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
            t0 = time.perf_counter()
            with torch.inference_mode():
                pbar = tqdm(enumerate(dl, 1), total=len(dl), ncols=130, desc=f"eval:{stem}")
                for i, (xb, yb) in pbar:
                    xb = xb.to(device, non_blocking=True).float()
                    yb = yb.squeeze(1).to(device, non_blocking=True).float()
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

            plot_error_heatmaps(y_true_a, y_pred_a, out_sub)

            # True vs Predicted trajectory plot (SVG hybrid output)
            plt.figure(figsize=(7.5, 6.5))
            plt.title('True vs Predicted Positions')
            # ---- True trajectory (vector) with breaks on large jumps ----
            try:
                N = int(y_true_a.shape[0])
                bt = float(max(0.0, args.break_thresh))
                breaks = np.zeros(N, dtype=bool)
                for i in range(1, N):
                    jump = float(np.linalg.norm(y_true_a[i] - y_true_a[i-1]))
                    if bt > 0.0 and jump > bt:
                        breaks[i] = True
                true_xy = y_true_a.copy().astype(np.float32)
                true_xy[breaks] = np.nan
                plt.plot(true_xy[:,0], true_xy[:,1], color='blue', linewidth=1, label='True Trajectory', zorder=3)
            except Exception:
                plt.plot(y_true_a[:,0], y_true_a[:,1], color='blue', linewidth=1, label='True Trajectory', zorder=3)

            # ---- Predicted points (rasterized) ----
            sc = plt.scatter(y_pred_a[:,0], y_pred_a[:,1],c=err,cmap='plasma',s=1, alpha=0.65,edgecolors='none',rasterized=True ,zorder=2)# scatter 栅格化
            #sc = plt.scatter(y_pred_a[:,0], y_pred_a[:,1],c=np.arange(len(y_pred_a)),cmap='plasma',s=0.3, alpha=0.65,edgecolors='none',rasterized=True ,zorder=2)# scatter 栅格化
            cb = plt.colorbar(sc); cb.set_label('Frame index')
            plt.xlabel('X'); plt.ylabel('Y'); plt.grid(True, linestyle='--', linewidth=0.2); plt.axis('equal'); plt.legend()
            # ---- Export SVG (vector + raster mix) ----
            plt.tight_layout(); plt.savefig(os.path.join(out_sub, 'pred_vs_true.svg'),bbox_inches='tight',pad_inches=0.01,dpi=300); plt.close()

            np.savez(os.path.join(out_sub, 'val_preds.npz'), y_true=y_true_a, y_pred=y_pred_a, err=err,
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
        csv_path = os.path.join(args.out_dir, "eval_summary.csv")
        with open(csv_path, "w", encoding="utf-8") as f:
            f.write("rank,name,count,mean,median,p80,p90,out_dir\n")
            for i, r in enumerate(summary, 1):
                f.write(f"{i},{r['name']},{r['count']},{r['mean']:.6f},{r['median']:.6f},{r['p80']:.6f},{r['p90']:.6f},{r['out_dir']}\n")
        print({"summary": csv_path})
        # write ranking summary even in per-file mode
        return

    print({"error": "no .json/.npy files found under feat_root", "feat_root": args.feat_root})


if __name__ == "__main__":
    main()
