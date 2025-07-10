function [fData] = FtheData(Data)
%JAH Filter the data
global p PARAMS
fa = p.fa;
fb = p.fb;
fs = PARAMS.fs;
ir = dfilter(7,fa,fs); % high pass 7 pole fa cutoff
% Ensure input is double
Data = double(Data);
sda = size(Data);
fData = zeros(sda(1),sda(2));
for idata = 1:sda(1)
    fData(idata,:) = filtfilt(ir,Data(idata,:));
end