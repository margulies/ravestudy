% Statistical comparison of discriminability / validity of different pipelines

statfile = '/SCR/ellamil/ravestudy_stats/pilot/disco_validity_anova.mat';
corrfile = '/SCR/ellamil/ravestudy_stats/pilot/disco_validity.mat';

% Correlation data
load(corrfile); 
correlation = RHO;
pipeline = preproc;

% Fisher's Z-transform
fishercorr = fisherz(correlation(:,1));

% Parameter options
paramname = cell(length(pipeline),1);
paramvalue = zeros(length(pipeline),6);
for i = 1:length(pipeline)
    
    paramname{i} = strsplit(pipeline{i},{'_','.'});
    
    % Group synchrony measure
    if strcmp(paramname{i}{2},'cpm')
        paramvalue(i,1) = 1;
    elseif strcmp(paramname{i}{2},'ips')
        paramvalue(i,1) = 2;
    end
    
    % Wavelet decomposition: Wavelet family
    if ~isempty(strfind(paramname{i}{3},'coif'))
        paramvalue(i,2) = 1;        
    elseif ~isempty(strfind(paramname{i}{3},'db'))
        paramvalue(i,2) = 2;
    elseif ~isempty(strfind(paramname{i}{3},'sym'))
        paramvalue(i,2) = 3;
    end
    
    % Wavelet decomposition: Vanishing moments
    if ~isempty(strfind(paramname{i}{3},'1')) || ~isempty(strfind(paramname{i}{3},'2'))
        paramvalue(i,3) = 1;
    elseif ~isempty(strfind(paramname{i}{3},'3')) || ~isempty(strfind(paramname{i}{3},'4'))
        paramvalue(i,3) = 2;
    elseif ~isempty(strfind(paramname{i}{3},'5')) || ~isempty(strfind(paramname{i}{3},'6'))
        paramvalue(i,3) = 3;
    end
    
    % Data downsampling
    if strcmp(paramname{i}{4},'decimate')
        paramvalue(i,4) = 1;
    elseif strcmp(paramname{i}{4},'mean')
        paramvalue(i,4) = 2;
    end
    
    % Time interpolation
    if strcmp(paramname{i}{5},'cubic')
        paramvalue(i,5) = 1;
    elseif strcmp(paramname{i}{5},'linear')
        paramvalue(i,5) = 2;
    elseif strcmp(paramname{i}{5},'nearest')
        paramvalue(i,5) = 3;
    end
    
    % Axes combination
    if strcmp(paramname{i}{6},'vector')
        paramvalue(i,6) = 1;
    elseif strcmp(paramname{i}{6},'xalign')
        paramvalue(i,6) = 2;
    elseif strcmp(paramname{i}{6},'yalign')
        paramvalue(i,6) = 3;
    elseif strcmp(paramname{i}{6},'zalign')
        paramvalue(i,6) = 4;
    end    
    
end

% N-way ANOVA
y = fishercorr; % Fisher's Z-transformed correlations
g1 = paramvalue(:,1); % Group synchrony measure
g2 = paramvalue(:,2); % Wavelet decomposition: Wavelet family
g3 = paramvalue(:,3); % Wavelet decomposition: Vanishing moments
g4 = paramvalue(:,4); % Data downsampling
g5 = paramvalue(:,5); % Time interpolation
g6 = paramvalue(:,6); % Axes combination
[~,anovastats,~] = anovan(y,{g1,g2,g3,g4,g5,g6},'display','off');

% Multiple comparisons 
p = 6; % Axes combination
compstats = zeros(p,4);
pair = 0;
for c1 = 1:max(paramvalue(:,p)) % For each pair of levels
    for c2 = 1:max(paramvalue(:,p))
        if c2 > c1
            pair = pair + 1;            
            dataX = fishercorr(paramvalue(:,p)==c1);
            dataY = fishercorr(paramvalue(:,p)==c2);
            [~,pval,~,stats] = ttest2(dataX,dataY);            
            compstats(pair,:) = [c1,c2,stats.tstat,pval];
        end
    end
end

% Means, SEMs, and raw correlations per factor level
corravg = cell(size(paramvalue,2),1);
corrstd = cell(size(paramvalue,2),1);
corrsem = cell(size(paramvalue,2),1);
corrval = cell(size(paramvalue,2),4);
for p = 1:size(paramvalue,2) % Parameter / Factor
    for c = 1:max(paramvalue(:,p)) % Category / Level
        corravg{p}(c) = ifisherz(mean(fishercorr(paramvalue(:,p)==c))); % Mean
        corrstd{p}(c) = ifisherz(std(fishercorr(paramvalue(:,p)==c))); % Standard deviation
        corrsem{p}(c) = ifisherz(std(fishercorr(paramvalue(:,p)==c)) / sqrt(length(fishercorr(paramvalue(:,p)==c)))); % SEM
        corrval{p}{c} = correlation(paramvalue(:,p)==c); % Raw values (correlations)
    end
end

save(statfile,'corravg','corrstd','corrsem','corrval','anovastats','compstats');