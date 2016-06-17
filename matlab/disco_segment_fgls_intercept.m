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
Ytable = array2table(Y,'VariableNames',{'Sync'}); % Synchrony

% Cycle through segments for intercept
X2dummy = dummyvar(X2); % Segment
seglbl = {'Seg1','Seg2','Seg3','Seg4','Seg5'};
segidx = {[2 3 4 5],[1 3 4 5],[1 2 4 5],[1 2 3 5],[1 2 3 4]};
OLSModel1 = cell(length(segidx),1);
for j = 1:length(segidx)
    X2table = array2table(X2dummy(:,segidx{j}),...
        'VariableNames',seglbl(segidx{j})); % Dummy variable table (minus one segment)    
    DataTable1 = [X1table X2table Ytable];
    OLSModel1{j} = fitlm(DataTable1); % OLS test
end

% FGLS estimates
FGLSlags   = 5; % AR lags to consider
FGLSbetas  = 1 + 8 + 4; % Intercept + Song-1 + Segment-1
FGLScoeff  = cell(FGLSlags,length(segidx));
FGLSstderr = cell(FGLSlags,length(segidx));
FGLSestcov = cell(FGLSlags,length(segidx));

disp([datestr(now),': FGLS start']);
for i = 1:FGLSlags
    for j = 2:length(segidx) % First set already done
        
        X2table = array2table(X2dummy(:,segidx{j}),'VariableNames',seglbl(segidx{j}));
        DataTable1 = [X1table X2table Ytable];
        
        [FGLScoeff{i,j},FGLSstderr{i,j},FGLSestcov{i,j}] = fgls(DataTable1,'innovMdl','AR','arLags',i);
        disp([datestr(now),': Lag = ',num2str(i),', Seg = ',num2str(j)]);
        
    end
end
save(output,'FGLSestcov','FGLSstderr','FGLScoeff');
disp([datestr(now),': FGLS end']);


%%% Plot FGLS results

% Data
load /scr/kongo1/ellamil/ravestudy_stats/disco/disco_segment_fgls_olslag0_seg1to5.mat % OLSModel1
load /scr/kongo1/ellamil/ravestudy_stats/disco/disco_segment_fgls_lag1to20_seg1.mat % FGLScoeff1, etc.
FGLScoeff1 = FGLScoeff; FGLSestcov1 = FGLSestcov; FGLSstderr1 = FGLSstderr;
load /scr/kongo1/ellamil/ravestudy_stats/disco/disco_segment_fgls_lag1to5_seg2to5.mat % FGLScoeff, etc.

% Matrix
x = 0:5; % Lags
for i = 0:5 % Lags
    for j = 1:5 % Segments
        if i == 0 % Original OLS (Lag 0)
            y(i+1,j) = OLSModel1{j}.Coefficients.Estimate(1); % Intercepts (means)
            e(i+1,j) = OLSModel1{j}.Coefficients.SE(1); % Standard errors
        elseif j == 1 % Original FGLS (Segment 1)
            y(i+1,j) = FGLScoeff1(i,1);
            e(i+1,j) = FGLSstderr1(i,1);
        else
            y(i+1,j) = FGLScoeff{i,j}(1);
            e(i+1,j) = FGLSstderr{i,j}(1);
        end
    end  
end

% Figure
for j = 1:5 % Segments
    errorbar(x,y(:,j),e(:,j),'o-','LineWidth',2);
    if j == 1  hold on;  end
end

axis([0 5 -inf inf]); grid on;
set(gca,'xtick',0:5); xticks = get(gca,'xtick'); set(gca,'xticklabel',sprintf('%d\n',xticks));
yticks = get(gca,'ytick'); set(gca,'yticklabel',sprintf('%.5f\n',yticks));
xlabel('AR Lag'); ylabel('Means'); legend({'Intro/Outro','Verse','Prechorus/Bridge','Chorus','Interlude'});

saveas(gcf,'FGLSmeans','psc');