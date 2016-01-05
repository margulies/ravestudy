function accel_veloc

clear;

filename = 'accel_data.mat';
subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'};{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
datafile = load(filename);

frequency = 90; % Sampling frequency in Hz
time = [1:length(datafile.(subject{1}).x)]' ./ frequency; % Time in seconds
% limits = [0 250 -4000 4000]; % Axis limits
figure;

data = cell(length(subject),1);
for s = 1:length(subject)
    
    data{s} = datafile.(subject{s});
    
    % Detrend axis measures (Acceleration)
    data{s}.xDetr = detrend(data{s}.x);
    data{s}.yDetr = detrend(data{s}.y);
    data{s}.zDetr = detrend(data{s}.z);
    
    % Integrate axis measures (Velocity)
    % data{s}.xInt = cumtrapz(data{s}.x); % Original data
    % data{s}.yInt = cumtrapz(data{s}.y);
    % data{s}.zInt = cumtrapz(data{s}.z);
    data{s}.xDetrInt = cumtrapz(data{s}.xDetr); % Detrended data
    data{s}.yDetrInt = cumtrapz(data{s}.yDetr);
    data{s}.zDetrInt = cumtrapz(data{s}.zDetr);
    
    % Combine axis measures (Acceleration)
    % data{s}.dist = sqrt(data{s}.x .^ 2 + data{s}.y .^ 2 + data{s}.z .^ 2);

    % Combine axis measures (Velocity)
    % data{s}.distInt = sqrt(data{s}.xInt .^ 2 + data{s}.yInt .^ 2 + data{s}.zInt .^ 2); % Original data
    data{s}.distDetrInt = sqrt(data{s}.xDetrInt .^ 2 + data{s}.yDetrInt .^ 2 + data{s}.zDetrInt .^ 2); % Detrended data

    % subplot(length(subject)/2,length(subject)/2/2,s); plot(time,data{s}.dist); title(subject{s}); % Acceleration
    % subplot(length(subject)/2,length(subject)/2/2,s); plot(time,data{s}.distInt); title(subject{s}); % axis(limits); % Velocity (Original data)
    subplot(length(subject)/2,length(subject)/2/2,s); plot(time,data{s}.distDetrInt); title(subject{s}); % axis(limits); % Velocity (Detrended data)
    
end

% subplot(length(subject)/2,length(subject)/2/2,1); ylabel('acceleration');
% subplot(length(subject)/2,length(subject)/2/2,2); ylabel('acceleration');
subplot(length(subject)/2,length(subject)/2/2,1); ylabel('velocity');
subplot(length(subject)/2,length(subject)/2/2,2); ylabel('velocity');
subplot(length(subject)/2,length(subject)/2/2,length(subject)-1); xlabel('time (s)');
subplot(length(subject)/2,length(subject)/2/2,length(subject)); xlabel('time (s)');