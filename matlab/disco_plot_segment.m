% Box and whisker plots of synchrony for different song segments

figfile  = '/SCR/ellamil/ravestudy_stats/disco/disco_plot_segment'; % .ps + .mat

% Regression test (for within-song normalized / standardized synchrony values) 
load('/SCR/ellamil/ravestudy_stats/disco/disco_parser.mat','samplerateMSall');
[~,~,~,~,segment,SYNCnorm,SYNCcond] = disco_segment(...
    '/SCR/ellamil/ravestudy_stats/disco/disco_ips_coif1_mean_linear_zalign.mat',...
    '/SCR/ellamil/ravestudy_stats/disco/disco_millisecond_songparts.mat',...
    '/SCR/ellamil/ravestudy_stats/disco/disco_millisecond_wholesongs.mat',...
    ceil(samplerateMSall));

% Normalized synchrony values and segment string & number labels
seglabel = segment;
SYNCcond = SYNCcond';
SYNCnorm = SYNCnorm';
normdata = padcat(SYNCnorm(SYNCcond==1),...
                  SYNCnorm(SYNCcond==2),...
                  SYNCnorm(SYNCcond==3),...
                  SYNCnorm(SYNCcond==4),...
                  SYNCnorm(SYNCcond==5));

% Figure size
fig = figure;
screen = get(0,'screensize'); 
set(fig,'position',[0 0 screen(3)*.75 screen(4)*.75]);

% Plot segment data
bplot(normdata,'colors','black'); % User-written box and whiskers plot function
ylabel('Intersubject phase synchrony');
xlabel('Song segment label');
set(gca,'xtick',1:length(seglabel),'xticklabel',seglabel,'fontsize',10,'fontname','arial'); % X-axis labels

% Appearance
% set(gca,'looseinset',get(gca,'tightinset')); % Remove white space
yticks = get(gca,'ytick'); set(gca,'yticklabel',sprintf('%.2f\n',yticks),'fontsize',10,'fontname','arial'); % Y-axis labels
hold on;

% Remove upper and right tick marks
set(gca,'box','off');
coordX = get(gca,'xlim');
coordY = get(gca,'ylim');
plot([coordX(2) coordX(2)],[coordY(1) coordY(2)],'color','black','linewidth',.01)
plot([coordX(1) coordX(2)],[coordY(2) coordY(2)],'color','black','linewidth',.01)

% Save variables and figure
save([figfile,'.mat'],'normdata','seglabel');
set(gcf,'paperorientation','landscape'); saveas(gcf,figfile,'ps');