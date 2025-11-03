%% ================================
%  Batch Process pred_vs_true.csv
%  Generates: k-xerr / k-yerr / k-totalerr heatmaps (real error scale)
%  Export only SVG
% =================================

clc; clear; close all;

dataRoot = 'E:\course\master\mamba\Cmamba_reconstruct\test_out';  % ✅ 设置你的数据根目录
outputFolderName = 'err_vis';

fileList = dir(fullfile(dataRoot, '**', 'pred_vs_true.csv'));

fprintf("Found %d files.\n\n", numel(fileList));

for idx = 1:numel(fileList)

    csvPath = fullfile(fileList(idx).folder, fileList(idx).name);
    relPath = strrep(fileList(idx).folder, dataRoot, '');

    % 清理开头斜杠
    while ~isempty(relPath) && (relPath(1)=='/' || relPath(1)=='\' || relPath(1)==filesep)
        relPath = relPath(2:end);
    end

    % 输出路径
    outDir = fullfile(dataRoot, relPath, outputFolderName);
    if ~exist(outDir, 'dir'); mkdir(outDir); end

    fprintf("[%d/%d] %s\n", idx, numel(fileList), csvPath);

    %% === load ===
    T = readtable(csvPath);
    y_true_x = T.y_true_x;  y_true_y = T.y_true_y;
    y_pred_x = T.y_pred_x;  y_pred_y = T.y_pred_y;

    N = height(T);
    k = (1:N)';

    x_err = y_pred_x - y_true_x;
    y_err = y_pred_y - y_true_y;
    total_err = sqrt(x_err.^2 + y_err.^2);

    %% === adaptive bins ===
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

    %% === Plot real-value heatmaps ===
    fig = figure('Color','w','Position',[200,100,900,800]);

    subplot(3,1,1);
    imagesc(k_edges, x_edges, Hx'); axis xy; 
    colormap(turbo); colorbar;
    title('k vs x error'); ylabel('x error (m)');

    subplot(3,1,2);
    imagesc(k_edges, y_edges, Hy'); axis xy;
    colormap(turbo); colorbar;
    title('k vs y error'); ylabel('y error (m)');

    subplot(3,1,3);
    imagesc(k_edges, t_edges, Ht'); axis xy;
    colormap(hot); colorbar;
    title('k vs total error'); ylabel('total error (m)'); xlabel('k');

    set(findall(gcf,'-property','FontSize'),'FontSize',12);

    saveas(fig, fullfile(outDir, 'k_err_heatmap.svg'));
    close(fig);

    %% === total error curve ===
    fig2 = figure('Color','w');
    plot(k, total_err,'LineWidth',1);
    xlabel('k'); ylabel('total error (m)');
    title('Total Error vs k'); grid on;

    saveas(fig2, fullfile(outDir, 'total_error_curve.svg'));
    close(fig2);

end

disp("✅ All SVG files generated");
