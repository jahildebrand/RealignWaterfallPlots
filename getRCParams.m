function params = getRCParams
% JAH 6/2021 5/2025 using 2103 SAG
%if seeking decimated files get them from snowman
% use PowerShell to create drive mapping berfore using this command:
% JAH> net use Z: "\\snowman\GofMX_Decimated_5\GOM_AC_01\GOM_AC_01_disk05_df100"
%Or to delete
%net use Z: /delete

%   params - A struct with variable fields of parameter settings
% Parameters
params.site = 'y1c';
% where to put the results
params.sp = 'y';
params.outRC = 'K:\GoogleDriveBackUp\RainbowClick\ResultsNEW\';
params.outLO = 'K:\GoogleDriveBackUp\Localize\ResultsNEW\';
% HARP data summary location
params.hdatasum = 'K:\GoogleDriveBackUp\RainbowClick\Data\HARPDataSummary_20250205.xlsx';
% where to start the analysis
params.Year = '2021';
params.Month = '04';
params.Day = '30';
params.ymd = [params.Year,params.Month,params.Day];
params.Hour = '09';%
params.Min = '59';% actual start will be 2 min later
params.Sec = '36';
%GOM_AC_01_210515_120229_df10020210519132200_de
params.dedate = [params.Year,params.Month,params.Day,params.Hour,params.Min,params.Sec];
params.fs = 2000; % sample rate
% ship mapping
params.shipmap = [1,2];
params.mmsi = cell(1,5);
params.mmsi{1,1} = '257692000';
params.mmsi{1,2} = '259645000';

% Site labels
% params.lab = {'ac','ga','gc','sl','dc','ce','mr','y1b','y1c,','y1d','lc','dt'};
params.HARPName = ["AC"; "CE" ; "DT" ; ...
                  "GA"; "GC"; "LC"; "MR"; ...
                    "Y1B"; "Y1C"];
params.lab = lower(params.HARPName);
params.lab = cellstr(params.lab);  % convert string array to cell array of char
params.nsites = length(params.lab);
params.nshots = 1; % number of shots
params.nships = 2; % number of ships
% Clock correction
% params.clockcor = [0, 0, 0, 5.6, 6.7]; % dt and hh -based on earthquake
params.clockcor = [0, 0, 0, 0, 0,0,0,0,0,0,0,0,]; % dt and hh -based on earthquake

%
params.Method = 'SEQ';% 'SEQ' 'KF' or 'JH' method for associating pulses
params.isiX = 13; %62 sec interval
params.isiXE = 3; % 5 sec error in isi
params.selectts = datenum(str2double(params.Year),str2double(params.Month),...
    str2double(params.Day),str2double(params.Hour),str2double(params.Min),...
    str2double(params.Sec));
params.dstr = [params.Year(3:4),params.Month,params.Day,'_',...
    params.Hour,params.Min,params.Sec];
params.debug = 'n';
params.filterdata = 'n';
params.saveDE = 'y';  % save DetEdit data
params.saveRC = 'y'; % save vgood and figure
params.usepg2 = 'n'; % use the ISI interval as selection criteria
params.direction = '+'; % direction of scan in time
params.dur = 240; % duration of window
params.step = 120; % forward step between windows
params.nsd= 24*60*60; % numbers of sec in a day
params.fa = 15; % low frequency cutoff for filter
params.fb = 500; % high freq curtoff for filter
params.maxrlag = 1000; % when cal lag for initial
%
params.gain = 0.001; %gain on waterfall plot
params.spgain = 0.004; % gain for spectra

% use varargin toget site name
switch params.site
     case 'ac'
         params.infolder = '\\snowman\GofMX_Decimated_5\GOM_AC_01\GOM_AC_01_disk05_df100\';
         fn = 'GOM_AC_01_210426_230229_df100.x.wav';
         params.gain = .0002;

    case 'ce'
        params.infolder = '\\frosty\GofMX_Decimated_6_BU\GOM_CE_01\GOM_CE_01_disk05_df100\';
        fn = 'GOM_CE_01_210517_121230_df100.x';

    case 'dc'
        params.infolder = '\\frosty\GofMX_Decimated_6_BU\GOM_DC_13\GOM_DC_13_disk05_df100\';
        fn = 'GOM_DC_13_210519_072730_df100.x';
         params.gain = .003;

    case  'dt'
        params.infolder = '\\frosty\GofMX_Decimated_6_BU\GOM_DT_13\GOM_DT_13_disk05_df100\';
        fn = 'GOM_DT_13_210517_025730_df100.x';

    case 'ga'
        % MARP 20 KHz
       params.infolder = '\\frosty\GofMX_Decimated_9\GOM_GA_01\GOM_GA_01_disk04_df10\';
       fn = 'GOM_GA_01_210517_091230_df10.x';
        params.gain = .0005;

    case 'gc'
        params.infolder = '\\frosty\GofMX_Decimated_6_BU\GOM_GC_13\GOM_GC_13_disk05_df100\';
        fn = 'GOM_GC_13_210516_171959_df100.x';

    case 'lc'
        params.infolder = '\\frosty\GofMX_Decimated_6_BU\GOM_LC_01\GOM_LC_01_disk05_df100\';
        fn = 'GOM_LC_01_210516_023500_df100.x';

    case 'mr'
       params.infolder = '\\snowman\GofMX_Decimated_5\GOM_MR_01\GOM_MR_01_disk05_df100\';
        fn = 'GOM_MR_01_210518_200615_df100.x';

    case 'sl'
        %MARP 20kHz
       params.infolder = '\\frosty\GofMX_Decimated_9\GOM_SL_01\GOM_SL_01_disk05_df10\';
       fn = 'GOM_SL_01_210518_202500_df10.x';

    case 'y1b'
        params.infolder = '\\frosty\GofMX_Decimated_6_BU\GOM_Y1B_01\GOM_Y1B_01_disk05_df100\';
        fn = 'GOM_Y1B_01_210516_032615_df100.x';

    case 'y1c'
        params.infolder = '\\frosty\GofMX_Decimated_6_BU\GOM_Y1C_01\GOM_Y1C_01_disk05_df100\';
        fn = 'GOM_Y1C_01_210516_211115_df100.x';

    case 'y1d'
        params.infolder = '\\frosty\GofMX_Decimated_6_BU\GOM_Y1D_01\GOM_Y1D_01_disk05_df100\';
        fn = 'GOM_Y1D_01_210515_084845_df100.x';

end
params.filename = [fn,'.wav'];
params.fileresult = [fn(1:end-2),'rc.mat'];
params.outname = fn(1:end-2);

params.fn_out = [params.outname,params.Year,params.Month,params.Day,...
    params.Hour,params.Min,params.Sec,'.',...
    num2str(params.dur),'.rc'];
params.mtfn = fullfile(params.outRC,[params.ymd]);
% params.mtfn = fullfile(params.outRC,'mtdoa',[params.ymd]);
% User defined parameters
% userParams()
params.nsec = 8; % length of MSN for DE file, with MTT at center of window
params.overlap = 50; % overlap in DE fft
params.before = 1; % data before detection peak in sec
params.after = 3.0; % data after detection peak in sec
params.within = 2.0; % combine duplicate detections within x sec
params.withinc = 2.0; % continue designation of pulse series when match with x sec
params.withinisi = 2.0; % has ISI within 2 sec of pgood
params.sdcut = 2.0; % limit on Stand Dev for ISI
params.thres = 1000; % threshold for peak detector in counts
params.xthres = 0.2; % percent of max for peaks in xcov
params.xlock = 5; % sec lockout for xcov peaks
params.lock = 5; %  sec lock out on detector
params.minshot = 5; % minimum shot interval
params.maska = 1.0; % mask level of suppression in xcov .. higher is more
params.maskl = 1.5; % length of time for mask relative to before/after
params.colors = 9; % num colors in rainbow click increase if needed
params.C = linspecer(params.colors,'qualitative'); % colors in RCFig
%
% % parameters from file header
% m,year,month,day,hour,minute,secs,ticks,byte_loc,byte_length,dnumStart
params.m = []; % number raw files
params.year = [];
params.month = [];
params.day = [];
params.hour = [];
params.minute = [];
params.secs = [];
params.ticks = [];
params.byte_loc = [];
params.byte_length = [];
params.dnumStart = [];
% Specify inputs
Project = 'GOM';
date_check = datetime(2021, 5, 1); %middle of the surevey

params.HARPlat = []; params.HARPlon = []; params.HARPdep = [];
nharp = length(params.HARPName);

for iharp = 1: nharp
    [lat, lon, dep] = getLocationInfo(Project, params.HARPName(iharp), date_check,params.hdatasum);
%
    params.HARPlat = [params.HARPlat lat];
    params.HARPlon = [params.HARPlon lon];
    params.HARPdep = [params.HARPdep dep];
end

% Harp sites
end

