from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path

import numpy as np


def _load_npy(path: Path, limit: int = 0) -> np.ndarray:
    arr = np.load(path).astype(np.float32)
    if limit > 0:
        arr = arr[:limit]
    return arr


def _err_norm(y_true: np.ndarray, y_pred: np.ndarray) -> np.ndarray:
    return np.sqrt(np.sum((y_pred - y_true) ** 2, axis=1))


def _abs_diff(y_a: np.ndarray, y_b: np.ndarray) -> np.ndarray:
    return np.abs(y_a - y_b)


def _summary(values: np.ndarray) -> dict:
    flat = values.reshape(-1).astype(np.float64)
    return {
        "mean": float(np.mean(flat)),
        "median": float(np.median(flat)),
        "p80": float(np.percentile(flat, 80)),
        "p90": float(np.percentile(flat, 90)),
        "p95": float(np.percentile(flat, 95)),
        "p99": float(np.percentile(flat, 99)),
        "max": float(np.max(flat)),
    }


def _metric_summary(y_true: np.ndarray, y_pred: np.ndarray) -> dict:
    return _summary(_err_norm(y_true, y_pred))


def _bootstrap_mean_ci(values: np.ndarray, rounds: int, seed: int) -> dict:
    flat = values.reshape(-1).astype(np.float64)
    rng = np.random.default_rng(seed)
    means = np.empty(rounds, dtype=np.float64)
    n = flat.shape[0]
    for i in range(rounds):
        means[i] = np.mean(flat[rng.integers(0, n, size=n)])
    return {
        "mean": float(np.mean(flat)),
        "ci95_low": float(np.percentile(means, 2.5)),
        "ci95_high": float(np.percentile(means, 97.5)),
        "bootstrap_rounds": int(rounds),
    }


def main() -> None:
    p = argparse.ArgumentParser(description="Analyze quantization degradation, error distribution, and outliers.")
    p.add_argument("--case_dir", type=str, required=True)
    p.add_argument("--limit", type=int, default=0, help="Use first N samples from the latest hw_like_full.npy; 0 means all available.")
    p.add_argument("--top_k", type=int, default=20)
    p.add_argument("--bootstrap", type=int, default=1000)
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--out_json", type=str, default="")
    p.add_argument("--out_csv", type=str, default="")
    args = p.parse_args()

    case_dir = Path(args.case_dir)
    float_dir = case_dir / "float"
    log_dir = case_dir / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)

    y_true = _load_npy(float_dir / "y_true.npy", args.limit)
    y_float = _load_npy(float_dir / "y_float.npy", args.limit)
    y_cpp = _load_npy(float_dir / "cpp_full_int16.npy", args.limit)
    y_hw = _load_npy(float_dir / "hw_like_full.npy", args.limit)

    n = min(y_true.shape[0], y_float.shape[0], y_cpp.shape[0], y_hw.shape[0])
    y_true = y_true[:n]
    y_float = y_float[:n]
    y_cpp = y_cpp[:n]
    y_hw = y_hw[:n]

    float_err = _err_norm(y_true, y_float)
    cpp_err = _err_norm(y_true, y_cpp)
    hw_err = _err_norm(y_true, y_hw)
    hw_minus_float = hw_err - float_err
    hw_vs_float = _abs_diff(y_hw, y_float)
    hw_vs_cpp = _abs_diff(y_hw, y_cpp)

    worst_order = np.argsort(-hw_minus_float)[: int(args.top_k)]
    outliers = []
    for idx in worst_order:
        outliers.append(
            {
                "sample_index": int(idx),
                "float_err": float(float_err[idx]),
                "cpp_err": float(cpp_err[idx]),
                "hw_err": float(hw_err[idx]),
                "hw_minus_float": float(hw_minus_float[idx]),
                "hw_vs_float_mae": float(np.mean(hw_vs_float[idx])),
                "hw_vs_float_max_abs": float(np.max(hw_vs_float[idx])),
                "y_true": y_true[idx].astype(float).tolist(),
                "y_float": y_float[idx].astype(float).tolist(),
                "y_cpp": y_cpp[idx].astype(float).tolist(),
                "y_hw": y_hw[idx].astype(float).tolist(),
            }
        )

    report = {
        "samples": int(n),
        "task_metrics_vs_y_true": {
            "float": _metric_summary(y_true, y_float),
            "cpp_int16": _metric_summary(y_true, y_cpp),
            "hw_like": _metric_summary(y_true, y_hw),
            "hw_minus_float_err": _summary(hw_minus_float),
            "cpp_minus_float_err": _summary(cpp_err - float_err),
        },
        "numeric_diff": {
            "hw_like_vs_float_abs": _summary(hw_vs_float),
            "hw_like_vs_cpp_abs": _summary(hw_vs_cpp),
            "hw_like_vs_float_mean_ci95": _bootstrap_mean_ci(hw_vs_float, int(args.bootstrap), int(args.seed)),
        },
        "outliers_by_task_degradation": outliers,
    }

    out_json = Path(args.out_json) if args.out_json else log_dir / f"quant_eval_analysis_{n}samples.json"
    out_csv = Path(args.out_csv) if args.out_csv else log_dir / f"quant_eval_outliers_{n}samples.csv"

    out_json.write_text(json.dumps(report, indent=2), encoding="utf-8")
    with out_csv.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "sample_index",
                "float_err",
                "cpp_err",
                "hw_err",
                "hw_minus_float",
                "hw_vs_float_mae",
                "hw_vs_float_max_abs",
            ],
        )
        writer.writeheader()
        for row in outliers:
            writer.writerow({k: row[k] for k in writer.fieldnames})

    print(json.dumps(report["task_metrics_vs_y_true"], indent=2))
    print(f"[analysis] wrote {out_json}")
    print(f"[analysis] wrote {out_csv}")


if __name__ == "__main__":
    main()
