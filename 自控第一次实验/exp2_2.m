clc; clear; close all;

K_vals = [0.1, 0.25, 0.5];                 % 稳定、临界稳定、不稳定
K_labels = {'稳定', '临界稳定', '不稳定'};   % 对应标签

figure('Name', '系统零极点图', 'NumberTitle', 'off');

for i = 1:length(K_vals)
    K = K_vals(i);

    % 系统传递函数 G(s) = K / (s^4 + 4s^3 + 3s^2 + 2s + (1+K))
    num = K;
    den = [1 4 3 2 1 + K];

    subplot(3,1,i);
    pzmap(num, den);
    % 求系统极点
    sys = tf(num, den);
    p = pole(sys);
    fprintf('\n=== %s状态 (K = %.2f) ===\n', K_labels{i}, K);
    disp('系统特征根：');
    disp(p);
    title(sprintf('%s状态零极点图 (K = %.2f)', K_labels{i}, K), 'FontWeight','bold');
end
