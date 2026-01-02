clear; clc;close all;
%% 1. 比例环节 Kp
Kp = [1, 2, 5];
figure;

% 时域响应
subplot(2,1,1);
for i = 1:length(Kp)
    sys = tf(Kp(i), 1);
    step(sys); hold on;
end
xlabel('时间'); ylabel('幅值'); title('比例环节');
legend('Kp=1','Kp=2','Kp=5', 'Location', 'best');
grid on;

% 频域响应
subplot(2,1,2);
for i = 1:length(Kp)
    sys = tf(Kp(i), 1);
    bode(sys); hold on;
end
grid on;
legend('Kp=1','Kp=2','Kp=5', 'Location', 'best');

%% 2. 积分环节
Ti = [0.5, 1, 2];
figure

% 时域响应
subplot(2,1,1);
for i = 1:length(Ti)
    sys = tf(1, [Ti(i), 0]);
    step(sys); hold on;
end
xlabel('时间'); ylabel('幅值'); title('积分环节');
legend('Ti=0.5','Ti=1','Ti=2', 'Location', 'best');
grid on;

% 频域响应
subplot(2,1,2);
for i = 1:length(Ti)
    sys = tf(1, [Ti(i), 0]);
    bode(sys); hold on;
end
grid on;
legend('Ti=0.5','Ti=1','Ti=2', 'Location', 'best');

%% 3. 微分环节
T = 0.1; Td = [0.1, 0.5, 1];
figure;

% 时域响应
subplot(2,1,1);
for i = 1:length(Td)
    sys = tf([Td(i), 0], [T, 1]);
    step(sys); hold on;
end
xlabel('时间'); ylabel('幅值'); title('微分环节');
legend('Td=0.1','Td=0.5','Td=1', 'Location', 'best');
grid on;

% 频域响应
subplot(2,1,2);
for i = 1:length(Td)
    sys = tf([Td(i), 0], [T, 1]);
    bode(sys); hold on;
end
grid on;
legend('Td=0.1','Td=0.5','Td=1', 'Location', 'best');

%% 4. 惯性环节
T = [0.5, 1, 2];
figure;

% 时域响应
subplot(2,1,1);
for i = 1:length(T)
    sys = tf(1, [T(i), 1]);
    step(sys); hold on;
end
xlabel('时间'); ylabel('幅值'); title('惯性环节');
legend('T=0.5','T=1','T=2', 'Location', 'best');
grid on;

% 频域响应
subplot(2,1,2);
for i = 1:length(T)
    sys = tf(1, [T(i), 1]);
    bode(sys); hold on;
end
grid on;
legend('T=0.5','T=1','T=2', 'Location', 'best');

%% 5. 比例积分控制器
Kp = [1, 2]; Ti = [0.5, 1];
figure;

% 生成所有组合
legend_strs = {};
sys_counter = 1;

% 时域响应
subplot(2,1,1);
for i = 1:length(Kp)
    for j = 1:length(Ti)
        sys = tf([Kp(i)*Ti(j), 1], [Ti(j), 0]);
        step(sys); hold on;
        legend_strs{sys_counter} = sprintf('Kp=%.1f,Ti=%.1f', Kp(i), Ti(j));
        sys_counter = sys_counter + 1;
    end
end
xlabel('时间'); ylabel('幅值'); title('比例积分环节');
legend(legend_strs, 'Location', 'best');
grid on;

% 频域响应
subplot(2,1,2);
sys_counter = 1;
legend_strs2 = {};
for i = 1:length(Kp)
    for j = 1:length(Ti)
        sys = tf([Kp(i)*Ti(j), 1], [Ti(j), 0]);
        bode(sys); hold on;
        legend_strs2{sys_counter} = sprintf('Kp=%.1f,Ti=%.1f', Kp(i), Ti(j));
        sys_counter = sys_counter + 1;
    end
end
grid on;
legend(legend_strs2, 'Location', 'best');

%% 6. 比例微分控制器
Kp = [1, 2]; Td = [0.1, 0.5]; T = 0.1;
figure;

% 生成所有组合
legend_strs = {};
sys_counter = 1;

% 时域响应
subplot(2,1,1);
for i = 1:length(Kp)
    for j = 1:length(Td)
        sys = tf([Kp(i)*T+Td(j), Kp(i)], [T, 1]);
        step(sys); hold on;
        legend_strs{sys_counter} = sprintf('Kp=%.1f,Td=%.1f', Kp(i), Td(j));
        sys_counter = sys_counter + 1;
    end
end
xlabel('时间'); ylabel('幅值'); title('比例微分环节');
legend(legend_strs, 'Location', 'best');
grid on;

% 频域响应
subplot(2,1,2);
sys_counter = 1;
legend_strs2 = {};
for i = 1:length(Kp)
    for j = 1:length(Td)
        sys = tf([Kp(i)*T+Td(j), Kp(i)], [T, 1]);
        bode(sys); hold on;
        legend_strs2{sys_counter} = sprintf('Kp=%.1f,Td=%.1f', Kp(i), Td(j));
        sys_counter = sys_counter + 1;
    end
end
grid on;
legend(legend_strs2, 'Location', 'best');
