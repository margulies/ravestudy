output     = '/scr/kongo1/ellamil/ravestudy_stats/disco/disco_segment_fgls.mat';
input      = '/scr/kongo1/ellamil/ravestudy_stats/disco/disco_ips_coif1_mean_linear_zalign.mat';
timefile   = '/scr/kongo1/ellamil/ravestudy_stats/disco/disco_millisecond_songparts.mat';
songfile   = '/scr/kongo1/ellamil/ravestudy_stats/disco/disco_millisecond_wholesongs.mat';
samplerate = ceil(18.5594);

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
band1 = 6;  % floor(size(SYNC,1) / 5) * 2;
band2 = 10; % band1 + 5 - 1;
SYNCmean = mean(SYNC(band1:band2,:))';


%%% Condition labels for whole songs

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

SYNCsong = zeros(1,length(SYNCmean));
for t = 1:length(timeROW) % For each whole song
    if t < length(timeROW)
        first = timeROW(t);
        last = timeROW(t+1)-1;
        SYNCsong(1,first:last) = repmat(t,1,last-first+1);
    else
        first = timeROW(t);
        last = length(SYNCsong);
        SYNCsong(1,first:last) = repmat(t,1,last-first+1);
    end
end


%%% Condition labels for song segments

SYNCcond = zeros(1,length(SYNCmean));
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


%%% Regression test of time series

% Data table
X1 = SYNCsong';
X2 = SYNCcond';
Y  = SYNCmean;
DataTable = table(X1,X2,Y,'VariableNames',{'Song','Segment','Synchrony'});
DataTable.Song = nominal(DataTable.Song); % Categorical variable
DataTable.Segment = nominal(DataTable.Segment); % Categorical variable

% OLS estimates
OLSModel = fitlm(DataTable);

% Dummy variables
X1dummy = dummyvar(X1); % Song
X1table = array2table(X1dummy(:,2:end),...
    'VariableNames',{'Song2','Song3','Song4','Song5','Song6','Song7','Song8','Song9'}); % Dummy variable table (minus first song)
X2dummy = dummyvar(X2); % Segment
X2table = array2table(X2dummy(:,2:end),...
    'VariableNames',{'Seg2','Seg3','Seg4','Seg5'}); % Dummy variable table (minus intro/outro)
Ytable = array2table(Y,'VariableNames',{'Sync'}); % Synchrony
DataTable1 = [X1table X2table Ytable];
% OLSModel1 = fitlm(DataTable1); % OLS test

% FGLS estimates
FGLSlags   = 20; % AR lags to consider
FGLSbetas  = 1 + 8 + 4; % Intercept + Song-1 + Segment-1
FGLScoeff  = zeros(FGLSlags,FGLSbetas);
FGLSstderr = zeros(FGLSlags,FGLSbetas);
FGLSestcov = cell(FGLSlags,1);

disp([datestr(now),': FGLS start']);
for i = 1:FGLSlags
    [FGLScoeff(i,:),FGLSstderr(i,:),FGLSestcov{i,1}] = fgls(DataTable1,'innovMdl','AR','arLags',i);
    disp([datestr(now),': Lag = ',num2str(i)]);
end
save(output,'FGLSestcov','FGLSstderr','FGLScoeff');
disp([datestr(now),': FGLS end']);


%%% Plot FGLS results
load '/scr/kongo1/ellamil/ravestudy_stats/disco/disco_segment_fgls.mat';

% t-statistics and p-values
FGLStstat = FGLScoeff ./ FGLSstderr;
FGLSpval = 1 - tcdf(FGLStstat,96974);

% Data for figure
figdata = [OLSModel.Coefficients.Estimate(10:13)';FGLScoeff(:,10:13)]; % figdata = [OLSModel.Coefficients.Estimate(1)';FGLScoeff(:,1)];
figlegend = {'Verse','Prechorus/Bridge','Chorus','Interlude'}; % figlegend = {'Intro/Outro'};
figylabel = 'Coefficient';
figname = 'FGLScoeff'; % figname = 'FGLScoeff_int';

% Plot figure
figure; plot(figdata,'o-','LineWidth',2); 
axis([1 21 -inf inf]); grid on;
set(gca,'xtick',1:21); xticks = get(gca,'xtick'); set(gca,'xticklabel',sprintf('%d\n',0:20));
yticks = get(gca,'ytick'); set(gca,'yticklabel',sprintf('%.5f\n',yticks));
xlabel('AR Lag'); ylabel(figylabel); legend(figlegend);
saveas(gcf,figname,'psc');

% Plot means

x = 1:20; % AR lags
m = repmat(FGLScoeff(:,1),1,4) + FGLScoeff(:,10:13); % means = intercept + parameters
y = [FGLScoeff(:,1) m]; % means
e = [FGLSstderr(:,1) FGLSstderr(:,10:13)]; % standard errors (intercept and parameters)

figure;
for i = 1:5
    errorbar(x,y(:,i),e(:,i),'o-','LineWidth',1);
    if i == 1  hold on;  end
end

axis([1 20 -inf inf]); grid on;
set(gca,'xtick',1:20); xticks = get(gca,'xtick'); set(gca,'xticklabel',sprintf('%d\n',1:20));
yticks = get(gca,'ytick'); set(gca,'yticklabel',sprintf('%.5f\n',yticks));
xlabel('AR Lag'); ylabel('Means'); legend({'Intro/Outro','Verse','Prechorus/Bridge','Chorus','Interlude'});