from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path

import numpy as np

from refactor.bittrue.debug_dt_chain_mismatch import _tensor_stats
from refactor.bittrue.eval_bittrue import _metric_dict
from refactor.bittrue.eval_hw_like_full import _forward_full_hw_like, _run_cpp_batch
from refactor.bittrue.export_hw_debug import _load_packed_mem_q88


def _write_json(path: Path, obj: dict | list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2), encoding="utf-8")


def _run_block0_batch(
    cpp_block0_bin: Path,
    export_json: Path,
    samples_npy: Path,
    out_npy: Path,
    din: int,
    mode: str,
) -> np.ndarray:
    cmd = [
        str(cpp_block0_bin),
        str(export_json),
        str(samples_npy),
        str(din),
        str(out_npy),
        "--mode",
        mode,
    ]
    subprocess.run(cmd, check=True)
    return np.load(out_npy).astype(np.float32)


def main() -> None:
    p = argparse.ArgumentParser(description="Evaluate the test-only RTL-like selective-scan C++ path.")
    p.add_argument("--export_json", type=str, required=True)
    p.add_argument("--case_dir", type=str, required=True)
    p.add_argument("--cpp_batch_bin", type=str, default="build/bittrue/main_batch.exe")
    p.add_argument("--cpp_block0_bin", type=str, default="build/bittrue/main_block0_y.exe")
    p.add_argument("--din", type=int, default=2100)
    args = p.parse_args()

    export_json = Path(args.export_json)
    case_dir = Path(args.case_dir)
    float_dir = case_dir / "float"
    log_dir = case_dir / "logs"
    cpp_batch_bin = Path(args.cpp_batch_bin)
    cpp_block0_bin = Path(args.cpp_block0_bin)
    log_dir.mkdir(parents=True, exist_ok=True)

    samples = np.load(float_dir / "samples.npy").astype(np.float32)
    y_true = np.load(float_dir / "y_true.npy").astype(np.float32)
    y_float = np.load(float_dir / "y_float.npy").astype(np.float32)

    y_cpp = _run_cpp_batch(
        cpp_batch_bin,
        export_json,
        float_dir / "samples.npy",
        float_dir / "cpp_full_int16.npy",
        int(args.din),
        mode="int16",
    )
    y_cpp_rtl_ssm = _run_cpp_batch(
        cpp_batch_bin,
        export_json,
        float_dir / "samples.npy",
        float_dir / "cpp_full_rtl_ssm_test.npy",
        int(args.din),
        mode="rtl_ssm_test",
    )

    y_hw = np.zeros_like(y_cpp, dtype=np.float32)
    for i in range(samples.shape[0]):
        hw_out, _ = _forward_full_hw_like(export_json, samples[i])
        y_hw[i] = hw_out
    np.save(float_dir / "hw_like_full.npy", y_hw.astype(np.float32))

    block0_cpp = _run_block0_batch(
        cpp_block0_bin,
        export_json,
        float_dir / "samples.npy",
        float_dir / "cpp_block0_y_cppbittrue.npy",
        int(args.din),
        mode="int16",
    )
    block0_cpp_rtl_ssm = _run_block0_batch(
        cpp_block0_bin,
        export_json,
        float_dir / "samples.npy",
        float_dir / "cpp_block0_y_rtl_ssm_test.npy",
        int(args.din),
        mode="rtl_ssm_test",
    )
    block0_golden = _load_packed_mem_q88(case_dir / "stages" / "reuse_mamba_block_top" / "y_golden_q88.mem").astype(np.float32)

    cpp_rtl_vs_cpp = np.abs(y_cpp_rtl_ssm - y_cpp)
    cpp_rtl_vs_hw = np.abs(y_cpp_rtl_ssm - y_hw)
    cpp_rtl_vs_float = np.abs(y_cpp_rtl_ssm - y_float)
    hw_vs_cpp = np.abs(y_hw - y_cpp)

    summary = {
        "samples": int(samples.shape[0]),
        "full_output": {
            "rtl_ssm_test_vs_cpp": {
                "mae": float(np.mean(cpp_rtl_vs_cpp)),
                "max_abs": float(np.max(cpp_rtl_vs_cpp)),
            },
            "rtl_ssm_test_vs_hw_like": {
                "mae": float(np.mean(cpp_rtl_vs_hw)),
                "max_abs": float(np.max(cpp_rtl_vs_hw)),
            },
            "rtl_ssm_test_vs_float": {
                "mae": float(np.mean(cpp_rtl_vs_float)),
                "max_abs": float(np.max(cpp_rtl_vs_float)),
            },
            "hw_like_vs_cpp": {
                "mae": float(np.mean(hw_vs_cpp)),
                "max_abs": float(np.max(hw_vs_cpp)),
            },
            "metrics_vs_y_true": {
                "cpp_int16": _metric_dict(y_true, y_cpp),
                "cpp_rtl_ssm_test": _metric_dict(y_true, y_cpp_rtl_ssm),
                "hw_like": _metric_dict(y_true, y_hw),
            },
        },
        "block0_local_y_sample0": {
            "cpp_int16_vs_golden": _tensor_stats(block0_cpp[0], block0_golden),
            "cpp_rtl_ssm_test_vs_golden": _tensor_stats(block0_cpp_rtl_ssm[0], block0_golden),
            "cpp_rtl_ssm_test_vs_cpp_int16": _tensor_stats(block0_cpp_rtl_ssm[0], block0_cpp[0]),
        },
        "sample0": {
            "y_cpp_int16": y_cpp[0].astype(float).tolist(),
            "y_cpp_rtl_ssm_test": y_cpp_rtl_ssm[0].astype(float).tolist(),
            "y_hw_like": y_hw[0].astype(float).tolist(),
            "y_true": y_true[0].astype(float).tolist(),
            "block0_cpp_int16_row0": block0_cpp[0, 0].astype(float).tolist(),
            "block0_cpp_rtl_ssm_test_row0": block0_cpp_rtl_ssm[0, 0].astype(float).tolist(),
            "block0_golden_row0": block0_golden[0].astype(float).tolist(),
        },
    }

    out_json = log_dir / "cpp_rtl_ssm_test_eval.json"
    _write_json(out_json, summary)
    print(json.dumps(summary, indent=2))
    print(f"[saved] {out_json}")


if __name__ == "__main__":
    main()
