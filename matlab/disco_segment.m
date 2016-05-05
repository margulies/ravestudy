function [model,ftest,stats,contrasts,segment] = disco_segment(input,timefile,songfile,samplerate)
% [model,ftest,stats,contrasts,segment] = disco_segment(input,timefile,songfile,samplerate)
% Mean (and SD & N) of synchrony time course for each segment (e.g., chorus)
%   input = Input data file (IPS/CPM,msec)
%   timefile = File containing segment times in ms
%   songfile = File containing song times in ms
%   samplerate = Sampling rate in ms 
%   (e.g., ceil(mean of actual rate across Ss) = ceil(18.5594) = 19 ms)
%
% [model,ftest,stats,contrasts,segment] = disco_segment(...
%     '/SCR/ellamil/ravestudy_stats/disco/disco_ips_coif1_mean_linear_zalign.mat',...
%     '/SCR/ellamil/ravestudy_stats/disco/disco_millisecond_songparts.mat',...
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
load(timefile,'timeMSEC','timeNAME'); segmentMSEC = timeMSEC; segmentNAME = timeNAME;
load(songfile,'timeMSEC'); songMSEC = timeMSEC; % songNAME = timeNAME;

% Mean of synchrony timecourse across the middle 5 frequency bands
band1 = floor(size(SYNC,1) / 5) * 2;
band2 = band1 + 5 - 1;
SYNCmean = mean(SYNC(band1:band2,:))';


%%% Normalize synchrony values within each song

timeAVG = msec; % Mean timepoint for each set of downsampled values (from disco_downsample.mat)
timeALL = zeros(length(timeAVG),samplerate); % All individual timepoints (columns) for each mean timepoint (rows)
for i = 1:length(timeAVG)
    timeALL(i,:) = [timeAVG(i)-floor(samplerate/2):timeAVG(i) timeAVG(i)+1:timeAVG(i)+floor(samplerate/2)];
end

timeIDX = zeros(length(songMSEC)-1,1); % Indices of song start and end timepoints
for i = 1:length(songMSEC)-1 % Not need end timepoint
    timeIDX(i) = find(timeALL == songMSEC(i));
end
[timeROW,~] = ind2sub(size(timeALL),timeIDX); % Row numbers (indices) of corresponding mean timepoints

SYNCnorm = zeros(1,length(SYNCmean)); 
for i = 1:length(timeROW)
    if i < length(timeROW)
        SYNCnorm(timeROW(i):timeROW(i+1)-1) = zscore(SYNCmean(timeROW(i):timeROW(i+1)-1)); % For each song: mean = 0, variance = 1
    else % End timepoint
        SYNCnorm(timeROW(i):end) = zscore(SYNCmean(timeROW(i):end));
    end
end


%%% Regression test of song segments

SYNCcond = zeros(1,length(SYNCmean)); % Predictor variable: Segment type
for t = 1:length(segmentMSEC)-1 % For each song segment    
    
    first = ceil((segmentMSEC(t) - segmentMSEC(1)) / samplerate); % First timepoint    
    last = ceil((segmentMSEC(t+1) - segmentMSEC(1)) / samplerate); % Last timepoint    
    if first < 1
        first = 1;
    elseif last > length(SYNCcond)
        last = length(SYNCcond);
    end 
    
    if strcmp(segmentNAME{t},'intro') || strcmp(segmentNAME{t},'outro')
        category = 1;
    elseif strcmp(segmentNAME{t},'verse')
        category = 2;
    elseif strcmp(segmentNAME{t},'bridge') % Includes pre-chorus
        category = 3;
    elseif strcmp(segmentNAME{t},'chorus')
        category = 4;
    elseif strcmp(segmentNAME{t},'interlude') % Instrumental break
        category = 5;
    end
    
    SYNCcond(1,first:last) = repmat(category,1,last-first+1);
    
end

tbl = table(SYNCcond',SYNCnorm','VariableNames',{'Segment','Synchrony'});
tbl.Segment = nominal(tbl.Segment); % Categorical predictor variable
model = fitlm(tbl,'Synchrony ~ 1 + Segment'); % Outcome ~ 1 + Predictor
disp(model);
disp(' ');

ftest = anova(model,'summary');
disp(ftest);

beta = model.Coefficients.Estimate;
sigma = model.CoefficientCovariance;
dfe = model.DFE;

segment = { 'Intro/Outro' ; 'Verse' ; 'Pre-chorus/Bridge' ; 'Chorus' ; 'Interlude' };
contrasts = ... % Segment type pairs
[   1 -1  0  0  0 ;
    1  0 -1  0  0 ;
    1  0  0 -1  0 ;
    1  0  0  0 -1 ;
    0  1 -1  0  0 ;
    0  1  0 -1  0 ;
    0  1  0  0 -1 ;
    0  0  1 -1  0 ;
    0  0  1  0 -1 ;
    0  0  0  1 -1   ]; 

stats = zeros(length(contrasts),2);
for c = 1:length(contrasts)
    [stats(c,1),stats(c,2)] = linhyptest(beta,sigma,0,contrasts(c,:),dfe); % [p,F]
end

disp(' ');
disp([datestr(now),': Done!']);