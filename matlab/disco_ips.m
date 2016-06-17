function disco_ips(input,fileID,subjectSTR)
% disco_ips(input,fileID,subjectSTR)
% Intersubject phase synchronization for group synchrony measure
%   input = Input data file (timeseries,filename)
%   [output = Output data file (IPS,msec,fileID,subjectSTR)]
%   fileID = File identifier (''[all],'groupA','groupB')
%   subjectSTR = List of subjects to include in analysis
% 
% disco_ips(...
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

pairs = length(subjects) * (length(subjects) - 1) / 2; % Number of subject pairs
IPS = zeros(size(timeseries{1,1},2)-1,size(timeseries{1,1},1)); % Intersubject phase synchronization for each frequency band (levels x samples)
for level = 1:size(timeseries{1,1},2)-1 % For each frequency band (level) [first column = msec]
    
    disp([datestr(now),': Level = ',num2str(level)]);
    
    %%% ADAPTED FROM CALCULATEPHASESYNCH.M (ISC TOOLBOX) %%%
    
    i = 0;
    AD = zeros(size(timeseries{1,1},1),pairs); % Angular distance at each time point for each subject pair 
    for s1 = subjects' % For each subject pair ['subjects' needs to be a row vector]
        t1 = hilbert(timeseries{s1,1}(:,1+level)); % Hilbert transform to obtain corresponding analytic signal [first column = msec]
        for s2 = subjects'
            if s2 > s1
                i = i + 1;
                t2 = hilbert(timeseries{s2,1}(:,1+level));
                AD(:,i) = angle(t1) - angle(t2);
                
                disp([datestr(now),': ',filename{s1},', ',filename{s2}]);
            end
        end
    end

    if pairs == 1
        absAD = abs(AD); % Absolute angular distance (Dissimilarity measure)
    else
        absAD = sum(abs(AD),2) / pairs; % Average of all subject-pairwise absolute angular distances
    end
    
    IPS(level,:) = 1 - absAD / pi; % Normalized version of (average) absolute angular distance(s)

end

[pathstr,namestr,~] = fileparts(input);
underscore = strfind(namestr,'_');
previous = namestr(underscore(2)+1:end);
if strcmp(fileID,'')
    output = [pathstr,'/',mfilename,'_',previous,'.mat'];
else
    output = [pathstr,'/',mfilename,'_',fileID,'_',previous,'.mat'];
end
disp([datestr(now),': Saving ',output]);
save(output,'IPS','msec','fileID','subjectSTR');
disp([datestr(now),': Done!']);