function disco_features(syncfile,featdir,featvar)
% disco_features(syncfile,featdir,featvar)
% Correlation test of synchrony timecourse with different music features
%   syncfile = Synchrony measure file
%   featdir = Folder of feature files
%   featvar = List of music features
%   [output = Output data file (CORRval,CORRfeat,X=feat,Y=sync)]
% 
%   disco_features(...
%       '/SCR/ellamil/ravestudy_stats/disco/disco_ips_coif1_mean_linear_zalign.mat',...
%       '/SCR/ellamil/ravestudy_stats/disco/features/frame',...
%       {'energy',... % Dynamics
%        'tempo','metroid','mstrength','pulse',... % Rhythm
%        'attack','noise','flux','bright','rough','irregular',... % Timbre
%        'pitch','inharmonic',... % Pitch
%        'mode','hcdf',... % Tone
%        'novel','emotion'}); % High-Level

disp([datestr(now),': Running ',mfilename,'.m']);

% Synchrony measure variable
[~,namestr,~] = fileparts(syncfile);
syncvar = upper(namestr(7:9));

% Load synchrony data
eval(['load(syncfile,''',syncvar,''');']); 
eval(['synclevels = ',syncvar,';']);

% Mean synchrony timecourse across the middle 5 frequency bands
band1 = 6;  % floor(size(synclevels,1) / 5) * 2;
band2 = 10; % band1 + 5 - 1;
sync = mean(synclevels(band1:band2,:));

count = 0;
featvar = featvar';
for f = 1:length(featvar)
    
    % Load feature data
    eval(['load(''',featdir,'/disco_mir_',featvar{f},'.mat'');']);    
    
    % Assign feature data
    if strcmp(featvar{f},'emotion')
        feat(1:3,:) = cell2mat(emotion.dimdata{1}); % Dimensions: activity, valence, tension
        featname(1:3,1) = emotion.dim';
        feat(4:8,:) = cell2mat(emotion.classdata{1}); % Classes: happy sad, tender, anger, fear
        featname(4:8,1) = emotion.class';
    elseif strcmp(featvar{f},'flux')
        feattemp = mirgetdata(flux);
        feat(1,:) = feattemp(1,:,2); % Band #2: low frequency, 50-100Hz
        featname{1,1} = 'lowfreqflux';
        feat(2,:) = feattemp(1,:,9); % Band #9: high frequency, 6400-12800Hz
        featname{2,1} = 'highfreqflux';
    elseif strcmp(featvar{f},'pitch')
        % feattemp = mirgetdata(pitch); % Error
        feattemp = cell2matpad(pitch.amplitude{1,1}{1,1},NaN); % Pitch components (5 total)
        feat = feattemp(1,:); % First pitch component (only 1 complete timeseries)
        featname{1,1} = featvar{f};
    elseif strcmp(featvar{f},'inharmonic') || strcmp(featvar{f},'novel')
        eval(['feat = ',featvar{f},';']);
        featname{1,1} = featvar{f};
    else
        eval(['feat = mirgetdata(',featvar{f},');']);
        featname{1,1} = featvar{f};
    end

    for i = 1:size(feat,1) % Main feature or Sub-features

        % Interpolate feature data
        % Linear interpolation used for synchrony data
        if find(feat(i,:)~=0,1,'first') ~= 1 || find(feat(i,:)~=0,1,'last') ~= length(feat(i,:))
            index1 = find(feat(i,:)~=0,1,'first'); % First non-zero element
            index2 = find(feat(i,:)~=0,1,'last'); % Last non-zero element
        else
            index1 = find(~isnan(feat(i,:)),1,'first'); % First non-NaN element
            index2 = find(~isnan(feat(i,:)),1,'last'); % Last non-NaN element
        end
        featNAN = feat(i,index1:index2); % Trim the 0 or NaN edges
        featNAN(featNAN==0) = NaN; % Replace 0's with NaN's
        fInterpolate = naninterp(featNAN,'linear'); % Interpolate over NaN's
                      
        % Detrend feature data
        % Prevents edge artifacts when filtering
        fDetrend = detrend(fInterpolate);
        fDetrend = zscore(fDetrend);
        
        % Decompose (filter) feature data
        % Coif1 mother wavelet used for synchrony data        
        fWavelet = modwt(fDetrend,'coif1');
        fReconstruct = zeros(size(fWavelet,1)-1,size(fWavelet,2));
        for level = 1:size(fWavelet,1)-1
            fReconstruct(level,:) = imodwt(fWavelet,level-1,'coif1');
        end
        
        % Mean feature timeseries from middle 5 frequency bands    
        % Mean feature timeseries back into its original length        
        band1 = ceil(level/2) - 2;
        band2 = ceil(level/2) + 2;
        fMiddle = NaN(size(feat(i,:)),'like',feat(i,:));
        fMiddle(index1:index2) = mean(fReconstruct(band1:band2,:));

        % Detrend synchrony data
        % Prevents edge artifacts when downsampling
        sDetrend = detrend(sync);
        sDetrend = zscore(sDetrend);
        
        % Resample (downsample) synchrony data to match feature data
        % Allows non-multiple downsampling rate
        if length(fMiddle) < length(sDetrend)
            try
                P = floor(length(fMiddle) / length(sDetrend) * 100000); % Upsample factor
                Q = 100000; % Downsample factor
                sResample = resample(sDetrend,P,Q);
            catch
                P = ceil(length(fMiddle) / length(sDetrend) * 100000); % Upsample factor
                Q = 100000; % Downsample factor
                sResample = resample(sDetrend,P,Q);
                sResample = sResample(1:length(fMiddle)); % Correct for 1 extra sample at end
            end            
        else % if length(fMiddle) > length(sDetrend)
            P = ceil(length(sDetrend) / length(fMiddle) * 100000); % Upsample factor
            Q = 100000; % Downsample factor
            fResample = resample(fMiddle,P,Q);
            fResample = fResample(1:length(sDetrend)); % Correct for 1 extra sample at end
        end

        % Correlate sychrony data and feature data
        count = count + 1;
        if length(fMiddle) < length(sDetrend)
            X{count,1} = (fMiddle(index1:index2))'; % Feature timeseries
            Y{count,1} = (sResample(index1:index2))'; % Synchrony timeseries
        else % if length(fMiddle) > length(sDetrend)
            index1 = find(~isnan(fResample),1,'first'); % First non-NaN element
            index2 = find(~isnan(fResample),1,'last'); % Last non-NaN element
            X{count,1} = (fResample(index1:index2))'; % Feature timeseries
            Y{count,1} = (sDetrend(index1:index2))'; % Synchrony timeseries
        end       
        [CORRval(count,1),CORRval(count,2)] = corr(X{count,1}(:),Y{count,1}(:),'type','spearman'); % [r,p]
        CORRfeat{count,1} = featname{i,1};
        
        % Mean and SD to calculate raw values for feature and synchrony
        Xavg = mean(fInterpolate); 
        Xstd = std(fInterpolate);
        Yavg = mean(sync); 
        Ystd = std(sync);
        Xraw{count,1} = X{count,1} * Xstd + Xavg;
        Yraw{count,1} = Y{count,1} * Ystd + Yavg;        
        
        disp([datestr(now),': ',CORRfeat{count,1}]);

    end
    
    clear('feattemp','feat','featname');
    
end

output = [featdir,'/',mfilename,'.mat'];
disp([datestr(now),': Saving ',output]);
save(output,'CORRval','CORRfeat','X','Y','Xraw','Yraw');
disp([datestr(now),': Done!']);