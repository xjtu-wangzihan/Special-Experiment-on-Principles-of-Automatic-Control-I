clc clear
syms K real

% 系统特征多项式：s^4 + 4s^3 + 3s^2 + 2s + (1+K)
a4 = 1;
a3 = 4;
a2 = 3;
a1 = 2;
a0 = 1 + K;

R1 = [a4, a2, a0];
R2 = [a3, a1, 0];

R3_1 = (R2(1)*R1(2) - R1(1)*R2(2)) / R2(1);
R3_2 = (R2(1)*R1(3) - R1(1)*0) / R2(1);
R4_1 = simplify((R3_1*R2(2) - R2(1)*R3_2) / R3_1);
R5_1 = a0;

routh_first_col = simplify([R1(1), R2(1), R3_1, R4_1, R5_1]);
disp('劳斯表首列元素：')
disp(routh_first_col)

% 稳定性条件
cond1 = [(R4_1)>0, (R5_1)>0];
disp('稳定性条件：')
disp(cond1)
% 使用reduce得到逻辑交集
K_range = solve(cond1, K, 'ReturnConditions', true);
disp('系统稳定的K范围：')
disp(simplify(K_range.conditions))

K_stable_val = 0.1;  % 稳定
K_critical_val = 0.25; % 临界稳定
K_unstable_val = 0.5;  % 不稳定

figure;

% 稳定
num = K_stable_val;
den = [1 4 3 2 1 + num];
sys_stable = tf(num, den);
subplot(3,1,1);
hold on
step(sys_stable);
xlim([0 600]);  % 调整坐标轴范围
xlabel('时间','Fontsize',16);
ylabel('响应幅值','Fontsize',16);
title(['稳定状态 K = ', num2str(num)],'FontSize',16);

% 临界稳定
num = K_critical_val;
den = [1 4 3 2 1 + num];
sys_critical = tf(num, den);
subplot(3,1,2);
step(sys_critical);
xlim([0 100 ]);  % 调整坐标轴范围
xlabel('时间','Fontsize',16);
ylabel('响应幅值','Fontsize',16);
title(['临界稳定 K = ', num2str(num)],'FontSize',16);

% 不稳定
num = K_unstable_val;
den = [1 4 3 2 1 + num];
sys_unstable = tf(num, den);
subplot(3,1,3);
step(sys_unstable);
xlim([0 60]);
xlabel('时间','Fontsize',16);
ylabel('响应幅值','Fontsize',16);
title(['不稳定状态 K = ', num2str(num)],'FontSize',16);