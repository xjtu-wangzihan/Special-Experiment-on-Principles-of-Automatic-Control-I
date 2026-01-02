clc
clear
close all

% 固定参数
zeta_under = 0.5;   % 欠阻尼阻尼比
zeta_over  = 2.0;   % 过阻尼阻尼比
wn0 = 5;            % 基准自然频率
t = 0:0.001:40;

% 欠阻尼与过阻尼的自然频率取值
wn_under = [wn0/5, wn0, 5*wn0];
wn_over  = [wn0/10, wn0, 10*wn0];

colors = lines(6);  % 自动生成颜色

figure;

%% 欠阻尼
subplot(2,1,1);
hold on; grid on;
legendStr = {};
fprintf("欠阻尼系统性能指标 \n");
fprintf("%8s %8s %10s %8s %8s %8s %8s\n", ...
    'ζ','ω_n','超调量(%)','峰值时间(s)','上升时间(s) ','稳态时间(s)','稳态误差');
for i = 1:length(wn_under)
    wn = wn_under(i);
    num = wn^2;
    den = [1, 2*zeta_under*wn, wn^2];
    sys = tf(num, den);
    [y, t_out] = step(sys, t);
    plot(t_out, y, 'Color', colors(i,:), 'LineWidth', 1.8);
    legendStr{end+1} = sprintf('ζ=%.1f, ω_n=%.1f', zeta_under, wn);
    S = stepinfo(sys, 'RiseTimeLimits', [0 1]);  % 默认0–100%
    ess = abs(1 - y(end));  % 稳态误差
    fprintf("%8.2f %8.2f %10.2f %10.3f %10.3f %10.3f %10.4f\n", ...
        zeta_under, wn, S.Overshoot, S.PeakTime, S.RiseTime, S.SettlingTime, ess);
end
title('欠阻尼系统(\zeta = 0.5)：不同自然频率下的阶跃响应','Fontsize',16);
xlabel('时间 (s)','Fontsize',16);
ylabel('响应幅值','Fontsize',16);
legend(legendStr, 'Location', 'Best','Fontsize',16);
axis([0 10 0 2]);

%% 子图2：过阻尼
subplot(2,1,2);
hold on; grid on;
legendStr = {};
fprintf("\n过阻尼系统性能指标\n");
fprintf("%8s %8s %8s %8s %8s \n", ...
    'ζ','ω_n','上升时间(s)','稳态时间(s)','稳态误差');
for i = 1:length(wn_over)
    wn = wn_over(i);
    num = wn^2;
    den = [1, 2*zeta_over*wn, wn^2];
    sys = tf(num, den);
    [y, t_out] = step(sys, t);
    plot(t_out, y, 'Color', colors(i+3,:), 'LineWidth', 1.8);
    legendStr{end+1} = sprintf('ζ=%.1f, ω_n=%.1f', zeta_over, wn);
    S = stepinfo(sys, 'RiseTimeLimits', [0.1 0.9]);
    fprintf("%8.2f %8.2f %10.3f %10.3f %10.4f\n", ...
        zeta_over, wn, S.RiseTime, S.SettlingTime, ess);
end
title('过阻尼系统(\zeta = 2.0)：不同自然频率下的阶跃响应','Fontsize',16);
xlabel('时间 (s)','Fontsize',16);
ylabel('响应幅值','Fontsize',16);
legend(legendStr, 'Location', 'Best','Fontsize',16);
axis([0 40 0 2.2]);