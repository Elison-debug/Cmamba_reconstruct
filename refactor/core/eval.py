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
    p.add_argument("--Din", type=int, default=4200)
    p.add_argument("--K", type=int, default=12)
    p.add_argument("--proj_dim", type=int, default=64)
    p.add_argument("--d_model", type=int, default=96)
    p.add_argument("--n_layer", type=int, default=3)
    p.add_argument("--patch_len", type=int, default=8)
    p.add_argument("--stride", type=int, default=4)
    p.add_argument("--batch_size", type=int, default=64)
    p.add_argument("--ckpt", type=str, default="refactor_last.pt")
    # 量化后端/位宽（CLI 可覆写 ckpt；未提供则回退 ckpt）
    p.add_argument("--quant_backend", type=str, choices=["cpp", "python"], default=None)
    # 三态开关：未提供(None)→回退 ckpt；提供则为 True
    p.add_argument("--quantize_all", action="store_true", default=None)
    p.add_argument("--q_proj", action="store_true", default=None)
    p.add_argument("--q_head", action="store_true", default=None)
    p.add_argument("--q_block_linear", action="store_true", default=None)
    p.add_argument("--q_backbone_linear", action="store_true", default=None)
    # legacy flag for backward compatibility: maps to both q_proj and q_head
    p.add_argument("--q_proj_head", action="store_true", default=None)
    # bits: 0 -> fallback to ckpt; otherwise validate later (8 or 16)
    p.add_argument("--quant_bits", type=int, default=0)
    # quantization mode and calibration controls
    p.add_argument("--quant_mode", type=str, choices=["dynamic", "fixed88"], default="fixed88",
                   help="dynamic: standard dynamic scaling; fixed88: INT16 fixed-point (scale=1/256)")
    p.add_argument("--calib_method", type=str, choices=["maxabs", "p99"], default="maxabs",
                   help="eval-time calibration method for dynamic scale")
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
    p.add_argument("--save_calib_ckpt", type=str, default="ckpt_refactor/logo/calibrate_last.pt", help="path to save scale-initialized checkpoint after eval")
    p.add_argument("--dont_save_calib_ckpt", action="store_true")
    p.add_argument("--dump_quant_stats", action="store_true", help="print per‑layer a_scale/w_scale and saturation ratios for a small sample")
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

    # 读取 ckpt 中的 arch（用于 baseline 与保存）
    arch = {}
    if ckpt_obj is not None and isinstance(ckpt_obj, dict):
        arch = ckpt_obj.get("arch", {}) or {}

    # 解析量化配置：use_cli=False → 完全按 ckpt；use_cli=True → CLI 覆写（未提供的回退 ckpt）
    def resolve_quant_cfg(use_cli: bool) -> dict:
        if not use_cli:
            # backward-compat: map old q_proj_head->(q_proj,q_head)
            qph = bool(arch.get("q_proj_head", False))
            return {
                "quant_backend": str(arch.get("quant_backend", "python")),
                "quantize_all": bool(arch.get("quantize_all", False)),
                "q_proj": bool(arch.get("q_proj", qph)),
                "q_head": bool(arch.get("q_head", qph)),
                "q_block_linear": bool(arch.get("q_block_linear", False)),
                "q_backbone_linear": bool(arch.get("q_backbone_linear", False)),
                "quant_bits": int(arch.get("quant_bits", 8)),
                "quant_mode": str(arch.get("quant_mode", "dynamic")),
            }
        def _res_flag(cli_val, key):
            return bool(cli_val) if cli_val is not None else bool(arch.get(key, False))
        cfg_local = {
            "quant_backend": (args.quant_backend if args.quant_backend is not None else str(arch.get("quant_backend", "python"))),
            "quantize_all": _res_flag(args.quantize_all, "quantize_all"),
            "q_proj": _res_flag(args.q_proj, "q_proj") if ("q_proj" in arch or args.q_proj is not None) else bool(arch.get("q_proj_head", False)),
            "q_head": _res_flag(args.q_head, "q_head") if ("q_head" in arch or args.q_head is not None) else bool(arch.get("q_proj_head", False)),
            "q_block_linear": _res_flag(args.q_block_linear, "q_block_linear"),
            "q_backbone_linear": _res_flag(args.q_backbone_linear, "q_backbone_linear"),
            "quant_bits": (int(args.quant_bits) if int(args.quant_bits) in (8,16) else int(arch.get("quant_bits", 8))),
            "quant_mode": (str(args.quant_mode) if (args.quant_mode is not None) else str(arch.get("quant_mode", "dynamic"))),
        }
        if args.q_proj_head:
            cfg_local["q_proj"] = True
            cfg_local["q_head"] = True
        return cfg_local

    # 单次评估流程（可选校准/保存）
    def run_once(quant_cfg: dict, out_dir_sub: str, calib_batches: int | None, save_ckpt_path: str | None):
        # 设置后端
        os.environ["QUANT_BACKEND"] = str(quant_cfg["quant_backend"])
        from .mamba_regressor import MambaRegressor
        # 非量化结构按 ckpt（或 CLI）
        pe_off = bool(arch.get("pe_off", args.pe_off))
        pe_scale = float(arch.get("pe_scale", args.pe_scale))
        gate_off = bool(arch.get("gate_off", args.gate_off))
        agg_pool = str(arch.get("agg_pool", args.agg_pool))
        use_dwconv = bool(arch.get("use_dwconv", args.use_dwconv))
        print({"quant_cfg": quant_cfg})
        # 构建模型
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
            quantize_all=bool(quant_cfg["quantize_all"]),
            q_proj=bool(quant_cfg["q_proj"]),
            q_head=bool(quant_cfg["q_head"]),
            q_block_linear=bool(quant_cfg["q_block_linear"]),
            q_backbone_linear=bool(quant_cfg["q_backbone_linear"]),
            quant_backend=str(quant_cfg["quant_backend"]),
            quant_bits=int(quant_cfg["quant_bits"]),
        ).to(device)
        # 诊断
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
        # 加载权重
        if ckpt_obj is not None:
            sd = ckpt_obj.get("state_dict", ckpt_obj)
            # 覆写量化场景：若模型为 qconv 而 ckpt 仍为旧 conv 键，先在内存中迁移键名（conv -> qconv）
            try:
                def _migrate_pw(name: str, mod_root) -> int:
                    moved = 0
                    if mod_root is None:
                        return moved
                    qc = getattr(mod_root, "qconv", None)
                    if qc is None:
                        return moved
                    w_old, b_old = f"{name}.conv.weight", f"{name}.conv.bias"
                    # Python backend path: qconv.conv.*
                    if hasattr(qc, "conv"):
                        w_new, b_new = f"{name}.qconv.conv.weight", f"{name}.qconv.conv.bias"
                        if w_old in sd:
                            sd[w_new] = sd[w_old]
                            moved += 1
                        if b_old in sd and getattr(qc.conv, "bias", None) is not None:
                            sd[b_new] = sd[b_old]
                            moved += 1
                    # C++ backend path: qconv.impl.conv.*
                    elif hasattr(qc, "impl") and hasattr(qc.impl, "conv"):
                        w_new, b_new = f"{name}.qconv.impl.conv.weight", f"{name}.qconv.impl.conv.bias"
                        if w_old in sd:
                            sd[w_new] = sd[w_old]
                            moved += 1
                        if b_old in sd and getattr(qc.impl.conv, "bias", None) is not None:
                            sd[b_new] = sd[b_old]
                            moved += 1
                    return moved

                moved_total = 0
                moved_total += _migrate_pw("proj", getattr(model, "proj", None))
                moved_total += _migrate_pw("head", getattr(model, "head", None))
                if hasattr(model, "backbone") and hasattr(model.backbone, "blocks"):
                    for i, blk in enumerate(model.backbone.blocks):
                        moved_total += _migrate_pw(f"backbone.blocks.{i}.in_proj", getattr(blk, "in_proj", None))
                        moved_total += _migrate_pw(f"backbone.blocks.{i}.out_proj", getattr(blk, "out_proj", None))
                if moved_total > 0:
                    print({"ckpt_migrate_conv_to_qconv": int(moved_total)})
            except Exception as e:
                print({"ckpt_migrate_warn": str(e)})
            r = model.load_state_dict(sd, strict=False)
            try:
                miss = list(getattr(r, "missing_keys", []))
                unexp = list(getattr(r, "unexpected_keys", []))
                print({"ckpt_load": {"missing": len(miss), "unexpected": len(unexp),
                                       "missing_samp": miss[:5], "unexpected_samp": unexp[:5]}})
            except Exception:
                pass
        # 可选校准
        if calib_batches is not None and int(calib_batches) >= 0:
            def _collect_targets(root):
                pairs = []
                for m in root.modules():
                    qc = getattr(m, "qconv", None)
                    if qc is None: continue
                    if hasattr(qc, "qa") and hasattr(qc, "qw"): pairs.append((m, qc, "python"))
                    elif hasattr(qc, "impl"): pairs.append((m, qc, "cpp"))
                return pairs
            targets = _collect_targets(model)
            cal_stats = { id(l): {"amax": 0.0, "abs_vals": [], "amax_c": None} for (_, l, _) in targets }
            handles = []
            def _pre(mod, inputs):
                try:
                    x = inputs[0]
                    s = cal_stats.get(id(mod), None)
                    if s is not None:
                        xa = x.detach().abs()
                        s["amax"] = max(float(xa.max().item()), float(s["amax"]))
                        # If per-channel activation quantization, track channel-wise maxima (axis=1 for (B,C,K))
                        try:
                            qa = getattr(mod, "qa", None)
                            if qa is not None and getattr(qa, "per_channel", False):
                                amax_c = xa.amax(dim=(0, 2)).to(torch.float32).cpu()
                                if s.get("amax_c", None) is None:
                                    s["amax_c"] = amax_c
                                else:
                                    s["amax_c"] = torch.maximum(s["amax_c"], amax_c)
                        except Exception:
                            pass
                        if args.calib_method == "p99":
                            # collect a small sample for percentile (subsample to avoid memory blowup)
                            flat = xa.view(-1)
                            if flat.numel() > 4096:
                                idx = torch.randperm(flat.numel(), device=flat.device)[:4096]
                                s["abs_vals"].append(flat[idx].cpu())
                            else:
                                s["abs_vals"].append(flat.cpu())
                except Exception:
                    pass
                return None
            for (_, qc, _) in targets:
                try:
                    handles.append(qc.register_forward_pre_hook(_pre))
                except Exception:
                    pass
            nb = int(calib_batches)
            model.eval()
            with torch.no_grad():
                for i, (xb, yb) in enumerate(dl, 1):
                    xb = xb.to(device, non_blocking=True).float()
                    _ = model(xb)
                    if nb > 0 and i >= nb: break
            for h in handles:
                try: h.remove()
                except Exception: pass
            for (_, qc, be) in targets:
                try:
                    s = cal_stats.get(id(qc), None)
                    # Select quantization mode
                    qmode = str(quant_cfg.get("quant_mode", "dynamic"))
                    qb = int(quant_cfg.get("quant_bits", 8))
                    if qmode == "fixed88":
                        # Force INT16 8.8: scale = 1/256 for activations and weights
                        a_scale = 1.0 / 256.0
                        w_scale = 1.0 / 256.0
                        # For cpp per-channel activation, fill vector with 1/256
                        if be == "cpp" and hasattr(qc, "impl") and hasattr(qc.impl, "a_scale"):
                            with torch.no_grad():
                                qc.impl.w_scale.data.fill_(float(w_scale))
                                qc.impl.a_scale.data.fill_(float(a_scale))
                            a_scale = None
                    else:
                        # dynamic: max-abs or percentile
                        qa = getattr(qc, "qa", None)
                        # Try per-channel activations if we have channel stats
                        a_scales = None
                        if s is not None and s.get("amax_c", None) is not None:
                            amax_c = s["amax_c"].to(torch.float32)
                            qmax = (1 << (qb - 1)) - 1
                            a_scales = torch.clamp(amax_c / max(1, qmax), min=1e-8)
                        # Python backend: if per-channel QA, write vector
                        if be == "python" and qa is not None and getattr(qa, "per_channel", False) and a_scales is not None and hasattr(qc.qa, "scale") and qc.qa.scale is not None:
                            with torch.no_grad():
                                sc = a_scales.to(qc.qa.scale.device, dtype=qc.qa.scale.dtype)
                                qc.qa.scale.data = sc.view(-1)  # (C,)
                            a_scale = None
                        # C++ backend: write per-channel vector into impl.a_scale
                        elif be == "cpp" and a_scales is not None and hasattr(qc, "impl") and hasattr(qc.impl, "a_scale"):
                            with torch.no_grad():
                                sc = a_scales.to(qc.impl.a_scale.device, dtype=qc.impl.a_scale.dtype)
                                if qc.impl.a_scale.dim() == 1 and qc.impl.a_scale.numel() == sc.numel():
                                    qc.impl.a_scale.data.copy_(sc)
                                else:
                                    qc.impl.a_scale.data.fill_(float(a_scales.mean().item()))
                            a_scale = None
                        else:
                            # Per-tensor fallback
                            if args.calib_method == "p99" and s is not None and s["abs_vals"]:
                                vals = torch.cat(s["abs_vals"], dim=0)
                                amax = float(torch.quantile(vals, 0.99).item())
                            else:
                                amax = float(s["amax"]) if s is not None else 1.0
                            qmax = (1 << (qb - 1)) - 1
                            a_scale = max(1e-8, amax / max(1, qmax))
                    if a_scale is not None and be == "python" and hasattr(qc, "qa") and hasattr(qc.qa, "scale") and qc.qa.scale is not None:
                        with torch.no_grad(): qc.qa.scale.data.fill_(float(a_scale))  # type: ignore
                    elif be == "cpp" and hasattr(qc, "impl") and hasattr(qc.impl, "a_scale"):
                        with torch.no_grad(): qc.impl.a_scale.data.fill_(float(a_scale)) # type: ignore
                    # Resolve weight tensor for scaling (python: qc.conv, cpp: qc.impl.conv)
                    W = None
                    if hasattr(qc, "conv") and getattr(qc, "conv", None) is not None:
                        W = qc.conv.weight.detach()
                    elif hasattr(qc, "impl") and hasattr(qc.impl, "conv") and getattr(qc.impl, "conv", None) is not None:
                        W = qc.impl.conv.weight.detach()
                    if W is not None:
                        if str(quant_cfg.get("quant_mode", "dynamic")) == "fixed88":
                            # fixed 8.8 -> uniform 1/256
                            ws = torch.full((W.shape[0],), 1.0/256.0, device=W.device, dtype=torch.float32)
                        else:
                            # dynamic per-channel max-abs
                            w_amax = W.abs().amax(dim=(1,2)) if W.dim() == 3 else W.abs().amax(dim=1)
                            qmax_w = (1 << (int(quant_cfg.get("quant_bits", 8)) - 1)) - 1
                            ws = (w_amax / max(1, qmax_w)).clamp(min=1e-8)
                    if be == "python" and hasattr(qc, "qw") and hasattr(qc.qw, "scale") and qc.qw.scale is not None:
                        # Support both legacy (out,1) and new (out,) scale parameter shapes
                        if qc.qw.scale.dim() == 2 and qc.qw.scale.shape[1] == 1:
                            ws_ = ws.view(-1, 1).to(qc.qw.scale.device, dtype=qc.qw.scale.dtype)
                        else:
                            ws_ = ws.view(-1).to(qc.qw.scale.device, dtype=qc.qw.scale.dtype)
                        with torch.no_grad(): qc.qw.scale.data.copy_(ws_)  # type: ignore
                    elif be == "cpp" and hasattr(qc, "impl") and hasattr(qc.impl, "w_scale"):
                        with torch.no_grad():
                            ws_ = ws.to(qc.impl.w_scale.device, dtype=qc.impl.w_scale.dtype)
                            tgt = qc.impl.w_scale
                            if tgt.numel() == ws_.numel():
                                tgt.data.copy_(ws_)
                            elif tgt.dim() == 2 and tgt.shape[1] == 1 and tgt.shape[0] == ws_.numel():
                                tgt.data.copy_(ws_.view(-1, 1))
                            else:
                                flat = ws_.view(-1)
                                need = tgt.numel()
                                rep = (need + flat.numel() - 1) // flat.numel()
                                upd = flat.repeat(rep)[:need]
                                tgt.data.view(-1).copy_(upd)
                except Exception:
                    pass
        # 评估
        loss_fn = HuberEPE(delta=1.0)
        show = (args.progress or (not args.no_progress))
        ev_loss, stats = evaluate(model, dl, device, loss_fn, show_progress=show)  # type: ignore
        print({"eval_loss": ev_loss, **stats})
        # 可选：量化统计（快速诊断常量输出）
        if bool(args.dump_quant_stats):
            try:
                def _iter_qconvs(root):
                    for m in root.modules():
                        qc = getattr(m, "qconv", None)
                        if qc is not None:
                            yield m, qc
                # collect one small batch for saturation estimate
                xs = None
                for xb, _ in dl:
                    xs = xb.to(device).float()
                    break
                qstats = []
                for mod, qc in _iter_qconvs(model):
                    be = "cpp" if hasattr(qc, "impl") else ("python" if hasattr(qc, "qa") else "unknown")
                    # scales
                    a_s = None; w_s = None
                    try:
                        if be == "python" and hasattr(qc, "qa") and getattr(qc.qa, "scale", None) is not None:
                            a_s = qc.qa.scale.detach().flatten().abs().float().cpu()
                        if be == "cpp" and hasattr(qc, "impl") and getattr(qc.impl, "a_scale", None) is not None:
                            a_s = qc.impl.a_scale.detach().flatten().abs().float().cpu()
                        if be == "python" and hasattr(qc, "qw") and getattr(qc.qw, "scale", None) is not None:
                            w_s = qc.qw.scale.detach().flatten().abs().float().cpu()
                        if be == "cpp" and hasattr(qc, "impl") and getattr(qc.impl, "w_scale", None) is not None:
                            w_s = qc.impl.w_scale.detach().flatten().abs().float().cpu()
                    except Exception:
                        pass
                    # saturation estimate on one batch
                    sat_ratio = None
                    try:
                        if xs is not None:
                            # forward input to this module boundary: project using registered name
                            # Use module's own forward pre-hook idea: approximate by taking current xs through parent up to this mod is complex; instead, use scale to estimate: assume Gaussian and compute fraction > qmax*scale ~ conservative not trivial.
                            # Here we fallback to printing scale min/max only.
                            sat_ratio = -1.0
                    except Exception:
                        pass
                    qstats.append({
                        "name": mod.__class__.__name__,
                        "backend": be,
                        "a_scale_min": (float(a_s.min()) if a_s is not None else None),
                        "a_scale_max": (float(a_s.max()) if a_s is not None else None),
                        "a_scale_len": (int(a_s.numel()) if a_s is not None else 0),
                        "w_scale_min": (float(w_s.min()) if w_s is not None else None),
                        "w_scale_max": (float(w_s.max()) if w_s is not None else None),
                        "w_scale_len": (int(w_s.numel()) if w_s is not None else 0),
                        "sat_ratio": sat_ratio,
                    })
                print({"quant_stats": qstats[:6]})
            except Exception as e:
                print({"quant_stats_error": str(e)})
        # 输出
        out_dir = os.path.join(args.out_dir, out_dir_sub)
        Path(out_dir).mkdir(parents=True, exist_ok=True)
        y_true_list, y_pred_list = [], []
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
            np.savez(os.path.join(out_dir, 'val_preds.npz'), y_true=y_true, y_pred=y_pred, err=err,
                     mean=np.float32(mean), median=np.float32(median), p80=np.float32(p80), p90=np.float32(p90))
            if args.save_csv:
                import csv
                with open(os.path.join(out_dir, 'pred_vs_true.csv'), 'w', newline='') as f:
                    w = csv.writer(f); w.writerow(['y_true_x','y_true_y','y_pred_x','y_pred_y','err_m'])
                    for (yt, yp, e_) in zip(y_true, y_pred, err):
                        w.writerow([yt[0], yt[1], yp[0], yp[1], e_])
            e_sorted = np.sort(err); ycdf = np.arange(1, len(e_sorted) + 1) / len(e_sorted)
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
            
            # True vs Predicted (SVG) — 恢复 pred_vs_true.svg 绘制
            plt.figure(figsize=(7.5, 6.5))
            plt.title('True vs Predicted Positions')
            # True trajectory with breaks between grids and large jumps
            try:
                N = int(y_true.shape[0])
                # dataset order matches concatenated predictions when shuffle=False
                fi_seq = [fi for (fi, _s, _t) in ds.index[:N]]
                breaks = np.zeros(N, dtype=bool)
                bt = float(max(0.0, args.break_thresh))
                for i in range(1, N):
                    jump = float(np.linalg.norm(y_true[i] - y_true[i-1]))
                    if fi_seq[i] != fi_seq[i-1] or (bt > 0.0 and jump > bt):
                        breaks[i] = True
                true_xy = y_true.copy().astype(np.float32)
                true_xy[breaks] = np.nan
                plt.plot(true_xy[:,0], true_xy[:,1], color='blue', linewidth=1, label='True Trajectory', zorder=3)
            except Exception:
                # Fallback: plot as a single line if anything goes wrong
                plt.plot(y_true[:,0], y_true[:,1], color='blue', linewidth=1, label='True Trajectory', zorder=3)
            # Predicted points (rasterized for lightweight SVG)
            sc = plt.scatter(
                y_pred[:,0], y_pred[:,1], c=err, cmap='plasma', s=1,
                alpha=0.65, edgecolors='none', rasterized=True, zorder=2
            )
            cb = plt.colorbar(sc); cb.set_label('Error (m)')
            plt.xlabel('X'); plt.ylabel('Y'); plt.grid(True, linestyle='--', linewidth=0.2)
            plt.axis('equal'); plt.legend()
            plt.tight_layout(); plt.savefig(os.path.join(out_dir, 'pred_vs_true.svg'), bbox_inches='tight', pad_inches=0.01, dpi=300)
            plt.close()
            
        # 保存校准后 ckpt（仅在覆写量化跑时）
        if (save_ckpt_path is not None) and (not bool(args.dont_save_calib_ckpt)):
            try:
                meta_arch = dict(arch)
                meta_arch.update({
                    "quant_backend": str(quant_cfg["quant_backend"]),
                    "quantize_all": bool(quant_cfg["quantize_all"]),
                    "q_proj": bool(quant_cfg["q_proj"]),
                    "q_head": bool(quant_cfg["q_head"]),
                    "q_block_linear": bool(quant_cfg["q_block_linear"]),
                    "q_backbone_linear": bool(quant_cfg["q_backbone_linear"]),
                    "quant_bits": int(quant_cfg["quant_bits"]),
                    "quant_mode": str(quant_cfg.get("quant_mode", "dynamic")),
                    "use_dwconv": bool(use_dwconv),
                    "pe_off": bool(pe_off),
                    "pe_scale": float(pe_scale),
                    "gate_off": bool(gate_off),
                    "agg_pool": str(agg_pool),
                })
                torch.save({"state_dict": model.state_dict(), "cfg": vars(cfg), "arch": meta_arch}, save_ckpt_path)
                print({"save_calib_ckpt": os.path.abspath(save_ckpt_path)})
            except Exception as e:
                print({"save_calib_ckpt": f"failed: {e}"})

    # 先跑 baseline（严格按 ckpt.arch）
    baseline_cfg = resolve_quant_cfg(use_cli=False)
    run_once(baseline_cfg, out_dir_sub="baseline", calib_batches=None, save_ckpt_path=None)
    # 若 CLI 指定了量化参数，则再跑一次覆写量化并可选校准/保存
    any_override = (
        args.quant_backend is not None or
        (int(args.quant_bits) in (8,16)) or
        (args.quantize_all is not None) or
        (args.q_proj_head is not None) or
        (args.q_block_linear is not None) or
        (args.q_backbone_linear is not None)
    )
    if any_override:
        override_cfg = resolve_quant_cfg(use_cli=True)
        run_once(override_cfg, out_dir_sub="quant", calib_batches=int(args.quant_calib_batches), save_ckpt_path=args.save_calib_ckpt)

    return

if __name__ == "__main__":
    main()
