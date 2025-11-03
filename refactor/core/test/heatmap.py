import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
import os

def plot_error_heatmaps(y_true, y_pred, out_dir):

    # errors
    x_err = y_pred[:,0] - y_true[:,0]
    y_err = y_pred[:,1] - y_true[:,1]
    total_err = np.sqrt(x_err**2 + y_err**2)
    k = np.arange(len(y_true))

    # auto bins like MATLAB
    N = len(k)
    if N < 5000:
        numKBins = max(50, int(N/50))
    elif N < 200000:
        numKBins = max(100, int(N/200))
    else:
        numKBins = int(np.sqrt(N))
    numEBins = numKBins

    # clipsigma like MATLAB
    clip = 4
    x_lim = (x_err.mean() - clip*x_err.std(), x_err.mean() + clip*x_err.std())
    y_lim = (y_err.mean() - clip*y_err.std(), y_err.mean() + clip*y_err.std())
    t_lim = (0, np.percentile(total_err, 99.5))

    # define bins
    k_bins = np.linspace(0, N, numKBins+1)
    x_bins = np.linspace(x_lim[0], x_lim[1], numEBins+1)
    y_bins = np.linspace(y_lim[0], y_lim[1], numEBins+1)
    t_bins = np.linspace(t_lim[0], t_lim[1], numEBins+1)

    # 2D histograms
    Hx, _, _ = np.histogram2d(k, x_err, bins=[k_bins, x_bins])
    Hy, _, _ = np.histogram2d(k, y_err, bins=[k_bins, y_bins])
    Ht, _, _ = np.histogram2d(k, total_err, bins=[k_bins, t_bins])

    # plot
    fig, axs = plt.subplots(3, 1, figsize=(7.5, 7.5))

    # x error
    im0 = axs[0].imshow(Hx.T, origin='lower',
                        extent=[0, N, x_lim[0], x_lim[1]],
                        aspect='auto', cmap='turbo')
    axs[0].set_title("k vs x_error")
    axs[0].set_ylabel("x error (m)")
    fig.colorbar(im0, ax=axs[0])

    # y error
    im1 = axs[1].imshow(Hy.T, origin='lower',
                        extent=[0, N, y_lim[0], y_lim[1]],
                        aspect='auto', cmap='turbo')
    axs[1].set_title("k vs y_error")
    axs[1].set_ylabel("y error (m)")
    fig.colorbar(im1, ax=axs[1])

    # total error
    im2 = axs[2].imshow(Ht.T, origin='lower',
                        extent=[0, N, t_lim[0], t_lim[1]],
                        aspect='auto', cmap='hot')
    axs[2].set_title("k vs total_error")
    axs[2].set_ylabel("total error (m)")
    axs[2].set_xlabel("k (index)")
    fig.colorbar(im2, ax=axs[2])

    plt.tight_layout()

    # save svg only
    os.makedirs(out_dir, exist_ok=True)
    plt.savefig(os.path.join(out_dir, "k_error_heatmap.svg"),
                dpi=300, bbox_inches='tight')
    plt.close()
