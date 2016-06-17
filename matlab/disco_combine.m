function disco_combine(input,type)
% disco_combine(input,type)
% Combines the three axis measures into one measure
%   input = Input data file (timeseries,filename,starttime,endtime)
%   [output = Output data file (timeseries,filename,starttime,endtime)]
%   type = Combination type ('vector','xalign','yalign','zalign')
% 
% disco_combine(...
%     '/SCR/ellamil/ravestudy_stats/pilot/disco_parser.mat',...
%     'vector');

disp([datestr(now),': Running ',mfilename,'.m, type = ',type]);

load(input,'timeseries','filename','starttime','endtime'); % Variables from disco_parser.mat

old = timeseries;
new = cell(size(old));
if strcmp(type,'vector') % = SQRT(X^2 + Y^2 + Z^2)
    for subject = 1:length(old)        
        new{subject,1}(:,1) = old{subject,1}(:,1); % Msec
        new{subject,1}(:,2) = sqrt(old{subject,1}(:,2) .^ 2 + old{subject,1}(:,3) .^ 2 + old{subject,1}(:,4) .^ 2);
        disp([datestr(now),': ',filename{subject}]);
    end
    
elseif strcmp(type,'xalign') % = ARCSIN(X / SQRT(X^2 + Y^2 + Z^2))
    for subject = 1:length(old)        
        new{subject,1}(:,1) = old{subject,1}(:,1); % Msec   
        new{subject,1}(:,2) = asin(old{subject,1}(:,2) ./ sqrt(old{subject,1}(:,2) .^ 2 + old{subject,1}(:,3) .^ 2 + old{subject,1}(:,4) .^ 2));
        disp([datestr(now),': ',filename{subject}]);
    end    
    
elseif strcmp(type,'yalign') % = ARCSIN(Y / SQRT(X^2 + Y^2 + Z^2))
    for subject = 1:length(old)        
        new{subject,1}(:,1) = old{subject,1}(:,1); % Msec
        new{subject,1}(:,2) = asin(old{subject,1}(:,3) ./ sqrt(old{subject,1}(:,2) .^ 2 + old{subject,1}(:,3) .^ 2 + old{subject,1}(:,4) .^ 2));
        disp([datestr(now),': ',filename{subject}]);
    end
    
elseif strcmp(type,'zalign') % = ARCSIN(Z / SQRT(X^2 + Y^2 + Z^2))
    for subject = 1:length(old)        
        new{subject,1}(:,1) = old{subject,1}(:,1); % Msec
        new{subject,1}(:,2) = asin(old{subject,1}(:,4) ./ sqrt(old{subject,1}(:,2) .^ 2 + old{subject,1}(:,3) .^ 2 + old{subject,1}(:,4) .^ 2));
        disp([datestr(now),': ',filename{subject}]);
    end
    
end
timeseries = new;

[pathstr,~,~] = fileparts(input);
output = [pathstr,'/',mfilename,'_',type,'.mat'];
disp([datestr(now),': Saving ',output]);
save(output,'timeseries','filename','starttime','endtime','-v7.3'); % "Warning: Variable cannot be saved to a MAT-file whose version is older than 7.3. To save this variable, use the -v7.3 switch."
disp([datestr(now),': Done!']);