function X = naninterp(X, type)
% http://www.mathworks.com/matlabcentral/fileexchange/8225-naninterp
% Interpolate over NaNs
% See INTERP1 for more info

if strcmp(type, 'linear')
    X(isnan(X)) = interp1(find(~isnan(X)), X(~isnan(X)), find(isnan(X)), 'linear', 'extrap');
elseif strcmp(type, 'cubic')
    X(isnan(X)) = interp1(find(~isnan(X)), X(~isnan(X)), find(isnan(X)), 'pchip');
else
    X(isnan(X)) = interp1(find(~isnan(X)), X(~isnan(X)), find(isnan(X)), type);
end

return