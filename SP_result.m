clear;

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

%% 计算目标Bin位置（核心逻辑不变）
targetBin = round(L_target * 2 / physConst.c / para.rx.TDC_res + para.rx.Delay / para.rx.TDC_res);

%% 噪声估计与SNR计算（严格保持原始定义）
% 1. 噪声估计：排除目标区域（±10 Bins）
noiseRegion = countsHistogram;
noiseRegion(targetBin-10 : targetBin+10) = 0; % 屏蔽目标信号
noise_count = sum(noiseRegion) / (numel(noiseRegion) - 21); % 平均噪声计数

% 2. 信号估计：目标区域（±10 Bins）
signalRegion = countsHistogram(targetBin-10 : targetBin+10);

% 3. SNR计算（原始定义：信号功率/噪声功率）
SNR_values = sum(signalRegion) / sqrt(sum(signalRegion) + noise_count);

%% 绘图（标注关键参数）
figure;
ax_main = axes('Position', [0.1 0.1 0.8 0.8]);
bar(activeBins, countsHistogram, 'b', 'BarWidth', 4);
hold on;

% 标注目标位置与噪声窗口
rectangle('Position', [targetBin-100, 0, 200, max(countsHistogram)], ...
    'EdgeColor', 'r', 'LineStyle', '--', 'LineWidth', 0.1);

% 标题与标签
numSPAD = para.rx.N_subpixel;
ambientLightIn = env.ambientLightIn * 1e-3; % 环境光（klux）
titleStr = sprintf(...
    'SinglePixel: %.2f klux', ...
    ambientLightIn);
title(titleStr);
xlabel('Time (Bin)'); 
ylabel('Photon Counts');
xlim([gateStartBin-100, gateEndBin+100]);
set(gca, 'FontName', 'Times New Roman', 'YAxisLocation', 'right');

% 局部放大图（目标峰区）
ax_zoom = axes('Position', [0.6 0.5 0.25 0.3]);
bar(activeBins, countsHistogram, 'b', 'BarWidth', 4);
hold on;
titleStr = sprintf('Signal Peak Zoom(SNR=%.2f)', SNR_values);
title(titleStr);
xlim([targetBin-100, targetBin+100]);
set(gca, 'FontName', 'Times New Roman', 'YAxisLocation', 'right');
grid on;