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
    """Try to read QLinearINT8 learnable params for export."""
    q = {}
    # cpp impl attributes
    for name in ["a_scale", "a_zp", "w_scale"]:
        if hasattr(mod, name):
            val = getattr(mod, name)
            if isinstance(val, torch.nn.Parameter) or torch.is_tensor(val):
                q[name] = val.detach().cpu().numpy()
    # lsq fallback
    if hasattr(mod, "qa") and hasattr(mod.qa, "scale") and mod.qa.scale is not None:
        q["a_scale"] = mod.qa.scale.detach().cpu().numpy() 
        # no zp in symmetric LSQ fallback
        q["a_zp"] = np.array([0.0], dtype=np.float32)
    if hasattr(mod, "qw") and hasattr(mod.qw, "scale") and mod.qw.scale is not None:
        # per-channel
        q["w_scale"] = mod.qw.scale.detach().cpu().view(-1).cpu().numpy()
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

    for i, blk in enumerate(bb.blocks):
        entry = {}
        for name in ["in_proj_a", "in_proj_b", "out_proj"]:
            lin = getattr(blk, name)
            W = lin.weight.detach().cpu().numpy()
            B = lin.bias.detach().cpu().numpy() if lin.bias is not None else None
            wname = _save_npy(out_dir, f"block{i}_{name}_W", W)
            entry[f"{name}_W"] = wname
            if B is not None:
                bname = _save_npy(out_dir, f"block{i}_{name}_B", B)
                entry[f"{name}_B"] = bname
        # depthwise conv
        dw = blk.dw_conv
        W = dw.weight.detach().cpu().numpy()
        B = dw.bias.detach().cpu().numpy() if dw.bias is not None else None
        entry["dw_weight"] = _save_npy(out_dir, f"block{i}_dw_W", W)
        if B is not None:
            entry["dw_bias"] = _save_npy(out_dir, f"block{i}_dw_B", B)
        blocks.append(entry)

    meta = {
        "d_model": int(args.d_model),
        "d_inner": int(args.d_inner),
        "n_layer": int(args.n_layer),
        "d_conv": int(args.d_conv),
        "num_patches": int(args.num_patches),
        "patch_len": int(args.patch_len),
        "stride": int(args.stride),
    }
    j = {"meta": meta, "patch_embedding": {"W": "patch_embed_W.npy", "B": "patch_embed_B.npy"}, "blocks": blocks}
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
