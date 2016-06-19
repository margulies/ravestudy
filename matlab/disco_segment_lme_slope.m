output     = '/scr/kongo1/ellamil/ravestudy_stats/disco/disco_segment_lme.mat';
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
    
    % Slope for first half of each segment
    segxvalues = (first:floor((first+last)/2))'; % X = timepoints
    segyvalues = SYNCmean(first:floor((first+last)/2),1); % Y = synchrony
    seglinefit(t,:) = polyfit(segxvalues,segyvalues,1); % Least-squares fit (slope, intercept)
    segcateg(t,1) = category; % Segment label
    segsong(t,1) = SYNCsong(1,first); % Song label
        
end


%%% LME test of segment slopes
tbl = table(segsong,segcateg,seglinefit(:,1),'VariableNames',{'Song','Segment','Slope'});
% tbl.Segment = nominal(tbl.Segment); tbl.Song = nominal(tbl.Song); % Categorical variables
lme = fitlme(tbl,'Slope ~ Segment + (1|Song)');


%%% Repeated measures ANOVA of slopes
segslope = seglinefit(:,1);
for i = 1:max(SYNCsong);
    for j = 1:max(SYNCcond)
        datamatrix(i,j) = mean(segslope(segsong==i & segcateg==j));
    end
end
datatable = array2table(datamatrix,'VariableNames',{'Seg1','Seg2','Seg3','Seg4','Seg5'});
withinvar = [1 2 3 4 5]';
rm = fitrm(datatable,'Seg1-Seg5 ~ 1','WithinDesign',withinvar);
rmtbl = ranova(rm);


%%% Plot segment slopes

% Repeated measures data
figure;
bplot(datamatrix,'colors','black'); % User-written box and whiskers plot function
ylabel('Group synchrony slope');
xlabel('Song segment label');
seglabel = {'Intro/Outro','Verse','Prechorus/Bridge','Chorus','Interlude'};
set(gca,'xtick',1:length(seglabel),'xticklabel',seglabel,'fontsize',10,'fontname','arial'); % X-axis labels

% Appearance
yticks = get(gca,'ytick'); set(gca,'yticklabel',sprintf('%.5f\n',yticks),'fontsize',10,'fontname','arial'); % Y-axis labels

% Save figure
saveas(gcf,'RMAslopes','psc');

% Linear mixed effects data
figure;
nonaggregate = padcat(segslope(segcateg==1),...
                      segslope(segcateg==2),...
                      segslope(segcateg==3),...
                      segslope(segcateg==4),...
                      segslope(segcateg==5));
bplot(nonaggregate,'colors','black'); % User-written box and whiskers plot function
ylabel('Group synchrony slope');
xlabel('Song segment label');
seglabel = {'Intro/Outro','Verse','Prechorus/Bridge','Chorus','Interlude'};
set(gca,'xtick',1:length(seglabel),'xticklabel',seglabel,'fontsize',10,'fontname','arial'); % X-axis labels

% Appearance
yticks = get(gca,'ytick'); set(gca,'yticklabel',sprintf('%.5f\n',yticks),'fontsize',10,'fontname','arial'); % Y-axis labels

% Save figure
saveas(gcf,'LMEslopes','psc');