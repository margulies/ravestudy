% Scatter plot of synchrony values with song popularity

figfile  = '/SCR/ellamil/ravestudy_stats/disco/disco_plot_popular'; % .ps + .mat
syncfile = '/SCR/ellamil/ravestudy_stats/disco/disco_ips_coif1_mean_linear_zalign.mat';
timefile = '/SCR/ellamil/ravestudy_stats/disco/disco_millisecond_wholesongs.mat';
ratefile = '/SCR/ellamil/ravestudy_stats/disco/disco_parser.mat';

% Song scrobbles 
scrobble(1) = 1427228;
scrobble(2) =  773514;
scrobble(3) =  365335;
scrobble(4) =  760696;
scrobble(5) =  628852;
scrobble(6) = 3174790;
scrobble(7) = 1108520;
scrobble(8) =  441468;
scrobble(9) =  850543;

% Song titles
songname{1} = 'Sir Duke';
songname{2} = 'You Can''t Hurry Love';
songname{3} = 'Car Wash';
songname{4} = 'Celebration';
songname{5} = 'Le Freak';
songname{6} = 'Black Or White';
songname{7} = 'Wake Me Up Before You Go-Go';
songname{8} = 'YMCA';
songname{9} = 'I''m So Excited';

% Synchrony data
load(ratefile,'samplerateMSall');
samplerate = ceil(samplerateMSall);
[synchrony,~] = disco_song(syncfile,timefile,samplerate);

% Figure size
fig = figure;
screen = get(0,'screensize'); 
set(fig,'position',[0 0 screen(3)*0.50 screen(4)*0.75]);

% Scatter plot
X = scrobble;
Y = synchrony(:,1);
scatter(X,Y,150,'black','filled','s'); % size, color, fill, marker
title('rho = .800, p = .014');
xlabel('Song plays (in millions)');
ylabel('Intersubject phase synchrony');

% Scatter text
dX = 50000; % Displacement
dY = 0; % Displacement
text(X+dX,Y+dY,songname,'fontsize',10,'fontname','arial');

% Appearance
xticks = get(gca,'xtick');
yticks = get(gca,'ytick');
set(gca,'xticklabel',sprintf('%.2f\n',xticks/1000000),'fontsize',10,'fontname','arial');
set(gca,'yticklabel',sprintf('%.2f\n',yticks),'fontsize',10,'fontname','arial');
    
% Remove upper and right tick marks
a = gca; set(a,'box','off','color','none'); 
b = axes('position',get(a,'position'),'box','on','xtick',[],'ytick',[]); 
axes(a); linkaxes([a b]);

% Save variables and figure
save([figfile,'.mat'],'scrobble','synchrony','songname');
set(gcf,'paperorientation','landscape'); saveas(gcf,figfile,'ps');