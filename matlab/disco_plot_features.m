% Hex scatter plots of synchrony timecourse with different music features

figfile   = '/SCR/ellamil/ravestudy_stats/disco/disco_plot_features_raw'; % .ps + .mat
featfile  = '/SCR/ellamil/ravestudy_stats/disco/disco_features_raw.mat';
featvar   = {'metroid','mstrength','irregular','rough','highfreqflux','tension'};

% Feature labels
featlabel{1} = 'Metrical centroid';
featlabel{2} = 'Metrical strength';
featlabel{3} = 'Spectral irregularity';
featlabel{4} = 'Sensory dissonance';
featlabel{5} = 'High-frequency spectral flux';
featlabel{6} = 'Tension arousal';

% Correlation values
corrvalue{1} = 'rho = -.454, p < .001';
corrvalue{2} = 'rho = .363, p < .001';
corrvalue{3} = 'rho = .410, p < .001';
corrvalue{4} = 'rho = .358, p < .001';
corrvalue{5} = 'rho = .322, p < .001';
corrvalue{6} = 'rho = -.440, p < .001';

% Feature data
load(featfile,'Xraw','Yraw','CORRfeat'); 
X = Xraw; Y = Yraw;

% Figure size
fig = figure('renderer','painters');
screen = get(0,'screensize'); 
set(fig,'position',[0 0 screen(3) screen(4)]);

% Hex scatter plot
rows = 2; cols = length(featvar) / rows;
for i = 1:length(featvar)
    
    % Feature index    
    temp = strfind(lower(CORRfeat),featvar{i});
    featid = find(not(cellfun('isempty',temp)));
    
    % Feature plot
    subplot(rows,cols,i);
    hexscatter(X{featid},Y{featid},'showzeros','true');
    title(corrvalue{i});
    xlabel(featlabel{i});
    ylabel('Intersubject phase synchrony');    
    
    % Appearance
    colorbar;    
    set(gca,'xlim',[min(X{featid}) max(X{featid})]); % Axis limits
    set(gca,'ylim',[min(Y{featid}) max(Y{featid})]);
    xticks = get(gca,'xtick');
    yticks = get(gca,'ytick');
    if strcmp(featvar{i},'mstrength') || strcmp(featvar{i},'irregular') || strcmp(featvar{i},'tension')
        set(gca,'xticklabel',sprintf('%.2f\n',xticks),'fontsize',10,'fontname','arial'); % Axis labels
    else
        set(gca,'xticklabel',sprintf('%.0f\n',xticks),'fontsize',10,'fontname','arial');
    end
    set(gca,'yticklabel',sprintf('%.2f\n',yticks),'fontsize',10,'fontname','arial');
    % box off;
    
end

% White to black color scale
colormap gray; % Black to white
colormap(flipud(colormap)); % Reverse scale

% Save variables and figure
save([figfile,'.mat'],'featvar','featlabel','corrvalue','X','Y','CORRfeat');
set(gcf,'paperorientation','landscape'); saveas(gcf,figfile,'ps');