function disco_clusterphase % Cluster phase method for collective synchrony measure

% clear;

load('./ravestudy/disco_pilot/disco_timeseries.mat');
load('./ravestudy/disco_pilot/disco_TSsmooth.mat');



%%% Create data matrix for cluster phase method input
count = 1;
for subject = 1:length(filename)
if subject ~= 15 && subject ~= 17 && subject ~= 43 % I don't know why these error out (during alignment)
    data0(:,count) = TSsmooth(:,subject); % Remove zero columns for #15, #17, and #43
    file{count,1} = filename{subject,1}; % Remove file names for #15, #17, and #43
    count = count + 1;
end
end
data1 = downsample(data0,20); % Downsample data to 50Hz
dlmwrite('./ravestudy/disco_pilot/disco_TSdownsample.txt',data1,'delimiter','\t','precision','%.6f'); % Save to text file



%%% Call cluster phase method function

TSfilename = './ravestudy/disco_pilot/disco_TSdownsample.txt'; % Data file name
TSnumber = size(data1,2); % Number of time series
TSfsamp = 1; % First time point
TSlsamp = size(data1,1); % Last time point
TSsamplerate = 100; % Sampling rate in Hz
plotflag = 1; % Plot results

[GRPrhoM INDrhoM INDrpM TSrhoGRP TSrpIND] = ClusterPhase_do(TSfilename, TSnumber, TSfsamp, TSlsamp, TSsamplerate, plotflag);
% GRPrhoM: mean group rho (0 to 1; 1 = perfect sync)
% INDrhoM: mean rho for each TS to group (0 to 1; 1 = perfect sync)
% INDrpM: mean Relative Phase for each TS to group cluster phase 
% TSrhoGRP: group rho time-series
% TSrpIND: relative phase time-series for each individual TS to cluster phase

save('./ravestudy/disco_pilot/disco_clusterphase.mat','GRPrhoM','INDrhoM','INDrpM','TSrhoGRP','TSrpIND');