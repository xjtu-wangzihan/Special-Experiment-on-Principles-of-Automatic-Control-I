clc
clear;
% 固定自然频率
wn = 5; 
% 定义5个阻尼比ζ
zeta = [0, 0.2, 0.5, 1, 2];  % 无阻尼、欠阻尼、临界阻尼、过阻尼
t = 0:0.001:10;  % 时间区间（秒）

figure;
hold on; 
grid on;

% 颜色与线型设置
colors = ['r', 'g', 'b', 'k', 'm'];
legendStr = cell(1, length(zeta));
fprintf("%8s %8s %10s %8s %8s %8s %8s\n", ...
    'ζ','ω_n','超调量(%)','峰值时间(s)','上升时间(s) ','稳态时间(s)','稳态误差');

% 循环绘制不同ζ的阶跃响应
for i = 1:length(zeta)
    num = wn^2;                        % 分子
    den = [1, 2*zeta(i)*wn, wn^2];     % 分母
    sys = tf(num, den);                % 传递函数对象
    [y, t_out] = step(sys, t);         % 阶跃响应
    plot(t_out, y, 'Color', colors(i), 'LineWidth', 1.5);
    legendStr{i} = sprintf('\\zeta = %.1f', zeta(i));
    if i==1
        continue
    else
        if i >=4
            S = stepinfo(sys, 'RiseTimeLimits', [0.1 0.9]);  % 默认0–100%
        else
            S = stepinfo(sys, 'RiseTimeLimits', [0 1]);  % 默认0–100%
        end
        ess = abs(1 - y(end));  % 稳态误差
        fprintf("%8.2f %8.2f %10.2f %10.3f %10.3f %10.3f %10.4f\n", ...
            zeta(i), wn, S.Overshoot, S.PeakTime, S.RiseTime, S.SettlingTime, ess);
    end
end
% 图形标注
title(sprintf('二阶系统阶跃响应比较 (\\omega_n = %.1f rad/s)', wn),'FontSize',16);
xlabel('时间 (s)','FontSize',16);
ylabel('响应幅值','FontSize',16);
legend(legendStr, 'Location', 'Best','FontSize',16);
axis([0 6 0 2.5]);  % 调整坐标轴范围
hold off;
