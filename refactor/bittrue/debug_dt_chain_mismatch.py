from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from refactor.bittrue.eval_hw_like_full import _forward_full_cppish
from refactor.bittrue.hw_like_chain4 import (
    _conv1d_run_integer_desc,
    _quant_q88,
    block_step_hw_q88_trace,
    build_chain4_ctx,
)


def _tensor_stats(a: np.ndarray, b: np.ndarray) -> dict:
    if a.shape != b.shape:
        if a.size != b.size:
            raise ValueError(f"shape mismatch with different element count: {a.shape} vs {b.shape}")
        a = a.reshape(-1)
        b = b.reshape(-1)
    d = np.abs(a.astype(np.float32) - b.astype(np.float32))
    flat = d.reshape(-1)
    idx = int(np.argmax(flat))
    return {
        "shape": list(a.shape),
        "mae": float(np.mean(flat)),
        "max_abs": float(np.max(flat)),
        "max_abs_flat_index": idx,
    }


def _q88_to_f32(x: np.ndarray) -> np.ndarray:
    return x.astype(np.float32) / 256.0


def _q016_to_f32(x: np.ndarray) -> np.ndarray:
    return x.astype(np.float32) / float(1 << 16)


def _forward_full_hw_like(export_json: Path, case_dir: Path, x_sample_kd: np.ndarray, scan_mode: str) -> tuple[np.ndarray, list[dict]]:
    ctx = build_chain4_ctx(export_json, case_dir=case_dir)
    export = ctx["export"]
    backbone = ctx["backbone"]
    base_dir = ctx["base_dir"]
    seq_len = int(export["model"]["seq_len"])

    proj = _conv1d_run_integer_desc(export["proj"], base_dir, x_sample_kd.astype(np.float32), seq_len, bits=16)
    patch = _conv1d_run_integer_desc(backbone["patch_embedding"], base_dir, proj, proj.shape[0], bits=16)
    if backbone.get("positional_encoding", {}).get("enabled") and backbone["positional_encoding"].get("file"):
        pe = np.load(base_dir / backbone["positional_encoding"]["file"]).astype(np.float32)
        patch += float(backbone["positional_encoding"].get("scale", 1.0)) * pe.reshape(patch.shape)

    x_q88 = _quant_q88(patch.reshape(-1)).astype(np.int16)
    traces: list[dict] = [{"stage": "patch_embedding", "x_next": _q88_to_f32(x_q88).reshape(32, 4)}]
    for bi, blk_cache in enumerate(ctx["blocks"]):
        hw = block_step_hw_q88_trace(blk_cache, x_q88, scan_mode=scan_mode)
        traces.append(
            {
                "stage": f"block{bi}",
                "x_norm": _q88_to_f32(hw["h_norm_q88"]),
                "u": _q88_to_f32(hw["u_q88_rows"]),
                "z": _q88_to_f32(hw["z_q88_rows"]),
                "u_act": _q88_to_f32(hw["u_act_q88"]),
                "z_silu": _q88_to_f32(hw["z_silu_q88"]),
                "dt": _q88_to_f32(hw["dt_q88"]),
                "lam": _q016_to_f32(hw["lam_q016"]),
                "ssm_scan": _q88_to_f32(hw["ssm_q88"]),
                "gate_y": _q88_to_f32(hw["gate_y_q88"]),
                "y_blk": _q88_to_f32(hw["y_q88"]),
                "x_next": _q88_to_f32(hw["x_next_q88"]),
            }
        )
        x_q88 = hw["x_next_q88"].reshape(-1).astype(np.int16)
    return _q88_to_f32(x_q88).reshape(32, 4), traces


def _block_report(cpp_b: dict, hw_b: dict) -> dict:
    return {
        "norm": _tensor_stats(cpp_b["x_norm"], hw_b["x_norm"]),
        "inproj_u": _tensor_stats(cpp_b["u"], hw_b["u"]),
        "inproj_z": _tensor_stats(cpp_b["z"], hw_b["z"]),
        "silu_u": _tensor_stats(cpp_b["u_act"], hw_b["u_act"]),
        "silu_gate": _tensor_stats(cpp_b["z_silu"], hw_b["z_silu"]),
        "dtproj": _tensor_stats(cpp_b["dt"], hw_b["dt"]),
        "dt_sigmoid": _tensor_stats(cpp_b["lam"], hw_b["lam"]),
        "selective_scan": _tensor_stats(cpp_b["ssm_scan"], hw_b["ssm_scan"]),
        "ewm_gating": _tensor_stats(cpp_b["gate_y"], hw_b["gate_y"]),
        "outproj": _tensor_stats(cpp_b["y_blk"], hw_b["y_blk"]),
        "block_output": _tensor_stats(cpp_b["x_next"], hw_b["x_next"]),
    }


def main() -> None:
    p = argparse.ArgumentParser(description="Debug dt/ssm chain mismatch between cpp-like and hw-like semantics.")
    p.add_argument("--export_json", type=str, required=True)
    p.add_argument("--case_dir", type=str, required=True)
    p.add_argument("--sample_idx", type=int, default=0)
    p.add_argument("--scan_mode", type=str, default="fixed_q88", choices=["fixed_q88", "scaled_state"])
    args = p.parse_args()

    export_json = Path(args.export_json)
    case_dir = Path(args.case_dir)
    samples = np.load(case_dir / "float" / "samples.npy").astype(np.float32)
    sample_idx = int(args.sample_idx)
    x = samples[sample_idx]

    _, cpp_traces = _forward_full_cppish(export_json, x)
    _, hw_traces = _forward_full_hw_like(export_json, case_dir, x, scan_mode=args.scan_mode)
    cpp_map = {t["stage"]: t for t in cpp_traces}
    hw_map = {t["stage"]: t for t in hw_traces}

    report = {
        "sample_idx": sample_idx,
        "scan_mode": args.scan_mode,
        "blocks": {
            name: _block_report(cpp_map[name], hw_map[name])
            for name in sorted(cpp_map)
            if name.startswith("block") and name in hw_map
        },
    }

    suffix = "" if args.scan_mode == "fixed_q88" else f"_{args.scan_mode}"
    out = case_dir / "logs" / f"dt_chain_debug_sample{sample_idx}{suffix}.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report, indent=2))
    print(f"[saved] {out}")


if __name__ == "__main__":
    main()
