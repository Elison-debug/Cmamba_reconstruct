from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from refactor.bittrue.eval_hw_like_full import _forward_full_cppish, _forward_full_hw_like


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
    _, hw_traces = _forward_full_hw_like(export_json, x, scan_mode=args.scan_mode)
    cpp_map = {t["stage"]: t for t in cpp_traces}
    hw_map = {t["stage"]: t for t in hw_traces}

    cpp_b0 = cpp_map["block0"]
    hw_b0 = hw_map["block0"]

    report = {
        "sample_idx": sample_idx,
        "scan_mode": args.scan_mode,
        "block0": {
            "norm": _tensor_stats(cpp_b0["x_norm"], hw_b0["x_norm"]),
            "inproj_u": _tensor_stats(cpp_b0["u"], hw_b0["u"]),
            "inproj_z": _tensor_stats(cpp_b0["z"], hw_b0["z"]),
            "silu_gate": _tensor_stats(cpp_b0["z_silu"], hw_b0["z_silu"]),
            "dtproj": _tensor_stats(cpp_b0["dt"], hw_b0["dt"]),
            "dt_sigmoid": _tensor_stats(cpp_b0["lam"], hw_b0["lam"]),
            "selective_scan": _tensor_stats(cpp_b0["ssm_scan"], hw_b0["ssm_scan"]),
            "ewm_gating": _tensor_stats(cpp_b0["gate_y"], hw_b0["gate_y"]),
            "outproj": _tensor_stats(cpp_b0["y_blk"], hw_b0["y_blk"]),
            "block_output": _tensor_stats(cpp_b0["x_next"], hw_b0["x_next"]),
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
