function countsHistogram = MacroPixelSimulation(L_target, gateStartBin, TDCtype, ...
                                                NOISE, coincidenceThreshold, coincidenceTime, ...
                                                para, physConst, env)

    %% 时间门配置
    gateDurationBins = single(para.rx.gateDuration/para.rx.TDC_res);
    gateEndBin = gateStartBin + gateDurationBins - 1;
    activeBins = gateStartBin:gateEndBin;
    numActiveBins = numel(activeBins);
    
    %% 光子数预计算
    N_subpixel = para.rx.N_subpixel;
    bin_sec = para.rx.TDC_res;  % 时间分辨率
    N_values = zeros(1, numActiveBins, 'single');
    
    parfor binIdx = 1:numActiveBins
        t_current = activeBins(binIdx);
        [N_signal, N_background] = photonCalculations(L_target, t_current, para, physConst, env);
        if NOISE == 1
            N_values(binIdx) = (N_signal + N_background) * para.rx.PDE + para.rx.DCR * bin_sec;
        else
            N_values(binIdx) = N_signal * para.rx.PDE + para.rx.DCR * bin_sec;
        end
    end
    
    %% 蒙特卡洛模拟
    countsHistogram = zeros(1, numActiveBins);
    dead_bins = round(para.rx.deadTime / bin_sec);
    
    parfor pulseIdx = 1:para.rx.pluseCounts
        macropixel = zeros(N_subpixel, numActiveBins);
        single_countsHistogram = zeros(1, numActiveBins);
        
        for n = 1:N_subpixel
            dead_time_flag = false(1, numActiveBins);
            % 生成每个门控的光子数
            photon_events = poissrnd(N_values);
    
            for binIdx = 1:numActiveBins
                if photon_events(binIdx) >= 1 && ~dead_time_flag(binIdx)
                    macropixel(n, binIdx) = 1;
                    % 设置死区标志
                    end_j = min(binIdx + dead_bins, numActiveBins);
                    dead_time_flag(binIdx:end_j) = true;
                end
            end
        end
        binIdx_1 = 1;
        while binIdx_1 <= numActiveBins
            window = sum(macropixel(:, binIdx_1), 'all');
            start = binIdx_1;
            stop = min(binIdx_1+coincidenceTime-1, numActiveBins);
            counts = sum(macropixel(:, start:stop), 'all');
            if  window >= 1
                if counts >= coincidenceThreshold
                    single_countsHistogram(binIdx_1) = 1;
                    if TDCtype == 0
                        break;  % 单次触发机制
                    end
                else
                    binIdx_1 = binIdx_1 + coincidenceTime;
                end
            else
                binIdx_1 = binIdx_1 + 1;
            end
        end
    % 累加到全局直方图
    countsHistogram = countsHistogram + single_countsHistogram;
    end
    
end