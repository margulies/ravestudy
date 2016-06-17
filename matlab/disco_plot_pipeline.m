% Box and whisker plots of validity and reliability for different pipeline parameters

figfile = '/SCR/ellamil/ravestudy_stats/pilot/disco_plot_pipeline'; % .ps + .mat
valfile = '/SCR/ellamil/ravestudy_stats/pilot/disco_validity_anova.mat';
relfile = '/SCR/ellamil/ravestudy_stats/pilot/disco_reliability_anova.mat';

% Validity data
load(valfile,'corrval'); validity = corrval;
valdata = padcat(validity{1}{1},validity{1}{2},...
                 validity{2}{1},validity{2}{2},validity{2}{3},...
                 validity{3}{1},validity{3}{2},validity{3}{3},...
                 validity{4}{1},validity{4}{2},...
                 validity{5}{1},validity{5}{2},validity{5}{3},...
                 validity{6}{1},validity{6}{2},validity{6}{3},validity{6}{4});

% Reliability data
load(relfile,'corrval'); reliability = corrval;
reldata = padcat(reliability{1}{1},reliability{1}{2},...
                 reliability{2}{1},reliability{2}{2},reliability{2}{3},...
                 reliability{3}{1},reliability{3}{2},reliability{3}{3},...
                 reliability{4}{1},reliability{4}{2},...
                 reliability{5}{1},reliability{5}{2},reliability{5}{3},...
                 reliability{6}{1},reliability{6}{2},reliability{6}{3},reliability{6}{4});

% Pipeline parameter labels
paramlabel{1} = 'Synchrony measure: CPM';
paramlabel{2} = 'Synchrony measure: IPS';
paramlabel{3} = 'Wavelet family: Coiflet';
paramlabel{4} = 'Wavelet family: Daubechies';
paramlabel{5} = 'Wavelet family: Symlet';
paramlabel{6} = 'Filter length: Short';
paramlabel{7} = 'Filter length: Medium';
paramlabel{8} = 'Filter length: Long';
paramlabel{9} = 'Downsampling: Decimate';
paramlabel{10} = 'Downsampling: Average';
paramlabel{11} = 'Interpolation: Cubic';
paramlabel{12} = 'Interpolation: Linear';
paramlabel{13} = 'Interpolation: Nearest';
paramlabel{14} = 'Combination: Standard';
paramlabel{15} = 'Combination: X-align';
paramlabel{16} = 'Combination: Y-align';
paramlabel{17} = 'Combination: Z-align';

% Figure size
fig = figure;
screen = get(0,'screensize'); 
set(fig,'position',[0 0 screen(3) screen(4)]);

% Plot validity data
subplot(2,1,1);
bplot(valdata,'colors','black'); % User-written box and whiskers plot function
ylabel('Discriminability (Pearson''s r)');
xlabel('Preprocessing and analysis pipeline parameter');
set(gca,'xtick',1:length(paramlabel),'xticklabel',paramlabel,'fontsize',10,'fontname','arial'); % X-axis labels

% Appearance
% set(gca,'looseinset',get(gca,'tightinset')); % Remove white space
xticklabel_rotate([],30,[],'fontsize',10,'fontname','arial'); % Rotate x-axis labels
% yticks = get(gca,'ytick'); set(gca,'yticklabel',sprintf('%.2f\n',yticks),'fontsize',10,'fontname','arial'); % Y-axis labels
hold on;

% Remove upper and right tick marks
set(gca,'box','off');
coordX = get(gca,'xlim');
coordY = get(gca,'ylim');
plot([coordX(2) coordX(2)],[coordY(1) coordY(2)],'color','black','linewidth',.01)
plot([coordX(1) coordX(2)],[coordY(2) coordY(2)],'color','black','linewidth',.01)

% Plot reliability data
subplot(2,1,2);
bplot(reldata,'colors','black'); % User-written box and whiskers plot function
ylabel('Reliability (Intraclass correlation)');
xlabel('Preprocessing and analysis pipeline parameter'); 
set(gca,'xtick',1:length(paramlabel),'xticklabel',paramlabel,'fontsize',10,'fontname','arial'); % X-axis labels

% Appearance
% set(gca,'looseinset',get(gca,'tightinset')); % Remove white space
xticklabel_rotate([],30,[],'fontsize',10,'fontname','arial'); % Rotate x-axis labels
% yticks = get(gca,'ytick'); set(gca,'yticklabel',sprintf('%.2f\n',yticks),'fontsize',10,'fontname','arial'); % Y-axis labels
hold on;

% Remove upper and right tick marks
set(gca,'box','off');
coordX = get(gca,'xlim');
coordY = get(gca,'ylim');
plot([coordX(2) coordX(2)],[coordY(1) coordY(2)],'color','black','linewidth',.01)
plot([coordX(1) coordX(2)],[coordY(2) coordY(2)],'color','black','linewidth',.01)

% Save variables and figure
save([figfile,'.mat'],'valdata','reldata','paramlabel');
set(gcf,'paperorientation','landscape'); saveas(gcf,figfile,'ps');