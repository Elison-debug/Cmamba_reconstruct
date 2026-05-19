from __future__ import annotations

import argparse
import csv
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
CMAMBA_ROOT = Path(r"E:\course\master\mamba\CMamba_stable")


@dataclass(frozen=True)
class CurveSpec:
    label: str
    npz_path: Path
    color: str
    linestyle: str = "-"
    linewidth: float = 2.0


def _ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def _set_academic_style() -> None:
    plt.rcParams.update(
        {
            "font.family": "serif",
            "font.serif": ["Times New Roman", "Times", "DejaVu Serif"],
            "font.size": 10,
            "axes.labelsize": 11,
            "axes.titlesize": 11,
            "axes.linewidth": 0.8,
            "legend.fontsize": 9,
            "xtick.labelsize": 9,
            "ytick.labelsize": 9,
            "grid.linewidth": 0.5,
            "grid.alpha": 0.35,
            "lines.linewidth": 2.0,
            "savefig.dpi": 300,
            "savefig.bbox": "tight",
        }
    )


def _load_err(npz_path: Path) -> np.ndarray:
    data = np.load(npz_path)
    err = data["err"].astype(np.float64)
    return np.sort(err)


def _load_aggregated_err(grid_root: Path) -> np.ndarray:
    direct_npz = grid_root / "val_preds.npz"
    if direct_npz.exists():
        data = np.load(direct_npz)
        return np.sort(data["err"].astype(np.float64).ravel())

    all_err: list[np.ndarray] = []
    for npz_path in sorted(grid_root.glob("Grid*/val_preds.npz")):
        data = np.load(npz_path)
        all_err.append(data["err"].astype(np.float64).ravel())
    if not all_err:
        raise FileNotFoundError(f"No Grid*/val_preds.npz found under {grid_root}")
    return np.sort(np.concatenate(all_err, axis=0))


def _load_summary_csv(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    df["grid_num"] = df["name"].str.extract(r"(\d+)").astype(int)
    return df


def _load_pred_vs_true(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path, header=None)
    if df.shape[1] < 5:
        raise ValueError(f"Expected at least 5 columns in {csv_path}")
    df = df.iloc[:, :5].copy()
    df.columns = ["y_true_x", "y_true_y", "y_pred_x", "y_pred_y", "err_m"]
    for col in df.columns:
        df[col] = pd.to_numeric(df[col], errors="coerce")
    df = df.dropna().reset_index(drop=True)
    return df


def _cdf_xy(sorted_err: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
    y = np.arange(1, len(sorted_err) + 1, dtype=np.float64) / len(sorted_err)
    return sorted_err, y


def plot_k_ablation_cdf(output_path: Path) -> None:
    specs = [
        CurveSpec(
            label=r"$K=2$, patch $(2,2)$",
            npz_path=ROOT / "eval_out_abolation_K" / "parity_2100_K2_pl2_test" / "baseline" / "val_preds.npz",
            color="#1f77b4",
        ),
        CurveSpec(
            label=r"$K=8$, patch $(8,4)$",
            npz_path=ROOT / "eval_out_abolation_K" / "parity_2100_K8_pl2_test" / "baseline" / "val_preds.npz",
            color="#d62728",
        ),
        CurveSpec(
            label=r"$K=16$, patch $(8,4)$",
            npz_path=ROOT / "eval_out_abolation_K" / "parity_2100_K16_test" / "baseline" / "val_preds.npz",
            color="#2ca02c",
        ),
        CurveSpec(
            label=r"$K=32$, patch $(8,4)$",
            npz_path=ROOT / "eval_out_abolation_K" / "parity_2100_K32_test" / "baseline" / "val_preds.npz",
            color="#7f7f7f",
            linestyle="--",
        ),
    ]

    fig, ax = plt.subplots(figsize=(6.4, 4.3))
    for spec in specs:
        err = _load_err(spec.npz_path)
        x, y = _cdf_xy(err)
        ax.plot(
            x,
            y,
            label=f"{spec.label}  ({np.mean(err):.3f} m)",
            color=spec.color,
            linestyle=spec.linestyle,
            linewidth=spec.linewidth,
        )

    ax.set_xlim(0.0, 0.6)
    ax.set_ylim(0.0, 1.0)
    ax.set_xlabel("Position error (m)")
    ax.set_ylabel("CDF")
    ax.grid(True, linestyle="--")
    ax.legend(
        loc="lower right",
        frameon=True,
        framealpha=0.95,
        labelspacing=0.35,
        borderpad=0.55,
        handlelength=2.0,
    )
    fig.savefig(output_path)
    plt.close(fig)


def plot_model_comparison_cdf(output_path: Path) -> None:
    specs = [
        ("Slim-Mamba (CIR + Power)", ROOT / "test_out_ablation_K" / "parity_test", "#1f77b4", "-"),
        (
            "channel mamba (CIR + Power)",
            CMAMBA_ROOT / "test" / "eval_out_testing_1",
            "#ff7f0e",
            "-.",
        ),
        (
            "channel mamba (CIR + Power + 100 amplitude channels)",
            CMAMBA_ROOT / "test" / "eval_out_bak",
            "#d62728",
            "--",
        ),
    ]

    fig, ax = plt.subplots(figsize=(6.2, 4.1))
    for label, grid_root, color, linestyle in specs:
        err = _load_aggregated_err(grid_root)
        x, y = _cdf_xy(err)
        ax.plot(
            x,
            y,
            color=color,
            linestyle=linestyle,
            linewidth=2.1,
            label=f"{label}  ({np.mean(err):.3f} m)",
        )

    ax.set_xlim(0.0, 0.5)
    ax.set_ylim(0.0, 1.0)
    ax.set_xlabel("Position error (m)")
    ax.set_ylabel("CDF")
    ax.grid(True, linestyle="--")
    ax.legend(
        loc="lower right",
        frameon=True,
        framealpha=0.95,
        borderpad=0.55,
        handlelength=2.1,
        labelspacing=0.35,
    )
    fig.savefig(output_path)
    plt.close(fig)


def plot_slim_grid_ranking(output_path: Path) -> None:
    csv_path = ROOT / "test_out_ablation_K" / "parity_test" / "eval_summary.csv"
    df = _load_summary_csv(csv_path)
    df = df.sort_values("mean", ascending=True).reset_index(drop=True)

    typical_idx = len(df) // 2
    best_idx = 0
    worst_idx = len(df) - 1

    fig, ax = plt.subplots(figsize=(6.8, 4.2))
    bars = ax.bar(
        np.arange(len(df)),
        df["mean"].to_numpy(),
        color="#4c78a8",
        edgecolor="black",
        linewidth=0.4,
    )

    for idx, color in [(best_idx, "#2ca02c"), (typical_idx, "#ff7f0e"), (worst_idx, "#d62728")]:
        bars[idx].set_color(color)

    ax.set_xlabel("Test grid (sorted by mean error)")
    ax.set_ylabel("Mean localization error (m)")
    ax.set_xticks([0, typical_idx, worst_idx])
    ax.set_xticklabels(
        [
            f"Best\n{df.loc[best_idx, 'name']}",
            f"Typical\n{df.loc[typical_idx, 'name']}",
            f"Worst\n{df.loc[worst_idx, 'name']}",
        ]
    )
    ax.grid(True, axis="y", linestyle="--")
    ax.set_axisbelow(True)
    ymax = float(df["mean"].max())
    ax.set_ylim(0.0, ymax + 0.03)

    for idx in [best_idx, typical_idx, worst_idx]:
        y = float(df.loc[idx, "mean"])
        x = idx - 0.08 if idx == worst_idx else idx
        ha = "right" if idx == worst_idx else "center"
        ax.text(x, y + 0.009, f"{y:.3f}", ha=ha, va="bottom", fontsize=8)

    fig.savefig(output_path)
    plt.close(fig)


def _normalize_blocks(df: pd.DataFrame, block_size: int = 5) -> pd.DataFrame:
    out = df.copy()
    for start in range(0, len(out), block_size):
        end = min(start + block_size, len(out))
        base_true_x = out.at[start, "y_true_x"]
        out.loc[start:end - 1, ["y_true_x", "y_pred_x"]] = (
            out.loc[start:end - 1, ["y_true_x", "y_pred_x"]] - base_true_x
        )
    return out


def _plot_single_trajectory(ax: plt.Axes, df: pd.DataFrame, title: str) -> None:
    df = _normalize_blocks(df)
    ax.plot(df["y_true_x"], df["y_true_y"], color="#1f77b4", linewidth=1.5, label="Ground truth")
    sc = ax.scatter(
        df["y_pred_x"],
        df["y_pred_y"],
        c=df["err_m"],
        cmap="viridis",
        s=11,
        alpha=0.82,
        vmin=0.0,
        vmax=max(0.35, float(df["err_m"].quantile(0.95))),
    )
    x_true = df["y_true_x"].to_numpy()
    x_pred = df["y_pred_x"].to_numpy()
    y_true = df["y_true_y"].to_numpy()
    y_pred = df["y_pred_y"].to_numpy()
    x_all = np.concatenate([x_true, x_pred])
    y_all = np.concatenate([y_true, y_pred])

    x_min, x_max = float(np.min(x_all)), float(np.max(x_all))
    y_min, y_max = float(np.min(y_all)), float(np.max(y_all))
    x_span = x_max - x_min
    y_span = y_max - y_min

    x_pad = max(0.04, 0.18 * x_span, 0.10 * y_span)
    y_pad = max(0.04, 0.06 * y_span)

    ax.set_xlim(x_min - x_pad, x_max + x_pad)
    ax.set_ylim(y_min - y_pad, y_max + y_pad)
    if title:
        ax.set_title(title, fontsize=9, pad=4)
    ax.set_aspect("auto")
    ax.set_box_aspect(0.96)
    ax.grid(True, linestyle="--")
    return sc


def plot_best_typical_worst_comparison(output_path: Path) -> None:
    slim_summary = _load_summary_csv(ROOT / "test_out_ablation_K" / "parity_test" / "eval_summary.csv")
    slim_summary = slim_summary.sort_values("mean", ascending=True).reset_index(drop=True)

    selection = [
        ("Low error", slim_summary.loc[0, "name"]),
        ("Mid error", slim_summary.loc[len(slim_summary) // 2, "name"]),
        ("High error", slim_summary.loc[len(slim_summary) - 1, "name"]),
    ]

    slim_root = ROOT / "test_out_ablation_K" / "parity_test"
    cmamba_root = CMAMBA_ROOT / "test" / "eval_out_testing_1"

    fig, axes = plt.subplots(
        2,
        3,
        figsize=(9.4, 5.6),
        constrained_layout=True,
        gridspec_kw={"wspace": 0.06, "hspace": 0.06},
    )
    colorbar_ref = None

    for col, (case_label, grid_name) in enumerate(selection):
        slim_df = _load_pred_vs_true(slim_root / grid_name / "pred_vs_true.csv")
        cmamba_df = _load_pred_vs_true(cmamba_root / grid_name / "pred_vs_true.csv")

        colorbar_ref = _plot_single_trajectory(
            axes[0, col],
            slim_df,
            f"{case_label}: {grid_name}",
        )
        _plot_single_trajectory(
            axes[1, col],
            cmamba_df,
            "",
        )

    for ax in axes[:, 0]:
        ax.set_ylabel("Y coordinate")
    for ax in axes[1, :]:
        ax.set_xlabel("X coordinate")
    for ax in axes[0, :]:
        ax.tick_params(labelbottom=False)

    axes[0, 0].text(
        0.03,
        0.04,
        "Blue line:\nground truth",
        transform=axes[0, 0].transAxes,
        fontsize=8,
        ha="left",
        va="bottom",
        bbox=dict(boxstyle="round,pad=0.2", facecolor="white", edgecolor="0.75", alpha=0.9),
    )
    axes[0, 0].text(
        0.03,
        0.96,
        "Slim-Mamba",
        transform=axes[0, 0].transAxes,
        fontsize=8.5,
        fontweight="bold",
        ha="left",
        va="top",
        bbox=dict(boxstyle="round,pad=0.18", facecolor="white", edgecolor="0.75", alpha=0.92),
    )
    axes[1, 0].text(
        0.03,
        0.96,
        "channel mamba",
        transform=axes[1, 0].transAxes,
        fontsize=8.5,
        fontweight="bold",
        ha="left",
        va="top",
        bbox=dict(boxstyle="round,pad=0.18", facecolor="white", edgecolor="0.75", alpha=0.92),
    )
    if colorbar_ref is not None:
        cbar = fig.colorbar(
            colorbar_ref,
            ax=axes,
            shrink=0.83,
            pad=0.015,
            location="right",
            fraction=0.028,
        )
        cbar.set_label("Point-wise error (m)", fontsize=9)
        cbar.ax.tick_params(labelsize=8)

    fig.savefig(output_path)
    plt.close(fig)


def _iter_outputs(output_dir: Path, selected: Iterable[str]) -> list[tuple[str, Path]]:
    mapping = {
        "model_comparison_cdf": output_dir / "software_eval_model_comparison_cdf.png",
        "k_cdf": output_dir / "software_eval_k_ablation_cdf.png",
        "grid_ranking": output_dir / "software_eval_slim_grid_ranking.png",
        "trajectory_panel": output_dir / "software_eval_best_typical_worst_panel.png",
    }
    return [(name, mapping[name]) for name in selected]


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate publication-style figures for the Software Model Evaluation section."
    )
    parser.add_argument(
        "--output_dir",
        type=str,
        default=str(ROOT / "thesis" / "generated_figures"),
        help="Directory to save generated figures.",
    )
    parser.add_argument(
        "--figures",
        nargs="+",
        choices=["model_comparison_cdf", "k_cdf", "grid_ranking", "trajectory_panel", "all"],
        default=["all"],
        help="Select which figures to generate.",
    )
    args = parser.parse_args()

    _set_academic_style()

    output_dir = Path(args.output_dir)
    _ensure_dir(output_dir)

    selected = ["model_comparison_cdf", "k_cdf", "grid_ranking", "trajectory_panel"] if "all" in args.figures else args.figures

    for name, path in _iter_outputs(output_dir, selected):
        if name == "model_comparison_cdf":
            plot_model_comparison_cdf(path)
        elif name == "k_cdf":
            plot_k_ablation_cdf(path)
        elif name == "grid_ranking":
            plot_slim_grid_ranking(path)
        elif name == "trajectory_panel":
            plot_best_typical_worst_comparison(path)
        print(f"[ok] wrote {path}")


if __name__ == "__main__":
    main()
