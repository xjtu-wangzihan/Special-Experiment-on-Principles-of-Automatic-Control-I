clc ;clear;close all

% 创建主窗口
fig = figure('Name', 'Quanser 角度 PID 控制 (绝对位置)', ...
    'Position', [150 150 1200 800], ...
    'NumberTitle', 'off', ...
    'Resize', 'off');

%% --------------------- PID参数输入区域 ---------------------
% Kp标签与输入框
uicontrol('Style', 'text', 'Position', [50 730 40 40], ...
    'String', 'Kp', 'FontSize', 10, 'HorizontalAlignment', 'left');
hKp = uicontrol('Style', 'edit', 'Position', [80 740 50 40], ...
    'String', '0.2');

% Ki标签与输入框
uicontrol('Style', 'text', 'Position', [150 730 40 40], ...
    'String', 'Ki', 'FontSize', 10, 'HorizontalAlignment', 'left');
hKi = uicontrol('Style', 'edit', 'Position', [180 740 50 40], ...
    'String', '0.0005');

% Kd标签与输入框
uicontrol('Style', 'text', 'Position', [250 730 40 40], ...
    'String', 'Kd', 'FontSize', 10, 'HorizontalAlignment', 'left');
hKd = uicontrol('Style', 'edit', 'Position', [280 740 50 40], ...
    'String', '0.02');

%% --------------------- 仿真参数输入区域 ---------------------
% 目标角度标签与输入框
uicontrol('Style', 'text', 'Position', [350 730 100 40], ...
    'String', '目标角度 (°):', 'FontSize', 10, 'HorizontalAlignment', 'left');
hTargetAngle = uicontrol('Style', 'edit', 'Position', [430 740 100 40], ...
    'String', '180');

% 运行时间标签与输入框
uicontrol('Style', 'text', 'Position', [550 730 100 40], ...
    'String', '运行时间 (s):', 'FontSize', 10, 'HorizontalAlignment', 'left');
hRunTime = uicontrol('Style', 'edit', 'Position', [630 740 100 40], ...
    'String', '10');

% 虚拟仿真按钮
hStartSim = uicontrol('Style', 'pushbutton', 'Position', [750 740 100 40], ...
    'String', '模拟仿真', 'FontSize', 12, 'Callback', @startSimulation);

%% --------------------- 虚拟仿真状态显示 ---------------------
% 实时角度标题
uicontrol('Style', 'text', 'Position', [940 740 150 30], ...
    'String', '模拟控制实时角度', 'FontWeight', 'bold', 'FontSize', 12);
% 实时角度数值显示
hRealTimeAngle = uicontrol('Style', 'text', 'Position', [970 710 100 30], ...
    'String', '0.00 度', 'FontSize', 12);

% 性能指标标题
uicontrol('Style', 'text', 'Position', [940 670 150 30], ...
    'String', '模拟控制性能指标', 'FontWeight', 'bold', 'FontSize', 12);
% 超调量显示
hOvershoot = uicontrol('Style', 'text', 'Position', [920 620 130 30], ...
    'String', '超调量: ','Fontsize',12);
% 调节时间显示
hSettlingTime = uicontrol('Style', 'text', 'Position', [920 580 190 30], ...
    'String', '调节时间(2%): ','Fontsize',12,'HorizontalAlignment', 'left');
% 稳态误差显示
hSteadyError = uicontrol('Style', 'text', 'Position', [920 540 130 30], ...
    'String', '稳态误差: ','Fontsize',12);

% --------------------- 虚拟响应绘图区域 ---------------------
% 角度动态响应曲线
axesResponse = axes('Parent', fig, 'Position', [0.05 0.58 0.4 0.3]);
title('模拟控制响应曲线');
xlabel('时间(s)');
ylabel('角度(°)');
hold on;

% 实时角度指针绘图区域
axesPointer = axes('Parent', fig, 'Position', [0.4 0.58 0.5 0.3]);
title('模拟控制角度变化');
axis equal;
xlim([-1.5 1.5]);
ylim([-1.5 1.5]);
hold on;

% 绘制圆形轨迹(浅灰色)
theta_circle = linspace(0, 2*pi, 100);
plot(cos(theta_circle), sin(theta_circle), 'Color', [0.8 0.8 0.8], ...
    'LineWidth', 1, 'Parent', axesPointer);

% 绘制主要角度刻度线
for angle = 0:30:330
    angle_rad = deg2rad(angle);
    r_start = 0.85;
    r_end = 1.0;
    plot([r_start*cos(angle_rad), r_end*cos(angle_rad)], ...
         [r_start*sin(angle_rad), r_end*sin(angle_rad)], ...
         'k-', 'LineWidth', 1, 'Parent', axesPointer);
    % 角度标签 - 上半圆0-180°，下半圆0到-180°
    if angle <= 180
        label_text = sprintf('%d°', angle);
    else
        label_text = sprintf('%d°', angle - 360);
    end
    text(1.15*cos(angle_rad), 1.15*sin(angle_rad), label_text, ...
        'HorizontalAlignment', 'center', 'FontSize', 8, 'Parent', axesPointer);
end

plot([-1 1], [0 0], 'k--', 'LineWidth', 0.5, 'Parent', axesPointer); % 水平基准线
plot([0 0], [-1 1], 'k--', 'LineWidth', 0.5, 'Parent', axesPointer); % 垂直基准线

% 初始位置标记(绿色点)
hInitialMarker = plot(axesPointer, 0, 0, 'go', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'g', 'LineWidth', 2, 'Visible', 'off');

% 目标位置标记(红色点)
hTargetMarker = plot(axesPointer, 0, 0, 'ro', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'r', 'LineWidth', 2, 'Visible', 'off');

% 运动轨迹线(青色虚线)
hTrajectory = plot(axesPointer, 0, 0, 'c--', 'LineWidth', 1.5, 'Visible', 'off');

% 当前位置指针(红色粗线)
hPointer = plot(axesPointer, [0 1], [0 0], 'r', 'LineWidth', 3);

% 中心点
plot(0, 0, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'Parent', axesPointer);

%% --------------------- 电机控制区域 ---------------------
% 标定按钮(新增)
hCalibrate = uicontrol('Style', 'pushbutton', 'Position', [950 420 90 40], ...
    'String', '标定零点', 'FontSize', 11, 'Callback', @calibrateZeroCallback, ...
    'Enable', 'on', 'BackgroundColor', [0.95 0.95 0.7]);

% 电机控制按钮
hMotorControl = uicontrol('Style', 'pushbutton', 'Position', [1050 420 100 40], ...
    'String', '电机控制', 'FontSize', 12, 'Callback', @motorControlCallback, ...
    'Enable', 'on');

% --------------------- 电机角度绘图与显示 ---------------------
% 电机角度响应曲线
axesMotorResponse = axes('Parent', fig, 'Position', [0.05 0.18 0.4 0.3]);
title('电机实际角度响应曲线');
xlabel('时间 (s)');
ylabel('角度 (°)');
hold on;

% 电机实时角度指针绘图区域
axesMotorPointer = axes('Parent', fig, 'Position', [0.4 0.18 0.5 0.3]);
title('电机实时角度变化');
axis equal;
xlim([-1.5 1.5]);
ylim([-1.5 1.5]);
hold on;

% 绘制圆形轨迹(浅灰色)
theta_circle = linspace(0, 2*pi, 100);
plot(cos(theta_circle), sin(theta_circle), 'Color', [0.8 0.8 0.8], ...
    'LineWidth', 1, 'Parent', axesMotorPointer);

% 绘制主要角度刻度线
for angle = 0:30:330
    angle_rad = deg2rad(angle);
    r_start = 0.85;
    r_end = 1.0;
    plot([r_start*cos(angle_rad), r_end*cos(angle_rad)], ...
         [r_start*sin(angle_rad), r_end*sin(angle_rad)], ...
         'k-', 'LineWidth', 1, 'Parent', axesMotorPointer);
    % 角度标签 - 上半圆0-180°，下半圆0到-180°
    if angle <= 180
        label_text = sprintf('%d°', angle);
    else
        label_text = sprintf('%d°', angle - 360);
    end
    text(1.15*cos(angle_rad), 1.15*sin(angle_rad), label_text, ...
        'HorizontalAlignment', 'center', 'FontSize', 8, 'Parent', axesMotorPointer);
end

plot([-1 1], [0 0], 'k--', 'LineWidth', 0.5, 'Parent', axesMotorPointer); % 水平基准线
plot([0 0], [-1 1], 'k--', 'LineWidth', 0.5, 'Parent', axesMotorPointer); % 垂直基准线

% 初始位置标记(绿色点)
hMotorInitialMarker = plot(axesMotorPointer, 0, 0, 'go', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'g', 'LineWidth', 2, 'Visible', 'off');

% 目标位置标记(红色点)
hMotorTargetMarker = plot(axesMotorPointer, 0, 0, 'ro', 'MarkerSize', 10, ...
    'MarkerFaceColor', 'r', 'LineWidth', 2, 'Visible', 'off');

% 运动轨迹线(青色虚线)
hMotorTrajectory = plot(axesMotorPointer, 0, 0, 'c--', 'LineWidth', 1.5, 'Visible', 'off');

% 当前位置指针(红色粗线)
hMotorPointer = plot(axesMotorPointer, [0 1], [0 0], 'r', 'LineWidth', 3);

% 中心点
plot(0, 0, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'Parent', axesMotorPointer);

% 电机实时角度显示
uicontrol('Style', 'text', 'Position', [940 390 150 30], ...
    'String', '电机实时角度', 'FontWeight', 'bold', 'FontSize', 12);
hMotorRealTimeAngle = uicontrol('Style', 'text', 'Position', [970 360 100 30], ...
    'String', '0.00 度', 'FontSize', 12);

% 电机性能指标显示
uicontrol('Style', 'text', 'Position', [940 320 150 30], ...
    'String', '电机控制性能指标', 'FontWeight', 'bold', 'FontSize', 12);
hMotorOvershoot = uicontrol('Style', 'text', 'Position', [920 300 130 30], ...
    'String', '超调量: ','Fontsize',12);
hMotorSettlingTime = uicontrol('Style', 'text', 'Position', [920 270 130 30], ...
    'String', '调节时间(2%): ','Fontsize',12);
hMotorSteadyError = uicontrol('Style', 'text', 'Position', [920 240 130 30], ...
    'String', '稳态误差: ','Fontsize',12);

% --------------------- 存储控件句柄 ---------------------
handles = struct(...
    'hKp', hKp, ...
    'hKi', hKi, ...
    'hKd', hKd, ...
    'hTargetAngle', hTargetAngle, ...
    'hRunTime', hRunTime, ...
    'axesResponse', axesResponse, ...
    'axesPointer', axesPointer, ...
    'hPointer', hPointer, ...
    'hInitialMarker', hInitialMarker, ...
    'hTargetMarker', hTargetMarker, ...
    'hTrajectory', hTrajectory, ...
    'hOvershoot', hOvershoot, ...
    'hSettlingTime', hSettlingTime, ...
    'hSteadyError', hSteadyError, ...
    'hRealTimeAngle', hRealTimeAngle, ...
    'hStartSim', hStartSim, ...
    'hCalibrate', hCalibrate, ...
    'hMotorControl', hMotorControl, ...
    'axesMotorResponse', axesMotorResponse, ...
    'axesMotorPointer', axesMotorPointer, ...
    'hMotorPointer', hMotorPointer, ...
    'hMotorInitialMarker', hMotorInitialMarker, ...
    'hMotorTargetMarker', hMotorTargetMarker, ...
    'hMotorTrajectory', hMotorTrajectory, ...
    'hMotorRealTimeAngle', hMotorRealTimeAngle, ...
    'hMotorOvershoot', hMotorOvershoot, ...
    'hMotorSettlingTime', hMotorSettlingTime, ...
    'hMotorSteadyError', hMotorSteadyError, ...
    'absoluteZeroOffset', 0, ...  % 存储绝对零点偏移量
    'currentSimAngle', 0);  % 存储虚拟仿真的当前角度
    
% 将句柄存储到figure中
guidata(fig, handles);

%% =====================================================================
%  标定零点回调函数(新增)
function calibrateZeroCallback(~, ~)
    handles = guidata(gcf);
    
    try
        % 硬件配置参数
        board_type = 'qube_servo3_usb';
        board_identifier = '0';
        encoder_channels = 0;
        counts_per_revolution = 2048;
        
        % 打开硬件连接
        fprintf('正在连接Quanser硬件进行零点标定...\n');
        [board, err] = quanser.hardware.hil.open(board_type, board_identifier);
        
        if err ~= 0
            errordlg('无法连接到Quanser硬件,请检查设备连接。', '硬件错误');
            return;
        end
        
        % 读取当前编码器位置
        current_count = board.read_encoder(encoder_channels);
        current_angle = double(current_count) * 360 / counts_per_revolution;
        
        % 保存为零点偏移
        handles.absoluteZeroOffset = current_angle;
        guidata(gcf, handles);
        
        % 关闭硬件
        board.close();
        
        fprintf('零点标定完成!当前位置设为0度 (编码器读数: %.2f度)\n', current_angle);
        msgbox(sprintf('零点标定成功!\n当前位置已设为 0 度\n(原始读数: %.2f度)', current_angle), ...
            '标定完成');
        
    catch ME
        try
            if exist('board', 'var')
                board.close();
            end
        catch
        end
        errordlg(['零点标定出错: ' ME.message], '错误');
    end
end

%% =====================================================================
%  虚拟仿真回调函数(修改为绝对角度控制)
function startSimulation(~, ~)
    handles = guidata(gcf); 
    
    try
        % 1. 获取PID参数
        Kp = str2double(get(handles.hKp, 'String'));
        Ki = str2double(get(handles.hKi, 'String'));
        Kd = str2double(get(handles.hKd, 'String'));
        
        % 2. 获取目标角度和运行时间
        targetAngle = str2double(get(handles.hTargetAngle, 'String'));
        runTime = str2double(get(handles.hRunTime, 'String'));
        
        % 参数有效性检查
        if isnan(Kp) || isnan(Ki) || isnan(Kd) || isnan(targetAngle) || isnan(runTime)
            errordlg('请输入有效的数值参数!', '输入错误');
            return;
        end
        
        % 获取当前仿真角度(初始位置)
        initialAngle = handles.currentSimAngle;
        
        % 计算实际需要移动的角度
        deltaAngle = targetAngle - initialAngle;
        
        fprintf('\n========== 虚拟仿真开始 ==========\n');
        fprintf('初始位置: %.2f度\n', initialAngle);
        fprintf('目标位置: %.2f度\n', targetAngle);
        fprintf('移动角度: %.2f度\n', deltaAngle);
        fprintf('================================\n\n');
        
        % 3. 定义被控对象传递函数 G(s) = 30 / (0.1s^2 + s)
        G = tf(30, [0.1 1 0]);
        
        % 4. 定义PID控制器 C(s) = Kp + Ki/s + Kd*s
        C = pid(Kp, Ki, Kd);
        
        % 5. 计算闭环传递函数
        closedLoop = feedback(C*G, 1);
        
        % 6. 生成时间向量和计算阶跃响应(相对于移动量)
        t = 0:0.01:runTime;
        [y_relative, t] = step(closedLoop, t);
        
        % 转换为绝对角度:初始位置 + 移动量 * 响应
        y = initialAngle + deltaAngle * y_relative;
        
        % 7. 清空之前的绘图
        cla(handles.axesResponse);
        axes(handles.axesResponse);
        
        % 8. 绘制初始位置参考线(绿色虚线)
        plot(handles.axesResponse, [0 runTime], [initialAngle initialAngle], ...
            'g--', 'LineWidth', 1.5, 'DisplayName', '初始位置');
        hold(handles.axesResponse, 'on');
        
        % 绘制目标角度参考线(红色虚线)
        plot(handles.axesResponse, [0 runTime], [targetAngle targetAngle], ...
            'r--', 'LineWidth', 2, 'DisplayName', '目标角度');
        
        % *** 移除2%误差带绘制代码 ***
        
        % 9. 实时动画显示响应曲线(蓝色实线)
        hLine = plot(handles.axesResponse, t(1), y(1), 'b-', 'LineWidth', 2.5, ...
            'DisplayName', '实际响应');
        
        % 设置图例
        legend(handles.axesResponse, 'Location', 'best');
        
        % 动态调整Y轴范围
        y_min = min([initialAngle, targetAngle, min(y)]);
        y_max = max([initialAngle, targetAngle, max(y)]);
        y_range = y_max - y_min;
        ylim(handles.axesResponse, [y_min - 0.1*y_range, y_max + 0.1*y_range]);
        
        % 设置指针图的初始和目标标记
        initial_rad = deg2rad(initialAngle);
        target_rad = deg2rad(targetAngle);
        
        % 显示初始位置标记(绿色)
        set(handles.hInitialMarker, 'XData', cos(initial_rad), ...
            'YData', sin(initial_rad), 'Visible', 'on');
        
        % 显示目标位置标记(红色)
        set(handles.hTargetMarker, 'XData', cos(target_rad), ...
            'YData', sin(target_rad), 'Visible', 'on');
        
        % 预计算轨迹路径(用于绘制轨迹线)
        % 直接按照角度差值计算，不选择最短路径
        deltaAngle = targetAngle - initialAngle;
        
        % 生成从初始角度到目标角度的完整轨迹
        trajectory_angles = linspace(initialAngle, targetAngle, 50);
        
        trajectory_rad = deg2rad(trajectory_angles);
        trajectory_x = cos(trajectory_rad);
        trajectory_y = sin(trajectory_rad);
        set(handles.hTrajectory, 'XData', trajectory_x, 'YData', trajectory_y, 'Visible', 'on');
        
        % 10. 动画更新
        animationSpeed = 10; % 每次更新显示10个点,加快动画速度
        
        % 记录累积角度用于指针连续旋转
        cumulative_angle = initialAngle;
        
        for i = 1:animationSpeed:length(t)
            % 更新响应曲线
            set(hLine, 'XData', t(1:i), 'YData', y(1:i));
            
            % 更新实时角度显示
            currentAngle = y(i);
            set(handles.hRealTimeAngle, 'String', sprintf('%.2f 度', currentAngle));
            
            % 在响应曲线上绘制当前点(红色圆点)
            if i > 1
                delete(findobj(handles.axesResponse, 'Tag', 'CurrentPoint'));
            end

            hpoint = plot(handles.axesResponse, t(i), y(i), 'ro', 'MarkerSize', 8, ...
                'MarkerFaceColor', 'r', 'Tag', 'CurrentPoint');
            set(get(get(hpoint, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
            
            % 更新指针显示 - 使用累积角度实现连续旋转
            if i > 1
                % 计算实际角度变化量（保持方向）
                prev_angle = y(max(1, i-animationSpeed));
                delta = currentAngle - prev_angle;
                cumulative_angle = cumulative_angle + delta;
            else
                cumulative_angle = currentAngle;
            end
            
            % 使用累积角度来显示指针，确保旋转方向正确
            angle_rad = deg2rad(cumulative_angle);
            x_end = cos(angle_rad);
            y_end = sin(angle_rad);
            set(handles.hPointer, 'XData', [0 x_end], 'YData', [0 y_end]);
            
            % 刷新显示
            drawnow;
            pause(0.001); % 短暂暂停以显示动画效果
        end
        
        % 删除最后的当前点标记
        delete(findobj(handles.axesResponse, 'Tag', 'CurrentPoint'));
        
        % 11. 计算性能指标(基于绝对角度)
        % 超调量 (Overshoot) 
        if abs(deltaAngle) > 0.1  % 避免除以接近零的数
            if deltaAngle > 0  % 正向移动
                y_max = max(y);
                overshoot = ((y_max - targetAngle) / abs(deltaAngle)) * 100;
            else  % 反向移动
                y_min = min(y);
                overshoot = ((targetAngle - y_min) / abs(deltaAngle)) * 100;
            end
            if overshoot < 0
                overshoot = 0; % 无超调
            end
        else
            overshoot = 0;  % 移动量太小,不计算超调
        end
        
        % 调节时间 (Settling Time) - 2%误差带
        tolerance = 0.02 * abs(deltaAngle);
        if tolerance < 0.5  % 最小容差阈值
            tolerance = 0.5;
        end
        settling_indices = find(abs(y - targetAngle) <= tolerance);
        if ~isempty(settling_indices)
            % 找到最后一次离开误差带的时刻
            last_exit = 1;
            for j = 2:length(settling_indices)
                if settling_indices(j) - settling_indices(j-1) > 1
                    last_exit = j;
                end
            end
            settling_idx = settling_indices(last_exit);
            settlingTime = t(settling_idx);
        else
            settlingTime = runTime; % 未达到稳定
        end
        
        % 稳态误差 (Steady State Error)
        y_final = y(end);
        steadyError = abs(targetAngle - y_final);
        
        % 12. 显示性能指标
        set(handles.hOvershoot, 'String', sprintf('超调量: %.2f%%', overshoot));
        set(handles.hSettlingTime, 'String', sprintf('调节时间(2%%): %.3f s', settlingTime));
        set(handles.hSteadyError, 'String', sprintf('稳态误差: %.3f°', steadyError));
        
        % 13. 更新当前仿真角度为最终位置
        handles.currentSimAngle = y_final;
        guidata(gcf, handles);
        
        % 14. 保存仿真数据供电机控制使用
        save('dynamic_response_data.mat', 't', 'y', 'targetAngle', 'initialAngle', ...
            'deltaAngle', 'Kp', 'Ki', 'Kd');
        
        % 15. 启用电机控制按钮
        set(handles.hMotorControl, 'Enable', 'on');
        
        fprintf('虚拟仿真完成!\n');
        fprintf('最终位置: %.2f度\n', y_final);
        fprintf('稳态误差: %.3f度\n\n', steadyError);
        
        msgbox(sprintf('虚拟仿真完成!\n初始: %.2f° → 目标: %.2f°\n最终: %.2f° (误差: %.3f°)', ...
            initialAngle, targetAngle, y_final, steadyError), '仿真完成');

    catch ME
        errordlg(['仿真出错: ' ME.message], '错误');
    end
end

%% =====================================================================
%  电机控制回调函数 (修改版：跟踪仿真轨迹)
function motorControlCallback(~, ~)
    handles = guidata(gcf);

    try
        % --- 1. 检查并加载仿真轨迹数据 ---
        if ~exist('dynamic_response_data.mat', 'file')
            errordlg('未发现仿真数据，请先点击“模拟仿真”！', '错误');
            return;
        end
        sim_data = load('dynamic_response_data.mat');
        
        % --- 2. 获取参数 ---
        Kp = str2double(get(handles.hKp, 'String'));
        Ki = str2double(get(handles.hKi, 'String'));
        Kd = str2double(get(handles.hKd, 'String'));
        runTime = str2double(get(handles.hRunTime, 'String'));
        zeroOffset = handles.absoluteZeroOffset;

        % --- 3. 硬件配置参数 ---
        board_type = 'qube_servo3_usb';
        board_identifier = '0';
        frequency = 100; % 采样频率 100Hz
        period = 1/frequency;
        tf = runTime; 
        
        encoder_channels = 0;
        analog_channels = 0;
        digital_channels = 0;
        motor_enable = 1;
        counts_per_revolution = 2048;
        voltage_limit = 10;
        samples_to_read = 1;
        
        % --- 4. 准备指令信号 (跟踪仿真 y 值) ---
        t_motor = 0:period:tf;
        % 使用线性插值确保电机指令与仿真时间对齐
        command_signal = interp1(sim_data.t, sim_data.y, t_motor, 'linear', 'extrap');

        % --- 5. 打开硬件连接 ---
        fprintf('正在连接Quanser硬件以进行轨迹跟踪...\n');
        [board, err] = quanser.hardware.hil.open(board_type, board_identifier);
        if err ~= 0, errordlg('硬件连接失败！'); return; end

        [task, err] = board.task_create_encoder_reader(10 * frequency, encoder_channels);
        if err ~= 0, board.close; errordlg('读取任务创建失败！'); return; end

        board.write_digital(digital_channels, motor_enable);
        
        % --- 6. 绘图区域初始化 ---
        cla(handles.axesMotorResponse);
        axes(handles.axesMotorResponse);
        % 绘制仿真轨迹作为参考 (红色点划线)
        plot(handles.axesMotorResponse, sim_data.t, sim_data.y, 'r-.', 'LineWidth', 1.5, 'DisplayName', '仿真参考轨迹');
        hold(handles.axesMotorResponse, 'on');
        % 实际响应曲线 (蓝色实线)
        hMotorLine = plot(handles.axesMotorResponse, 0, 0, 'b-', 'LineWidth', 2.5, 'DisplayName', '电机实际跟踪');
        legend(handles.axesMotorResponse, 'Location', 'best');
        grid(handles.axesMotorResponse, 'on');

        % --- 7. 控制循环变量 ---
        num_samples = length(t_motor);
        time_data = zeros(num_samples, 1);
        position_data = zeros(num_samples, 1);
        integral = 0;
        prev_error = 0;
        start_time = tic;

        task.start(0, frequency, -1);

        % --- 8. 主控制循环 ---
        for time_idx = 1:num_samples
            current_time = (time_idx-1) * period;
            time_data(time_idx) = current_time;
            
            % 当前的目标值为仿真轨迹在该时刻的值
            current_command = command_signal(time_idx);
            
            % 读取位置
            try
                count = task.read_encoder(samples_to_read);
                position = double(count) * 360 / counts_per_revolution - zeroOffset;
                position_data(time_idx) = position;
            catch
                position = position_data(max(1, time_idx-1));
            end

            % PID 计算 (轨迹跟踪控制)
            error = current_command - position;
            integral = integral + error * period;
            % 简单的抗饱和
            integral = max(min(integral, voltage_limit/max(Ki, 0.1)), -voltage_limit/max(Ki, 0.1));
            derivative = (error - prev_error) / period;
            
            voltage = Kp * error + Ki * integral + Kd * derivative;
            voltage = max(min(voltage, voltage_limit), -voltage_limit);
            
            % 写入硬件
            board.write_analog(analog_channels, voltage);
            prev_error = error;
            
            % 界面更新 (每10个采样更新一次)
            if mod(time_idx, 10) == 0
                set(hMotorLine, 'XData', time_data(1:time_idx), 'YData', position_data(1:time_idx));
                set(handles.hMotorRealTimeAngle, 'String', sprintf('%.2f 度', position));
                
                % 更新指针
                angle_rad = deg2rad(position);
                set(handles.hMotorPointer, 'XData', [0 cos(angle_rad)], 'YData', [0 sin(angle_rad)]);
                drawnow limitrate;
            end
            
            % 时间精确同步
            while toc(start_time) < current_time + period, end
        end

        % --- 9. 停止与清理 ---
        task.stop; task.close;
        board.write_analog(analog_channels, 0);
        board.close;
        msgbox('轨迹跟踪控制完成！', '完成');

    catch ME
        if exist('board', 'var'), board.close; end
        errordlg(['跟踪出错: ' ME.message]);
    end
end