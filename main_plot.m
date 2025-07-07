clear;
addpath("result");  % 添加结果目录

%% 加载信噪比数据
load('type_1_SNR.mat');  % 单像素结构
load('type_2_SNR.mat');  % 1x2宏像素结构
load('type_3_SNR.mat');  % 2x2宏像素结构
load('type_4_SNR.mat');  % 3x3宏像素结构

%% 设置参数
ambientLight = [0, 10, 40, 70];  % 背景光照水平 (klux)
winSize = 1:4;             % 波长索引范围

%% 创建包含4个子图的图形
figure('Name', 'SNR Comparison at Different Ambient Light Levels', ...
       'NumberTitle', 'off', ...
       'Position', [100, 100, 1200, 800]);
   
% 设置全局字体
set(gcf, 'DefaultAxesFontName', 'Times New Roman', 'DefaultAxesFontSize', 10);
set(gcf, 'DefaultTextFontName', 'Times New Roman');

% 预存储图例句柄和标签
legendHandles = [];
legendLabels = {};

%% 循环创建子图
for k = 1:length(ambientLight)
    subplot(2, 2, k);
    hold on;
    grid on;
    box on;
    
    % 设置当前子图字体
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 10);
    
    % 定义不同类型的点标记和线型
    markerTypes = {'o', 's', 'd', '^'};  % 单像素: 圆圈, 1x2: 正方形, 2x2: 菱形, 3x3: 三角形
    lineStyles = {'-', '--', ':', '-.'};  % 不同的线型
    
    %% 1. 绘制单像素结构（水平线）
    singlePixelData = repmat(SNR_SinglePixel(k), size(winSize));
    h1 = plot(winSize, singlePixelData, ...
              'Marker', markerTypes{1}, 'MarkerSize', 6, 'Color', [0 0 0], ...
              'LineWidth', 1.5, 'LineStyle', '-');
    
    % 只在第一次循环时记录图例句柄
    if k == 1
        legendHandles = [legendHandles, h1];
        legendLabels{end+1} = 'Single Pixel';
    end
    
    %% 2. 绘制1x2宏像素结构
    configCount = size(SNR_12MacroPixel, 2);
    colors = lines(configCount); 
    for config = 1:configCount
        yData = squeeze(SNR_12MacroPixel(k, config, :));
        h2 = plot(winSize, yData, ...
                  'Marker', markerTypes{2}, 'MarkerSize', 5, 'Color', colors(config, :), ...
                  'LineWidth', 1.5, 'LineStyle', lineStyles{1});
        
        % 只在第一次循环时记录图例句柄
        if k == 1
            legendHandles = [legendHandles, h2];
            legendLabels{end+1} = sprintf('1x2 (th=%d)', config);
        end
    end
    
    %% 3. 绘制2x2宏像素结构
    configCount = size(SNR_22MacroPixel, 2);
    colors = summer(configCount); 
    for config = 1:configCount
        yData = squeeze(SNR_22MacroPixel(k, config, :));
        h3 = plot(winSize, yData, ...
                  'Marker', markerTypes{3}, 'MarkerSize', 5, 'Color', colors(config, :), ...
                  'LineWidth', 1.5, 'LineStyle', lineStyles{2});
        
        % 只在第一次循环时记录图例句柄
        if k == 1
            legendHandles = [legendHandles, h3];
            legendLabels{end+1} = sprintf('2x2 (th=%d)', config);
        end
    end
    
    %% 4. 绘制3x3宏像素结构
    configCount = size(SNR_33MacroPixel, 2);
    colors = jet(configCount); 
    for config = 1:configCount
        yData = squeeze(SNR_33MacroPixel(k, config, :));
        h4 = plot(winSize, yData, ...
                  'Marker', markerTypes{4}, 'MarkerSize', 5, 'Color', colors(config, :), ...
                  'LineWidth', 1.5, 'LineStyle', lineStyles{3});
        
        % 只在第一次循环时记录图例句柄
        if k == 1
            legendHandles = [legendHandles, h4];
            legendLabels{end+1} = sprintf('3x3 (th=%d)', config);
        end
    end
    
    %% 子图美化
    title(sprintf('(%c)Ambient Light:%d klux', 96+k, ambientLight(k)), 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Window Size/bins', 'FontSize', 10);
    ylabel('SNR', 'FontSize', 10);
    
    % 设置坐标轴
    xticks(winSize);
    xlim([min(winSize)-0.2, max(winSize)+0.2]);
    
    % 添加网格线
    set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);
    
    hold off;
end

%% 添加全局标题
sgtitle('Signal-to-Noise Ratio Performance at Different Ambient Light Levels', ...
        'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');

%% 添加统一图例
% 计算图例位置（整个图形的右上角）
legendPos = [0.91, 0.68, 0.08, 0.2];  % [left, bottom, width, height]

% 创建图例
hLegend = legend(legendHandles, legendLabels, ...
                 'Position', legendPos, ...
                 'FontSize', 7, ...
                 'NumColumns', 1);
title(hLegend, 'Pixel Configuration', 'FontWeight', 'bold');

%% 调整子图间距
set(gcf, 'Color', 'w');  % 设置背景为白色
ha = findobj(gcf, 'type', 'axes');

% 保存高质量图片
% print('SNR_Comparison_All_Conditions', '-dpng', '-r300');
% print('SNR_Comparison_All_Conditions', '-depsc', '-r600');