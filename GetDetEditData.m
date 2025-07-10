function [sPP,sSN,sUSN,sSP,sUSP] = GetDetEditData(dn1,dn2,iMTT,detno)
% get data from a Wav file (not X wav) and make DetEdit Data
global PARAMS 
% wav data or Xwav data?
if strcmp(PARAMS.xhd.hSubchunkID,'data')
    [sPP,sSN,sUSN,sSP,sUSP] = GetDetEditDataW(dn1,dn2,iMTT,detno); % wav
else
    [sPP,sSN,sUSN,sSP,sUSP] = GetDetEditDataX(dn1,dn2,iMTT,detno); % xwav
end