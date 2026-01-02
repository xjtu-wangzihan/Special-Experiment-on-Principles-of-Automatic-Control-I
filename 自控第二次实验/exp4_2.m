clc; clear; close all;

s = tf('s');
G = 120/(s^3 + 12*s^2 + 20*s + 5);
t =0:0.001:50;

%% ================================================================
% --- 方法一：衰减曲线法（4:1 衰减比） ---
fprintf('【方法一：衰减曲线法】\n');
lambda = 4;                 % 衰减比 4:1

Kp_critical = 0.75;  
Tc = 2.14;             

fprintf('  衰减比 λ = %d:1\n', lambda);
fprintf('  临界比例增益 Kp_critical = %.4f\n', Kp_critical);
fprintf('  振荡周期 Tc = %.4f s\n', Tc);

% P 控制器参数
Kp_p    = Kp_critical/1;

% PI 控制器参数
Kp_pi   = Kp_critical/1.2;
Ti_pi   = 0.5 * Tc;

% PID 控制器参数
Kp_pid  = Kp_critical/0.8;
Ti_pid  = 0.3 * Tc;
Td_pid  = 0.1 * Tc;

fprintf('\n  --- P 控制器参数 ---\n');
fprintf('  Kp_p = %.4f\n', Kp_p);

fprintf('\n  --- PI 控制器参数 ---\n');
fprintf('  Kp_pi = %.4f, Ti_pi = %.4f\n', Kp_pi, Ti_pi);

fprintf('\n  --- PID 控制器参数 ---\n');
fprintf('  Kp_pid = %.4f, Ti_pid = %.4f, Td_pid = %.4f\n\n', Kp_pid, Ti_pid, Td_pid);


% 构造控制器
C_p_decay   = Kp_p;
C_pi_decay  = Kp_pi * (1 + 1/(Ti_pi * s));
C_pid_decay = Kp_pid * (1 + 1/(Ti_pid * s) + Td_pid * s);

% 绘图
figure('Name','衰减曲线法整定结果','NumberTitle','off'); 
hold on; grid on;

% 原系统阶跃响应
[y0,t0] = step(feedback(G,1),t);                     
plot(t0,y0,'k','LineWidth',1.5);

% P 控制
[y1,t1] = step(feedback(C_p_decay*G,1),t);   
plot(t1,y1,'r','LineWidth',1.5);

% PI 控制
[y2,t2] = step(feedback(C_pi_decay*G,1),t);  
plot(t2,y2,'b','LineWidth',1.5);

% PID 控制
[y3,t3] = step(feedback(C_pid_decay*G,1),t); 
plot(t3,y3,'g','LineWidth',1.5);

legend('原系统','P控制','PI控制','PID控制','Location','best');
title('衰减曲线法整定（4:1衰减比）阶跃响应对比');
xlabel('时间 (s)'); ylabel('输出'); ylim([0 2]);

%% ================================================================
%  方法二：临界比例度法
fprintf('【方法二：临界比例度法】\n');

Ku = 1.958;   
Pu = 1.41;   

fprintf('  临界比例增益 Ku = %.4f\n', Ku);
fprintf('  临界振荡周期 Pu = %.4f\n', Pu);

Kp_p=0.5*Ku;
Kp_pi = Ku/2.2;
Ti_pi = 0.85*Pu;
% Z-N 公式
Kp_ZN = 0.6 * Ku;
Ti_ZN = 0.5 * Pu;
Td_ZN = 0.125 * Pu;

fprintf('    P控制:   Kp = %.4f\n', 0.45*Ku);
fprintf('    PI控制:  Kp = %.4f, Ti = %.4f\n', 0.45*Ku, Pu/1.2);
fprintf('    PID控制: Kp = %.4f, Ti = %.4f, Td = %.4f\n\n', Kp_ZN, Ti_ZN, Td_ZN);

% 构造控制器
C_p_ZN   = Kp_p;
C_pi_ZN  = Kp_pi*(1 + 1/(Ti_pi*s));
C_pid_ZN = Kp_ZN*(1 + 1/(Ti_ZN*s) + Td_ZN*s);

% 绘图（比例度法）
figure('Name','临界比例度法结果','NumberTitle','off'); hold on; grid on;
[y0,t0] = step(feedback(G,1),t);                    
plot(t0,y0,'k','LineWidth',1.5);
[y1,t1] = step(feedback(C_p_ZN*G,1),t);   plot(t1,y1,'r','LineWidth',1.5);
[y2,t2] = step(feedback(C_pi_ZN*G,1),t);  plot(t2,y2,'b','LineWidth',1.5);
[y3,t3] = step(feedback(C_pid_ZN*G,1),t); plot(t3,y3,'g','LineWidth',1.5);
legend('原系统','P控制','PI控制','PID控制','Location','best');
title('临界比例度法阶跃响应对比');
xlabel('时间 (s)'); ylabel('输出'); ylim([0 2]);


%% ================================================================
%  方法三：试凑法
% ================================================================
fprintf('【方法三：试凑法（手动调参）】\n');

Kp_try = 1.2;
Ki_trial = 0.6;
Kd_trial = 0.5;

fprintf('  初始参数: Kp = %.2f, Ti = %.2f, Td = %.2f\n\n', Kp_try, Ki_trial, Kd_trial);

% figure('Name','试凑法整定结果','NumberTitle','off');
% step(feedback(pid(Kp_try,Kd_trial,Ki_trial)*G,1),t);
% grid on;
% title('试凑法 PID 控制参数响应');
% xlabel('时间 (s)'); ylabel('输出');

ctrl_P = pid(Kp_try, 0, 0);
% PI控制器（比例+积分，Kd=0）
ctrl_PI = pid(Kp_try, Ki_trial, 0);
% PID控制器（比例+积分+微分）
ctrl_PID = pid(Kp_try, Ki_trial, Kd_trial);

% 若需使用时间常数形式（Kp(1+1/(Ti s)+Td s)），改用pidstd函数：
% Ti = 0.5; Td = 0.3;  % 积分时间、微分时间
% ctrl_PID_std = pidstd(Kp_try, Ti, Td);

% --------------- 同图绘制三条响应曲线 ---------------
figure('Name','试凑法整定结果','NumberTitle','off');
% 绘制P校正阶跃响应
step(feedback(ctrl_P*G, 1), t);
hold on;  % 保持当前图，后续曲线叠加
% 绘制PI校正阶跃响应
step(feedback(ctrl_PI*G, 1), t);
% 绘制PID校正阶跃响应
step(feedback(ctrl_PID*G, 1), t);

% --------------- 图形美化与标注 ---------------
grid on;  % 显示网格
title('P/PI/PID 校正阶跃响应对比（试凑法）');
xlabel('时间 (s)'); 
ylabel('输出');
% 添加图例（与绘制顺序对应）
legend('P校正','PI校正','PID校正','Location','best');
hold off;  % 释放绘图保持
%% ================================================================
%  方法综合对比
figure('Name','两种方法PID控制效果对比','NumberTitle','off'); 
hold on; 
grid on;

[y0,t0] = step(feedback(G,1),t);                     plot(t0,y0,'k','LineWidth',2);
[y1,t1] = step(feedback(C_pid_decay*G,1),t); plot(t1,y1,'b','LineWidth',1.5);
[y2,t2] = step(feedback(C_pid_ZN*G,1),t);    plot(t2,y2,'r','LineWidth',1.5);
[y3,t3] = step(feedback(pid(Kp_try,Kd_trial,Ki_trial)*G,1),t);     plot(t3,y3,'m','LineWidth',1.5);

legend('原系统','衰减法PID','Z-N法PID','试凑法PID','Location','best');
title('不同整定方法的 PID 控制效果对比');
xlabel('时间 (s)'); ylabel('输出'); ylim([0 2]);
