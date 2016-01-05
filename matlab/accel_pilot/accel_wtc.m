function accel_wtc % Wavelet coherence

clear;

filename = 'accel_data.mat';
subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'};{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
datafile = load(filename);

frequency = 90; % Sampling frequency in Hz
time = [1:length(datafile.(subject{1}).dist)]' ./ frequency; % Time in seconds

% ALL = zeros(length(datafile.(subject{1}).dist),length(subject));
% for s = 1:length(subject) % All data    
%     ALL(:,s) = datafile.(subject{s}).dist; % Combined x, y, z
% end

i = 0;
HAND = zeros(length(datafile.(subject{1}).dist),4);
for s = 1:4 % Hand data    
    i = i + 1;
    HAND(:,i) = datafile.(subject{s}).dist;
end

i = 0;
HIP = zeros(length(datafile.(subject{1}).dist),4);
for s = 5:8 % Hip data  
    i = i + 1;
    HIP(:,i) = datafile.(subject{s}).dist;
end

% Z-scores for each time course
% zALL = zscore(ALL); 
zHAND = zscore(HAND);
zHIP = zscore(HIP);

% Means across time courses
% mALL = mean(zALL,2);
mHAND = mean(zHAND,2);
mHIP = mean(zHIP,2);

% Wavelet coherence between 2 time courses
% Monte Carlo count = 0 turns off Monte Carlo significance test
figure; wtc([time mHAND],[time mHIP],'mcc',0); % accel_wtc_hand-hip.png