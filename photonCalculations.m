function [N_signal, N_background] = photonCalculations(L, i, para, physConst, env)
% 计算单bin单像素的光子数量
% 输入：
%   i     - 所在bin
%   L     - 目标距离 (m)
%   para  - 系统参数结构体
%   physConst - 物理常数
%   env   - 环境参数
% 输出：
%   N_signal     - 信号光子数
%   N_background - 背景噪声光子数
%   N_backscatter- 后向散射光子数

    %% 基础计算函数
    function area = spotArea(L)
        area = pi * (para.tx.divergence/2)^2 * L^2;
    end

    function area = fovArea(L)
        area = pi * (para.rx.FOV_pixel/2)^2 * L^2;
    end

    %% 核心光子数计算
    % 信号光子数
    function N = calcSignalPhoton(i, L)
        t_delay = para.rx.Delay;
        P_laser = @(t) para.tx.energy * 2/para.tx.pulseWidth * ...
                  sqrt(log(2)/pi) * exp(-4*log(2)*((t-t_delay)/para.tx.pulseWidth).^2);
        
        P_s = @(t) P_laser(t-2*L/physConst.c) / spotArea(L) * ...
               env.targetReflect * fovArea(L)/pi * ...
               (pi*para.rx.aperture^2)/(4*L^2) * ...
               para.rx.fillFactor * para.tx.optEff * para.rx.optEff * ...
               exp(-2*env.atmExtinct*(L/1e3));
        
        E_s = integral(P_s, (i-1)*para.rx.TDC_res, i*para.rx.TDC_res);
        N = E_s / physConst.hv;
    end

    % 背景噪声光子数
    function N = calcBackgroundPhoton(L)
        P_b = env.ambientLightIn/(1e5) * env.solarIrrad * para.rx.filterBW * ...
              env.targetReflect * cosd(env.sunAngle) * fovArea(L)/pi * ...
              (pi*para.rx.aperture^2)/(4*L^2) * ...
              para.rx.fillFactor * para.rx.optEff * ...
              exp(-env.atmExtinct*(L/1e3));
        
        E_b = P_b * para.rx.TDC_res;
        N = E_b / physConst.hv;
    end

    %% 执行计算
    N_signal = calcSignalPhoton(i, L);
    N_background = calcBackgroundPhoton(L);
end