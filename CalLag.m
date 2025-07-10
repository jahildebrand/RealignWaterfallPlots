function [slag,rellag] = CalLag(X,N,ns,slag,rellag,maxrlag)
% calculate slags
%JAH

slag{1,ns} = zeros(size(N)); % absolute lag (in samples) for each signal to align w/ previous signal
rellag{1,ns} = zeros(size(N)); % lag (in samples) in relation to previous signal
slag{1,ns}(1) = 0;

% make initial lag estimates for slag

for n = 2:length(N)
    [xc, lags] = xcov(X(n-1, :), X(n, :));
    [~,I] = max((xc));
    nshift = lags(I);
    if abs(nshift) > maxrlag
        nshift = 0;
    end
    slag{1,ns}(n) = slag{1,ns}(n-1) + nshift;
    rellag{1,ns}(n) = nshift;
end