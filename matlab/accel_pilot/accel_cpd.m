function accel_cpd % Change point detection

clear;

filename = 'accel_data.mat';
datafile = load(filename);

% subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'};{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
% subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'}];
subject = [{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
measure = 'dist'; % Combined x, y, z
samplingHz = 90; % Sampling rate in Hz
time = (1:length(datafile.(subject{1}).(measure)))' ./ samplingHz; % Time in seconds

DATA = zeros(length(datafile.(subject{1}).(measure)),length(subject)); % Combined acceleration
for s = 1:length(subject)
    DATA(:,s) = datafile.(subject{s}).(measure);
end
zDATA = zscore(DATA); % Z-scores for each time course
mDATA = mean(zDATA,2); % Means across time courses
% figure; plot(time,mDATA); title('mean time course'); ylabel('acceleration'); xlabel('time (s)');

% Change point detection
y = mDATA'; n = 50; k = 10; a = .0;
score1 = change_detection(y,n,k,a); % Change point detection going from left to right
score2 = change_detection(y(:,end:-1:1),n,k,a); % Change point detection going from right to left
score2 = score2(end:-1:1); % Reverse back scores so going from left to right

% Plot change point scores
figure; 
subplot(2,1,1); plot(time,y,'blue'); title('original signal'); ylabel('acceleration'); xlabel('time (s)');
subplot(2,1,2); plot(time,[ zeros(1,2*n-2+k) , score1+score2 ],'red'); title('change point score'); ylabel('score'); xlabel('time (s)');
% 2*n+k-2 is the size of the "buffer zone" (before the first change point score was calculated)
