function [fold,fin,fout] = SelectSite(varargin)
%select which site
global p
varin = lower(strtrim(char(varargin)));
fold =  [p.outRC,varin,'_Realign'];
% fmiddle = [p.Year,p.Month,p.Day];
fmiddle = [p.Year,p.Month,p.Day,'\',p.Hour];
%
switch varin
    case 'ac'
        fin = fullfile(fold,fmiddle,['GOM_AC_01_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_AC_01_',p.dedate,'_deC.mat']);

    case 'ce'
        fin = fullfile(fold,fmiddle,['GOM_CE_01_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_CE_01_',p.dedate,'_deC.mat']);

    case 'dc'
        fin = fullfile(fold,fmiddle,['GOM_DC_13_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_DC_13_',p.dedate,'_deC.mat']);

    case 'dt'
        fin = fullfile(fold,fmiddle,['GOM_DT_13_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_DT_13_',p.dedate,'_deC.mat']);

    case 'ga'
        fin = fullfile(fold,fmiddle,['GOM_GA_01_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_GA_01_',p.dedate,'_deC.mat']);

    case 'gc'
        fin = fullfile(fold,fmiddle,['GOM_GC_13_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_GC_13_',p.dedate,'_deC.mat']);

    case 'lc'
        fin = fullfile(fold,fmiddle,['GOM_LC_01_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_LC_01_',p.dedate,'_deC.mat']);

    case 'mr'
        fin = fullfile(fold,fmiddle,['GOM_MR_01_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_MR_01_',p.dedate,'_deC.mat']);

    case 'sl'
        fin = fullfile(fold,fmiddle,['GOM_SL_01_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_SL_01_',p.dedate,'_deC.mat']);

    case 'y1b'
        fin = fullfile(fold,fmiddle,['GOM_Y1B_01_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_Y1B_01_',p.dedate,'_deC.mat']);

    case 'y1c'
        fin = fullfile(fold,fmiddle,['GOM_Y1C_01_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_Y1C_01_',p.dedate,'_deC.mat']);

    case 'y1d'
        fin = fullfile(fold,fmiddle,['GOM_Y1D_01_',p.dedate,'_de.mat']);
        fout = fullfile(fold,fmiddle,['GOM_Y1D_01_',p.dedate,'_deC.mat']);

end