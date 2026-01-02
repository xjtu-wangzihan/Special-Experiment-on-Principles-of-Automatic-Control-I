clc; clear; close all;
s = tf('s');
K = 100; 
G = K / ((s+1)*(0.5*s+1)*(0.002*s+1));  % 开环传递函数
t = 0:0.001:6;
% 绘制校正前伯德图，计算相位裕度
figure('Name','校正前伯德图');
margin(G); 
%grid on;
title('校正前开环系统伯德图','FontSize',16);
[Gm0, Pm0, Wcg0, Wcp0] = margin(G);  % 计算稳定裕度
disp('===== 校正前系统性能 =====');
disp(['开环增益K = ', num2str(K)]);
disp(['相位裕度PM = ', num2str(Pm0, '%.1f'), '°']);
disp(['相角穿越频率Wcg = ', num2str(Wcg0, '%.1f'), 'rad/s']);

%% 设计超前校正装置
PM_target = 50;  % 目标相位裕度
delta_PM = PM_target - Pm0 + 6;  % 需超前相位（+6°补偿频率右移的相位衰减）
alpha = (1 - sin(delta_PM*pi/180)) / (1 + sin(delta_PM*pi/180));  % 超前校正参数α

% 找到幅频|G(jw)|=√α对应的频率（新的增益穿越频率w_c）
[mag, ~, w] = bode(G);
mag = squeeze(mag);  % 转换为向量
sqrt_alpha = sqrt(alpha);
idx = find(mag < sqrt_alpha, 1, 'first');  % 找到幅频首次小于√α的点
w_c = interp1(mag(idx-1:idx), w(idx-1:idx), sqrt_alpha);  % 插值得到w_c

% 计算超前校正的时间常数T
T = 1 / (w_c * sqrt(alpha));
Gc = (1 + T*s) / (1 + alpha*T*s);  % 超前校正传递函数

%% 校正后系统分析
G_corrected = Gc * G;  % 校正后开环传递函数

% 绘制校正后伯德图，验证性能
figure('Name','校正后伯德图');
margin(G_corrected); 
title('校正后开环系统伯德图','FontSize',16);
[Gm_c, Pm_c, Wcg_c, Wcp_c] = margin(G_corrected);
disp('===== 超前校正装置参数 =====');
disp(['传递函数：Gc(s) = (1 + Ts)/(1 + αTs)']);
disp(['参数：T = ', num2str(T, '%.4f'), ' s，α = ', num2str(alpha, '%.4f')]);
disp(['具体形式：Gc(s) = (1 + ', num2str(T, '%.4f'), 's) / (1 + ', num2str(alpha*T, '%.4f'), 's)']);

disp('===== 校正后系统性能 =====');
disp(['相位裕度PM = ', num2str(Pm_c, '%.1f'), '°']);
disp(['相角穿越频率Wcg = ', num2str(Wcg_c, '%.1f'), ' rad/s']);

%% 绘制校正前后阶跃响应
figure('Name','校正前后阶跃响应');
sys_before = feedback(G, 1);    % 校正前闭环系统
sys_after = feedback(G_corrected, 1);  % 校正后闭环系统
step(sys_before, sys_after,t); 
grid on;
xlabel('时间','FontSize',16)
ylabel('振幅','FontSize',16)
title('校正前后闭环系统阶跃响应','FontSize',16);
legend('校正前','校正后','Location','best','FontSize',16);