function [etshift,esshift] = estimateTS(dnum,ns,actsite,impsite)
%JAH estimate time shift
% given timeB MTT(1) and timeE MTT(end)
% Shiplocation from AIS  input file p.shipn{ns}
% ship number ns
% actual site actsite
% import site impsite

global p
actfind = find(p.Model.Hname == actsite);
impfind = find(p.Model.Hname == impsite);
actlat = p.Model.H(actfind,1);  actlon = p.Model.H(actfind,2);
implat = p.Model.H(impfind,1);  implon = p.Model.H(impfind,2);
%
% global Model
hMTT = []; hlat = []; hlon = [];
% used to be for iship = 1 : p.nship
load(p.shipnam{1,ns});
hMTT = [hMTT;T];
hlat = [hlat;LAT];
hlon = [hlon;LON];
%end
MTT = sort(hMTT); lat = sort(hlat); lon = sort(hlon);
gt = find(dnum > MTT(1) & dnum < MTT(end));
if isempty(gt)
    gt = length(MTT);
end
slatB = lat(gt(1)); slatE = lat(gt(end));
slonB = lon(gt(end)); slonE = lon(gt(end));
[ractB,~,~] = wgs84(actlat,actlon,slatB,slonB,1);
[ractE,~,~] = wgs84(actlat,actlon,slatE,slonE,1);
[rimpB,~,~] = wgs84(implat,implon,slatB,slonB,1);
[rimpE,~,~] = wgs84(implat,implon,slatE,slonE,1);

etshift = (ractB - rimpB)/1500.; % should be real ssp
temp = (ractE - rimpE)/1500.; % should be real ssp
esshift = temp - etshift;

end