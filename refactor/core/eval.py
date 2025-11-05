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
    # Quantization backend/bits (CLI can override ckpt; unset -> fallback to ckpt)
    p.add_argument("--quant_backend", type=str, choices=["cpp", "python"], default=None)
    # Tri-state toggles: --foo / --no-foo; default None -> fallback to ckpt
    g_all = p.add_mutually_exclusive_group()
    g_all.add_argument("--quantize_all", dest="quantize_all", action="store_true")
    g_all.add_argument("--no_quantize_all", dest="quantize_all", action="store_false")
    p.set_defaults(quantize_all=None)
    g_ph = p.add_mutually_exclusive_group()
    g_ph.add_argument("--q_proj_head", dest="q_proj_head", action="store_true")
    g_ph.add_argument("--no_q_proj_head", dest="q_proj_head", action="store_false")
    p.set_defaults(q_proj_head=None)
    g_bl = p.add_mutually_exclusive_group()
    g_bl.add_argument("--q_block_linear", dest="q_block_linear", action="store_true")
    g_bl.add_argument("--no_q_block_linear", dest="q_block_linear", action="store_false")
    p.set_defaults(q_block_linear=None)
    g_bb = p.add_mutually_exclusive_group()
    g_bb.add_argument("--q_backbone_linear", dest="q_backbone_linear", action="store_true")
    g_bb.add_argument("--no_q_backbone_linear", dest="q_backbone_linear", action="store_false")
    p.set_defaults(q_backbone_linear=None)
    # bits: 0 -> fallback to ckpt; otherwise validate later (8 or 16)
    p.add_argument("--quant_bits", type=int, default=0)
    p.add_argument("--use_dwconv", action="store_true")
    p.add_argument("--workers", type=int, default=4)
    p.add_argument("--prefetch", type=int, default=4)
    p.add_argument("--mmap_off", action="store_true")
    p.add_argument("--target", type=str, default="eval", choices=["auto","train","eval","test"], help="which indices to use")
    # fine-grained toggles configured above via tri-state groups
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
    # Quantization calibration (eval-time)
    p.add_argument("--quant_calib_batches", type=int, default=0, help="run N batches to calibrate quant scales before eval (0=all)")
    p.add_argument("--save_calib_ckpt", type=str, default="ckpt_refactor/logo_quant_head/calibrate_last.pt", help="path to save scale-initialized checkpoint after eval")
    p.add_argument("--dont_save_calib_ckpt", action="store_true")
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

    # Read arch toggles from ckpt if available to avoid mismatch with training
    arch = {}
    if ckpt_obj is not None and isinstance(ckpt_obj, dict):
        arch = ckpt_obj.get("arch", {}) or {}
    # Resolve effective quant config: CLI overrides when provided; otherwise fall back to ckpt arch
    eff_quant_backend = (args.quant_backend if args.quant_backend is not None else str(arch.get("quant_backend", "python")))
    def _res_bool(cli_val, key, default=False):
        return bool(cli_val) if cli_val is not None else bool(arch.get(key, default))
    eff_quantize_all = _res_bool(args.quantize_all, "quantize_all", False)
    eff_q_proj_head = _res_bool(args.q_proj_head, "q_proj_head", False)
    eff_q_block_linear = _res_bool(args.q_block_linear, "q_block_linear", False)
    eff_q_backbone_linear = _res_bool(args.q_backbone_linear, "q_backbone_linear", False)
    eff_quant_bits = int(args.quant_bits) if int(args.quant_bits) in (8,16) else int(arch.get("quant_bits", 8))
    quant_cfg = {
        "quant_backend": eff_quant_backend,
        "quantize_all": eff_quantize_all,
        "q_proj_head": eff_q_proj_head,
        "q_block_linear": eff_q_block_linear,
        "q_backbone_linear": eff_q_backbone_linear,
        "quant_bits": eff_quant_bits,
    }
    print({"quant_cfg": quant_cfg})

    # Set backend before import
    os.environ["QUANT_BACKEND"] = eff_quant_backend
    # no env toggles for model config; pass explicitly to constructor
    from .mamba_regressor import MambaRegressor  # delayed import

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
        # Quantization toggles (effective)
        quantize_all=eff_quantize_all,
        q_proj_head=eff_q_proj_head,
        q_block_linear=eff_q_block_linear,
        q_backbone_linear=eff_q_backbone_linear,
        quant_backend=eff_quant_backend,
        quant_bits=eff_quant_bits,
    ).to(device)
    # Diagnostic: summarize model pointwise impls
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
        "pe_off": bool(pe_off),
        "agg_pool": str(agg_pool),
    })

    if ckpt_obj is not None:
        sd = ckpt_obj.get("state_dict", ckpt_obj)
        r = model.load_state_dict(sd, strict=False)
        try:
            miss = list(getattr(r, "missing_keys", []))
            unexp = list(getattr(r, "unexpected_keys", []))
            print({
                "ckpt_load": {
                    "missing": len(miss),
                    "unexpected": len(unexp),
                    "missing_samp": miss[:5],
                    "unexpected_samp": unexp[:5],
                }
            })
        except Exception:
            pass

    # Optional: eval-time calibration of quant scales
    if int(args.quant_calib_batches) >= 0:
        def _collect_targets(modules_root):
            pairs = []
            for m in modules_root.modules():
                qc = getattr(m, "qconv", None)
                if qc is None:
                    continue
                if hasattr(qc, "qa") and hasattr(qc, "qw"):
                    pairs.append((m, qc, "python"))
                elif hasattr(qc, "impl"):
                    pairs.append((m, qc, "cpp"))
            return pairs

        targets = _collect_targets(model)
        cal_stats = { id(lin): {"sum_abs": 0.0, "count": 0} for (_, lin, _) in targets }
        handles = []
        def _prehook(mod, inputs):
            try:
                x = inputs[0]
                s = cal_stats.get(id(mod), None)
                if s is not None:
                    s["sum_abs"] += float(x.detach().abs().sum().item())
                    s["count"] += int(x.numel())
            except Exception:
                pass
            return None
        # register hooks on QConv1x1INT modules (the inner module referenced by parent.lin)
        for (_, lin, _) in targets:
            try:
                h = lin.register_forward_pre_hook(_prehook)
                handles.append(h)
            except Exception:
                pass
        # run N batches to accumulate activation stats
        nb = int(args.quant_calib_batches)
        model.eval()
        with torch.no_grad():
            for i, (xb, yb) in enumerate(dl, 1):
                xb = xb.to(device, non_blocking=True).float()
                _ = model(xb)
                if nb > 0 and i >= nb:
                    break
        # remove hooks
        for h in handles:
            try:
                h.remove()
            except Exception:
                pass
        # write back scales for activations and weights
        for (parent, lin, be) in targets:
            try:
                # activation scale: per-tensor symmetric, approx 2*mean(|x|)
                s = cal_stats.get(id(lin), None)
                if s and s["count"] > 0:
                    a_scale = max(1e-8, 2.0 * (s["sum_abs"] / s["count"]))
                if be == "python" and hasattr(lin, "qa") and hasattr(lin.qa, "scale") and lin.qa.scale is not None:
                    with torch.no_grad():
                        lin.qa.scale.data.fill_(float(a_scale))  # type: ignore
                elif be == "cpp" and hasattr(lin, "impl") and hasattr(lin.impl, "a_scale"):
                    with torch.no_grad():
                        lin.impl.a_scale.data.fill_(float(a_scale))
                # weight scale: per-out symmetric, approx 2*mean(|W|) along in_features
                W = lin.conv.weight.detach() if hasattr(lin, "conv") else None
                if W is not None:
                    w_mean = 2.0 * W.abs().mean(dim=1)  # (out_f,)
                    if be == "python" and hasattr(lin, "qw") and hasattr(lin.qw, "scale") and lin.qw.scale is not None:
                        ws = w_mean.view(-1, 1).to(lin.qw.scale.device, dtype=lin.qw.scale.dtype)
                        with torch.no_grad():
                            lin.qw.scale.data.copy_(ws)  # type: ignore
                    elif be == "cpp" and hasattr(lin, "impl") and hasattr(lin.impl, "w_scale"):
                        ws = w_mean.to(lin.impl.w_scale.device, dtype=lin.impl.w_scale.dtype)
                        if lin.impl.w_scale.numel() == ws.numel():
                            with torch.no_grad():
                                lin.impl.w_scale.data.copy_(ws)
            except Exception:
                pass

        # If ckpt contains LSQ scales (python backend) but current model uses cpp backend,
        # import those scales into cpp impl to preserve calibration.
        try:
            def _import_scales_from_lsq(sdict, pw_mod):
                if pw_mod is None or not hasattr(pw_mod, "qconv"):
                    return False
                lin = pw_mod.qconv
                if not hasattr(lin, "impl"):
                    return False
                impl = lin.impl
                changed = False
                # activation scale (per-tensor)
                a_key = None
                w_key = None
                # find relative name by probing known prefixes
                # We call this function per proj/head with concrete keys outside.
                return False

            # Project/head mapping
            for name in ("proj", "head"):
                pw = getattr(model, name, None)
                if pw is None or not hasattr(pw, "qconv") or not hasattr(pw.qconv, "impl"):
                    continue
                impl = pw.qconv.impl
                a_key = f"{name}.qconv.qa.scale"
                w_key = f"{name}.qconv.qw.scale"
                if a_key in sd:
                    try:
                        a_sc = sd[a_key]
                        if isinstance(a_sc, torch.Tensor):
                            val = float(a_sc.detach().mean().abs().item())
                        else:
                            val = float(a_sc)
                        if hasattr(impl, "a_scale"):
                            with torch.no_grad():
                                impl.a_scale.data.fill_(max(1e-8, val))
                    except Exception:
                        pass
                if w_key in sd:
                    try:
                        w_sc = sd[w_key]
                        if isinstance(w_sc, torch.Tensor):
                            w_vec = w_sc.detach().view(-1).float().abs()
                        else:
                            w_vec = torch.as_tensor(w_sc).view(-1).float().abs()
                        if hasattr(impl, "w_scale") and impl.w_scale.numel() == w_vec.numel():
                            with torch.no_grad():
                                impl.w_scale.data.copy_(w_vec.view_as(impl.w_scale))
                    except Exception:
                        pass
        except Exception:
            pass

    # Diagnostic: quant param summary for proj/head
    def _qsummary(pw):
        try:
            if hasattr(pw, "lin"):
                lin = pw.lin
                if hasattr(lin, "impl"):  # cpp backend
                    impl = lin.impl
                    return {
                        "backend": "cpp",
                        "a_bits": int(getattr(impl, "a_bits", -1)),
                        "w_bits": int(getattr(impl, "w_bits", -1)),
                        "a_scale": float(getattr(impl, "a_scale", torch.tensor(0.0)).detach().abs().mean().item()) if hasattr(impl, "a_scale") else None,
                        "w_scale_shape": list(getattr(impl, "w_scale").shape) if hasattr(impl, "w_scale") else None,
                    }
                elif hasattr(lin, "qa") and hasattr(lin, "qw"):
                    qa = lin.qa; qw = lin.qw
                    sc = (None if getattr(qa, "scale", None) is None else qa.scale.detach().abs().mean().item())
                    return {
                        "backend": "python",
                        "a_bits": int(getattr(qa, "bits", -1)),
                        "w_bits": int(getattr(qw, "bits", -1)),
                        "a_scale_mean_abs": (float(sc) if sc is not None else None),
                        "w_scale_len": (int(qw.scale.numel()) if getattr(qw, "scale", None) is not None else None),
                    }
        except Exception:
            return {"error": "qsummary_failed"}
        return {"note": "not_quantized"}
    print({
        "q_proj": _qsummary(getattr(model, "proj", None)),
        "q_head": _qsummary(getattr(model, "head", None)),
    })

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

    # Save a scale-initialized checkpoint for deployment if requested
    if not bool(args.dont_save_calib_ckpt) and args.save_calib_ckpt:
        save_path = os.path.abspath(args.save_calib_ckpt)
        try:
            meta_arch = dict(arch)
            # ensure quant cfg fields are present
            meta_arch.update({
                "quant_backend": eff_quant_backend,
                "quantize_all": eff_quantize_all,
                "q_proj_head": eff_q_proj_head,
                "q_block_linear": eff_q_block_linear,
                "q_backbone_linear": eff_q_backbone_linear,
                "quant_bits": eff_quant_bits,
                "use_dwconv": bool(use_dwconv),
                "pe_off": bool(pe_off),
                "pe_scale": float(pe_scale),
                "gate_off": bool(gate_off),
                "agg_pool": str(agg_pool),
            })
            torch.save({
                "state_dict": model.state_dict(),
                "cfg": vars(cfg),
                "arch": meta_arch,
            }, save_path)
            print({"save_calib_ckpt": save_path})
        except Exception as e:
            print({"save_calib_ckpt": f"failed: {e}"})


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
