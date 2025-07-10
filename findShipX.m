function [TT,MTT,zID,slag,rellag,iS] = findShipX(MTT,zID,slag,rellag,ns,fs)
% JAH 6-2021
%
iS = find(zID(:,2) == ns); % find all instance of ship i
TT = zeros(length(iS),1);
for n = 1 : length(iS)
    TT(n,1) = zID(iS(n),1)  - slag{1,ns}(n,1)/(24*60*60*fs);
    zID(iS(n),1) = TT(n,1);
    MTT(iS(n),1) = TT(n,1); % makes MTT and zID agree
    slag{1,ns}(n,1) = 0;
    rellag{1,ns}(n,1) = 0;
end





