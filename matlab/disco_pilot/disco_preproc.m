function disco_preproc % Data preprocessing

% clear;

load('./ravestudy/disco_pilot/disco_data.mat');

% Music start and end times in milliseconds (from Phone #76 at DJ booth)
starttime = 20*60*60*1000 + 33*60*1000 + 18*1000 + 64; % 20:33:18:64 
endtime = 21*60*60*1000 + 04*60*1000 + 00*1000 + 802; % 21:04:00:802

%%% Subject timeseries within music start and end times
count = 1;
for subject = 1:length(file)
    if ~strcmp('08.csv',file{subject,1}) ... % Daniel
    && ~strcmp('37.csv',file{subject,1}) ... % Louis
    && ~strcmp('67.csv',file{subject,1}) ... % Melissa
    && ~strcmp('76.csv',file{subject,1}) % DJ Booth
        startindex = find(data{subject,1}(:,9) <= starttime,1,'last'); % Last timepoint before music start time
        endindex = find(data{subject,1}(:,9) >= endtime,1,'first'); % First timepoint after music end time
        if ~isempty(startindex) && ~isempty(endindex) % If timeseries within music start and end times
            timeseries{count,1} = data{subject,1}(startindex:endindex,:); % Save subject timeseries
            filename{count,1} = file{subject,1}; % Save subject filename
            count = count + 1;
        end
    end
end
save('./ravestudy/disco_pilot/disco_timeseries.mat','timeseries','filename','starttime','endtime');



% clear;

% load('./ravestudy/disco_pilot/disco_timeseries.mat');

%%% Align subject timeseries with different sampling timepoints
TSalign = cell(length(filename),1); % Initialize cell array
for subject = 1:length(filename)
if subject ~= 15 && subject ~= 17 && subject ~= 43 % I don't know why these error out
    TSalign{subject,1}(:,1) = (starttime:endtime)'; % Column 1: All possible sampling timepoints in milliseconds
    sampleindex = find(ismember(TSalign{subject,1}(:,1),timeseries{subject,1}(:,9))); % Get indices of sampling timepoints from each subject timeseries    
    TSalign{subject,1}(:,2:5) = nan(length(TSalign{subject,1}(:,1)),4); % Initialize Xacc, Yacc, Zacc, and Gforce columns with NaN's
    TSalign{subject,1}(sampleindex,2:5) = deal(timeseries{subject,1}(2:end-1,5:8)); % Columns 2-5: Corresponding Xacc, Yacc, Zacc, and Gforce information
    % (2:end-1) because 1 = 1 timepoint before starttime and end = 1 timepoint after endtime
end
end
% save('./ravestudy/disco_pilot/disco_TSalign.mat','TSalign'); % Need to switch Matlab version to save this variable


%%% Interpolate over NaN's in aligned timeseries
TSinterp = cell(length(filename),1); % Initialize cell array
for subject = 1:length(filename)
if subject ~= 15 && subject ~= 17 && subject ~= 43 % I don't know why these error out (during alignment)
    TSinterp{subject,1}(:,1) = TSalign{subject,1}(:,1); % Msec
    % Function edited to perform piecewise cubic spline interpolation ('spline')
    TSinterp{subject,1}(:,2) = naninterp(TSalign{subject,1}(:,2)); % Xacc
    TSinterp{subject,1}(:,3) = naninterp(TSalign{subject,1}(:,3)); % Yacc
    TSinterp{subject,1}(:,4) = naninterp(TSalign{subject,1}(:,4)); % Zacc
    TSinterp{subject,1}(:,5) = naninterp(TSalign{subject,1}(:,5)); % Gforce
end
end
% save('./ravestudy/disco_pilot/disco_TSinterp.mat','TSinterp'); % Need to switch Matlab version to save this variable


%%% High pass filter to remove influence of gravity
filterconstant = 0.1; % Filter constant
TSfilter = cell(length(filename),1); % Initialize cell array
for subject = 1:length(filename)
if subject ~= 15 && subject ~= 17 && subject ~= 43 % I don't know why these error out (during alignment)
    
    TSfilter{subject,1}(:,1) = TSinterp{subject,1}(:,1); % Msec    
    TSfilter{subject,1}(:,2:4) = zeros(length(TSfilter{subject,1}(:,1)),3); % Initialize column vectors
    
    % Separate user acceleration from gravitational acceleration:
    % http://mathforum.org/kb/thread.jspa?threadID=2631608
    % http://developer.android.com/guide/topics/sensors/sensors_motion.html
    % 1. Isolate the force of gravity with the low-pass filter
    % 2. Remove the gravity contribution with the high-pass filter    
    TSfilter{subject,1}(:,2) = TSinterp{subject,1}(:,2) - ((TSinterp{subject,1}(:,2) * filterconstant) + (TSfilter{subject,1}(:,2) * (1.0 - filterconstant))); % Xacc
    TSfilter{subject,1}(:,3) = TSinterp{subject,1}(:,3) - ((TSinterp{subject,1}(:,3) * filterconstant) + (TSfilter{subject,1}(:,3) * (1.0 - filterconstant))); % Yacc
    TSfilter{subject,1}(:,4) = TSinterp{subject,1}(:,4) - ((TSinterp{subject,1}(:,4) * filterconstant) + (TSfilter{subject,1}(:,4) * (1.0 - filterconstant))); % Zacc
    
end
end
% save('./ravestudy/disco_pilot/disco_TSfilter.mat','TSfilter'); % Need to switch Matlab version to save this variable



%%% Combine three axis measures into one distance measure
TSdistance = zeros(length(TSfilter{1,1}(:,1)),length(filename)); % Initialize matrix
for subject = 1:length(filename)
if subject ~= 15 && subject ~= 17 && subject ~= 43 % I don't know why these error out (during alignment)
    TSdistance(:,subject) = sqrt(TSfilter{subject,1}(:,2) .^ 2 + TSfilter{subject,1}(:,3) .^ 2 + TSfilter{subject,1}(:,4) .^ 2); % D = SQRT(X^2 + Y^2 + Z^2)
end
end
save('./ravestudy/disco_pilot/disco_TSdistance.mat','TSdistance');



%%% Smooth timeseries data
window = gausswin(15000); % Gaussian window of 15 seconds with 1 sample per millisecond
TSsmooth = zeros(size(TSdistance)); % Initialize matrix
for subject = 1:length(filename)
if subject ~= 15 && subject ~= 17 && subject ~= 43 % I don't know why these error out (during alignment)
    TSsmooth(:,subject) = filter(window,1,TSdistance(:,subject)); % Gaussian smoothing
end
end
save('./ravestudy/disco_pilot/disco_TSsmooth.mat','TSsmooth');