function [X] = deldetno(X,detno)
% remove detno row of cell
%JAH June 2022
szx = size(X);
if szx(2) == 1
    X(detno:end-1) = X(detno+1:end);
    X(end) = [];
else
    X(detno:end-1,:) = X(detno+1:end,:);
    X(end,:) = [];
end