function accel_icc % Intraclass correlation

clear;

filename = 'accel_data.mat';
measure = 'dist'; % Combined x, y, z
% subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'};{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];
% subject = [{'handL1'};{'handL2'};{'handR1'};{'handR2'}];
subject = [{'hipL1'};{'hipL2'};{'hipR1'};{'hipR2'}];

datafile = load(filename);

i = 0;
D = zeros(length(datafile.(subject{1}).(measure)),length(subject));
for s = 1:length(subject)
    i = i + 1;
    D(:,i) = datafile.(subject{s}).(measure);
end

% '1-k': The degree of absolute agreement of measurements that are
% averages of k independent measurements on randomly selected objects.
type = '1-k'; alpha = .05; r0 = 0; 
[r, LB, UB, F, df1, df2, p] = ICC(D, type, alpha, r0);

% disp(' ');
disp(['ICC=',num2str(r),' p=',num2str(p),' LB=',num2str(LB),' UB=',num2str(UB)]); 
% disp(' ');