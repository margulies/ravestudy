function [SYNCpart,SYNCname] = disco_song(input,timefile,samplerate)
% [SYNCpart,SYNCname] = disco_song(input,timefile,samplerate)
% Mean (and SD & N) of synchrony time course for each song
%   input = Input data file (IPS/CPM,msec)
%   timefile = File containing song times in ms
%   samplerate = Sampling rate in ms 
%   (e.g., ceil(mean of actual rate across Ss) = ceil(18.5594) = 19 ms)
%
%   SYNCpart = Mean (and SD & N) of synchrony time course for each song
%   SYNCname = Corresponding song labels
%
% [SYNCpart,SYNCname] = disco_song(...
%     '/SCR/ellamil/ravestudy_stats/disco/disco_ips_coif1_mean_linear_zalign.mat',...
%     '/SCR/ellamil/ravestudy_stats/disco/disco_millisecond_wholesongs.mat',...
%     ceil(18.5594));

disp([datestr(now),': Running ',mfilename,'.m']);
disp([datestr(now),': Using ',timefile]);

% Synchrony measure variable (IPS/CPM)
[~,namestr,~] = fileparts(input);
measure = upper(namestr(7:9)); 

% Variables from disco_ips/cpm.mat
eval(['load(input,''',measure,''',''msec'');']); 
eval(['SYNC = ',measure,';']);

% Variables from disco_millisecond.mat
load(timefile,'timeMSEC','timeNAME'); 

timeAVG = msec; % Mean timepoint for each set of downsampled values (from disco_downsample.mat)
timeALL = zeros(length(timeAVG),samplerate); % All individual timepoints (columns) for each mean timepoint (rows)
for i = 1:length(timeAVG)
    timeALL(i,:) = [timeAVG(i)-floor(samplerate/2):timeAVG(i) timeAVG(i)+1:timeAVG(i)+floor(samplerate/2)];
end

timeIDX = zeros(length(timeMSEC)-1,1); % Indices of song or segment start and end timepoints
for i = 1:length(timeMSEC)-1 % Not need end timepoint
    timeIDX(i) = find(timeALL == timeMSEC(i));
end
[timeROW,~] = ind2sub(size(timeALL),timeIDX); % Row numbers (indices) of corresponding mean timepoints

% Mean of synchrony timecourse across the middle 5 frequency bands
band1 = 6;  % floor(size(SYNC,1) / 5) * 2;
band2 = 10; % band1 + 5 - 1;
SYNCmean = mean(SYNC(band1:band2,:))';

% Mean, SD, and N of synchrony timecourse for each song or segment
SYNCname = timeNAME(1:end-1);
SYNCpart = zeros(length(timeROW),1);
for i = 1:length(timeROW)
    if i < length(timeROW)
        SYNCpart(i,1) = mean(SYNCmean(timeROW(i):timeROW(i+1)-1));
        SYNCpart(i,2) = std(SYNCmean(timeROW(i):timeROW(i+1)-1));
        SYNCpart(i,3) = length(SYNCmean(timeROW(i):timeROW(i+1)-1));
    else % End timepoint
        SYNCpart(i,1) = mean(SYNCmean(timeROW(i):end));
        SYNCpart(i,2) = std(SYNCmean(timeROW(i):end));
        SYNCpart(i,3) = length(SYNCmean(timeROW(i):end));
    end
end

disp([datestr(now),': Done!']);