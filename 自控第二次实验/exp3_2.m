clc; clear; close all;
s = tf('s'); 
K = 20;  
G = K / ((s+1)*(0.2*s+1)*(0.3*s+1));  % 开环传递函数

% 绘制校正前伯德图
figure('Name','校正前伯德图');
margin(G); 
title('校正前开环系统伯德图','FontSize',16);
[Gm, Pm0, Wcg0, Wcp0] = margin(G);  % 计算稳定裕度

disp('===== 校正前系统性能 =====');
disp(['开环增益 K = ', num2str(K)]);
disp(['幅值裕度 GM = ', num2str(20*log10(Gm), '%.1f'), 'dB (线性值:', num2str(Gm,'%.2f'),')']);
disp(['相位裕度 PM = ', num2str(Pm0, '%.1f'), '°']);
disp(['相角穿越频率 Wcg = ', num2str(Wcg0, '%.1f'), 'rad/s']);
disp(['幅值穿越频率 Wcp = ', num2str(Wcp0, '%.1f'), 'rad/s']);

%% 设计滞后校正装置

target_PM = 45;       % 题目要求的相位裕度
margin_safe = 6;      % 滞后校正通常留 5°-10° 的余量，防止校正网络自身的滞后影响
target_phase = -180 + target_PM + margin_safe; % 目标相位值 (-180 + 45 + 6 = -129度)

% 获取系统的伯德数据
[mag, phase, w] = bode(G);
mag = squeeze(mag);
phase = squeeze(phase);

% 找到满足相位要求的频率点 (新的穿越频率 w_c_new)
% 注意：bode得到的相位可能是连续负值(如-200)，需要确保在-180附近寻找
% 我们寻找 phase ≈ -129° 的频率
idx = find(phase <= target_phase, 1, 'first'); 
% 做简单的线性插值获取更精确的频率
w_c_new = interp1(phase(idx-1:idx), w(idx-1:idx), target_phase);

% 检查是否满足穿越频率 >= 2.1 的要求
if w_c_new < 2.1
    warning('警告：计算出的穿越频率小于2.1 rad/s，可能无法同时满足所有指标。将尝试强制设置。');
    % 如果计算出的频率太低，可能需要牺牲一点相位裕度或重新调整K
    % 但在这个题目的参数下，通常 w_c_new 会大于 2.1
end

% 计算该频率处的幅值，确定衰减因子 beta
mag_at_wc = interp1(w, mag, w_c_new); % 获取该频率处的线性幅值
beta = mag_at_wc;  % 滞后校正需衰减的倍数，使得该处增益变为1 (0dB)

% 确定滞后校正转折频率 (通常取 0.1 * w_c_new 以避免相位滞后影响穿越频率)
T = 10 / w_c_new; 

% 构造滞后校正传递函数 Gc(s) = (Ts + 1) / (beta*Ts + 1)
Gc = (T*s + 1) / (beta*T*s + 1);

%% 校正后系统分析
G_corrected = Gc * G;  % 校正后开环传递函数

% 绘制校正后伯德图
figure('Name','校正后伯德图');
margin(G_corrected); 
title('校正后开环系统伯德图','FontSize',16);
[Gm_c, Pm_c, Wcg_c, Wcp_c] = margin(G_corrected);
Gm_c_db = 20*log10(Gm_c); % 转换为dB

disp('===== 滞后校正装置参数 =====');
disp(['设计策略：令新穿越频率处的相位为 ', num2str(target_phase), '°']);
disp(['新的穿越频率 w_c* = ', num2str(w_c_new, '%.3f'), ' rad/s (要求>=2.1)']);
disp(['需要衰减的幅值 beta = ', num2str(beta, '%.3f')]);
disp(['参数：T = ', num2str(T, '%.4f'), ' s']);
disp(['传递函数 Gc(s) = (', num2str(T, '%.3f'), 's + 1) / (', num2str(beta*T, '%.3f'), 's + 1)']);

disp('===== 校正后系统性能验证 =====');
disp(['幅值裕度 GM = ', num2str(Gm_c_db, '%.1f'), ' dB (要求>10) -> ',  char(string(Gm_c_db>10))]);
disp(['相位裕度 PM = ', num2str(Pm_c, '%.1f'), '° (要求>45) -> ', char(string(Pm_c>45))]);
disp(['穿越频率 Wcg = ', num2str(Wcg_c, '%.3f'), ' rad/s (要求>=2.1) -> ', char(string(Wcg_c>=2.1))]);
disp('校正后系统：');
G_corrected;


%% 绘制校正前后阶跃响应（两个子图）
figure('Name','校正前后阶跃响应');

t = 0:0.001:15;
sys_before = feedback(G, 1);          % 校正前闭环
sys_after = feedback(G_corrected, 1); % 校正后闭环

subplot(2,1,1);
step(sys_before, t);
grid on;
title('校正前闭环系统阶跃响应 (K = 20)','FontSize',16);
xlabel('时间','FontSize',16)
ylabel('振幅','FontSize',16)

subplot(2,1,2);
step(sys_after, t);
grid on;
title('校正后闭环系统阶跃响应 (滞后校正)','FontSize',16);
xlabel('时间','FontSize',16)
ylabel('振幅','FontSize',16)