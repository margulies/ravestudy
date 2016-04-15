function disco_validity(folder,timefile,samplerate)
% disco_validity(folder,timefile,samplerate)
% Correlation test of synchrony timecourse from different pipelines
% with condition timecourse from the pilot experiment 
%   folder = Folder of synchrony measures files
%   timefile = File containing condition times in milliseconds
%   samplerate = Sampling rate in ms 
%   (e.g., ceil(mean of actual rate across Ss) = ceil(15.4120) = 16 ms)
%   [output = Output data file (RHO,preproc,RHOsortvalue,RHOsortname)]
%
% disco_validity(...
%     '/SCR/ellamil/ravestudy_stats/pilot/validity',...
%     '/SCR/ellamil/ravestudy_stats/pilot/preproc/disco_millisecond_conditions.mat',...
%     ceil(15.4120));

disp([datestr(now),': Running ',mfilename,'.m']);

list = dir([folder,'/','*.mat']); % Synchrony measures files
preproc = {list.name}'; % File names only

load(timefile); % Variable 'timeMSEC' from disco_millisecond.mat

RHO = zeros(length(preproc),4);
for p = 1:length(preproc) % For each preprocessing pipeline
    
    load([folder,'/',preproc{p}]); % From disco_cpm/ips.mat
    
    % Synchrony measure variable (CPM/IPS)
    measure = upper(preproc{p}(7:9));    
    eval(['SYNC = ',measure,';']); 
        
    % Mean of synchrony measure timecourses across the middle 5 frequency bands
    band1 = floor(size(SYNC,1) / 5) * 2;
    band2 = band1 + 5 - 1;
    meanSYNC = mean(SYNC(band1:band2,:));
        
    % Timecourse defining synchrony (1) and non-synchrony (0) conditions
    condSYNC = zeros(1,length(meanSYNC));
    for t = 2:2:length(timeMSEC)-1 % For each synchrony condition (2 timepoints)
        first = ceil((timeMSEC(t) - timeMSEC(1)) / samplerate); % First timepoint
        last = ceil((timeMSEC(t+1) - timeMSEC(1)) / samplerate); % Last timepoint
        if last > length(condSYNC)
            last = length(condSYNC);
        end        
        condSYNC(1,first:last) = ones(1,last-first+1);        
    end 
    
    % Correlation test of condition and synchrony timecourses
    [R,P,L,U] = corrcoef(condSYNC',meanSYNC'); % r-value, p-value, 95% CI lower bound, upper bound    
    RHO(p,1) = R(2,1);  RHO(p,2) = P(2,1);  RHO(p,3) = L(2,1);  RHO(p,4) = U(2,1);    
    
    disp([datestr(now),': ',preproc{p}]);
     
end

% Sorted positive and significant correlations
RHOthreshvalue = RHO( RHO(:,1) > 0  &  RHO(:,2) < .05/length(preproc) , : );
RHOthreshname = preproc( RHO(:,1) > 0  &  RHO(:,2) < .05/length(preproc) );
[RHOsortvalue,RHOsortindex] = sort( RHOthreshvalue(:,1) , 'descend' );
RHOsortvalue(:,2:4) = RHOthreshvalue( RHOsortindex , 2:4 );
RHOsortname = RHOthreshname( RHOsortindex );

output = [folder,'/',mfilename,'.mat'];
disp([datestr(now),': Saving ',output]);
save(output,'RHO','preproc','RHOsortvalue','RHOsortname');
disp([datestr(now),': Done!']);