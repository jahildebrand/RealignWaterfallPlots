function params = getLOCParams(params)
% JAH 5/2022
% Get parameters for Localization / SS inversion
params.inpath =  'K:\GoogleDriveBackUp\Localize';
params.AISpath =  'K:\GoogleDriveBackUp\RainbowClick\Data';
% params.outpath = 'D:\RC_Out\Localize\';
params.out = [params.inpath,'ResultsNEW\'];
params.Model.ctdoafn = fullfile(params.inpath,'cTDOA','ctdoa.mat');
%

% model origin times from closest station

% physcial model space - dimensions = [ lat lon]
params.lat0 = 28; %origin for plot and calculation
params.lon0 = -89; 
params.Model.xmin = -88.75;
params.Model.xmax = -87.5;
params.Model.ymin = 28.25;
params.Model.ymax = 29.25;
params.Model.zmin = 10; % in m
params.Model.zmax = 70;   % depth is positive down

% Resolution of solved locations [lat and lon]
params.Model.dx = .001; % lon is cos(28) closer than lat
params.Model.dy = .001; %200 data points per deg lat
params.Model.dz = 10;

% number of grid points for x, y and z
params.Model.nx = (params.Model.xmax - params.Model.xmin) / params.Model.dx + 1;
params.Model.ny = (params.Model.ymax - params.Model.ymin) / params.Model.dy + 1;
params.Model.nz = (params.Model.zmax - params.Model.zmin) / params.Model.dz + 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% environmental values
params.Model.sspeed = [1500, 1500, 1500, 1500, ...
                      1500, 1500, 1500, 1500, ...
                  1500, 1500, 1500, 1500];    % Sound Speed [m/s] by site
                        % 1 = ac, 2 =...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Receiver locations in Model Space [m]
% Hydrophone locations
%dlmread(fullfile(params.inpath,'latlonz5.txt'));
Project = 'GOM';
date_check = datetime(2021, 5, 1); %middle of the surevey
params.Model.Hname = lower(params.HARPName);
params.Model.nrcvr = length(params.HARPName) ;    % number of receivers
for iharp = 1: params.Model.nrcvr
    [params.Model.H(iharp,1),...
        params.Model.H(iharp,2),...
        params.Model.H(iharp,3)] = ...
        getLocationInfo(Project, params.HARPName(iharp), date_check,params.hdatasum);
end

% path to MTDOA data
params.mtdoafn = cell(1,5);
for iship = 1 : params.nships
    fname = ['mtdoa_',params.Year,params.Month,params.Day,params.Hour,'_',num2str(iship),'.mat'];
    params.mtdoafn{iship} = fullfile(params.out,'mtdoa',fname);
end

% path to AIS data
params.shipnam = cell(1,2);
params.shipnam{1,1} = fullfile(params.AISpath,'GOM_AGSurvey_SF2103_257692000');
params.shipnam{1,2} = fullfile(params.AISpath,'GOM_AGSurvey_SF2103_259645000');

