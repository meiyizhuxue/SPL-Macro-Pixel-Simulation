clear

%% 目标距（m）离和门控开始时间所在bin
L_target = 300;
gateStartBin = 1;

%% 背景噪声强度:lux
ambientLightIn = [0, 10e3, 40e3, 70e3];

%% 第一种类型：单像素
type1_SinglePixel;

%% 第二种类型：1*2宏像素
type2_12MacroPixel;

%% 第三种类型：2*2宏像素
type3_22MacroPixel;

%% 第四种类型：3*3宏像素
type4_33MacroPixel;