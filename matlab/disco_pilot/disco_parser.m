function disco_parser % Data parser

% clear;

folder = './ravestudy_data/disco/data/'; % Data directory
% Deleted timepoints after midnight in #28, #31, #41, and #47

list = dir([folder,'*.csv']); % CSV files information
file = {list.name}'; % File names only
data = cell(length(file),1); % Initialize cell array
for subject = 1:length(file)   
    fid = fopen([folder,file{subject}]); % Open data file
    data{subject,1} = textscan(fid,'%f %f %f %f %f %f %f %f','delimiter',';:','headerlines',1); % HH MM SS MS Xacc Yacc Zacc Gforce
    data{subject,1} = cell2matpad(data{subject,1},NaN); % Concatenate unequal arrays and pad with NaN's
    % Convert time to milliseconds from 00:00:00:000 (last column)
    data{subject,1}(:,size(data{subject,1},2)+1) = data{subject,1}(:,1)*60*60*1000 + data{subject,1}(:,2)*60*1000 + data{subject,1}(:,3)*1000 + data{subject,1}(:,4);
    fclose(fid);
end

save('./ravestudy/disco_pilot/disco_data.mat','data','file');