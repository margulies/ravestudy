function accel_isc % Sliding window intersubject correlation

clear;

filename = 'accel_data.mat';
datafile = load(filename);

subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'};{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
% subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'}];
% subject = [{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
measure = 'dist'; % Combined x, y, z
wavelet = 'db2';
samplingHz = 90; % Sampling rate in Hz
window = 90; % Window size in time points (1 timepoint = 1/samplingHz seconds)



% modwt: Maximal overlap discrete wavelet transform
% W = modwt(X,WNAME): modwt of a signal X using the wavelet WNAME
% W: LEV+1-by-N matrix of wavelet coeffs & final-level scaling coeffs
% LEV: Level of the modwt
% m-th row: Wavelet (detail) coefficients for scale 2^m
% LEV+1-th row: Scaling coefficients for scale 2^LEV

% imodwt: Inverse maximal overlap discrete wavelet transform
% R = imodwt(W,Lo,Hi): Reconstructs signal using scaling filter Lo & wavelet filter Hi

% Filter time courses
D = cell(length(subject),1); % Combined accelearation
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



% Sliding window average pairwise correlations
Dcorrmean = zeros(size(R{1},1),floor(length(datafile.(subject{1}).(measure))/window)); % Sliding window intersubject correlation for each frequency band
for f = 1:size(R{1},1) % For each frequency band
    i = 0;
    for t = 1:window:length(datafile.(subject{1}).(measure))-window+1 % For each time window
    
        Drecon = zeros(window,length(subject));
        for s = 1:length(subject)
            Drecon(:,s) = R{s}(f,t:t+window-1)'; % Reconstructed signal for each subject at frequency band f
        end

        Dcorr = corrcoef(Drecon); % Correlations for each pair of subjects
        
        Dfish = fisherz(Dcorr); % Column vector of Fisher's Z-transformed correlations
        Dfish = reshape(Dfish,[length(subject),length(subject)]); % Turn column vector back into correlation matrix
        Dfish = tril(Dfish); % Extract lower triangle of symmetrical correlation matrix (Turn upper triangle to 0's)
        Dfish(Dfish==0 | Dfish==Inf) = NaN; % Convert 0's and Inf's to NaN's
        
        i = i + 1;
        Dcorrmean(f,i) = nanmean(Dfish(:)); % Average of correlations for all pairs of subjects (Intersubject correlation)
        Dcorrmean(f,i) = ifisherz(Dcorrmean(f,i)); % Inverse Fisher's Z-transform back to r values
        
    end % End each time window
end % End each frequency band



% Plot intersubject correlations
imagesc(Dcorrmean); % Scale data and display as image (X-axis, Y-axis, Values)
set(gca,'YTick',1:size(W{1},1)-1); % Make tick marks for each scale / level
freq = samplingHz ./ 2 .^ (1:size(W{1},1)-1); % Frequencies corresponding to scales / levels
set(gca,'YTickLabel',num2str(freq','%.4f')); % Change tick labels to corresponding frequencies
time = 0 : 30 : floor(length(datafile.(subject{1}).(measure)) / samplingHz); % Time in seconds
set(gca,'XTick',time); % Make tick marks every 30 seconds
ylabel('Frequency (Hz)');
xlabel('Time (s)'); 
set(gca,'clim',[-1 1]); % Set color scale limits
colorbar; % Display color scale