# SPL-Macro-Pixel-Simulation
用于模拟单光子激光雷达（SPL）中宏像素的信号读取过程：
# 参数修改
在init_parameters中修改激光雷达的相关参数：包括激光器和光学收发系统、探测器参数、宏像素规模
# 结果
1）在SP_result中得到单像素的仿真结果：需先设置：目标距离（L_target = 300）;门控时间开始的bin（gateStartBin = 1）;TDC类型（单事件TDCtype=0；多事件TDCtpye=1）；是否有背景噪声（有背景噪声NOISE=1；无背景噪声NOISE=0）。
2）在MP_result中得到宏像素的仿真结果：除了上述设置外还需额外设置：宏像素阈值（coincidenceThreshold）；符合时间窗（coincidenceTime）。   
