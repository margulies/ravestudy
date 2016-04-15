function disco_reliability(folder)
% disco_reliability(folder)
% Reliablity test of synchrony timecourse from different pipelines
%   folder = Folder of synchrony measures files
%   [output = Output data file (REL,preproc,RELsortvalue,RELsortname)]
%
% disco_reliability('/SCR/ellamil/ravestudy_stats/pilot/reliability');

disp([datestr(now),': Running ',mfilename,'.m']);

list = dir([folder,'/','*groupA*.mat']); % Synchrony measures files from Group A 
preproc = {list.name}'; % File names only

% Type of ICC: A-1, Case 3 [i.e., A-ICC(3,1)]
% Absolute agreement among measurements; Two-way mixed effects single measures
% Model 3 = Each subject is assessed by each rater, but the raters are the only raters of interest
% Form 1 = Reliability calculated from a single measurement
% Two-way random effects [A-1, Case 2 or A-ICC(2,1)] and A-1, Case 3 have equivalent calculation and only differ in interpretation
type = 'A-1'; alpha = .05; r0 = 0;

REL = zeros(length(preproc),7);
for p = 1:length(preproc) % For each preprocessing pipeline
        
    load([folder,'/',preproc{p}]); % Group A; From disco_cpm/ips.mat    
    measure = upper(preproc{p}(7:9)); % Synchrony measure variable (CPM/IPS)
    eval(['SYNCa = ',measure,';']); 
    
    groupB = strrep(preproc{p},'groupA','groupB'); % Group B
    load([folder,'/',groupB]);
    eval(['SYNCb = ',measure,';']);

    % Mean of synchrony measure timecourses across the middle 5 frequency bands
    band1 = floor(size(SYNCa,1) / 5) * 2;
    band2 = band1 + 5 - 1;
    meanSYNCa = mean(SYNCa(band1:band2,:));
    meanSYNCb = mean(SYNCb(band1:band2,:));

    % Reliability test of synchrony timecourses
    % [r, LB, UB, F, df1, df2, p] = ICC(M, type, alpha, r0);
    M = [meanSYNCa' meanSYNCb'];
    [REL(p,1),REL(p,2),REL(p,3),REL(p,4),REL(p,5),REL(p,6),REL(p,7)] = ICC(M,type,alpha,r0);
 
    disp([datestr(now),': ',preproc{p}]);
    
end

% Sorted high and significant reliability coefficients
RELthreshvalue = REL( REL(:,1) > .70  &  REL(:,7) < .05/length(preproc) , : );
RELthreshname = preproc( REL(:,1) > .70  &  REL(:,7) < .05/length(preproc) );
[RELsortvalue,RELsortindex] = sort( RELthreshvalue(:,1) , 'descend' );
RELsortvalue(:,2:7) = RELthreshvalue( RELsortindex , 2:7 );
RELsortname = RELthreshname( RELsortindex );

output = [folder,'/',mfilename,'.mat'];
disp([datestr(now),': Saving ',output]);
save(output,'REL','preproc','RELsortvalue','RELsortname');
disp([datestr(now),': Done!']);