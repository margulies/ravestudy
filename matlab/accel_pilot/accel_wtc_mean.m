function accel_wtc_mean % Average of wavelet coherence pairs

clear;

filename = 'accel_data.mat';
measure = 'dist'; % Combined x, y, z
% subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'};{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
% subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'}];
subject = [{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
samplingHz = 90;

datafile = load(filename);
data = cell(length(subject),1);
for s = 1:length(subject)
    data{s} = datafile.(subject{s});
    data{s} = data{s}.(measure);
end

time = (1:length(data{1}))' / samplingHz;
pairs = length(subject) * (length(subject) - 1) / 2;
Rsq = cell(pairs,1); period = cell(pairs,1); scale = cell(pairs,1); coi = cell(pairs,1); sig95 = cell(pairs,1); Wxy = cell(pairs,1); dt = cell(pairs,1);
i = 1;
for s1 = 1:length(subject) % Wavelet coherence for each pair of time courses
    for s2 = 1:length(subject)
        if s2 > s1
            [Rsq{i,1},period{i,1},scale{i,1},coi{i,1},sig95{i,1},Wxy{i,1},dt{i,1}] = wtc([time data{s1}],[time data{s2}],'mcc',0);
            i = i + 1;
        end
    end
end

dim = ndims(Rsq{1}); % Get number of dimensions for arrays
Rsq_matrix = cat(dim+1,Rsq{:}); % Convert to (dim+1)-dimensional matrix
Rsq_mean = mean(Rsq_matrix,dim+1); % Get mean across arrays

dim = ndims(Wxy{1});
Wxy_matrix = cat(dim+1,Wxy{:});
Wxy_mean = mean(Wxy_matrix,dim+1);

dim = ndims(sig95{1});
sig95_matrix = cat(dim+1,sig95{:});
sig95_mean = mean(sig95_matrix,dim+1);

% Plot average wavelet coherence
H = imagesc(time,log2(period{1}),Rsq_mean); % Scale data and display as image (X-axis, Y-axis, Values)

set(gca,'clim',[0 1]); % Set object properties (Color scale)
HCB = colorbar; % Display color scale
Yticks = 2.^(fix(log2(min(period{1}))):fix(log2(max(period{1})))); % Y-axis values (Period)
Ylabels = 1 ./ Yticks; % Y-axis labels (Frequency)
set(gca,'YLim',log2([min(period{1}),max(period{1})]), ...
    'YDir','reverse','layer','top', ...
    'YTick',log2(Yticks(:)), ...
    'YTickLabel',num2str(Ylabels','%0.2f'), ...
    'layer','top');
ylabel('Frequency (Hz)');
xlabel('Time (s)');

hold on;

% Plot average phase directions
Wxy_mean_angle = angle(Wxy_mean); % Angle conversion of cross-wavelet results
Wxy_mean_angle_thresh = Wxy_mean_angle;
Wxy_mean_angle_thresh(Rsq_mean < .5) = NaN; % Remove phase indication where Rsq is low

arrowDensity = [30 30]; arrowSize = 1; arrowHeadSize = 1; % Default arrow values
arrowDensity_mean = mean(arrowDensity); 
arrowSize = arrowSize*30*.03/arrowDensity_mean;
arrowHeadSize = arrowHeadSize*120/arrowDensity_mean;

phs_dt = round(length(time)/arrowDensity(1)); tidx = max(floor(phs_dt/2),1):phs_dt:length(time); % Time (x) axis
phs_dp = round(length(period{1})/arrowDensity(2)); pidx = max(floor(phs_dp/2),1):phs_dp:length(period{1}); % Period (y) axis
phaseplot(time(tidx),log2(period{1}(pidx)),Wxy_mean_angle_thresh(pidx,tidx),arrowSize,arrowHeadSize);

% Plot cone of influence
time1 = [time([1 1])-dt{1}*.5;time;time([end end])+dt{1}*.5];
hcoi = fill(time1,log2([period{1}([end 1]) coi{1} period{1}([1 end])]),'w'); % Fills the 2D polygon defined by vectors X and Y with the color C
set(hcoi,'alphadatamapping','direct','facealpha',.5);

% Plot significance contours
if ~all(isnan(sig95_mean))
    [c,h] = contour(time,log2(period{1}),sig95_mean,[1 1],'k');
    set(h,'linewidth',2)
end

hold off;

save('accel_wtc_mean_hip.mat','Rsq','period','scale','coi','sig95','Wxy','dt');