function [para, physConst, env] = init_parameters()
    % 发射端参数
    para.tx.energy        = 100 * 1e-8;    % 脉冲激光能量 [J]
    para.tx.pulseWidth    = 4 * 1e-9;      % 脉冲宽度 [s]
    para.tx.divergence    = 20 * 1e-3;     % 激光发散角 [rad]
    para.tx.wavelength    = 1064 * 1e-9;   % 波长 [m]
    para.tx.optEff        = 0.8;           % 发射系统光学效率
    para.rx.Delay         = 20 * 1e-9;     % 脉冲激光发射延迟 [s]
    para.rx.frequence     = 2 * 1e4;       % 脉冲激光发射频率 [Hz]
    
    % 接收端参数
    para.rx.filterBW      = 2;             % 滤波器带宽 [nm]
    para.rx.aperture      = 150 * 1e-3;    % 接收孔径 [m]
    para.rx.FOV_total     = 19.2 * 1e-3;   % 总视场角 [rad]
    para.rx.FOV_pixel     = 0.3 * 1e-3;    % 单像素视场角 [rad]
    para.rx.TDC_res       = 1 * 1e-9;      % TDC时间分辨率 [s]
    para.rx.optEff        = 0.6;           % 接收系统光学效率
    para.rx.fillFactor    = 0.2;           % 填充因子
    para.rx.PDE           = 0.3;           % 光子探测效率
    para.rx.DCR           = 20 * 1e3;      % 暗计数率 [Hz]
    para.rx.deadTime      = 50 * 1e-9;     % 死区时间 [s]
    para.rx.gateDuration  = 4 * 1e-6;      % 门控时长 [s]
    para.rx.pluseCounts   = 5000;          % 单帧的脉冲激光累计数
    para.rx.N_subpixel    = 2;             % 宏像素拥有的SPAD数
    
    % 物理常数
    physConst.c           = 3e8;           % 光速 [m/s]
    physConst.hv          = 1.869e-19;     % 光子能量 [J]
    
    % 目标与环境参数
    env.ambientLightIn    = 40 * 1e3;       % 环境光强度 [luk]
    env.targetReflect     = 0.3;           % 目标反射率
    env.atmExtinct        = 0.135;         % 大气消光系数 [km⁻¹]
    env.scatterCoef       = 0.015;         % 体散射系数 [km⁻¹]
    env.solarIrrad        = 0.65;          % 太阳辐照度 [J/s/m²/nm]
    env.sunAngle          = 30;            % 太阳-目标夹角 [度]
end