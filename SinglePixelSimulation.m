function countsHistogram = SinglePixelSimulation(L_target, gateStartBin, para, physConst, env)

    %% 时间门配置
    gateDurationBins = single(para.rx.gateDuration/para.rx.TDC_res);
    gateEndBin = gateStartBin + gateDurationBins - 1;
    activeBins = gateStartBin:gateEndBin;
    numActiveBins = numel(activeBins);
    
    %% 光子数预计算
    bin_sec = para.rx.TDC_res;  % 时间分辨率
    N_values = zeros(1, numActiveBins, 'single');
    
    parfor i = 1:numActiveBins
        t_current = activeBins(i);
        [N_signal, N_background] = photonCalculations(L_target, t_current, para, physConst, env);
        N_values(i) = (N_signal + N_background) * para.rx.PDE + para.rx.DCR * bin_sec;
    end
    
    %% 蒙特卡洛模拟
    countsHistogram = zeros(1, numActiveBins);
    dead_bins = round(para.rx.deadTime / bin_sec);
    parfor pulseIdx = 1:para.rx.pluseCounts
        single_counts = zeros(1, numActiveBins);
        photon_events = poissrnd(N_values);
        dead_flags = false(1, numActiveBins);

        for binIdx = 1:numActiveBins
            if photon_events(binIdx) >= 1 && ~dead_flags(binIdx)
                single_counts(binIdx) = 1;

                % 死区结束位置
                dead_start = binIdx;
                dead_end = min(binIdx + dead_bins - 1, numActiveBins);
                dead_flags(dead_start:dead_end) = true;
                % 只记录一次光子事件
                break;
            end
        end
        countsHistogram = countsHistogram + single_counts;
    end
    
end