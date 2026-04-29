#!/usr/bin/env python3
"""Compare floating-point RMSNorm with the fixed-point hardware approximation.

The script reads the existing stage .mem files, computes a float reference from
the same dequantized Q8.8 input/gamma values, and compares it with the hardware
golden Q8.8 RMSNorm output.
"""

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path


Q88_SCALE = 256.0
INT16_MIN = -32768
INT16_MAX = 32767


def to_s16(v: int) -> int:
    v &= 0xFFFF
    return v - 0x10000 if v & 0x8000 else v


def unpack_vec4_hex(word_hex: str) -> list[int]:
    word = int(word_hex.strip(), 16)
    return [to_s16((word >> (16 * lane)) & 0xFFFF) for lane in range(4)]


def read_vec4_mem(path: Path) -> list[int]:
    values: list[int] = []
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        values.extend(unpack_vec4_hex(line))
    return values


def sat_s16(v: int) -> int:
    return max(INT16_MIN, min(INT16_MAX, v))


def round_to_q88(v: float) -> int:
    return sat_s16(int(round(v * Q88_SCALE)))


def float_rmsnorm_q88(x_q88: list[int], gamma_q88: list[int], eps_q16: int) -> list[int]:
    x = [v / Q88_SCALE for v in x_q88]
    gamma = [v / Q88_SCALE for v in gamma_q88]
    eps = eps_q16 / (Q88_SCALE * Q88_SCALE)
    rms = math.sqrt(sum(v * v for v in x) / len(x) + eps)
    return [round_to_q88((xi / rms) * gi) for xi, gi in zip(x, gamma)]


def hw_like_rmsnorm_q88(x_q88: list[int], gamma_q88: list[int], eps_q16: int) -> list[int]:
    """Software model of reuse_rmsnorm_scheduler.sv arithmetic."""
    dim = len(x_q88)
    sum_sq = sum(v * v for v in x_q88)
    mean_sq_q16 = ((sum_sq + (dim // 2)) // dim) + eps_q16
    rms_q88 = math.isqrt(mean_sq_q16) or 1
    recip_q30 = ((1 << 30) + (rms_q88 >> 1)) // rms_q88
    half = 1 << 29

    out: list[int] = []
    for x, g in zip(x_q88, gamma_q88):
        mul = x * g * recip_q30
        rounded = mul + half if mul >= 0 else mul - half
        out.append(sat_s16(rounded >> 30))
    return out


def write_csv(path: Path, x_q88: list[int], gamma_q88: list[int], float_q88: list[int],
              hw_q88: list[int], hw_model_q88: list[int]) -> None:
    with path.open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([
            "index",
            "x_q88",
            "gamma_q88",
            "float_ref_q88",
            "hw_golden_q88",
            "hw_model_q88",
            "float_ref_real",
            "hw_golden_real",
            "abs_error_real",
        ])
        for i, (x, g, fr, hw, model) in enumerate(zip(x_q88, gamma_q88, float_q88, hw_q88, hw_model_q88)):
            writer.writerow([
                i,
                x,
                g,
                fr,
                hw,
                model,
                fr / Q88_SCALE,
                hw / Q88_SCALE,
                abs(fr - hw) / Q88_SCALE,
            ])


def maybe_plot(path: Path, float_q88: list[int], hw_q88: list[int]) -> bool:
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        return False

    xs = list(range(len(float_q88)))
    float_real = [v / Q88_SCALE for v in float_q88]
    hw_real = [v / Q88_SCALE for v in hw_q88]
    err_real = [abs(a - b) for a, b in zip(float_real, hw_real)]
    mean_err = sum(err_real) / len(err_real)

    fig, (ax0, ax1) = plt.subplots(2, 1, figsize=(11, 6), sharex=True)
    ax0.plot(xs, float_real, label="Float reference", linewidth=1.6)
    ax0.plot(xs, hw_real, label="HW fixed-point approx", linewidth=1.2, linestyle="--")
    ax0.set_ylabel("RMSNorm output")
    ax0.grid(True, alpha=0.3)
    ax0.legend()

    ax1.plot(xs, err_real, color="tab:red", linewidth=1.2)
    ax1.set_xlabel("Hidden element index")
    ax1.set_ylabel("Absolute error")
    ax1.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig(path, dpi=180)
    return True


def write_svg(path: Path, float_q88: list[int], hw_q88: list[int]) -> None:
    width = 1100
    height = 620
    left = 70
    right = 30
    top = 35
    mid = 350
    bottom = 575
    plot_w = width - left - right

    float_real = [v / Q88_SCALE for v in float_q88]
    hw_real = [v / Q88_SCALE for v in hw_q88]
    err_real = [abs(a - b) for a, b in zip(float_real, hw_real)]
    mean_err = sum(err_real) / len(err_real)

    y_min = min(float_real + hw_real)
    y_max = max(float_real + hw_real)
    if y_min == y_max:
        y_min -= 1.0
        y_max += 1.0
    err_max = max(err_real) or 1.0

    def x_pos(i: int) -> float:
        return left + (i / max(1, len(float_real) - 1)) * plot_w

    def y_main(v: float) -> float:
        return top + (y_max - v) / (y_max - y_min) * (mid - top - 35)

    def y_err(v: float) -> float:
        return mid + 55 + (err_max - v) / err_max * (bottom - mid - 55)

    def polyline(values: list[float], y_fn) -> str:
        return " ".join(f"{x_pos(i):.2f},{y_fn(v):.2f}" for i, v in enumerate(values))

    svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
  <style>
    text {{ font-family: Arial, sans-serif; font-size: 14px; fill: #222; }}
    .axis {{ stroke: #777; stroke-width: 1; }}
    .grid {{ stroke: #ddd; stroke-width: 1; }}
    .float {{ fill: none; stroke: #1f77b4; stroke-width: 2; }}
    .hw {{ fill: none; stroke: #ff7f0e; stroke-width: 2; stroke-dasharray: 7 5; }}
    .err {{ fill: none; stroke: #d62728; stroke-width: 1.8; }}
  </style>
  <rect width="100%" height="100%" fill="white"/>
  <text x="{left}" y="22" font-weight="bold">RMSNorm Float Reference vs Hardware Fixed-point Approximation</text>
  <line class="axis" x1="{left}" y1="{top}" x2="{left}" y2="{mid - 35}"/>
  <line class="axis" x1="{left}" y1="{mid - 35}" x2="{width - right}" y2="{mid - 35}"/>
  <line class="grid" x1="{left}" y1="{y_main(0.0):.2f}" x2="{width - right}" y2="{y_main(0.0):.2f}"/>
  <text x="12" y="{top + 20}">Output</text>
  <text x="{left}" y="{mid - 10}">min={y_min:.4f}, max={y_max:.4f}</text>
  <polyline class="float" points="{polyline(float_real, y_main)}"/>
  <polyline class="hw" points="{polyline(hw_real, y_main)}"/>
  <line x1="{left + 660}" y1="20" x2="{left + 710}" y2="20" class="float"/>
  <text x="{left + 720}" y="25">Float reference</text>
  <line x1="{left + 850}" y1="20" x2="{left + 900}" y2="20" class="hw"/>
  <text x="{left + 910}" y="25">HW approximation</text>

  <text x="{left}" y="{mid + 35}" font-weight="bold">Absolute Error</text>
  <line class="axis" x1="{left}" y1="{mid + 55}" x2="{left}" y2="{bottom}"/>
  <line class="axis" x1="{left}" y1="{bottom}" x2="{width - right}" y2="{bottom}"/>
  <text x="12" y="{mid + 80}">Abs err</text>
  <text x="{left}" y="{bottom + 25}">Hidden element index</text>
  <text x="{left}" y="{mid + 52}">mean={mean_err:.6f}, max={err_max:.6f}</text>
  <polyline class="err" points="{polyline(err_real, y_err)}"/>
</svg>
"""
    path.write_text(svg)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--stage-dir",
        default="final_hw/cases/c02/stages/reuse_mamba_block_top_block0",
        help="Directory containing h_wr_data_s16_q8p8.mem, norm_gamma_s16_q8p8.mem, and h_norm_golden_s16_q8p8.mem.",
    )
    parser.add_argument("--eps-q16", type=int, default=1)
    parser.add_argument("--csv", default="final_hw/docs/rmsnorm_float_vs_hw.csv")
    parser.add_argument("--png", default="final_hw/docs/rmsnorm_float_vs_hw.png")
    parser.add_argument("--svg", default="final_hw/docs/rmsnorm_float_vs_hw.svg")
    args = parser.parse_args()

    stage_dir = Path(args.stage_dir)
    x_q88 = read_vec4_mem(stage_dir / "h_wr_data_s16_q8p8.mem")
    gamma_q88 = read_vec4_mem(stage_dir / "norm_gamma_s16_q8p8.mem")
    hw_q88 = read_vec4_mem(stage_dir / "h_norm_golden_s16_q8p8.mem")

    if not (len(x_q88) == len(gamma_q88) == len(hw_q88)):
        raise SystemExit(
            f"Length mismatch: x={len(x_q88)}, gamma={len(gamma_q88)}, hw={len(hw_q88)}"
        )

    float_q88 = float_rmsnorm_q88(x_q88, gamma_q88, args.eps_q16)
    hw_model_q88 = hw_like_rmsnorm_q88(x_q88, gamma_q88, args.eps_q16)

    csv_path = Path(args.csv)
    png_path = Path(args.png)
    svg_path = Path(args.svg)
    csv_path.parent.mkdir(parents=True, exist_ok=True)
    png_path.parent.mkdir(parents=True, exist_ok=True)
    svg_path.parent.mkdir(parents=True, exist_ok=True)
    write_csv(csv_path, x_q88, gamma_q88, float_q88, hw_q88, hw_model_q88)
    write_svg(svg_path, float_q88, hw_q88)
    plotted = maybe_plot(png_path, float_q88, hw_q88)

    abs_err = [abs(a - b) / Q88_SCALE for a, b in zip(float_q88, hw_q88)]
    max_err = max(abs_err)
    mean_err = sum(abs_err) / len(abs_err)
    model_mismatch = sum(1 for a, b in zip(hw_q88, hw_model_q88) if a != b)

    print(f"stage_dir={stage_dir}")
    print(f"elements={len(x_q88)}")
    print(f"csv={csv_path}")
    print(f"svg={svg_path}")
    print(f"png={png_path if plotted else 'not generated: matplotlib is not installed'}")
    print(f"max_abs_error_real={max_err:.8f}")
    print(f"mean_abs_error_real={mean_err:.8f}")
    print(f"hw_model_mismatch_count={model_mismatch}")


if __name__ == "__main__":
    main()
