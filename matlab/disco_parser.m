function disco_parser(input,output,startstring,endstring)
% disco_parser(input,output,startstring,endstring)
% Extracts data from accelerometer app CSV files
%   input = Input data directory
%   output = Output data directory (timeseries,filename,samplerateMS/HZ[all],start/endtime)
%   startstring = Event start time (HH:MM:SS:MS)
%   endstring = Event end time (HH:MM:SS:MS)
% 
% disco_parser(... % Max Planck Pilot
%     './ravestudy_data/pilot',...
%     '/SCR/ellamil/ravestudy_stats/pilot',...
%     '15:25:44:580','16:02:05:830');
% 
% disco_parser(... % Science of Disco
%     './ravestudy_data/disco',...
%     '/SCR/ellamil/ravestudy_stats/disco',...
%     '20:33:18:64','21:04:00:802');

disp([datestr(now),': Running ',mfilename,'.m']);

list = dir([input,'/','*.csv']); % CSV files information
file = {list.name}'; % File names only

% Event start and end times in milliseconds
startcell = str2double(strsplit(startstring,':'));
endcell = str2double(strsplit(endstring,':'));
starttime = startcell(1)*60*60*1000 + startcell(2)*60*1000 + startcell(3)*1000 + startcell(4);
endtime = endcell(1)*60*60*1000 + endcell(2)*60*1000 + endcell(3)*1000 + endcell(4);

count = 1;
for subject = 1:length(file)
if ~strcmp('08.csv',file{subject,1}) ... % DM
&& ~strcmp('37.csv',file{subject,1}) ... % LB
&& ~strcmp('67.csv',file{subject,1}) ... % ME
&& ~strcmp('76.csv',file{subject,1})     % DJ

    csv = [input,'/',file{subject}]; % Subject file   
    fid = fopen(csv); % Open data file    
    temp = textscan(fid,'%f %f %f %f %f %f %f','delimiter',';:','headerlines',1); % HH MM SS MS Xacc Yacc Zacc
    fclose(fid); % Close data file
        
    temp = cell2mat(temp); % Concatenate cell arrays
    temp(:,size(temp,2)+1) = temp(:,1)*60*60*1000 + temp(:,2)*60*1000 + temp(:,3)*1000 + temp(:,4); % Convert time to MS from 00:00:00:000 (last column)
    startindex = find(temp(:,end) <= starttime,1,'last'); % Last timepoint before event start time
    endindex = find(temp(:,end) >= endtime,1,'first'); % First timepoint after event end time
        
    if ~isempty(startindex) && ~isempty(endindex) % If timeseries within music start and end times
        
        timeseries{count,1}(:,1) = temp(startindex:endindex,end); % Msec
        timeseries{count,1}(:,2:4) = temp(startindex:endindex,5:7); % Xacc,Yacc,Zacc
        filename{count,1} = file{subject,1}; % Filename
        
        % Time between each sampling time point (ms)
        difference = diff(timeseries{count,1}(2:end-1,1)); % Exclude first(startindex) and last(endindex) timepoints 
        samplerateMS(count) = mean(difference); % Average sampling rate for each subject (ms)
        samplerateHZ(count) = 1000 / samplerateMS(count); % Average sampling rate for each subject (Hz)

        count = count + 1;
        
    end    
    
    disp([datestr(now),': ',csv]);

end
end

samplerateMSall = mean(samplerateMS); % Average sampling rate across all subjects (ms)
samplerateHZall = mean(samplerateHZ); % Average sampling rate across all subjects (Hz)
disp([datestr(now),': samplerateMSall = ',num2str(samplerateMSall)]);
disp([datestr(now),': samplerateHZall = ',num2str(samplerateHZall)]);

output = [output,'/',mfilename,'.mat'];
disp([datestr(now),': Saving ',output]);
save(output,'timeseries','filename','samplerateMS','samplerateHZ','samplerateMSall','samplerateHZall','starttime','endtime');
disp([datestr(now),': Done!']);