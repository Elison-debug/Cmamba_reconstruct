from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, Optional

import numpy as np
import torch
import torch.nn as nn

from refactor.bittrue.config import DEFAULT_CONFIG
from refactor.quant import spec


def _save_npy(out_dir: Path, name: str, arr: np.ndarray) -> str:
    out_dir.mkdir(parents=True, exist_ok=True)
    path = out_dir / (name if name.endswith(".npy") else f"{name}.npy")
    np.save(path, arr)
    return path.name


def _module_path(mod: torch.nn.Module) -> str:
    return f"{mod.__class__.__module__}.{mod.__class__.__name__}"


def _unwrap_conv(mod: Optional[torch.nn.Module]) -> Optional[nn.Conv1d]:
    if mod is None:
        return None
    if isinstance(mod, nn.Conv1d):
        return mod
    cur: Any = mod
    for part in ("conv",):
        if hasattr(cur, part) and isinstance(getattr(cur, part), nn.Conv1d):
            return getattr(cur, part)
    for path in ("qconv.conv", "qconv.impl.conv", "impl.conv"):
        cur = mod
        ok = True
        for part in path.split("."):
            if not hasattr(cur, part):
                ok = False
                break
            cur = getattr(cur, part)
        if ok and isinstance(cur, nn.Conv1d):
            return cur
    return None


def _unwrap_quant_owner(mod: Optional[torch.nn.Module]) -> Optional[torch.nn.Module]:
    if mod is None:
        return None
    if hasattr(mod, "qconv"):
        return getattr(mod, "qconv")
    return mod


def _save_tensor_if_present(out_dir: Path, name: str, tensor: Optional[torch.Tensor]) -> Optional[str]:
    if tensor is None:
        return None
    return _save_npy(out_dir, name, tensor.detach().cpu().numpy())


def _infer_quant_desc(mod: Optional[torch.nn.Module], out_dir: Path, stem: str, in_channels: int, out_channels: int) -> dict:
    owner = _unwrap_quant_owner(mod)
    if owner is None:
        return {
            "activation": {"enabled": False, "scheme": "none", "bits": 0},
            "weight": {"enabled": False, "scheme": "none", "bits": 0, "axis": 0},
        }

    mod_path = _module_path(owner)

    # Python fake-quant wrappers in refactor.quant.qat_layers
    if mod_path.endswith("qat_layers.QConv1x1INT") or mod_path.endswith("qat_layers.QConv1dINT"):
        qa_scale = getattr(getattr(owner, "qa", None), "scale", None)
        qw_scale = getattr(getattr(owner, "qw", None), "scale", None)
        qa_bits = int(getattr(getattr(owner, "qa", None), "bits", spec.ACT_BITS))
        qw_bits = int(getattr(getattr(owner, "qw", None), "bits", spec.W_BITS))
        act_scale = _save_tensor_if_present(out_dir, f"{stem}_A_SCALE", qa_scale)
        w_scale = _save_tensor_if_present(out_dir, f"{stem}_W_SCALE", qw_scale)
        return {
            "activation": {
                "enabled": act_scale is not None,
                "scheme": "per_channel_sym",
                "bits": qa_bits,
                "axis": 1,
                "channels": in_channels,
                "scale": act_scale,
                "zero_point": 0,
            },
            "weight": {
                "enabled": w_scale is not None,
                "scheme": "per_channel_sym",
                "bits": qw_bits,
                "axis": 0,
                "channels": out_channels,
                "scale": w_scale,
            },
        }

    # C++ fake-quant wrappers in refactor.quant.cpp_backend
    if mod_path.endswith("cpp_backend.QConv1x1INT"):
        a_bits = int(getattr(owner, "a_bits", spec.ACT_BITS))
        w_bits = int(getattr(owner, "w_bits", spec.W_BITS))
        a_scale_t = getattr(owner, "a_scale", None)
        a_zp_t = getattr(owner, "a_zp", None)
        w_scale_t = getattr(owner, "w_scale", None)
        w_scale = _save_tensor_if_present(out_dir, f"{stem}_W_SCALE", w_scale_t)
        if a_bits == 8:
            # Match cpp_backend.QConv1x1INT.forward(): use mean(a_scale) as scalar.
            a_scale_scalar = float(torch.as_tensor(a_scale_t).detach().cpu().mean().item()) if a_scale_t is not None else 1.0
            a_zp = int(round(float(torch.as_tensor(a_zp_t).detach().cpu().item()))) if a_zp_t is not None else 0
            activation = {
                "enabled": True,
                "scheme": "per_tensor_asym",
                "bits": a_bits,
                "scale": a_scale_scalar,
                "zero_point": a_zp,
                "qmin": 0,
                "qmax": (1 << a_bits) - 1,
            }
        else:
            a_scale = _save_tensor_if_present(out_dir, f"{stem}_A_SCALE", a_scale_t)
            activation = {
                "enabled": a_scale is not None,
                "scheme": "per_channel_sym",
                "bits": a_bits,
                "axis": 1,
                "channels": in_channels,
                "scale": a_scale,
                "zero_point": 0,
            }
        return {
            "activation": activation,
            "weight": {
                "enabled": w_scale is not None,
                "scheme": "per_channel_sym",
                "bits": w_bits,
                "axis": 0,
                "channels": out_channels,
                "scale": w_scale,
            },
        }

    if mod_path.endswith("cpp_backend.QConv1dINT"):
        a_bits = int(getattr(owner, "a_bits", spec.ACT_BITS))
        w_bits = int(getattr(owner, "w_bits", spec.W_BITS))
        a_scale = _save_tensor_if_present(out_dir, f"{stem}_A_SCALE", getattr(owner, "a_scale", None))
        w_scale = _save_tensor_if_present(out_dir, f"{stem}_W_SCALE", getattr(owner, "w_scale", None))
        return {
            "activation": {
                "enabled": a_scale is not None,
                "scheme": "per_channel_sym",
                "bits": a_bits,
                "axis": 1,
                "channels": in_channels,
                "scale": a_scale,
                "zero_point": 0,
            },
            "weight": {
                "enabled": w_scale is not None,
                "scheme": "per_channel_sym",
                "bits": w_bits,
                "axis": 0,
                "channels": out_channels,
                "scale": w_scale,
            },
        }

    return {
        "activation": {"enabled": False, "scheme": "none", "bits": 0},
        "weight": {"enabled": False, "scheme": "none", "bits": 0, "axis": 0},
    }


def _export_conv1d(mod: torch.nn.Module, out_dir: Path, stem: str, name: str) -> dict:
    conv = _unwrap_conv(mod)
    if conv is None:
        raise TypeError(f"Expected Conv1d-compatible module for {name}, got {type(mod)}")

    weight_name = _save_npy(out_dir, f"{stem}_W", conv.weight.detach().cpu().numpy())
    bias_name = _save_tensor_if_present(out_dir, f"{stem}_B", conv.bias)
    q = _infer_quant_desc(mod, out_dir, stem, in_channels=int(conv.in_channels), out_channels=int(conv.out_channels))

    return {
        "name": name,
        "type": "conv1d",
        "impl": _module_path(mod),
        "in_channels": int(conv.in_channels),
        "out_channels": int(conv.out_channels),
        "kernel_size": int(conv.kernel_size[0]),
        "stride": int(conv.stride[0]),
        "padding": int(conv.padding[0]),
        "groups": int(conv.groups),
        "bias": bias_name is not None,
        "weight": weight_name,
        "weight_shape": list(conv.weight.shape),
        "bias_file": bias_name,
        "bias_shape": ([int(conv.bias.numel())] if conv.bias is not None else []),
        "quant": q,
    }


def _export_rmsnorm(mod: torch.nn.Module, out_dir: Path, stem: str, name: str) -> dict:
    weight_name = _save_npy(out_dir, f"{stem}_W", mod.weight.detach().cpu().numpy())
    return {
        "name": name,
        "type": "rmsnorm",
        "impl": _module_path(mod),
        "dim": int(mod.weight.numel()),
        "eps": float(getattr(mod, "eps", 1e-5)),
        "weight": weight_name,
    }


def _bittrue_export_dict():
    cfg = DEFAULT_CONFIG.to_dict()
    return {
        "version": cfg["version"],
        "weights": cfg["weights"],
        "activations": cfg["activations"],
        "bias": cfg["bias"],
        "accumulators": cfg["accumulators"],
        "requant": cfg["requant"],
        "sigmoid_lut": cfg["sigmoid_lut"],
        "silu_lut": cfg["silu_lut"],
        "rmsnorm": cfg["rmsnorm"],
        "notes": cfg["notes"],
    }


def _export_block(block: torch.nn.Module, block_idx: int, out_dir: Path) -> dict:
    args = block.args
    entry = {
        "index": block_idx,
        "type": "slim_mamba_block",
        "d_model": int(args.d_model),
        "d_inner": int(args.d_inner),
        "d_conv": int(args.d_conv),
        "use_gate": bool(getattr(block, "use_gate", True)),
        "use_dwconv": getattr(block, "dw_conv", None) is not None,
        "norm": _export_rmsnorm(block.norm, out_dir, f"block{block_idx}_norm", f"block{block_idx}.norm"),
        "in_proj": _export_conv1d(block.in_proj, out_dir, f"block{block_idx}_in_proj", f"block{block_idx}.in_proj"),
        "ssm": {
            "type": "selective_scan_ic",
            "dim": int(args.d_inner),
            "dt_proj": _export_conv1d(block.ssm.dt_proj, out_dir, f"block{block_idx}_dt_proj", f"block{block_idx}.ssm.dt_proj"),
        },
        "out_proj": _export_conv1d(block.out_proj, out_dir, f"block{block_idx}_out_proj", f"block{block_idx}.out_proj"),
    }
    if getattr(block, "dw_conv", None) is not None:
        entry["dw_conv"] = _export_conv1d(block.dw_conv, out_dir, f"block{block_idx}_dw_conv", f"block{block_idx}.dw_conv")
    else:
        entry["dw_conv"] = {"enabled": False}
    return entry


def _save_backbone_params(model: torch.nn.Module, out_dir: Path) -> str:
    bb = getattr(model, "backbone")
    args = bb.args

    positional_encoding = {
        "enabled": bool(getattr(args, "pe_on", True)),
        "scale": float(getattr(args, "pe_scale", 1.0)),
        "num_patches": int(args.num_patches),
        "d_model": int(args.d_model),
        "file": None,
    }
    if positional_encoding["enabled"]:
        if hasattr(bb, "pe_buf") and bb.pe_buf is not None:
            pe_arr = bb.pe_buf.detach().cpu().numpy()
        else:
            pe_arr = bb._build_sincos(args.num_patches, args.d_model).detach().cpu().numpy()  # type: ignore[attr-defined]
        positional_encoding["file"] = _save_npy(out_dir, "positional_encoding", pe_arr)

    output_head = {
        "kind": "pool" if getattr(args, "agg_pool", "") in ("avg", "max") else "flat",
        "agg_pool": str(getattr(args, "agg_pool", "")),
        "flat": _export_conv1d(bb.output_layer_flat, out_dir, "output_flat", "backbone.output_flat"),
        "pool": _export_conv1d(bb.output_layer_pool, out_dir, "output_pool", "backbone.output_pool"),
    }

    meta = {
        "d_model": int(args.d_model),
        "d_inner": int(args.d_inner),
        "n_layer": int(args.n_layer),
        "d_conv": int(args.d_conv),
        "num_patches": int(args.num_patches),
        "patch_len": int(args.patch_len),
        "stride": int(args.stride),
        "seq_len": int(args.seq_len),
        "num_channels": int(args.num_channels),
        "forecast_len": int(args.forecast_len),
        "pe_on": bool(getattr(args, "pe_on", True)),
        "pe_scale": float(getattr(args, "pe_scale", 1.0)),
        "gate_off": bool(getattr(args, "gate_off", False)),
        "agg_pool": str(getattr(args, "agg_pool", "")),
        "use_dwconv": bool(getattr(args, "use_dwconv", False)),
    }

    j = {
        "version": 2,
        "type": "mamba_slim_backbone",
        "meta": meta,
        "bittrue": _bittrue_export_dict(),
        "patch_embedding": _export_conv1d(bb.patch_embedding, out_dir, "patch_embedding", "backbone.patch_embedding"),
        "positional_encoding": positional_encoding,
        "blocks": [_export_block(block, i, out_dir) for i, block in enumerate(bb.blocks)],
        "final_norm": _export_rmsnorm(bb.norm_f, out_dir, "final_norm", "backbone.final_norm"),
        "output_head": output_head,
    }

    with open(out_dir / "backbone.json", "w", encoding="utf-8") as f:
        json.dump(j, f, indent=2)
    return str(out_dir / "backbone.json")


def export_minimal(model: torch.nn.Module, out_dir: str) -> str:
    out_dir_p = Path(out_dir)
    out_dir_p.mkdir(parents=True, exist_ok=True)

    meta = {
        "input_dim": int(getattr(model, "Din", 0)),
        "seq_len": int(getattr(model, "K", 0)),
        "proj_dim": 64,
        "d_model": 96,
        "n_layer": 3,
        "patch_len": 8,
        "stride": 4,
        "forecast_len": 1,
        "output_dim": 2,
    }
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

    proj_desc = _export_conv1d(model.proj, out_dir_p, "proj", "proj")
    head_desc = _export_conv1d(model.head, out_dir_p, "head", "head")
    _save_backbone_params(model, out_dir_p)

    export_obj = {
        "version": 2,
        "type": "mamba_regressor",
        "model": meta,
        "quant": {
            "rounding": spec.ROUNDING,
            "saturate": spec.SATURATE,
            "act_bits": spec.ACT_BITS,
            "weight_bits": spec.W_BITS,
        },
        "bittrue": _bittrue_export_dict(),
        "proj": proj_desc,
        "backbone": {
            "type": "mamba_slim_backbone",
            "file": "backbone.json",
        },
        "head": head_desc,
    }

    export_path = out_dir_p / "export.json"
    with open(export_path, "w", encoding="utf-8") as f:
        json.dump(export_obj, f, indent=2)
    return str(export_path)
