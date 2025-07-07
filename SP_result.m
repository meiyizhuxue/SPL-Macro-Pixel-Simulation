clear all;

% 目标距离
L_target = 300;
% 门控时间开始的bin
gateStartBin = 1;
% TDC类型：单事件TDC=0；多事件TDC=1
TDCtype = 0;
% 是否有背景噪声：有背景噪声=1；无背景噪声=0
NOISE = 1;
no_NOISE = 0;
% para：激光雷达系统参数；phyConst：物理常量；env：目标和环境参数
[para, physConst, env] = init_parameters();

%% 时间门配置
gateDurationBins = single(para.rx.gateDuration/para.rx.TDC_res);
gateEndBin = gateStartBin + gateDurationBins - 1;
activeBins = gateStartBin:gateEndBin;
numActiveBins = numel(activeBins);

%% 仿真和概率计算
countsHistogram = SinglePixelSimulation(L_target, gateStartBin, TDCtype, NOISE, para, physConst, env);
figure;
% 主图
ax_main = axes('Position', [0.1 0.1 0.8 0.8]); % 主图坐标轴位置
bar(activeBins, countsHistogram, 'b', 'BarWidth', 4);
xlabel('Time/ns');
ylabel('Counts');
title('SinglePixel: 0klux')
xlim([gateStartBin-100, gateEndBin+100]);
text(0.95, 0.1, 'a', 'Units', 'normalized', 'FontSize', 14, ...
     'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

% 局部放大子图
ax_zoom = axes('Position', [0.6 0.5 0.25 0.3]); % 右中部位置[1,6](@ref)
bar(activeBins, countsHistogram, 'b', 'BarWidth', 4);
xlim([1900, 2100]);
set(gca, 'FontName', 'Times New', 'YAxisLocation', 'right');
grid on;

% 主图标注放大区域
y_range = ylim(ax_main);
rectangle(ax_main, 'Position', [1900, y_range(1), 200, diff(y_range)], ...
          'LineStyle', '--', 'EdgeColor', 'r');

% 添加箭头
annotation('arrow', [0.55 0.6], [0.55 0.6], 'Color', 'k', 'LineWidth', 1);

countsHistogram_1 = countsHistogram;
countsHistogram_1(2020-10:2020+10) = 0;
noise_count = sum(countsHistogram_1)/(4000-21);
SNR = countsHistogram(2020-10:2020+10)/sqrt(countsHistogram(2020-10:2020+10)+noise_count);
disp(SNR);
