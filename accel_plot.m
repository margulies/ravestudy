function accel_plot

clear; load accel_data.mat;

trial = [{'handL1'};{'handL2'};{'handR1'};{'handR2'};{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
frequency = 90; % Sampling frequency in Hz
% limits = [0 250 -4000 4000]; % Axis limits

% Detrend axis measures (Acceleration)
for i = 1:length(trial)
    eval([trial{i},'.xDetr = detrend(',trial{i},'.x);']);
    eval([trial{i},'.yDetr = detrend(',trial{i},'.y);']);
    eval([trial{i},'.zDetr = detrend(',trial{i},'.z);']);
end

% Integrate axis measures (Velocity)
% handL1.xInt = cumtrapz(handL1.x); handL1.yInt = cumtrapz(handL1.y); handL1.zInt = cumtrapz(handL1.z);
for i = 1:length(trial)
    eval([trial{i},'.xDetrInt = cumtrapz(',trial{i},'.xDetr);']); % Detrended data
    eval([trial{i},'.yDetrInt = cumtrapz(',trial{i},'.yDetr);']);
    eval([trial{i},'.zDetrInt = cumtrapz(',trial{i},'.zDetr);']);
end

% Combine axis measures (Acceleration)
% handL1.dist = sqrt(handL1.x .^ 2 + handL1.y .^ 2 + handL1.z .^ 2);

% Combine axis measures (Velocity)
% handL1.distInt = sqrt(handL1.xInt .^ 2 + handL1.yInt .^ 2 + handL1.zInt .^ 2);
for i = 1:length(trial)
    eval([trial{i},'.distDetrInt = sqrt(',trial{i},'.xDetrInt .^ 2 + ',trial{i},'.yDetrInt .^ 2 + ',trial{i},'.zDetrInt .^ 2);']) % Detrended data
end

figure;
eval(['time = [1:length(',trial{1},'.dist)]'' ./ frequency;']); % Time in seconds
for i = 1:length(trial)
    % eval(['subplot(length(trial)/2,length(trial)/2/2,i); plot(time,',trial{i},'.dist); title(''',trial{i},''');']); % Acceleration
    % eval(['subplot(length(trial)/2,length(trial)/2/2,i); plot(time,',trial{i},'.distInt); title(''',trial{i},''');']); % axis(limits); % Velocity
    eval(['subplot(length(trial)/2,length(trial)/2/2,i); plot(time,',trial{i},'.distDetrInt); title(''',trial{i},''');']); % axis(limits); % Velocity (Detrended data)
end

% subplot(length(trial)/2,length(trial)/2/2,1); ylabel('acceleration');
% subplot(length(trial)/2,length(trial)/2/2,2); ylabel('acceleration');
subplot(length(trial)/2,length(trial)/2/2,1); ylabel('velocity');
subplot(length(trial)/2,length(trial)/2/2,2); ylabel('velocity');
subplot(length(trial)/2,length(trial)/2/2,length(trial)-1); xlabel('time (s)');
subplot(length(trial)/2,length(trial)/2/2,length(trial)); xlabel('time (s)');
