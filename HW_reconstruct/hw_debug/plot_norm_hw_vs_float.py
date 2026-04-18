from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

import matplotlib
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt


def read_mem64(path: Path) -> np.ndarray:
    rows: list[int] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        s = line.strip()
        if s:
            rows.append(int(s, 16))
    return np.asarray(rows, dtype=np.uint64)


def unpack_q88_words(words: np.ndarray) -> np.ndarray:
    out = np.empty((words.shape[0], 4), dtype=np.int16)
    for i, word in enumerate(words.tolist()):
        for lane in range(4):
            val = (word >> (16 * lane)) & 0xFFFF
            if val >= 0x8000:
                val -= 0x10000
            out[i, lane] = val
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description="Plot RMSNorm float vs HW-equivalent outputs for a hw_debug case.")
    ap.add_argument("--case_dir", required=True, help="Path to hw_debug case directory, e.g. HW_reconstruct/hw_debug/cases/test_case_norm")
    ap.add_argument("--export_dir", default="export_bittrue/case1", help="Path to export directory that contains block0_norm_W.npy")
    ap.add_argument("--plot", default="", help="Optional output plot path. Defaults to <case_dir>/logs/norm_hw_vs_float.png")
    args = ap.parse_args()

    root = Path.cwd()
    case_dir = (root / args.case_dir).resolve() if not Path(args.case_dir).is_absolute() else Path(args.case_dir)
    export_dir = (root / args.export_dir).resolve() if not Path(args.export_dir).is_absolute() else Path(args.export_dir)
    stage_dir = case_dir / "stages" / "reuse_rmsnorm_scheduler"
    rtl_dir = case_dir / "rtl_out" / "reuse_rmsnorm_scheduler"
    logs_dir = case_dir / "logs"
    logs_dir.mkdir(parents=True, exist_ok=True)
    plot_path = Path(args.plot) if args.plot else (logs_dir / "norm_hw_vs_float.png")
    summary_path = logs_dir / "norm_hw_vs_float_summary.json"
    csv_path = logs_dir / "norm_hw_vs_float.csv"
    rtl_path = rtl_dir / "norm_rtl_q88.mem"

    if not rtl_path.exists():
        raise FileNotFoundError(
            f"Missing RTL dump: {rtl_path}. Run the rmsnorm hw_debug testbench first to generate norm_rtl_q88.mem."
        )

    raw_q88 = unpack_q88_words(read_mem64(stage_dir / "h_raw_wr_data_q88.mem")).reshape(-1)
    hw_q88 = unpack_q88_words(read_mem64(rtl_path)).reshape(-1)
    gamma_q88 = unpack_q88_words(read_mem64(stage_dir / "norm_weight_q88.mem")).reshape(-1)
    weight_f = np.load(export_dir / "block0_norm_W.npy").astype(np.float32).reshape(-1)

    x_f = raw_q88.astype(np.float32) / 256.0
    hw_f = hw_q88.astype(np.float32) / 256.0
    gamma_q88_f = gamma_q88.astype(np.float32) / 256.0

    rms_float = float(np.sqrt(np.mean(np.square(x_f, dtype=np.float64)) + 1e-5))
    float_out = (x_f / rms_float) * weight_f

    sum_sq = int(np.sum(raw_q88.astype(np.int64) * raw_q88.astype(np.int64)))
    dim = int(raw_q88.shape[0])
    mean_sq_q16 = (sum_sq + (dim // 2)) // dim
    rms_q88 = int(math.isqrt(max(1, mean_sq_q16 + 1)))
    rms_hw_f = rms_q88 / 256.0

    err = hw_f - float_out
    abs_err = np.abs(err)
    rel_err = abs_err / np.maximum(np.abs(float_out), 1e-8)
    float_qgamma = (x_f / rms_float) * gamma_q88_f
    err_vs_qgamma = hw_f - float_qgamma

    summary = {
        "count": int(hw_f.size),
        "rms_q88_from_integer_model": rms_q88,
        "rms_hw_float": rms_hw_f,
        "rms_float": rms_float,
        "rms_abs_diff": abs(rms_hw_f - rms_float),
        "mae_hw_vs_float": float(abs_err.mean()),
        "rmse_hw_vs_float": float(np.sqrt(np.mean(err ** 2))),
        "max_abs_err_hw_vs_float": float(abs_err.max()),
        "mean_rel_err_hw_vs_float": float(rel_err.mean()),
        "p95_abs_err_hw_vs_float": float(np.quantile(abs_err, 0.95)),
        "mae_hw_vs_float_qgamma": float(np.abs(err_vs_qgamma).mean()),
        "max_abs_err_hw_vs_float_qgamma": float(np.abs(err_vs_qgamma).max()),
    }
    summary_path.write_text(json.dumps(summary, indent=2), encoding="utf-8")

    rows = ["idx,raw_q88,raw_float,weight_float,weight_q88_float,hw_q88,hw_float,float_out,error"]
    for i in range(hw_f.size):
        rows.append(
            f"{i},{int(raw_q88[i])},{x_f[i]:.9f},{float(weight_f[i]):.9f},{gamma_q88_f[i]:.9f},"
            f"{int(hw_q88[i])},{hw_f[i]:.9f},{float_out[i]:.9f},{err[i]:.9f}"
        )
    csv_path.write_text("\n".join(rows), encoding="utf-8")

    idx = np.arange(hw_f.size)
    fig, axes = plt.subplots(2, 1, figsize=(12, 7.2), constrained_layout=True)

    axes[0].plot(idx, float_out, label="Float RMSNorm", linewidth=1.6, linestyle="-")
    axes[0].plot(idx, hw_f, label="HW-equivalent Q8.8", linewidth=1.3, linestyle="--", alpha=0.95)
    axes[0].set_title("Norm Output: Float vs HW")
    axes[0].set_xlabel("Channel")
    axes[0].set_ylabel("Value")
    axes[0].legend()
    axes[0].grid(True, alpha=0.25)

    axes[1].plot(idx, err, color="tab:red", linewidth=1.2)
    axes[1].axhline(0.0, color="black", linewidth=0.8)
    axes[1].set_title("Error: HW - Float")
    axes[1].set_xlabel("Channel")
    axes[1].set_ylabel("Error")
    axes[1].grid(True, alpha=0.25)

    fig.suptitle(
        f"RMSNorm Approximation\nrms_float={rms_float:.6f}, rms_hw={rms_hw_f:.6f}, "
        f"MAE={abs_err.mean():.6f}, max|err|={abs_err.max():.6f}",
        fontsize=13,
    )
    fig.savefig(plot_path, dpi=160)
    plt.close(fig)

    print(f"plot={plot_path}")
    print(f"csv={csv_path}")
    print(f"summary={summary_path}")


if __name__ == "__main__":
    main()
