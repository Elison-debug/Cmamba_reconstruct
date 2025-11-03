import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import colors as mcolors

def plot_error_heatmaps(y_true, y_pred, out_dir,
                              pclip=99.0, gamma=0.6):
    """
    在训练阶段更清晰地查看误差分布：
    - k vs x_err / k vs y_err / k vs total_err 三张热力图
    - y 轴为真实误差值（米）
    - pclip 分位数裁剪 + γ 增强色彩对比
    - 仅保存 SVG

    Args:
        y_true: (N,2) ndarray, 真值坐标
        y_pred: (N,2) ndarray, 预测坐标
        out_dir: 输出目录
        pclip: 分位数裁剪百分位（默认 99）
        gamma: PowerNorm γ（默认 0.6，越小对比越强）
    """
    os.makedirs(out_dir, exist_ok=True)

    # --- 误差与索引 ---
    x_err = y_pred[:, 0] - y_true[:, 0]
    y_err = y_pred[:, 1] - y_true[:, 1]
    total_err = np.sqrt(x_err**2 + y_err**2)
    N = len(y_true)
    k = np.arange(N)

    # --- 自适应分箱（与 MATLAB 逻辑一致） ---
    if N < 5000:
        numKBins = max(50, int(N/50))
    elif N < 200000:
        numKBins = max(100, int(N/200))
    else:
        numKBins = int(np.sqrt(N))
    numEBins = numKBins

    k_bins = np.linspace(0, N, numKBins + 1)

    # --- 分位数裁剪，保证主密集区清晰 ---
    # 对于有符号的 x_err/y_err，用对称裁剪：根据百分位取上界，然后取 [-cap, cap]
    cap_x = np.percentile(np.abs(x_err), pclip)
    cap_y = np.percentile(np.abs(y_err), pclip)
    x_min, x_max = -cap_x, cap_x
    y_min, y_max = -cap_y, cap_y

    # 对于 total_err（非负），用 [0, pclip] 裁剪
    t_min, t_max = 0.0, float(np.percentile(total_err, pclip))

    x_bins = np.linspace(x_min, x_max, numEBins + 1)
    y_bins = np.linspace(y_min, y_max, numEBins + 1)
    t_bins = np.linspace(t_min, t_max, numEBins + 1)

    # --- 2D 直方图（密度热力） ---
    Hx, _, _ = np.histogram2d(k, np.clip(x_err, x_min, x_max), bins=[k_bins, x_bins])
    Hy, _, _ = np.histogram2d(k, np.clip(y_err, y_min, y_max), bins=[k_bins, y_bins])
    Ht, _, _ = np.histogram2d(k, np.clip(total_err, t_min, t_max), bins=[k_bins, t_bins])

    # --- 颜色归一化（γ 增强），提升主密度区对比度 ---
    # 注意：对“计数”做 γ（越小对比越强）；为防 0 值，vmin 取 0 或 1 都可
    norm_x = mcolors.PowerNorm(gamma=gamma, vmin=0, vmax=Hx.max() if Hx.max() > 0 else 1)
    norm_y = mcolors.PowerNorm(gamma=gamma, vmin=0, vmax=Hy.max() if Hy.max() > 0 else 1)
    norm_t = mcolors.PowerNorm(gamma=gamma, vmin=0, vmax=Ht.max() if Ht.max() > 0 else 1)

    # --- 画图 ---
    fig, axs = plt.subplots(3, 1, figsize=(7.5, 8.0))

    # x_err
    im0 = axs[0].imshow(Hx.T, origin='lower',
                        extent=[0, N, x_min, x_max],
                        aspect='auto', cmap='turbo', norm=norm_x)
    axs[0].set_title('k vs x error')
    axs[0].set_ylabel('x error (m)')
    fig.colorbar(im0, ax=axs[0], label='count (γ={:.2f})'.format(gamma))

    # y_err
    im1 = axs[1].imshow(Hy.T, origin='lower',
                        extent=[0, N, y_min, y_max],
                        aspect='auto', cmap='turbo', norm=norm_y)
    axs[1].set_title('k vs y error')
    axs[1].set_ylabel('y error (m)')
    fig.colorbar(im1, ax=axs[1], label='count (γ={:.2f})'.format(gamma))

    # total_err
    im2 = axs[2].imshow(Ht.T, origin='lower',
                        extent=[0, N, t_min, t_max],
                        aspect='auto', cmap='hot', norm=norm_t)
    axs[2].set_title('k vs total error')
    axs[2].set_ylabel('total error (m)')
    axs[2].set_xlabel('k (index)')
    fig.colorbar(im2, ax=axs[2], label='count (γ={:.2f})'.format(gamma))

    for ax in axs:
        ax.grid(True, linestyle='--', linewidth=0.25, alpha=0.6)

    plt.tight_layout()
    plt.savefig(os.path.join(out_dir, 'k_error_heatmap.svg'),
                dpi=300, bbox_inches='tight')
    plt.close(fig)

    # --- 可选：总误差曲线（训练时常用，用于快速定位 spike） ---
    fig2 = plt.figure(figsize=(7.5, 2.8))
    plt.plot(k, total_err, linewidth=1)
    plt.xlabel('k (index)'); plt.ylabel('total error (m)')
    plt.title('Total Error vs k'); plt.grid(True, linestyle='--', linewidth=0.25, alpha=0.6)
    plt.tight_layout()
    plt.savefig(os.path.join(out_dir, 'total_error_curve.svg'),
                dpi=300, bbox_inches='tight')
    plt.close(fig2)

# ===== 用法示例 =====
# plot_error_heatmaps_clear(y_true_a, y_pred_a, out_sub, pclip=99.0, gamma=0.6)
