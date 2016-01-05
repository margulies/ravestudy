function X = naninterp(X)
% http://www.mathworks.com/matlabcentral/fileexchange/8225-naninterp
% Interpolate over NaNs
% See INTERP1 for more info
X(isnan(X)) = interp1(find(~isnan(X)), X(~isnan(X)), find(isnan(X)), 'spline');
return