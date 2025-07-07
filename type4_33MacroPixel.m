
% 第4种类型：3*3宏像素
N_subpixel = 9;
figure('Name', '3*3-MacroPixel');
SNR_33MacroPixel = zeros(4, N_subpixel, 4);
Hst_33MacroPixel = cell(4, N_subpixel, 4);
for n = 1:length(ambientLightIn)
    [para, physConst, env] = init_parameters(N_subpixel, ambientLightIn(n));
    % 时间门配置
    gateDurationBins = single(para.rx.gateDuration/para.rx.TDC_res);
    gateEndBin = gateStartBin + gateDurationBins - 1;
    activeBins = gateStartBin:gateEndBin;
    numActiveBins = numel(activeBins);
    for th = 1:N_subpixel
        for W = 1:4
            % 仿真
            countsHistogram = MacroPixelSimulation(L_target, gateStartBin, ...
                th, W, para, physConst, env);
            Hst_33MacroPixel{n, th, W} = countsHistogram;
            % 计算SNR
            targetBin = round(L_target * 2 / physConst.c / para.rx.TDC_res + para.rx.Delay / para.rx.TDC_res);
            noiseRegion = countsHistogram;
            sigma = round(para.tx.pulseWidth/para.rx.TDC_res);
            noiseRegion(targetBin-3*sigma: targetBin+3*sigma) = 0;
            noise_count = sum(noiseRegion) / (numel(noiseRegion) - 6*sigma-1);
            signalRegion = countsHistogram(targetBin-3*sigma: targetBin+3*sigma);
            if sqrt(sum(signalRegion) + noise_count) == 0
                SNR_values = 0;
            else
                SNR_values = sum(signalRegion) / sqrt(sum(signalRegion) + noise_count);
            end
            SNR_33MacroPixel(n, th, W) = SNR_values;
        end
    end
end
% 绘图
% for n = 1:length(ambientLightIn)
%     subplot(2,2,n);
%     temp = squeeze(SNR_33MacroPixel(n, :, :));
%     % 获取各个背景光强度下的最大的信噪比及SNR对应的阈值和重合检测时间
%     [maxVal, linearIdx] = max(temp(:)); 
%     [th, W] = ind2sub(size(temp), linearIdx);
%     bar(activeBins, Hst_33MacroPixel{n, th, W}, 'b', 'BarWidth', 4);
%     hold on;
%     rectangle('Position', [targetBin-100, 0, 200, max(Hst_33MacroPixel{n, th, W})], ...
%               'EdgeColor', 'r', 'LineStyle', '--', 'LineWidth', 0.1); % 标记放大区
%     title(sprintf('(%c): M_{BG}=%.2f klux;th=%.1f;W=%.1f\nSNR=%.2f', 96+n, ambientLightIn(n)/1e3, th, W, maxVal));
%     xlabel('Time (Bin)'); ylabel('Photon Counts');
%     xlim([gateStartBin-100 gateEndBin+100])
%     set(gca, 'FontName', 'Times New Roman');
% end

% 设置全局字体和图形参数
figure('Color', 'w', 'Position', [100, 100, 1000, 800]);
set(gcf, 'DefaultAxesFontName', 'Times New Roman');
set(gcf, 'DefaultTextFontName', 'Times New Roman');

% 定义颜色
barColor = [0.2, 0.2, 1]; % 深蓝色
highlightColor = [1, 0, 0]; % 红色

% 循环绘制子图
for n = 1:length(ambientLightIn)
    subplot(2, 2, n);
    subplot(2,2,n);
    temp = squeeze(SNR_33MacroPixel(n, :, :));
    % 获取各个背景光强度下的最大的信噪比及SNR对应的阈值和重合检测时间
    [maxVal, linearIdx] = max(temp(:));
    [th, W] = ind2sub(size(temp), linearIdx);
    % 绘制条形图并保存句柄
    bar(activeBins, Hst_33MacroPixel{n, th, W}, 'FaceColor', barColor, 'EdgeColor', 'none', ...
        'BarWidth', 2, 'FaceAlpha', 0.8);
    hold on;
    
    % 创建红色虚线框标记目标区域
    yMax = max(Hst_33MacroPixel{n, th, W});
    highlightRect = rectangle('Position', [targetBin-100, 0, 200, yMax], ...
                             'EdgeColor', highlightColor, ...
                             'LineStyle', '--', ...
                             'LineWidth', 0.1);
    
    % 添加标题（学术格式）
    title(sprintf('(%c) Ambient Light: %.1f klux | SNR: %.2f', ...
                  char('a' + n - 1), ambientLightIn(n)/1e3, maxVal), ...
          'FontSize', 11, 'FontWeight', 'bold');
    
    % 设置坐标轴标签
    xlabel('Time/bin', 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('Photon Counts', 'FontSize', 10, 'FontWeight', 'bold');
    
    % 设置坐标轴范围
    xlim([gateStartBin-100 gateEndBin+100])
    ylim([0, yMax * 1.1]); % 留出10%的顶部空间
    
    % 添加网格线
    % grid on;
    % set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);
    
    % 设置坐标轴
    set(gca, 'FontSize', 9, 'Box', 'on', 'TickDir', 'out');
    
    % 添加子图标识字母（左上角）
    % text(0.02, 0.95, ['(', char('a' + n - 1), ')'], ...
    %      'Units', 'normalized', 'FontSize', 12, 'FontWeight', 'bold');
end

% 添加全局标题
sgtitle('Macro Pixel:3×3SPADs', ...
        'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');

% 调整子图间距
ha = findobj(gcf, 'type', 'axes');
set(ha, 'Layer', 'top'); % 确保网格在数据上方

% 保存高质量图片
% print('Photon_Count_Distribution', '-dpng', '-r300');
% print('Photon_Count_Distribution', '-depsc', '-r600');