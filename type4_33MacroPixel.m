
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
for n = 1:length(ambientLightIn)
    subplot(2,2,n);
    temp = squeeze(SNR_33MacroPixel(n, :, :));
    % 获取各个背景光强度下的最大的信噪比及SNR对应的阈值和重合检测时间
    [maxVal, linearIdx] = max(temp(:)); 
    [th, W] = ind2sub(size(temp), linearIdx);
    bar(activeBins, Hst_33MacroPixel{n, th, W}, 'b', 'BarWidth', 4);
    hold on;
    rectangle('Position', [targetBin-100, 0, 200, max(Hst_33MacroPixel{n, th, W})], ...
              'EdgeColor', 'r', 'LineStyle', '--', 'LineWidth', 0.1); % 标记放大区
    title(sprintf('(%c): M_{BG}=%.2f klux;th=%.1f;W=%.1f\nSNR=%.2f', 96+n, ambientLightIn(n)/1e3, th, W, maxVal));
    xlabel('Time (Bin)'); ylabel('Photon Counts');
    xlim([gateStartBin-100 gateEndBin+100])
    set(gca, 'FontName', 'Times New Roman');
end

