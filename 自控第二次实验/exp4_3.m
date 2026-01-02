% 系统传递函数: G(s) = 22/(50s+1) * e^(-20s)
clear; clc; close all;
K = 22;           % 增益
T = 50;           % 时间常数
tau = 20;         % 延迟时间

% 构建不含延迟的传递函数
G_no_delay = tf(K, [T 1]);
G = G_no_delay; 
G.InputDelay = tau;          % 添加纯滞后
%% 方法1: 动态特性参数法 (τ/T = 20/50 = 0.4)
fprintf('===== 方法1: 动态特性参数法 =====\n');
ratio = tau / T;
fprintf('τ/T = %.2f\n', ratio);

% 公式计算
inv_Kp1 = 2.6 * K * (ratio - 0.15) / (ratio + 0.88);
Kp1 = 1 / inv_Kp1;
Ti1 = 0.81 * T + 0.19 * tau;
Td1 = 0.25 * T;

fprintf('PID调节: Kp = %.4f, Ti = %.2f, Td = %.2f\n', Kp1, Ti1, Td1);

Ki1 = Kp1 / Ti1;
Kd1 = Kp1 * Td1;
C1 = pid(Kp1, Ki1, Kd1); 


%% 方法2: 科恩-库恩整定法
fprintf('\n===== 方法2: 科恩-库恩整定法 =====\n');

Kp_2 = (1.35 * (ratio)^(-1) + 0.27) / K;
Ti_2 = T * (2.5 * (ratio) + 0.5 * ratio*ratio) / (1 + 0.6 * ratio);
Td_2 = T * (0.37 * ratio) / (1 + 0.2 * ratio);

fprintf('PID参数:\n');
fprintf('Kp = %.4f\n', Kp_2);
fprintf('Ti = %.2f\n', Ti_2);
fprintf('Td = %.2f\n', Td_2);

% 构建PID控制器 (方法2)
C2 = pid(Kp_2, Kp_2/Ti_2, Kp_2*Td_2);

%% 仿真原系统响应 (不加PID)
t = 0:0.001:250;
sys_original = tf(K, [T 1], 'InputDelay', tau);
figure('Position', [100 100 1200 800]);

subplot(2,1,1);
step(feedback(sys_original,1), t);
title('原系统阶跃响应');
grid on;

sys_pid1 = feedback(C1 * sys_original, 1);
sys_pid2 = feedback(C2 * sys_original, 1);
% 比较两种方法
subplot(2,1,2);
step(sys_pid1, t); hold on;
step(sys_pid2, t);
legend('动态特性参数法', '科恩-库恩整定法');
title('两种PID控制方法比较');
grid on;

%% 4. 方法三：Smith 预估器控制
% 理论等效闭环： (C * G0) / (1 + C * G0) * exp(-tau*s)
Sys_Smith_NoDelay = feedback(C2 * G_no_delay, 1); 
Sys_Smith2 = Sys_Smith_NoDelay;
Sys_Smith2.InputDelay = tau;               

fprintf('Smith 预估器 (基于 Cohen-Coon 参数):\n 已构建等效模型。\n');

%绘图与对比分析
t = 0:0.01:400;
% --- 图2：Cohen-Coon 法 vs Smith 预估器 ---
figure('Name', 'Smith预估器效果');
hold on;
plot(t, step(sys_pid2, t), 'r', 'LineWidth', 1.5);
plot(t, step(Sys_Smith2, t), 'g--', 'LineWidth', 1.5);
legend('Cohen-Coon', 'Cohen-Coon + Smith预估器');
title('引入 Smith 预估器前后的效果对比');
grid on; hold off;

% 理论等效闭环： (C * G0) / (1 + C * G0) * exp(-tau*s)
Sys_Smith_NoDelay = feedback(C1 * G_no_delay, 1); 
Sys_Smith1 = Sys_Smith_NoDelay;
Sys_Smith1.InputDelay = tau;               

fprintf('Smith 预估器 (基于动态特性参数):\n 已构建等效模型。\n');
% --- 图3：动态特性法法 vs Smith 预估器 ---
figure('Name', 'Smith预估器效果');
hold on;
plot(t, step(sys_pid1, t), 'r', 'LineWidth', 1.5);
plot(t, step(Sys_Smith1, t), 'g--', 'LineWidth', 1.5);
legend('动态特性', '动态特性 + Smith预估器');
title('引入 Smith 预估器前后的效果对比');
grid on; hold off;

%% 性能指标计算
fprintf('===== 性能指标 =====\n');

% 获取阶跃响应信息
info_pid1 = stepinfo(sys_pid1);
info_pid2 = stepinfo(sys_pid2);
info_smith2 = stepinfo(feedback(Sys_Smith2, 1));
info_smith1 = stepinfo(feedback(Sys_Smith1, 1));

fprintf('方法1 (动态特性参数法):\n');
fprintf('  上升时间: %.2f s\n', info_pid1.RiseTime);
fprintf('  超调量: %.2f%%\n', info_pid1.Overshoot);
fprintf('  调节时间: %.2f s\n\n', info_pid1.SettlingTime);

fprintf('方法2 (科恩-库恩整定法):\n');
fprintf('  上升时间: %.2f s\n', info_pid2.RiseTime);
fprintf('  超调量: %.2f%%\n', info_pid2.Overshoot);
fprintf('  调节时间: %.2f s\n\n', info_pid2.SettlingTime);

% fprintf('Smith预估器:\n');
% fprintf('  上升时间: %.2f s\n', info_smith.RiseTime);
% fprintf('  超调量: %.2f%%\n', info_smith.Overshoot);
% fprintf('  调节时间: %.2f s\n\n', info_smith.SettlingTime);

fprintf('程序执行完成！\n');