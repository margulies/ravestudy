function disco_downsample(input,type,newrate)
% disco_downsample(input,type,newrate)
% Downsamples timeseries data
%   input = Input data file (timeseries,filename)
%   [output = Output data file (timeseries,filename)]
%   type = Downsampling type
%       - 'mean': Replace each set of N samples by their mean
%                 (Preserves temporal shape of waveform)
%       - 'decimate': Apply a low-pass filter before resampling
%                     (Preserves spectral information of waveform)
%   newrate = New sampling rate in ms
%   (e.g., ceil(mean of actual rate across Ss) = ceil(15.4120) = 16 ms)
% 
% disco_downsample(...
%     '/SCR/ellamil/ravestudy_stats/pilot/disco_interpolate_linear_vector.mat',...
%     'mean',...
%     ceil(15.4120));

disp([datestr(now),': Running ',mfilename,'.m, type = ',type]);

load(input,'timeseries','filename'); % Variables from disco_interpolate.mat

old = timeseries;
new = cell(size(old));
for subject = 1:length(old)
    
    % Detrend timeseries first    
    det = detrend(old{subject,1}(:,2)); % Linear detrend
        
    % Pad timeseries with mean of last window so length divisible by 'newrate'
    % 'newrate' is rounded up from average sampling rate so not using a slightly faster sampling rate
    padTS = zeros(newrate*ceil(length(det)/newrate),1);
    padTS(1:length(det)) = det;
    padRM = rem(length(det),newrate); % Last window
    padVL = length(padTS) - length(det); % Pad amount    
    padTS(end-padVL+1:end) = repmat(mean(det(end-padRM+1:end)),padVL,1);
    
    % Pad time information with additional milliseconds so length divisible by 'newrate'
    msec = old{subject,1}(:,1);
    padMS = zeros(newrate*ceil(length(msec)/newrate),1);    
    padMS(1:length(msec)) = msec;
    padVL = length(padMS) - length(msec); % Pad amount
    padMS(end-padVL+1:end) = padMS(end-padVL)+1 : padMS(end-padVL)+padVL;
    
    % Mean timepoint for each new sample
    new{subject,1}(:,1) = (mean(reshape(padMS,newrate,length(padMS)/newrate)))';
    
    % Downsample timeseries
    if strcmp(type,'mean') % Preserves temporal shape of waveform
        new{subject,1}(:,2) = (mean(reshape(padTS,newrate,length(padTS)/newrate)))'; % Replace each set of of N (=newrate) samples by their mean 
    elseif strcmp(type,'decimate') % Preserves spectral information of waveform
        new{subject,1}(:,2) = decimate(padTS,newrate); % Resample at a lower rate after low-pass filtering (to prevent aliasing) 
    end
    
    disp([datestr(now),': ',filename{subject}]);
    
end
timeseries = new;

[pathstr,namestr,~] = fileparts(input);
underscore = strfind(namestr,'_');
previous = namestr(underscore(2)+1:end);
output = [pathstr,'/',mfilename,'_',type,'_',previous,'.mat'];
disp([datestr(now),': Saving ',output]);
save(output,'timeseries','filename','-v7.3'); % "Warning: Variable cannot be saved to a MAT-file whose version is older than 7.3. To save this variable, use the -v7.3 switch."
disp([datestr(now),': Done!']);