function disco_decompose(input,type)
% disco_decompose(input,type)
% Wavelet decomposition of timeseries data
%   input = Input data file (timeseries,filename)
%   [output = Output data file (timeseries,filename)]
%   type = Wavelet to use
% 
% disco_decompose(...
%     '/SCR/ellamil/ravestudy_stats/pilot/disco_downsample_decimate_linear_vector.mat',...
%     'db2');

disp([datestr(now),': Running ',mfilename,'.m, type = ',type]);

load(input,'timeseries','filename'); % Variables from disco_downsample.mat

old = timeseries;
new = cell(size(old));
for subject = 1:length(old)
    
    % Number of levels in wavelet transformation
    % levels = floor(log2(length(old{1,1}(:,1)))); 

    % modwt: Maximal overlap discrete wavelet transform
    % W = modwt(X,WNAME): modwt of a signal X using the wavelet WNAME
    % W: LEV+1-by-N matrix of wavelet coeffs & final-level scaling coeffs
    % LEV: Level of the modwt
    % m-th row: Wavelet (detail) coefficients for scale 2^m
    % LEV+1-th row: Scaling coefficients for scale 2^LEV

    % imodwt: Inverse maximal overlap discrete wavelet transform
    % R = imodwt(W,Lo,Hi): Reconstructs signal using scaling filter Lo & wavelet filter Hi

    D = old{subject,1}(:,2); % Timeseries data
    D = zscore(D); % Normalization: mean = 0, variance = 1
    
    W = modwt(D,type); % Wavelet coefficients     
    R = zeros(size(W,1)-1,size(W,2));
    for level = 1:size(W,1)-1
        R(level,:) = imodwt(W,level-1,type); % Reconstructed signal
    end    

    new{subject,1}(:,1) = old{subject,1}(:,1); % First column with msecs
    new{subject,1}(:,2:2+size(R,1)-1) = R'; % Second+ columns with reconstructed signal
    
    disp([datestr(now),': ',filename{subject}]);
    
end
timeseries = new;

[pathstr,namestr,~] = fileparts(input);
underscore = strfind(namestr,'_');
previous = namestr(underscore(2)+1:end);
output = [pathstr,'/',mfilename,'_',type,'_',previous,'.mat'];
disp([datestr(now),': Saving ',output]);
save(output,'timeseries','filename','-v7.3'); % "Warning: Variable cannot be saved to a MAT-file whose version is older than 7.3. To save this variable, use the -v7.3 switch."
disp([datestr(now),': Done!']);