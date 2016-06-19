function disco_interpolate(input,type)
% disco_interpolate(input,type)
% Interpolates accelerometer timeseries
%   input = Input data file (timeseries,filename,starttime,endtime)
%   [output = Output data file (timeseries,filename)]
%   type = Interpolation type ('linear','cubic','nearest') 
% 
% disco_interpolate(...
%     '/SCR/ellamil/ravestudy_stats/pilot/disco_combine_vector.mat',...
%     'linear');

disp([datestr(now),': Running ',mfilename,'.m, type = ',type]);

load(input,'timeseries','filename','starttime','endtime'); % Variables from disco_combine.mat

if strcmp(type,'cubic')
    type = 'pchip';
end

old = timeseries;
new = cell(size(old));
for subject = 1:length(old)
    
    X = old{subject,1}(:,1); % Sampled Msec
    Y = old{subject,1}(:,2); % Sampled Acc

    [~,uniqueIDX] = unique(X); % Find unique Msec
    X = X(sort(uniqueIDX),:); % Remove duplicate Msec (2 samples in one Msec)
    Y = Y(sort(uniqueIDX),:); % Remove corresponding Acc
    
    XQ = (old{subject,1}(1,1):old{subject,1}(end,1))'; % Interpolated Msec    
    YQ = interp1(X,Y,XQ,type); % Interpolated Acc
    
    startIDX = find(XQ == starttime);
    endIDX = find(XQ == endtime);
    new{subject,1}(:,1) = XQ(startIDX:endIDX,:); % Interpolated Msec
    new{subject,1}(:,2) = YQ(startIDX:endIDX,:); % Interpolated Acc
    
    disp([datestr(now),': ',filename{subject}]);

end
timeseries = new;

if strcmp(type,'pchip')
    type = 'cubic';
end

[pathstr,namestr,~] = fileparts(input);
underscore = strfind(namestr,'_');
previous = namestr(underscore(2)+1:end);
output = [pathstr,'/',mfilename,'_',type,'_',previous,'.mat'];
disp([datestr(now),': Saving ',output]);
save(output,'timeseries','filename','-v7.3'); % "Warning: Variable cannot be saved to a MAT-file whose version is older than 7.3. To save this variable, use the -v7.3 switch."
disp([datestr(now),': Done!']);