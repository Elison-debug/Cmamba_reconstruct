from __future__ import annotations
import json
from pathlib import Path
from typing import Dict

import numpy as np
import torch

from refactor.quant import spec


def _save_npy(out_dir: Path, name: str, arr: np.ndarray) -> str:
    out_dir.mkdir(parents=True, exist_ok=True)
    np.save(out_dir / name, arr)
    return f"{name}.npy" if not name.endswith(".npy") else name


def _extract_qparams_from_module(mod: torch.nn.Module):
    """Try to read QConv1x1INT learnable params for export (python or cpp backend)."""
    q = {}
    # cpp impl attributes
    for name in ["a_scale", "a_zp", "w_scale"]:
        if hasattr(mod, name):
            val = getattr(mod, name)
            if isinstance(val, torch.nn.Parameter) or torch.is_tensor(val):
                q[name] = val.detach().cpu().numpy()
    # python lsq
    if hasattr(mod, "qa") and hasattr(mod.qa, "scale") and mod.qa.scale is not None:  # type: ignore
        q["a_scale"] = mod.qa.scale.detach().cpu().numpy()  # type: ignore
        # no zp in symmetric LSQ fallback
        q["a_zp"] = np.array([0.0], dtype=np.float32)
    if hasattr(mod, "qw") and hasattr(mod.qw, "scale") and mod.qw.scale is not None:# type: ignore
        # per-channel
        q["w_scale"] = mod.qw.scale.detach().cpu().view(-1).cpu().numpy()# type: ignore
    return q


def export_proj_head(model: torch.nn.Module, out_dir: str, meta: Dict):
    out_dir_p = Path(out_dir)
    sd = model.state_dict()
    # Expect keys from MambaRegressor
    proj_W = sd["proj.weight"].detach().cpu().numpy()
    proj_B = sd["proj.bias"].detach().cpu().numpy()
    head_W = sd["head.weight"].detach().cpu().numpy()
    head_B = sd["head.bias"].detach().cpu().numpy()

    proj_W_name = _save_npy(out_dir_p, "proj_W", proj_W)
    proj_B_name = _save_npy(out_dir_p, "proj_B", proj_B)
    head_W_name = _save_npy(out_dir_p, "head_W", head_W)
    head_B_name = _save_npy(out_dir_p, "head_B", head_B)

    # scales
    proj_mod = getattr(model, "proj", None)
    head_mod = getattr(model, "head", None)
    proj_q = _extract_qparams_from_module(proj_mod) if proj_mod is not None else {}
    head_q = _extract_qparams_from_module(head_mod) if head_mod is not None else {}

    proj_WS = proj_q.get("w_scale", np.ones((proj_W.shape[0],), dtype=np.float32))
    head_WS = head_q.get("w_scale", np.ones((head_W.shape[0],), dtype=np.float32))
    proj_WS_name = _save_npy(out_dir_p, "proj_WS", proj_WS)
    head_WS_name = _save_npy(out_dir_p, "head_WS", head_WS)
    a_scale_proj = float(np.asarray(proj_q.get("a_scale", np.array([1.0], dtype=np.float32))).reshape(-1)[0])
    a_zp_proj = int(np.rint(float(np.asarray(proj_q.get("a_zp", np.array([0.0], dtype=np.float32))).reshape(-1)[0])))
    a_scale_head = float(np.asarray(head_q.get("a_scale", np.array([1.0], dtype=np.float32))).reshape(-1)[0])
    a_zp_head = int(np.rint(float(np.asarray(head_q.get("a_zp", np.array([0.0], dtype=np.float32))).reshape(-1)[0])))

    j = {
        "version": 1,
        "model": meta,
        "quant": {
            "rounding": spec.ROUNDING,
            "saturate": spec.SATURATE,
            "act": {"scheme": "per_tensor_asym", "bits": spec.ACT_BITS},
            "weight": {
                "scheme": "per_channel_sym",
                "bits": spec.W_BITS,
                "axis": 0,
            },
        },
        "layers": [
            {
                "type": "linear",
                "name": "proj",
                "in": int(proj_W.shape[1]),
                "out": int(proj_W.shape[0]),
                "W": proj_W_name,
                "B": proj_B_name,
                "act_scale": a_scale_proj,
                "act_zp": a_zp_proj,
                "w_scale": proj_WS_name,
            },
            {
                "type": "cmamba_slim",
                "name": "backbone",
                "params": "backbone.json",  # to be extended
            },
            {
                "type": "linear",
                "name": "head",
                "in": int(head_W.shape[1]),
                "out": int(head_W.shape[0]),
                "W": head_W_name,
                "B": head_B_name,
                "act_scale": a_scale_head,
                "act_zp": a_zp_head,
                "w_scale": head_WS_name,
            },
        ],
    }
    with open(out_dir_p / "export.json", "w", encoding="utf-8") as f:
        json.dump(j, f, indent=2)
    return out_dir_p / "export.json"


def _save_backbone_params(model: torch.nn.Module, out_dir: Path) -> str:
    # Serialize SlimMamba backbone weights minimally
    bb = getattr(model, "backbone")
    args = bb.args
    blocks = []
    # patch embedding
    pe = bb.patch_embedding
    pe_W = pe.weight.detach().cpu().numpy(); pe_B = pe.bias.detach().cpu().numpy() if pe.bias is not None else None
    _save_npy(out_dir, "patch_embed_W", pe_W)
    if pe_B is not None:
        _save_npy(out_dir, "patch_embed_B", pe_B)
    # quant params for patch embedding if present
    try:
        from .pack import _extract_qparams_from_module as _eq  # type: ignore
    except Exception:
        _eq = _extract_qparams_from_module  # fallback to local
    q_pe = _extract_qparams_from_module(pe)
    pe_extra = {}
    if "w_scale" in q_pe:
        pe_extra["WS"] = _save_npy(out_dir, "patch_embed_WS", q_pe["w_scale"])  # per-out scale
    if "a_scale" in q_pe:
        pe_extra["act_scale"] = float(np.asarray(q_pe["a_scale"]).reshape(-1)[0])
    if "a_zp" in q_pe:
        pe_extra["act_zp"] = int(np.rint(float(np.asarray(q_pe["a_zp"]).reshape(-1)[0])))

    for i, blk in enumerate(bb.blocks):
        entry = {}
        # support old naming (in_proj_a/b) and new (in_proj)
        linear_names = []
        if hasattr(blk, "in_proj"):
            linear_names += ["in_proj"]
        else:
            if hasattr(blk, "in_proj_a"): linear_names += ["in_proj_a"]
            if hasattr(blk, "in_proj_b"): linear_names += ["in_proj_b"]
        if hasattr(blk, "out_proj"):
            linear_names += ["out_proj"]
        for name in linear_names:
            lin = getattr(blk, name)
            if not hasattr(lin, "weight"):
                continue
            W = lin.weight.detach().cpu().numpy()
            B = lin.bias.detach().cpu().numpy() if getattr(lin, "bias", None) is not None else None
            wname = _save_npy(out_dir, f"block{i}_{name}_W", W)
            entry[f"{name}_W"] = wname
            if B is not None:
                bname = _save_npy(out_dir, f"block{i}_{name}_B", B)
                entry[f"{name}_B"] = bname
            # quant params if present
            q = _extract_qparams_from_module(lin)
            if "w_scale" in q:
                ws_name = _save_npy(out_dir, f"block{i}_{name}_WS", q["w_scale"])
                entry[f"{name}_WS"] = ws_name
            if "a_scale" in q:
                entry[f"{name}_act_scale"] = float(np.asarray(q["a_scale"]).reshape(-1)[0])
            if "a_zp" in q:
                entry[f"{name}_act_zp"] = int(np.rint(float(np.asarray(q["a_zp"]).reshape(-1)[0])))
        # depthwise conv if present
        if hasattr(blk, "dw_conv") and getattr(blk, "dw_conv") is not None:
            dw = blk.dw_conv
            W = dw.weight.detach().cpu().numpy()
            B = dw.bias.detach().cpu().numpy() if dw.bias is not None else None
            entry["dw_weight"] = _save_npy(out_dir, f"block{i}_dw_W", W)
            if B is not None:
                entry["dw_bias"] = _save_npy(out_dir, f"block{i}_dw_B", B)
        # SSM params
        if hasattr(blk, "ssm"):
            ssm = blk.ssm
            # dt_proj weights/bias (quantizable)
            if hasattr(ssm, "dt_proj") and hasattr(ssm.dt_proj, "weight"):
                W = ssm.dt_proj.weight.detach().cpu().numpy()
                entry["dt_proj_W"] = _save_npy(out_dir, f"block{i}_dt_proj_W", W)
                if getattr(ssm.dt_proj, "bias", None) is not None:
                    B = ssm.dt_proj.bias.detach().cpu().numpy()
                    entry["dt_proj_B"] = _save_npy(out_dir, f"block{i}_dt_proj_B", B)
                q = _extract_qparams_from_module(ssm.dt_proj)
                if "w_scale" in q:
                    ws_name = _save_npy(out_dir, f"block{i}_dt_proj_WS", q["w_scale"])
                    entry["dt_proj_WS"] = ws_name
                if "a_scale" in q:
                    entry["dt_proj_act_scale"] = float(np.asarray(q["a_scale"]).reshape(-1)[0])
                if "a_zp" in q:
                    entry["dt_proj_act_zp"] = int(np.rint(float(np.asarray(q["a_zp"]).reshape(-1)[0])))
        # block RMSNorm weight if exists
        if hasattr(blk, "norm") and hasattr(blk.norm, "weight"):
            w = blk.norm.weight.detach().cpu().numpy()
            entry["norm_weight"] = _save_npy(out_dir, f"block{i}_norm_weight", w)
        blocks.append(entry)

    meta = {
        "d_model": int(args.d_model),
        "d_inner": int(args.d_inner),
        "n_layer": int(args.n_layer),
        "d_conv": int(args.d_conv),
        "num_patches": int(args.num_patches),
        "patch_len": int(args.patch_len),
        "stride": int(args.stride),
        # extra runtime knobs for FPGA
        "pe_on": bool(getattr(args, "pe_on", True)),
        "pe_scale": float(getattr(args, "pe_scale", 1.0)),
        "gate_off": bool(getattr(args, "gate_off", False)),
        "agg_pool": str(getattr(args, "agg_pool", "")),
    }
    # save positional encoding if enabled
    pe_name = None
    try:
        if meta["pe_on"]:
            # prefer cached pe buffer if exists
            if hasattr(bb, "pe_buf") and bb.pe_buf is not None:
                pe_arr = bb.pe_buf.detach().cpu().numpy()
            else:
                pe_arr = bb._build_sincos(args.num_patches, args.d_model).detach().cpu().numpy()  # type: ignore
            pe_name = _save_npy(out_dir, "pe", pe_arr)
    except Exception:
        pe_name = None

    # final norm weight
    final_norm = None
    if hasattr(bb, "norm_f") and hasattr(bb.norm_f, "weight"):
        w = bb.norm_f.weight.detach().cpu().numpy()
        final_norm = _save_npy(out_dir, "final_norm_weight", w)

    # output layers (flat/pool)
    out_layers = {}
    if hasattr(bb, "output_layer_flat") and hasattr(bb.output_layer_flat, "weight"):
        W = bb.output_layer_flat.weight.detach().cpu().numpy()
        B = bb.output_layer_flat.bias.detach().cpu().numpy() if bb.output_layer_flat.bias is not None else None
        _save_npy(out_dir, "out_flat_W", W)
        if B is not None: _save_npy(out_dir, "out_flat_B", B)
        q = _extract_qparams_from_module(bb.output_layer_flat)
        if "w_scale" in q: _save_npy(out_dir, "out_flat_WS", q["w_scale"])
        out_layers["flat"] = True
    if hasattr(bb, "output_layer_pool") and hasattr(bb.output_layer_pool, "weight"):
        W = bb.output_layer_pool.weight.detach().cpu().numpy()
        B = bb.output_layer_pool.bias.detach().cpu().numpy() if bb.output_layer_pool.bias is not None else None
        _save_npy(out_dir, "out_pool_W", W)
        if B is not None: _save_npy(out_dir, "out_pool_B", B)
        q = _extract_qparams_from_module(bb.output_layer_pool)
        if "w_scale" in q: _save_npy(out_dir, "out_pool_WS", q["w_scale"])
        out_layers["pool"] = True

    j = {
        "meta": meta,
        "patch_embedding": {"W": "patch_embed_W.npy", "B": "patch_embed_B.npy"},
        "blocks": blocks,
    }
    # attach patch embedding quant params if present
    if pe_extra:
        j["patch_embedding"].update({
            k.upper() if k=="WS" else k: ("patch_embed_WS.npy" if k=="WS" else pe_extra[k]) for k in pe_extra
        })
        # also place duplicated top-level keys for simpler C++ parser
        if "WS" in pe_extra: j["patch_embed_WS"] = "patch_embed_WS.npy"
        if "act_scale" in pe_extra: j["patch_embed_act_scale"] = pe_extra["act_scale"]
        if "act_zp" in pe_extra: j["patch_embed_act_zp"] = pe_extra["act_zp"]
    # final norm
    if final_norm is not None:
        j["final_norm_weight"] = "final_norm_weight.npy"
    # output layers
    if "flat" in out_layers:
        j["output_flat"] = {"W": "out_flat_W.npy", "B": "out_flat_B.npy", "WS": "out_flat_WS.npy"}
    if "pool" in out_layers:
        j["output_pool"] = {"W": "out_pool_W.npy", "B": "out_pool_B.npy", "WS": "out_pool_WS.npy"}
    if pe_name is not None:
        j["pe"] = "pe.npy"
    with open(out_dir / "backbone.json", "w", encoding="utf-8") as f:
        json.dump(j, f, indent=2)
    return str(out_dir / "backbone.json")


def export_minimal(model: torch.nn.Module, out_dir: str) -> str:
    # Extract meta from backbone args if present
    meta = {
        "seq_len": 12,
        "proj_dim": 64,
        "d_model": 96,
        "n_layer": 3,
        "patch_len": 8,
        "stride": 4,
        "forecast_len": 1,
    }
    # best-effort lookup
    try:
        args = getattr(model, "backbone").args
        meta.update(
            {
                "seq_len": int(args.seq_len),
                "proj_dim": int(args.num_channels),
                "d_model": int(args.d_model),
                "n_layer": int(args.n_layer),
                "patch_len": int(args.patch_len),
                "stride": int(args.stride),
                "forecast_len": int(args.forecast_len),
            }
        )
    except Exception:
        pass

    out_dir_p = Path(out_dir)
    out_path = export_proj_head(model, out_dir, meta)
    _save_backbone_params(model, out_dir_p)
    return str(out_path)
