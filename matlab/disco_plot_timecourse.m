% Synchrony timecourse plot with songs and segments demarcated

figfile  = '/SCR/ellamil/ravestudy_stats/disco/disco_plot_timecourse'; % .ps + .mat
syncfile = '/SCR/ellamil/ravestudy_stats/disco/disco_ips_coif1_mean_linear_zalign.mat';
songfile = '/SCR/ellamil/ravestudy_stats/disco/disco_millisecond_wholesongs.mat';
timefile = '/SCR/ellamil/ravestudy_stats/disco/disco_millisecond_songparts.mat';
ratefile = '/SCR/ellamil/ravestudy_stats/disco/disco_parser.mat';

% Synchrony timecourse
[~,namestr,~] = fileparts(syncfile);
measure = upper(namestr(7:9)); 
eval(['load(syncfile,''',measure,''',''msec'');']); 
eval(['SYNC = ',measure,';']);

% Mean synchrony timecourse over middle five frequency bands
band1 = 6;  % floor(size(SYNC,1) / 5) * 2;
band2 = 10; % band1 + 5 - 1;
SYNCmean = mean(SYNC(band1:band2,:))';

% Millisecond time vector converted to minutes
load(ratefile,'samplerateMSall');
samplerate = ceil(samplerateMSall);
SYNCtime = (1:length(SYNCmean))' ./ (1000/samplerate) ./ 60;

% Song and segment time information
load(songfile,'timeMSEC','timeNAME'); songMSEC = timeMSEC; songNAME = timeNAME;
load(timefile,'timeMSEC','timeNAME'); segmentMSEC = timeMSEC; segmentNAME = timeNAME;

% Figure size
fig = figure;
screen = get(0,'screensize'); 
set(fig,'position',[0 0 screen(3) screen(4)/2]);

% Plot synchrony timecourse
fig = plot(SYNCtime,SYNCmean);
xlabel('Time in minutes');
ylabel('Intersubject phase synchrony');

% Appearance
% set(gca,'looseinset',get(gca,'tightinset')); % Remove white space
set(fig,'color',[.25 .25 .25]); % Line color
axis([SYNCtime(1) SYNCtime(end) 0.15 .55]); % Axis limits
xticks = get(gca,'xtick'); set(gca,'xticklabel',sprintf('%02d:00\n',xticks),'fontsize',10,'fontname','arial'); % X-axis labels
yticks = get(gca,'ytick'); set(gca,'yticklabel',sprintf('%.2f\n',yticks),'fontsize',10,'fontname','arial'); % Y-axis labels
hold on;

% Plot bars for segments (Chorus)
coordY = get(gca,'ylim');
for i = 1:length(segmentMSEC)-1
    if strcmp(segmentNAME{i},'chorus') 
        coordX(1) = (segmentMSEC(i) - segmentMSEC(1)) / 1000 / 60; % Convert to minutes
        coordX(2) = (segmentMSEC(i+1) - segmentMSEC(1)) / 1000 / 60;
        v = [coordX(1) coordY(1); coordX(2) coordY(1); coordX(2) coordY(2); coordX(1) coordY(2)]; f = [1 2 3 4];
        patch('faces',f,'vertices',v,'linestyle','none','facecolor','black','facealpha',.05); % Bars
    end
end

% Plot lines for songs
% coordY = get(gca,'ylim');
for i = 1:length(songMSEC)-1
    coordX(1) = (songMSEC(i) - songMSEC(1)) / 1000 / 60; % Convert to minutes
    coordX(2) = (songMSEC(i+1) - songMSEC(1)) / 1000 / 60;
    if i+1 < length(songMSEC)    
        plot([coordX(2) coordX(2)],coordY,':k'); % Lines
    end
    titleX = mean([coordX(1) coordX(2)]); titleY = coordY(1)+.37;
    titleT = strsplit(songNAME{i},{' (',')'});
    text(titleX,titleY,titleT,'fontsize',10,'fontname','arial','horizontalalignment','center'); % Titles
end

% Remove upper and right tick marks
set(gca,'box','off');
coordX = get(gca,'xlim');
plot([coordX(2) coordX(2)],[coordY(1) coordY(2)],'color','black','linewidth',.01)
plot([coordX(1) coordX(2)],[coordY(2) coordY(2)],'color','black','linewidth',.01)

% Save variables and figure
save([figfile,'.mat'],'SYNCtime','SYNCmean','segmentMSEC','segmentNAME','songMSEC','songNAME');
set(gcf,'paperorientation','landscape'); saveas(gcf,figfile,'ps');