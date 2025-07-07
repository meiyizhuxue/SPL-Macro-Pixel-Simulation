clear
% 目标距离
L_target = 300;
gateStartBin = 1; % 门控起始Bin
TDCtype = 0;     % TDC类型（0=单事件）
NOISE = 1;        % 启用背景噪声
coincidenceThreshold = 4; % 宏像素阈值
coincidenceTime = 4;      % 符合时间窗
[para, physConst, env] = init_parameters();

%% 时间门配置
gateDurationBins = single(para.rx.gateDuration / para.rx.TDC_res);
gateEndBin = gateStartBin + gateDurationBins - 1;
activeBins = gateStartBin : gateEndBin;

% 调用模拟函数
countsHistogram = MacroPixelSimulation(L_target, gateStartBin, TDCtype, ...
    NOISE, coincidenceThreshold, coincidenceTime, para, physConst, env);

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
    'MacroPixel(SPAD=%.0f): %.2f klux | Coincidence: Thresh=%d, Window=%d bins', ...
    numSPAD, ambientLightIn, coincidenceThreshold, coincidenceTime);
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