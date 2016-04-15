function disco_cpm(input,fileID,subjectSTR)
% disco_cpm(input,fileID,subjectSTR)
% Cluster phase method for group synchrony measure
%   input = Input data file (timeseries,filename)
%   [output = Output data file (CPM,msec,fileID,subjectSTR)]
%   fileID = File identifier (''[all],'groupA','groupB')
%   subjectSTR = List of subjects to include in analysis
% 
% disco_cpm(...
%     '/SCR/ellamil/ravestudy_stats/pilot/disco_decompose_db2_decimate_linear_vector.mat',...
%     '',... % [all]
%     {'1b','2b','3b','4b','5b','6b'});

disp([datestr(now),': Running ',mfilename,'.m, fileID = ''',fileID,'''']);
disp([datestr(now),': Subjects = ',sprintf('%s  ',subjectSTR{:})]);

load(input,'timeseries','filename'); % Variables from disco_decompose.mat

% Millisecond time information
msec = timeseries{1,1}(:,1);

% Find indices of subject strings
subjectSTR = subjectSTR';
subjects = zeros(length(subjectSTR),1);
for s0 = 1:length(subjectSTR)
    temp = strfind(filename,subjectSTR{s0});
    subjects(s0) = find(not(cellfun('isempty',temp)));
end

% Variables for CPM function input
TSnumber = length(subjects); % Number of time series
TSfsamp = 1; % First time point
TSlsamp = size(timeseries{1,1},1); % Last time point
% TSsamplerate = samplerate; % Sampling rate in Hz
% samplerate = Sampling rate in Hz (e.g., 1000ms / 16ms = 62.50Hz)

% Statistics for each frequency band (level)
% GRPrhoM_all = zeros(size(timeseries{1,1},2)-1,1); % Mean group rho (levels x 1) [first column = msec]
% INDrhoM_all = zeros(size(timeseries{1,1},2)-1,length(subjects)); % Mean rho for each TS to group (levels x subjects) 
% INDrpM_all = zeros(size(timeseries{1,1},2)-1,length(subjects)); % Mean relative phase for each TS to group cluster phase (levels x subjects)
TSrhoGRP_all = zeros(size(timeseries{1,1},2)-1,size(timeseries{1,1},1)-1); % Group rho time-series (levels x samples) (-1 samples because of CPM code)
% TSrpIND_all = cell(size(timeseries{1,1},2)-1,1); % Relative phase time-series for each individual TS to cluster phase (levels x 1)

for level = 1:size(timeseries{1,1},2)-1 % For each frequency band (level) [first column = msec]

    disp([datestr(now),': Level = ',num2str(level)]);
    
    % Create data matrix for CPM function input
    count = 0;
    data = zeros(length(timeseries{1,1}(:,1)),length(subjects)); % (samples x subjects)    
    for s0 = subjects' % ['subjects' needs to be a row vector]
        count = count + 1;
        data(:,count) = timeseries{s0,1}(:,1+level); % 1+level because first column = msec
    end
        
    %%% ADAPTED FROM CLUSTERPHASE_DO.M %%%
    
    % Load timeseries data    
    for nts = 1:TSnumber
        ts_data(:,nts) = data(TSfsamp:TSlsamp,nts);
    end    
    TSlength = length(ts_data(:,1));
    % delta_t = 1 / TSsamplerate;
    % t = (1:TSlength) * delta_t;
 
    disp([datestr(now),': Computing phase for each timeseries using Hilbert transform...']);
    % Compute phase for each TS using Hilbert transform
    TSphase = zeros(TSlength-1,TSnumber);
    for k = 1:TSnumber
        hrp = hilbert(ts_data(:,k));
        for n = 1:TSlength-1
            TSphase(n,k) = atan2(real(hrp(n)),imag(hrp(n)));
        end
        TSphase(:,k) = unwrap(TSphase(:,k));
    end
    
    disp([datestr(now),': Computing mean running or cluster phase...']);
    % Compute mean running (cluster) phase
    clusterphase = zeros(1,TSlength-1);
    for n = 1:TSlength-1
        ztot = complex(0,0);
        for k = 1:TSnumber
            z = exp(1i * TSphase(n,k));
            ztot = ztot + z;
        end
        ztot = ztot / TSnumber;
        clusterphase(n) = angle(ztot);
    end
    clusterphase = unwrap(clusterphase);
    
    disp([datestr(now),': Computing relative phases between timeseries phase and cluster phase...']);
    % Compute relative phases between phase of TS and cluster phase
    TSrpIND = zeros(TSlength-1,TSnumber);
    INDrpM = zeros(TSnumber,1);
    INDrhoM = zeros(TSnumber,1);
    for k = 1:TSnumber
        ztot = complex(0,0);
        for n = 1:TSlength-1
            z = exp(1i * (TSphase(n,k) - clusterphase(n)));
            TSrpIND(n,k) = z;
            ztot = ztot + z;
        end
        TSrpIND(:,k) = angle(TSrpIND(:,k)) * 360 / (2*pi); % Convert radian to degrees
        ztot = ztot / (TSlength-1);
        INDrpM(k) = angle(ztot);
        INDrhoM(k) = abs(ztot);
    end
    TSRPM = INDrpM;
    INDrpM = (INDrpM(:,1) ./ (2*pi) * 360); % Convert radian to degrees
    
    disp([datestr(now),': Computing cluster amplitute in rotation frame...']);
    % Compute cluster amplitude rhotot in rotation frame
    TSrhoGRP = zeros(TSlength-1,1);
    for n = 1:TSlength-1
        ztot = complex(0,0);
        for k = 1:TSnumber
            z = exp(1i * (TSphase(n,k) - clusterphase(n) - TSRPM(k)));
            ztot = ztot + z;
        end
        ztot = ztot / TSnumber;
        TSrhoGRP(n) = abs(ztot);
    end
    GRPrhoM = mean(TSrhoGRP);    
        
    % GRPrhoM_all(level,1) = GRPrhoM;
    % INDrhoM_all(level,:) = INDrhoM;
    % INDrpM_all(level,:) = INDrpM;
    TSrhoGRP_all(level,:) = TSrhoGRP;
    % TSrpIND_all{level,1} = TSrpIND;
    
end

CPM = TSrhoGRP_all;

[pathstr,namestr,~] = fileparts(input);
underscore = strfind(namestr,'_');
previous = namestr(underscore(2)+1:end);
if strcmp(fileID,'')
    output = [pathstr,'/',mfilename,'_',previous,'.mat'];
else
    output = [pathstr,'/',mfilename,'_',fileID,'_',previous,'.mat'];
end
disp([datestr(now),': Saving ',output]);
save(output,'CPM','msec','fileID','subjectSTR');
disp([datestr(now),': Done!']);