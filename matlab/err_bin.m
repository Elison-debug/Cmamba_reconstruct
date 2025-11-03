%% ================================
%  Batch Process pred_vs_true.csv
%  Generates: k-xerr / k-yerr / k-totalerr heatmaps
%  Author: you
% =================================

clc; clear; close all;

rootDir = 'E:\course\master\mamba\Cmamba_reconstruct\test_out';   % ✅ 设置你的根目录
outputFolderName = 'err_vis'; % 输出文件夹名称

% 找所有 pred_vs_true.csv（递归）
fileList = dir(fullfile(rootDir, '**', 'pred_vs_true.csv'));

fprintf("Found %d files.\n", numel(fileList));

for idx = 1:numel(fileList)
    
    %% ---- 构造路径 ----
    csvPath = fullfile(fileList(idx).folder, fileList(idx).name);
    relPath = erase(fileList(idx).folder, rootDir);
    
    % 输出路径与目录结构同步
    outDir = fullfile(rootDir, relPath, outputFolderName);
    if ~exist(outDir, 'dir'); mkdir(outDir); end
    
    fprintf("Processing [%d/%d]: %s\n", idx, numel(fileList), csvPath);

    %% ---- 读取 CSV ----
    T = readtable(csvPath);
    y_true_x = T.y_true_x;  y_true_y = T.y_true_y;
    y_pred_x = T.y_pred_x;  y_pred_y = T.y_pred_y;

    N = height(T);
    k = (1:N)';
    x_err = y_pred_x - y_true_x;
    y_err = y_pred_y - y_true_y;
    total_err = sqrt(x_err.^2 + y_err.^2);

    %% ---- 自适应 bins ----
    if N < 5000
        numKBins = max(50, round(N/50));
    elseif N < 200000
        numKBins = max(100, round(N/200));
    else
        numKBins = round(sqrt(N));
    end
    numEBins = numKBins;

    clipSigma = 4;
    x_lim = mean(x_err) + clipSigma*[-std(x_err), std(x_err)];
    y_lim = mean(y_err) + clipSigma*[-std(y_err), std(y_err)];
    t_lim = [0, prctile(total_err, 99.5)];

    k_edges = linspace(1, N, numKBins+1);
    x_edges = linspace(x_lim(1), x_lim(2), numEBins+1);
    y_edges = linspace(y_lim(1), y_lim(2), numEBins+1);
    t_edges = linspace(t_lim(1), t_lim(2), numEBins+1);

    Hx = histcounts2(k, x_err, k_edges, x_edges);
    Hy = histcounts2(k, y_err, k_edges, y_edges);
    Ht = histcounts2(k, total_err, k_edges, t_edges);

    %% ---- 绘制 heatmap ----
    fig = figure('Color','w','Position',[200,100,900,800]);
    
    % x_err
    subplot(3,1,1);
    imagesc(Hx'); axis xy; colormap(turbo);
    title('k vs x\_err'); ylabel('x error'); colorbar;

    % y_err
    subplot(3,1,2);
    imagesc(Hy'); axis xy; colormap(turbo);
    title('k vs y\_err'); ylabel('y error'); colorbar;

    % total_err
    subplot(3,1,3);
    imagesc(Ht'); axis xy; colormap(hot);
    title('k vs total error'); ylabel('total error'); xlabel('k'); colorbar;

    set(findall(gcf,'-property','FontSize'),'FontSize',12);

    %% ---- 保存 ----
    saveas(fig, fullfile(outDir, 'k_err_heatmap.svg'));
    %% exportgraphics(fig, fullfile(outDir, 'k_err_heatmap.png'), 'Resolution', 300);

    %% ---- 单独 total err 曲线 ----
    fig2 = figure('Color','w');
    plot(k, total_err, 'LineWidth',1);
    xlabel('k'); ylabel('total error');
    title('Total Error vs k'); grid on;

    saveas(fig2, fullfile(outDir, 'total_error_curve.svg'));
    %% exportgraphics(fig2, fullfile(outDir, 'total_error_curve.png'), 'Resolution', 300);

    close(fig); close(fig2);
end

disp("✅ All done!");
