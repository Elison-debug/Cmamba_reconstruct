from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch


OUT = Path(r"E:\course\smamba\thesis\generated_figures\model_family_sequence_overview.png")

EC = "#6b6b6b"
ROW = "#404040"
BLUE_FC, BLUE_EC = "#dae8fc", "#6c8ebf"
GREEN_FC, GREEN_EC = "#d5e8d4", "#82b366"
PURPLE_FC, PURPLE_EC = "#e1d5e7", "#9673a6"
YELLOW_FC, YELLOW_EC = "#fff2cc", "#d6b656"
GRAY_FC = "#f7f7f7"


def rbox(ax, x, y, w, h, text="", *, fc="#ffffff", ec=EC, lw=1.2, fs=10.5, weight="normal"):
    ax.add_patch(
        FancyBboxPatch(
            (x, y),
            w,
            h,
            boxstyle="round,pad=0.02,rounding_size=0.08",
            facecolor=fc,
            edgecolor=ec,
            linewidth=lw,
        )
    )
    if text:
        ax.text(x + w / 2, y + h / 2, text, ha="center", va="center", fontsize=fs, fontweight=weight, color="#222222")


def arrow(ax, x1, y1, x2, y2, *, rad=0.0, lw=1.4, ms=12, color="#5b5b5b", style="-|>"):
    ax.add_patch(
        FancyArrowPatch(
            (x1, y1),
            (x2, y2),
            arrowstyle=style,
            mutation_scale=ms,
            linewidth=lw,
            color=color,
            connectionstyle=f"arc3,rad={rad}",
        )
    )


def title(ax, x, y, text):
    ax.text(x, y, text, ha="left", va="center", fontsize=14, fontweight="bold", color=ROW)


def model_label(ax, x, y, text):
    ax.text(x, y, text, ha="center", va="bottom", fontsize=12.5, fontweight="bold", color="#222222")


def draw_fcnn(ax, x, y):
    model_label(ax, x + 1.15, y + 0.70, "FCNN")
    rbox(ax, x + 0.00, y + 0.16, 0.46, 0.34, r"$x_t$", fc=BLUE_FC, ec=BLUE_EC, fs=11.5, weight="bold")
    rbox(ax, x + 0.72, y + 0.12, 0.78, 0.42, "Dense", fc=GRAY_FC, fs=10.5)
    rbox(ax, x + 1.76, y + 0.16, 0.32, 0.34, r"$\hat p_t$", fc="#ffffff", fs=11)
    arrow(ax, x + 0.46, y + 0.33, x + 0.72, y + 0.33)
    arrow(ax, x + 1.50, y + 0.33, x + 1.76, y + 0.33)


def draw_cnn(ax, x, y):
    model_label(ax, x + 1.20, y + 0.70, "CNN")
    for i in range(3):
        rbox(ax, x + 0.02 + 0.08 * i, y + 0.13 + 0.03 * i, 0.40, 0.34, fc=GREEN_FC, ec=GREEN_EC)
    rbox(ax, x + 0.74, y + 0.12, 0.74, 0.42, "Conv", fc=GRAY_FC, fs=10.5)
    rbox(ax, x + 1.74, y + 0.16, 0.32, 0.34, r"$\hat p_t$", fc="#ffffff", fs=11)
    arrow(ax, x + 0.56, y + 0.33, x + 0.74, y + 0.33)
    arrow(ax, x + 1.48, y + 0.33, x + 1.74, y + 0.33)


def draw_transformer(ax, x, y):
    model_label(ax, x + 1.35, y + 0.74, "Transformer")
    for i in range(3):
        rbox(ax, x + 0.03 + 0.08 * i, y + 0.12 + 0.03 * i, 0.42, 0.36, fc=PURPLE_FC, ec=PURPLE_EC)
    rbox(ax, x + 0.82, y + 0.10, 1.02, 0.44, "Attention", fc=GRAY_FC, fs=10.5)
    rbox(ax, x + 2.10, y + 0.15, 0.32, 0.34, r"$\hat p_t$", fc="#ffffff", fs=11)
    arrow(ax, x + 0.61, y + 0.32, x + 0.82, y + 0.32)
    arrow(ax, x + 1.84, y + 0.32, x + 2.10, y + 0.32)
    arrow(ax, x + 1.02, y + 0.50, x + 1.64, y + 0.50, style="<->", ms=10, rad=0.22)


def draw_rnn(ax, x, y):
    model_label(ax, x + 1.30, y + 0.82, "RNN")
    xs = [x + 0.02, x + 0.62, x + 1.22]
    for i, xx in enumerate(xs):
        rbox(ax, xx, y + 0.06, 0.30, 0.22, rf"$x_{{t-{2-i}}}$", fc=YELLOW_FC, ec=YELLOW_EC, fs=9.5)
        rbox(ax, xx - 0.01, y + 0.42, 0.34, 0.24, rf"$h_{{t-{2-i}}}$", fc="#ffffff", fs=9.5)
        arrow(ax, xx + 0.15, y + 0.28, xx + 0.15, y + 0.42, ms=9)
    arrow(ax, xs[0] + 0.34, y + 0.54, xs[1] - 0.01, y + 0.54)
    arrow(ax, xs[1] + 0.34, y + 0.54, xs[2] - 0.01, y + 0.54)
    rbox(ax, x + 2.00, y + 0.15, 0.32, 0.34, r"$\hat p_t$", fc="#ffffff", fs=11)
    arrow(ax, xs[2] + 0.33, y + 0.54, x + 2.00, y + 0.32, rad=0.03)


def draw_mamba(ax, x, y):
    model_label(ax, x + 1.42, y + 0.82, "Mamba")
    xs = [x + 0.00, x + 0.50, x + 1.00]
    for i, xx in enumerate(xs):
        rbox(ax, xx, y + 0.06, 0.26, 0.22, rf"$x_{{t-{2-i}}}$", fc=YELLOW_FC, ec=YELLOW_EC, fs=9.2)
        rbox(ax, xx - 0.01, y + 0.42, 0.30, 0.24, "state", fc="#ffffff", fs=9.2)
        arrow(ax, xx + 0.13, y + 0.28, xx + 0.13, y + 0.42, ms=9)
    arrow(ax, xs[0] + 0.29, y + 0.54, xs[1] - 0.01, y + 0.54)
    arrow(ax, xs[1] + 0.29, y + 0.54, xs[2] - 0.01, y + 0.54)
    rbox(ax, x + 1.52, y + 0.36, 0.62, 0.34, "update", fc=BLUE_FC, ec=BLUE_EC, fs=10)
    rbox(ax, x + 2.28, y + 0.15, 0.32, 0.34, r"$\hat p_t$", fc="#ffffff", fs=11)
    arrow(ax, xs[2] + 0.29, y + 0.54, x + 1.52, y + 0.53)
    arrow(ax, x + 2.14, y + 0.41, x + 2.28, y + 0.32)


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    fig, ax = plt.subplots(figsize=(11.2, 4.9), dpi=220)
    fig.patch.set_alpha(0.0)
    ax.set_facecolor("none")
    ax.set_xlim(0, 10.0)
    ax.set_ylim(0, 4.85)
    ax.axis("off")

    title(ax, 0.28, 4.15, "Feed-forward")
    draw_fcnn(ax, 2.05, 3.40)
    draw_cnn(ax, 5.75, 3.40)

    title(ax, 0.28, 2.50, "Window-parallel")
    draw_transformer(ax, 3.10, 1.75)

    title(ax, 0.28, 0.86, "Sequential-state")
    draw_rnn(ax, 2.05, 0.10)
    draw_mamba(ax, 5.70, 0.10)

    fig.tight_layout(pad=0.2)
    fig.savefig(OUT, dpi=300, transparent=True, bbox_inches="tight", pad_inches=0.03)


if __name__ == "__main__":
    main()
