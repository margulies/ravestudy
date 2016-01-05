function accel_ips % Intersubject phase synchronization

clear;

filename = 'accel_data.mat';
datafile = load(filename);

% subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'};{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
% subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'}];
subject = [{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
measure = 'dist'; % Combined x, y, z
wavelet = 'db2';
samplingHz = 90; % Sampling rate in Hz



% modwt: Maximal overlap discrete wavelet transform
% W = modwt(X,WNAME): modwt of a signal X using the wavelet WNAME
% W: LEV+1-by-N matrix of wavelet coeffs & final-level scaling coeffs
% LEV: Level of the modwt
% m-th row: Wavelet (detail) coefficients for scale 2^m
% LEV+1-th row: Scaling coefficients for scale 2^LEV

% imodwt: Inverse maximal overlap discrete wavelet transform
% R = imodwt(W,Lo,Hi): Reconstructs signal using scaling filter Lo & wavelet filter Hi

% Filter time courses
D = cell(length(subject),1); % Combined acceleration
W = cell(length(subject),1); % Wavelet coefficients
R = cell(length(subject),1); % Reconstructed signal
for s = 1:length(subject)
    D{s} = datafile.(subject{s}).(measure);
    W{s} = modwt(D{s},wavelet);    
    R{s} = zeros(size(W{s},1)-1,size(W{s},2));
    for level = 1:size(W{s},1)-1
        R{s}(level,:) = imodwt(W{s},level-1,wavelet); % Reconstruct signal for each level
    end    
end



% Frequency-specific intersubject phase synchronization
pairs = length(subject) * (length(subject) - 1) / 2;
IPS = zeros(size(W{1},1)-1,length(datafile.(subject{1}).(measure))); % Intersubject phase synchronization for each frequency
for f = 1:size(R{1},1) % For each frequency band
    
    i = 1;
    AD = zeros(length(datafile.(subject{s}).(measure)),pairs); % Angular distance at each time point for each subject pair 
    for s1 = 1:length(subject) % For each subject pair
        t1 = hilbert(R{s1}(f,:)); % Hilbert transform to obtain corresponding analytic signal
        for s2 = 1:length(subject)
            if s2 > s1
                t2 = hilbert(R{s2}(f,:));
                AD(:,i) = angle(t1) - angle(t2);
                i = i + 1;            
            end
        end
    end

    if pairs == 1
        absAD = abs(AD); % Absolute angular distance (Dissimilarity measure)
        IPS(f,:) = 1 - absAD / pi; % Normalized version of (average) absolute angular distance(s)
    else
        absAD = sum(abs(AD),2) / pairs; % Average of all subject-pairwise absolute angular distances
        IPS(f,:) = 1 - absAD / pi;
    end

end



% Plot intersubject phase synchronization
figure;
time = (1:length(datafile.(subject{1}).(measure)))' ./ samplingHz; % Time in seconds
imagesc(time,[],IPS); % Scale data and display as image (X-axis, Y-axis, Values)
set(gca,'YTick',1:size(W{1},1)-1); % Make tick marks for each scale / level
freq = samplingHz ./ 2 .^ (1:size(W{1},1)-1); % Frequencies corresponding to scales / levels
set(gca,'YTickLabel',num2str(freq','%.4f')); % Change tick labels to corresponding frequencies
ticks = 0 : 30 : floor(length(datafile.(subject{1}).(measure)) / samplingHz); % Make tick marks every 30 seconds
set(gca,'XTick',ticks); 
set(gca,'clim',[.75 1]); % 0 = complete absence of phase similary, 1 = complete phase similarity across subjects  
colorbar; % Display color scale
ylabel('Frequency (Hz)');
xlabel('Time (s)');