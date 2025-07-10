function [SP] = StheData(SN)
% Take Spectra of Data
%JAH 3-2022
global p PARAMS
% spectra parameters
durt = p.nsec; % sec
fs = PARAMS.fs;
durs = durt * fs; % number samples for snippet
nfft = durs;
window = hanning(nfft);
overlap = p.overlap;
noverlap = round((overlap/100)*nfft);
sda = size(SN);
SP = zeros(sda(1),sda(2)/2+1);
for idata = 1:sda(1)
    [SP(idata,:),f] = pwelch(SN(idata,:),window,noverlap,nfft,fs);
end
