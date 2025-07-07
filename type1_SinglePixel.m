
%% 第一种情况：单像素
N_subpixel = 1;
figure('Name', 'SinglePixel');
SNR_SinglePixel = zeros(1, 4);
Hst_SinglePixel = cell(1, 4);
for n = 1:length(ambientLightIn)
    [para, physConst, env] = init_parameters(N_subpixel, ambientLightIn(n));
    % 时间门配置
    gateDurationBins = single(para.rx.gateDuration/para.rx.TDC_res);
    gateEndBin = gateStartBin + gateDurationBins - 1;
    activeBins = gateStartBin:gateEndBin;
    numActiveBins = numel(activeBins);
    % 仿真
    countsHistogram = SinglePixelSimulation(L_target, gateStartBin, para, physConst, env);
    Hst_SinglePixel{n} = countsHistogram;
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
    SNR_SinglePixel(n) = SNR_values;
end
% 绘图
for n = 1:length(ambientLightIn)
    subplot(2,2,n);
    bar(activeBins, Hst_SinglePixel{n}, 'b', 'BarWidth', 4);
    hold on;
    rectangle('Position', [targetBin-100, 0, 200, max(Hst_SinglePixel{n})], ...
              'EdgeColor', 'r', 'LineStyle', '--', 'LineWidth', 0.1); % 标记放大区
    title(sprintf('(%c): M_{BG}=%.2f klux\nSNR=%.2f', 96+n, ambientLightIn(n)/1e3, SNR_SinglePixel(n)));
    xlabel('Time (Bin)'); ylabel('Photon Counts');
    xlim([gateStartBin-100 gateEndBin+100])
    set(gca, 'FontName', 'Times New Roman');
end