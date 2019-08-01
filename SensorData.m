clear;
close all;
addpath('Quaternions');
isHand = 0;
SensorNo = 7;
TimeDiff = -5.467;

%%%%% Read Sensor Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SE = readmatrix('0621Sensor/SensorData-5.csv');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Read Model Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = csvread('0621-location-Mark/0621-5-location-Mark/右腳踝location.csv', 0, 0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Read VICON Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OP = csvread('OpticalOutput/RANK_HITA_02.csv', 0, 0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TimeStamp = SE(:,1);
TimeStampDiff = diff(TimeStamp);
T2(1) = 0;
for i=1:length(TimeStampDiff)
    T2(i+1) = T2(i) + TimeStampDiff(i)*0.001;
end
SE_GyroscopeX = SE(:,SensorNo*6-4);
SE_GyroscopeY = SE(:,SensorNo*6-3);
SE_GyroscopeZ = SE(:,SensorNo*6-2);
SE_AccelerometerX = SE(:,SensorNo*6-1);
SE_AccelerometerY = SE(:,SensorNo*6);
SE_AccelerometerZ = SE(:,SensorNo*6+1);

gyr_magFilt = sqrt(SE_GyroscopeX.*SE_GyroscopeX + SE_GyroscopeY.*SE_GyroscopeY + SE_GyroscopeZ.*SE_GyroscopeZ);

Accelerometer = [SE_AccelerometerX SE_AccelerometerY SE_AccelerometerZ]*9.8;
Gyroscope = [SE_GyroscopeX SE_GyroscopeY SE_GyroscopeZ]*pi/180;

ifilt = imufilter();
for ii=1:size(Accelerometer,1)
    qimu(ii) = ifilt(Accelerometer(ii,:), Gyroscope(ii,:));
end
[a,b,c,d] = parts(qimu);
quat = [a' b' c' d'];
%%%%%%%%%%%%%%%%%%%%%%% ACCELERATIONS
acc = quaternRotate([SE_AccelerometerX SE_AccelerometerY SE_AccelerometerZ], quat);
acc = acc * 9.8;
acc(:,3) = acc(:,3) - mean(acc(1:200,3));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Compute accelerometer magnitude
acc_mag = sqrt(acc(:,1).*acc(:,1) + acc(:,2).*acc(:,2) + acc(:,3).*acc(:,3));
% 
% % HP filter accelerometer data
% filtCutOff = 0.001;
% [b, a] = butter(1, (2*filtCutOff)/100, 'high');
% acc_magFilt = filtfilt(b, a, acc_mag);
% 
% % Compute absolute value
% acc_magFilt = abs(acc_magFilt);
% 
% % LP filter accelerometer data
% filtCutOff = 5;
% [b, a] = butter(1, (2*filtCutOff)/100, 'low');
% acc_magFilt = filtfilt(b, a, acc_magFilt);

if isHand == 0
    acc_threshold = 1;
    mag_threshold = 20;
    DistThreshold = 0.5; %50cm
    VThreshold = 1;
else
    acc_threshold = 1;
    mag_threshold = 20;
    DistThreshold = 0.8; %80cm
    VThreshold = 3;
end
stationary = zeros(size(gyr_magFilt));
stationary = 1 - stationary;
for t = 2:length(stationary)
    if acc_mag(t) > acc_threshold || gyr_magFilt(t) > mag_threshold
        stationary(t) = 0;
    end
end
figure('Position', [9 39 900 600], 'NumberTitle', 'off', 'Name', 'Accelerations');
    hold on;
    plot(T2(1:length(acc(:,1))), acc(:,1), 'r');
    plot(T2(1:length(acc(:,2))), acc(:,2), 'g');
    plot(T2(1:length(acc(:,3))), acc(:,3), 'b');
    plot(T2(1:length(acc_mag)), acc_mag, ':k');
    plot(T2(1:length(stationary)), stationary, 'k', 'LineWidth', 2);
    title('穿戴Accelerations');
    xlabel('Time (s)');
    ylabel('Accelerations(m/s/s)');
    legend('X', 'Y', 'Z');
    hold off;
figure('Position', [9 39 900 600], 'NumberTitle', 'off', 'Name', 'GYR');
    hold on;
    plot(T2(1:length(Gyroscope(:,1))), Gyroscope(:,1), 'r');
    plot(T2(1:length(Gyroscope(:,2))), Gyroscope(:,2), 'g');
    plot(T2(1:length(Gyroscope(:,3))), Gyroscope(:,3), 'b');
    plot(T2(1:length(gyr_magFilt)), gyr_magFilt, ':k');
    plot(T2(1:length(stationary)), stationary, 'k', 'LineWidth', 2);
    title('穿戴GYR');
    xlabel('Time (s)');
    ylabel('Accelerations(m/s/s)');
    legend('X', 'Y', 'Z');
    hold off;
SE_Accelerations1D = sqrt(acc(:,1).*acc(:,1) + acc(:,2).*acc(:,2) + acc(:,3).*acc(:,3));
figure('Position', [9 39 900 600], 'NumberTitle', 'off', 'Name', 'Accelerations');
    hold on;
    plot(T2(1:length(SE_Accelerations1D))+3.469, SE_Accelerations1D, 'b');
    title('1DAccelerations');
    xlabel('Time (s)');
    ylabel('Accelerations(m/s/s)');
    hold off;

%%%%%%%%%%%%%%%%%%%%%%% VELOCITY
ori_vel = zeros(size(acc));
for t = 2:length(ori_vel)
    ori_vel(t,:) = ori_vel(t-1,:) + acc(t-1,:) * (TimeStampDiff(t-1)/1000);
end
figure('Position', [9 39 900 600], 'NumberTitle', 'off', 'Name', 'Orign Velocity');
    hold on;
    plot(T2(1:length(ori_vel(:,1))), ori_vel(:,1), 'r');
    plot(T2(1:length(ori_vel(:,2))), ori_vel(:,2), 'g');
    plot(T2(1:length(ori_vel(:,3))), ori_vel(:,3), 'b');
    title('穿戴ORI_Velocity');
    xlabel('Time (s)');
    ylabel('Velocity(m/s)');
    legend('X', 'Y', 'Z');
    hold off;
vel = zeros(size(acc));
for t = 2:length(vel)
    vel(t,:) = vel(t-1,:) + acc(t-1,:) * (TimeStampDiff(t-1)/1000);
    if(stationary(t) == 1)
        vel(t,:) = [0 0 0];     % force zero velocity when foot stationary
    end
end
velDrift = zeros(size(vel));
stationaryStart = find([0; diff(stationary)] == -1);
stationaryEnd = find([0; diff(stationary)] == 1);
for i = 1:numel(stationaryEnd)
    driftRate = vel(stationaryEnd(i)-1, :) / (stationaryEnd(i) - stationaryStart(i));
    enum = 1:(stationaryEnd(i) - stationaryStart(i));
    drift = [enum'*driftRate(1) enum'*driftRate(2) enum'*driftRate(3)];
    velDrift(stationaryStart(i):stationaryEnd(i)-1, :) = drift;
end
% Remove integral drift
vel = vel - velDrift;

figure('Position', [9 39 900 600], 'NumberTitle', 'off', 'Name', 'Velocity');
    hold on;
    plot(T2(1:length(vel(:,1))), vel(:,1), 'r');
    plot(T2(1:length(vel(:,2))), vel(:,2), 'g');
    plot(T2(1:length(vel(:,3))), vel(:,3), 'b');
    title('穿戴Velocity');
    xlabel('Time (s)');
    ylabel('Velocity(m/s)');
    legend('X', 'Y', 'Z');
    hold off;
SE_Velocity1D = sqrt(vel(:,1).*vel(:,1) + vel(:,2).*vel(:,2) + vel(:,3).*vel(:,3));
figure('Position', [9 39 900 600], 'NumberTitle', 'off', 'Name', 'Velocity');
    hold on;
    plot(T2(1:length(SE_Velocity1D)), SE_Velocity1D, 'r');
    title('穿戴Velocity1D');
    xlabel('Time (s)');
    ylabel('Velocity(m/s)');
    hold off;
%%%%%%%%%%%%%%%%%%%%%%% POSITION
pos = zeros(size(vel));
for t = 3:length(pos)
    pos(t,:) = pos(t-1,:) + vel(t-1,:) * (TimeStampDiff(t-2)/1000);
end
LineDistList = []; %出拳直線距離
PathDistList = []; %出拳路徑距離
ActionStartList = []; %動作起點
ActionEndList = []; %動作起點
MaxVelList = []; %最大速度
% stationaryEnd(6) = 844;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:numel(stationaryEnd)
    PunchDist = 0;
    for ii = stationaryStart(i):stationaryEnd(i)
        if ii < length(pos)
            PunchDist = PunchDist + sqrt((pos(ii,1) - pos(ii+1,1)).^2 + (pos(ii,2) - pos(ii+1,2)).^2 + (pos(ii,3) - pos(ii+1,3)).^2);
        end
    end
    [MaxVel,Index] = max(SE_Velocity1D(stationaryStart(i):stationaryEnd(i)));
    if PunchDist >= DistThreshold && MaxVel >= VThreshold
        if isHand == 1
            [MaxVel,Index] = max(SE_Velocity1D(stationaryStart(i):stationaryEnd(i)));
            for ii = stationaryStart(i) + Index - 1:stationaryEnd(i)
                if SE_Velocity1D(ii) < SE_Velocity1D(ii-1) && SE_Velocity1D(ii) < SE_Velocity1D(ii+1)
                    stationaryEnd(i) = ii+1;
                    break;
                end
            end
            PunchDist = 0;
            for ii = stationaryStart(i):stationaryEnd(i)
                PunchDist = PunchDist + sqrt((pos(ii,1) - pos(ii+1,1)).^2 + (pos(ii,2) - pos(ii+1,2)).^2 + (pos(ii,3) - pos(ii+1,3)).^2);
            end
        end
        LineDist = sqrt((pos(stationaryStart(i), 1) - pos(stationaryEnd(i), 1)).^2 + (pos(stationaryStart(i), 2) - pos(stationaryEnd(i), 2)).^2 + (pos(stationaryStart(i), 3) - pos(stationaryEnd(i), 3)).^2); 
        LineDistList = [LineDistList LineDist*100];
        PathDistList = [PathDistList PunchDist*100];
        ActionStartList = [ActionStartList stationaryStart(i)];
        ActionEndList = [ActionEndList stationaryEnd(i)];
        [MaxVel,Index] = max(SE_Velocity1D(stationaryStart(i):stationaryEnd(i)));
        MaxVelList = [MaxVelList MaxVel];
    end
end
figure('Position', [9 39 900 600], 'NumberTitle', 'off', 'Name', 'Position');
    hold on;
    plot(T2(1:length(pos(:,1))), pos(:,1), 'r');
    plot(T2(1:length(pos(:,2))), pos(:,2), 'g');
    plot(T2(1:length(pos(:,3))), pos(:,3), 'b');
    title('穿戴Position');
    xlabel('Time (s)');
    ylabel('Position(m)');
    legend('X', 'Y', 'Z');
    hold off;
for i=1:length(ActionStartList)
    disp('Sensor');
    disp(['第' num2str(i) '拳']);
    disp(['開始時間: ' num2str(T2(ActionStartList(i)))]);
    disp(['結束時間: ' num2str(T2(ActionEndList(i)-1))]);
    disp(['持續時間: ' num2str(T2(ActionEndList(i)-1) - T2(ActionStartList(i))) ' (s)']);
    disp(['直線距離: ' num2str(LineDistList(i)) ' (cm)']);
    disp(['軌跡距離: ' num2str(PathDistList(i)) ' (cm)']);
    disp(['最大速度: ' num2str(MaxVelList(i)) ' (m/s)']);
    fprintf('\n');
end
disp('--------------------------------------------');
disp('模型');
[datanumS, dia] = size(S);
DataS = S(1:datanumS, :);
DataSX = DataS(:,1)/100;
DataSY = DataS(:,2)/100;
DataSZ = DataS(:,3)/100;
for i=2:length(DataSX)
    VelocitySX(i) = (DataSX(i)-DataSX(i-1))/0.01;
    VelocitySY(i) = (DataSY(i)-DataSY(i-1))/0.01;
    VelocitySZ(i) = (DataSZ(i)-DataSZ(i-1))/0.01;
end
VelocitySX = VelocitySX(2:length(DataSZ));
VelocitySY = VelocitySY(2:length(DataSZ));
VelocitySZ = VelocitySZ(2:length(DataSZ));
S_Velocity1D = sqrt(VelocitySX.*VelocitySX + VelocitySY.*VelocitySY + VelocitySZ.*VelocitySZ);
for i = 1:numel(ActionStartList)
    SE_DIST_SUM(i) = 0;
    disp(['第' num2str(i) '拳']);
    SE_DIST_LINE(i) = sqrt((DataSX(ActionEndList(i)) - DataSX(ActionStartList(i)))^2 + (DataSY(ActionEndList(i)) - DataSY(ActionStartList(i)))^2 + (DataSZ(ActionEndList(i)) - DataSZ(ActionStartList(i)))^2);
    disp(['直線距離: ' num2str(SE_DIST_LINE(i)*100) ' (cm)']);
    for ii=ActionStartList(i):ActionEndList(i)
        SE_DIST_SUM(i) = SE_DIST_SUM(i) + sqrt((DataSX(ii)-DataSX(ii-1))^2 + (DataSY(ii)-DataSY(ii-1))^2 + (DataSZ(ii)-DataSZ(ii-1))^2);
    end
    disp(['軌跡距離: ' num2str(SE_DIST_SUM(i)*100) ' (cm)']);
    [MaxVel,Index] = max(S_Velocity1D(ActionStartList(i):ActionEndList(i)));
    disp(['最大速度: ' num2str(MaxVel) ' (m/s)']);
    fprintf('\n');
end
disp('--------------------------------------------');
disp('光學');
[datanum, dia] = size(OP);
OPData = OP(1:datanum-2, :);
NewOPDataX = (OPData(:,1) - OPData(1,1))/1000;
NewOPDataY = (OPData(:,2) - OPData(1,2))/1000;
NewOPDataZ = (OPData(:,3) - OPData(1,3))/1000;
T = [0 (1:datanum-3)./100];
for i=2:length(NewOPDataX)
    VelocityX(i) = (NewOPDataX(i)-NewOPDataX(i-1))/0.01;
    VelocityY(i) = (NewOPDataY(i)-NewOPDataY(i-1))/0.01;
    VelocityZ(i) = (NewOPDataZ(i)-NewOPDataZ(i-1))/0.01;
    if abs(VelocityX(i)) > 15
        VelocityX(i) = 0;
    end
    if abs(VelocityY(i)) > 15
        VelocityY(i) = 0;
    end
    if abs(VelocityZ(i)) > 15
        VelocityZ(i) = 0;
    end
end
VelocityX = VelocityX(2:length(NewOPDataX));
VelocityY = VelocityY(2:length(NewOPDataX));
VelocityZ = VelocityZ(2:length(NewOPDataX));
figure('Position', [9 39 900 600], 'NumberTitle', 'off', 'Name', 'Velocity');
    hold on;
    plot(T(1:length(VelocityX)), VelocityX, 'r');
    plot(T(1:length(VelocityY)), VelocityY, 'g');
    plot(T(1:length(VelocityZ)), VelocityZ, 'b');
    title('光學Velocity');
    xlabel('Time (s)');
    ylabel('Velocity(m/s)');
    legend('X', 'Y', 'Z');
    hold off;
OP_Velocity1D = sqrt(VelocityX.*VelocityX + VelocityY.*VelocityY + VelocityZ.*VelocityZ);
figure('Position', [9 39 900 600], 'NumberTitle', 'off', 'Name', 'Velocity');
    hold on;
    plot(T(1:length(OP_Velocity1D)), OP_Velocity1D, 'r');
    title('光學Velocity');
    xlabel('Time (s)');
    ylabel('Velocity(m/s)');
    hold off;
figure('Position', [9 39 900 600], 'NumberTitle', 'off', 'Name', '2Velocity');
    hold on;
    plot(T(1:length(OP_Velocity1D))-TimeDiff, OP_Velocity1D, 'r');
    plot(T2(1:length(SE_Velocity1D)), SE_Velocity1D, 'b');
    title('2Velocity');
    xlabel('Time (s)');
    ylabel('Velocity(m/s)');
    legend('光學', '穿戴');
    hold off;

for i = 1:numel(ActionStartList)
    disp(['第' num2str(i) '拳']);
    OP_DIST_SUM(i) = 0;
    START = round((T2(ActionStartList(i)) + TimeDiff) * 100);
    END = round((T2(ActionEndList(i)) + TimeDiff) * 100);
    OP_DIST_LINE(i) = sqrt((NewOPDataX(END) - NewOPDataX(START))^2 + (NewOPDataY(END) - NewOPDataY(START))^2 + (NewOPDataZ(END) - NewOPDataZ(START))^2);
    disp(['直線距離: ' num2str(OP_DIST_LINE(i)*100) ' (cm)']);
    for ii=START:END
        OP_DIST_SUM(i) = OP_DIST_SUM(i) + sqrt((NewOPDataX(ii)-NewOPDataX(ii-1))^2 + (NewOPDataY(ii)-NewOPDataY(ii-1))^2 + (NewOPDataZ(ii)-NewOPDataZ(ii-1))^2);
    end
    disp(['軌跡距離: ' num2str(OP_DIST_SUM(i)*100) ' (cm)']);
    [MaxVel,Index] = max(OP_Velocity1D(START:END));
    disp(['最大速度: ' num2str(MaxVel) ' (m/s)']);
    fprintf('\n');
end

disp('--------------------------------------------');
for i = 1:numel(ActionStartList)
    disp(['第' num2str(i) '拳          直線距離               軌跡距離               最大速度']);
    START = round((T2(ActionStartList(i)) + TimeDiff) * 100);
    END = round((T2(ActionEndList(i)) + TimeDiff) * 100);
    [MaxVelOP,~] = max(OP_Velocity1D(START:END));
    disp(['光學    ->   ' num2str(OP_DIST_LINE(i)*100) ' (cm)          ' num2str(OP_DIST_SUM(i)*100) ' (cm)          ' num2str(MaxVelOP) ' (m/s)']);
    [MaxVelM,~] = max(S_Velocity1D(ActionStartList(i):ActionEndList(i)));
    disp(['模型    ->   ' num2str(SE_DIST_LINE(i)*100) ' (cm)          ' num2str(SE_DIST_SUM(i)*100) ' (cm)          ' num2str(MaxVelM) ' (m/s)']);
    [MaxVelSE,~] = max(SE_Velocity1D(ActionStartList(i):ActionEndList(i)));
    disp(['sensor　->   ' num2str(LineDistList(i)) ' (cm)          ' num2str(PathDistList(i)) ' (cm)          ' num2str(MaxVelSE) ' (m/s)']);
    fprintf('\n');
end
disp('--------------------------------------------');
disp('誤差');
for i = 1:numel(ActionStartList)
    disp(['第' num2str(i) '拳          直線距離               軌跡距離               最大速度']);
    START = round((T2(ActionStartList(i)) + TimeDiff) * 100);
    END = round((T2(ActionEndList(i)) + TimeDiff) * 100);
    [MaxVelOP,~] = max(OP_Velocity1D(START:END));
    [MaxVelM,~] = max(S_Velocity1D(ActionStartList(i):ActionEndList(i)));
    [MaxVelSE,~] = max(SE_Velocity1D(ActionStartList(i):ActionEndList(i)));
    disp(['模型    ->   ' num2str(((SE_DIST_LINE(i)) - (OP_DIST_LINE(i))) / (OP_DIST_LINE(i)) * 100) ' (%)          ' num2str(((SE_DIST_SUM(i)) - (OP_DIST_SUM(i))) / (OP_DIST_SUM(i)) * 100) ' (%)          ' num2str((MaxVelM - MaxVelOP) / MaxVelOP * 100) ' (%)']);
    disp(['sensor　->   ' num2str(((LineDistList(i)/100) - (OP_DIST_LINE(i))) / (OP_DIST_LINE(i)) * 100) ' (%)          ' num2str(((PathDistList(i)/100) - (OP_DIST_SUM(i))) / (OP_DIST_SUM(i)) * 100) ' (%)          ' num2str((MaxVelSE - MaxVelOP) / MaxVelOP * 100) ' (%)']);
    fprintf('\n');
end