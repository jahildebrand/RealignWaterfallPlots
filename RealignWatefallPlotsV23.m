% realignWaterfallPlots
% Align airgun pulses, allows raw data read to correct time
%JAH 2-2022
% v22 works for Xwav (not yet debugged for Wav files)
% v23 estimates range - time for import data
warning('off')
clear all
clf
global PARAMS p
% strx = input('Enter Site: mc mp dc dt hh nr:  ', 's');
p = getRCParams; % paramter file
p = getLOCParams(p);
%
disp(['Working site: ',p.site])
siteok = input('Correct site: y on n? ','s');
if siteok == 'n'
    disp(strjoin(p.HARPName', ', '))
    p.site = input('Enter Site: ', 's');
end
% catch wrong inputfile
FindInfile();
%
fs = p.fs;
[fold,fin,fout] = SelectSite(p.site); % file in and file out
disp(fout)
PARAMS.inpath = p.infolder(1:end-1);
PARAMS.infile = p.filename;
%
% get dnumstart of all raw files in xwav
rdxwavhd % read header of XWave or Wav file
% wav data if strcmp(PARAMS.xhd.hSubchunkID,'data')
%
load(fout) % load existing DetEdit data
[MTT,~] = MTTfix(MTT);
%%
if ~exist('slag') % first time no slag
    nship = unique(zID(:,2));
    for ns = 1 : max(nship)
        N = find(zID(:,2)==ns); % indices of ships with label "ns"
        slag{1,ns} = zeros(size(N)); % absolute lag (in samples) for each signal to align w/ previous signal
        rellag{1,ns} = zeros(size(N)); % lag (in samples) in relation to previous signal
        slag{1,ns}(1) = 0;
    end
end
%
uZ = unique(zID(:,2));
NS = length(find(uZ)); % # of ships
%
detno = 0;
res = input('Import data from another site? y or n ','s');

while strcmp(res,'y') % import time from another site - same ship
    disp(strjoin(p.HARPName', ', '))
    strxI = input('Enter Site: ', 's');
    ns = input('Which Ship ? ');
    % p = getLOCParams(p);  %get AIS file information p.shipn
    if ns > 0 && ns <= NS
        tfout = fout;
        [fold,fin,fout] = SelectSite(strxI); % file in and file out
        % remove ns = zID and hold in tMTT
        iS = find(zID(:,2) ~= ns);
        tMTT = MTT(iS,1); tMPP = MPP(iS,1);
        tzID = zID(iS,:);
        tMSN = MSN(iS,:); tMSP = MSP(iS,:);
        load(fout) % read import data
        [MTT,~] = MTTfix(MTT);
%         if ~exist("etshift",'var')
            [etshift,esshift] = estimateTS(MTT,ns,p.site,strxI);
%         end
        tshift = input(['Enter time shift import data sec: estimate ',num2str(etshift),' ']);
        sshift = input(['Enter slope time to shift sec : estimate ', num2str(esshift),' ']);
        if sshift == 0
            sshift = 0.1;
        end
        fout = tfout; %change back
        % TT has new time, slag(ns) and rellag(ns) = 0;
        [TT,~,~,slag,rellag,~] = findShipX(MTT,zID,slag,rellag,ns,PARAMS.fs);
        iTT = length(TT); itMTT = length(tMTT);
        sepsi = sshift / (length(TT)-1);
        ashift = 0 : sepsi : sshift;
        TT = TT + (tshift+ashift')/(24*60*60);
        MTT = [tMTT; TT];
        nzID = ns * ones(iTT,1);
        nnzID = [TT,nzID];
        zID = [tzID ; nnzID];
        % get MSN data
        dn1 = zeros(iTT,1); dn2 = dn1;
        for i = 1 : iTT
            dn1(i) = TT(i) -  p.nsec/(2*24*60*60) ; % 2 makes shift 1/2 nsec
            dn2(i) = TT(i) +  p.nsec/(2*24*60*60) ;
        end
        
        %
        iMTT = itMTT + 1 : itMTT + iTT;
        [iMTT,~] = MTTfix(iMTT);
        [sPP,sSN,sUSN,sSP,sUSP] = GetDetEditData(dn1,dn2,iMTT,detno);
        MPP = [tMPP; sPP];
        if p.filterdata =='n'
            MSN = [tMSN; sUSN];
            MSP = [tMSP; sUSP];
        else
            MSN = [tMSN; sSN];
            MSP = [tMSP; sSP];
        end
        %sort
        [MTT,isort] = sort(MTT);
        MPP = MPP(isort);
        MSN = MSN(isort,:);
        MSP = MSP(isort,:);
        zID = zID(isort,:);
        N = find(zID(:,2)==ns);
        % noramilze
        mmMSN = max(max(MSN(N, :)));
        if mmMSN > 1
            mmMSN = 1;
        end
        g = p.gain;
        X = (MSN(N, :) - mean(MSN(N,:), 2))./mmMSN;
        figure(ns);
        [miss] = makeWaterfallPlot(X, zID(N,1), slag{1,ns}, g, fs);
        title([p.site,' Ship ', num2str(ns)])
        xlabel('Samples')
        % end loop
    end
    res = input('Import data from another site? y or n ','s');
end



ns = 1; detno = 0;
while ns > 0
    ns = input('Which Ship? (0 to end): ');
    N = find(zID(:,2)==ns); % indices of ships with label "ns"
    if ~isempty(N)
        % noramilze
        mmMSN = max(max(MSN(N, :)));
        if mmMSN > 1
            mmMSN = 1;
        end
        % take all arrivals labeled ship ns, zero mean, and normalize
        g = p.gain;
        X = (MSN(N, :) - mean(MSN(N,:), 2))./mmMSN;

        str = 't';  xh = [];  yh =[];
        while ~strcmp(str, 'n')
            % noramilze
            mmMSN = max(max(MSN(N, :)));
            if mmMSN > 1
                mmMSN = 1;
            end
            % check for duplicates
            dMTT = diff(MTT(N))*p.nsd;
            idiff = find(dMTT == 0);
            if (~isempty(idiff))
                for ndiff = 1 : length(idiff)
                    zID(N(idiff),2) = 0;
                    [slag,rellag] = CalLag(X,N,ns,slag,rellag,p.maxrlag);
                end
                N = find(zID(:,2)==ns);
                X = (MSN(N, :) - mean(MSN(N,:), 2))./mmMSN;
                dMTT = diff(MTT(N))*p.nsd;
            end
            %              sslag = size(slag)
            %             if ~exist('slag{ns}','var')
            %                 slag{1,ns} = zeros(size(N)); % absolute lag (in samples) for each signal to align w/ previous signal
            %                 rellag{1,ns} = zeros(size(N)); % lag (in samples) in relation to previous signal
            %                 slag{1,ns}(1) = 0;
            %             end

            try
                fig = figure(ns);
                [miss] = makeWaterfallPlot(X, zID(N,1), slag{1,ns}, g, fs);
                title([p.site,' Ship ', num2str(ns)])
                xlabel('Samples')
            catch
                warning('Error in plot');
            end
            str = input('''COMMAND''  \n', 's');

            switch str
                case '0' % auto calculate lags
                    recal = input('Recalculate Lags? y or n ','s');
                    hslag = slag; hrellag = rellag; % same variables
                    if (recal == 'y')
                        [slag,rellag] = CalLag(X,N,ns,slag,rellag,p.maxrlag);
                    end

                case '1'  % shift entire data set by given lag
                    shiftAmount = input('\n# of samples to shift # 1 by: ');
                    hslag = slag; hrellag = rellag;
                    for ishift = 1 : length(N) % change slag and no rellag
                        slag{1,ns}(ishift,1) =  slag{1,ns}(ishift,1) + shiftAmount;
                    end
                    figure(ns);
                    [miss] = makeWaterfallPlot(X, zID(N,1), slag{1,ns}, g, fs);

                case 'a' % add new detection
                    detno = input('\nEnter detection number to add: ');
                    if detno > 0
                        stime = input(['Time after ',num2str(detno-1),' sec:']);
                        MTT(end+1) = MTT(N(detno-1)) + stime/p.nsd;
                        zID(end+1,:) = [MTT(end),ns];
                        %
                        dnew1 = MTT(N(detno))  - p .nsec/(2*24*60*60);% , 'second');
                        dnew2 = MTT(N(detno))  + p.nsec/(2*24*60*60);% , 'second');
                        iMTT = N(detno);
                        [sPP,sSN,sUSN,sSP,sUSP] = GetDetEditData(dnew1,dnew2,iMTT,detno);
                        % move data to open spot
                        MPP(end+1) = sPP;
                        if p.filterdata =='n'
                            MSN(iMTT,1:length(sUSN)) = sUSN;
                            MSP(iMTT,1:length(sUSP)) = sUSP;
                        else
                            MSN(iMTT,1:length(sSN)) = sSN;
                            MSP(iMTT,1:length(sSP)) = sSP;
                        end
                        %sort
                        [MTT,isort] = sort(MTT);
                        zID = zID(isort,:);
                       
                        MPP = MPP(isort);
                        MSN = MSN(isort,:);
                        MSP = MSP(isort,:);

                        % make space in N, slag, reallg
                        N = find(zID(:,2)==ns);
                        slag{1,ns}(length(N),1) = 0;
                        rellag{1,ns}(length(N),1) = 0;

                        X = (MSN(N, :) - mean(MSN(N,:), 2))./mmMSN;
                        figure(ns);
                        [miss] = makeWaterfallPlot(X, zID(N,1), slag{1,ns}, g, fs);
                    end

                case 'd' % delete detection
                    detno = input('\nEnter detection number to delete: ');
                    MTT = deldetno(MTT,N(detno));
                    MPP = deldetno(MPP,N(detno));
                    MSN = deldetno(MSN,N(detno));
                    MSP = deldetno(MSP,N(detno));
                    zID = deldetno(zID,N(detno));
                    %
                    N = find(zID(:,2)==ns);
                    X = (MSN(N, :) - mean(MSN(N,:), 2))./mmMSN;
                    % delete in slag and rellag
                    slag{1,ns}(detno:end-1) = slag{1,ns}(detno+1:end);
                    slag{1,ns}(end) = [];
                    rellag{ns}(detno) = rellag{ns}(detno) + rellag{ns}(detno+1);
                    rellag{ns}(detno+1:end-1) =  rellag{ns}(detno+2:end);
                    rellag{ns}(end) = [];
                    %
                case 'g' % change plot gain
                    disp(['Current g = ',num2str(g)])
                    g = input('new g  ');

                case 'm' % move detections to another ship
                    celnums = inputdlg({'Pulses to move', 'New Group'}, 'Move', [1 50; 1 2]);
                    try
                        detno = str2num(celnums{1});
                        ngroup = str2num(celnums{2});
                        for nm = 1 : length(detno)
                            zID(N(detno(nm)),2)= ngroup;
                        end

                        N = find(zID(:,2)==ns);
                        X = (MSN(N, :) - mean(MSN(N,:), 2))./mmMSN;

                    catch
                        warning('Error on entry')
                    end

                case '>' % increase gain in waterfall
                    g = 1.5*g;
                    disp(['g = ',num2str(g)])
                    hold on
                    [miss] = makeWaterfallPlot(X, zID(N,1),  slag{1,ns}, g, fs);

                case '<' % decrease gain in waterfall
                    g = 0.75*g;
                    disp(['g = ',num2str(g)])
                    hold on
                    [miss] = makeWaterfallPlot(X, zID(N,1),  slag{1,ns}, g, fs);

                case 'e' %manually shift trace - ala Eric
                    detno = input('\nEnter misaligned detection number: ');

                    fprintf(['\nCurrent lag = ', num2str(slag{1,ns}(detno))])

                    shiftAmount = input('\n# of samples to shift by: ');
                    hslag = slag; hrellag = rellag;
                    slag{1,ns}(detno:end) = slag{1,ns}(detno:end) + shiftAmount;
                    rellag{ns}(detno) = rellag{ns}(detno) + shiftAmount;

                case 'x' % xcor shift selected data
                    %                     pic = figure(100);
                    [miss] = makeWaterfallPlot(X, zID(N,1),  slag{1,ns}, g, fs);
                    pause
                    zoom 'off'; pan 'off';
                    [~,xs,ys] = selectdataA('selectionmode','Rect');
                    hslag = slag; hrellag = rellag;
                    [slag,rellag,detno] = plalign(ns,xs,ys,slag,rellag);
                    [miss] = makeWaterfallPlot(X, zID(N,1),  slag{1,ns}, g, fs);

                case 'p' % paint to shift data
                    pic = figure(100);
                    [miss] = makeWaterfallPlot(X, zID(N,1),  slag{1,ns}, g, fs);
                    pause
                    zoom 'off'; pan 'off';

                    [~,xs,ys] = selectdataA('selectionmode','brush','BrushSize',0.01);
                    hslag = slag; hrellag = rellag;
                    [slag,rellag,detno] = brushA(ns,xs,ys,slag,rellag);
                    figure(ns);
                    [miss] = makeWaterfallPlot(X, zID(N,1),  slag{1,ns}, g, fs);

                case 'c' % click to shift data
                    pic = figure(100);
                    [miss] = makeWaterfallPlot(X, zID(N,1), slag{1,ns}, g, fs);
                    pause
                    zoom 'off'; pan 'off';
                    nmiss = 0;
                    [xs,ys] = ginput; % click points until hit return
%                     if miss > 0
%                         nmiss = input('Number of missing pulses:');
%                     end
                    hslag = slag; hrellag = rellag;
                    [slag,rellag,detno] = pickA(ns,xs,ys,slag,rellag,nmiss);
                    figure(ns);
                    [miss] = makeWaterfallPlot(X, zID(N,1), slag{1,ns}, g, fs);



                case 'R'  % Retreive data
                    res = input('Retrieve Data: y or n ','s');
                    if strcmp(res,'y')
                        % remove 0 zID
                        iS = find(zID(:,2) ~= 0);
                        MTT = MTT(iS);
                        zID = zID(iS,:);
                        %
                        [TT,MTT,zID,slag,rellag,iMTT] = findShipX(MTT,zID,slag,rellag,ns,PARAMS.fs);
                        dn1 = zeros(length(TT),1); dn2 = dn1;
                        for i = 1 : length(TT)
                            dn1(i) = TT(i) - p.nsec/(2*24*60*60) ;
                            dn2(i) = TT(i) + p.nsec/(2*24*60*60) ;
                        end
                        %
                        [sPP,sSN,sUSN,sSP,sUSP] = GetDetEditData(dn1,dn2,iMTT,detno);
                        MPP(iMTT) = sPP;
                        if p.filterdata =='n'
                            MSN(iMTT,1:length(sUSN)) = sUSN;
                            MSP(iMTT,1:length(sUSP)) = sUSP;
                        else
                            MSN(iMTT,1:length(sSN)) = sSN;
                            MSP(iMTT,1:length(sSP)) = sSP;
                        end

                        X = (MSN(N, :) - mean(MSN(N,:), 2))./mmMSN;
                        figure(ns);
                        [miss] = makeWaterfallPlot(X, zID(N,1), slag{1,ns}, g, fs);
                    end

                case 'r' % retreive single trace
                    detno = input('\nEnter first detection number to replace: ');
                    while detno > 0
                        if detno > 1
                            bdMTT = dMTT(detno -1);
                        else
                            bdMTT = 0;
                        end
                        if detno >= length(dMTT)
                            adMTT = 0;
                        else
                            adMTT = dMTT(detno);
                        end

                        fprintf(['\nCurrent ICIs = ', num2str(bdMTT),' ',num2str(adMTT)]);
                        stime = input('Shift MTT (sec) ');
                        if isempty(stime)
                            stime = 0;
                        end
                        MTT(N(detno)) = MTT(N(detno))+ stime/p.nsd;
                        zID(N(detno),1) = MTT(N(detno));
                        dnew1 = MTT(N(detno))  - p.nsec/(2*24*60*60);% , 'second');
                        dnew2 = MTT(N(detno))  + p.nsec/(2*24*60*60);% , 'second');
                        iMTT = N(detno);
                        [sPP,sSN,sUSN,sSP,sUSP] = GetDetEditData(dnew1,dnew2,iMTT,detno);
                        MPP(iMTT) = sPP;
                        USN(iMTT,:) = sUSN;
                        USP(iMTT,:) = sUSP;
                        SN(iMTT,:) = sSN;
                        SP(iMTT,:) = sSP;
                        if p.filterdata =='n'
                            MSN(iMTT,1:length(sUSN)) = sUSN;
                            MSP(iMTT,1:length(sUSP)) = sUSP;
                        else
                            MSN(iMTT,1:length(sSN)) = sSN;
                            MSP(iMTT,1:length(sSP)) = sSP;
                        end

                        X = (MSN(N, :) - mean(MSN(N,:), 2))./mmMSN;
                        figure(ns);
                        [miss] = makeWaterfallPlot(X, zID(N,1), slag{1,ns}, g, fs);

                        nex = input(['Next Before -' ...
                            ' or After + '],'s');
                        if nex == '-'
                            detno = detno -1;
                        elseif  nex == '+'
                            detno = detno + 1;
                        else
                            detno = 0;
                        end
                    end

                case 'f' % turn filtering on or off
                    p.filterdata = input('Filter Data? y or n ','s');
                    [TT,MTT,zID,slag,rellag,iMTT] = findShipX(MTT,zID,slag,rellag,ns,PARAMS.fs);
                    dn1 = zeros(length(TT),1); dn2 = dn1;
                    for i = 1 : length(TT)
                        dn1(i) = TT(i) - p.nsec/(2*24*60*60) ;
                        dn2(i) = TT(i) + p.nsec/(2*24*60*60) ;
                    end
                    %
                    [sPP,sSN,sUSN,sSP,sUSP] = GetDetEditData(dn1,dn2,iMTT,detno);
                    MPP(iMTT) = sPP;
                    if p.filterdata =='n'
                        MSN(iMTT,1:length(sUSN)) = sUSN;
                        MSP(iMTT,1:length(sUSP)) = sUSP;
                    else
                        MSN(iMTT,1:length(sSN)) = sSN;
                        MSP(iMTT,1:length(sSP)) = sSP;
                    end

                    X = (MSN(N, :) - mean(MSN(N,:), 2))./mmMSN;
                    figure(ns);
                    [miss] = makeWaterfallPlot(X, zID(N,1), slag{1,ns}, g, fs);

                case 'u' % undo last change
                    if exist('hslag','var')
                        slag = hslag; rellag = hrellag;
                        figure(ns);
                        [miss] = makeWaterfallPlot(X, zID(N,1), slag{1,ns}, g, fs);
                    else
                        disp('Cannot Undo')
                    end

                case 's' % save data to fout
                    % if (~exist('SN','var') && p.filterdata == 'n')
                   if (~exist('SN','var') )
                        SN = FtheData(MSN);
                        SP = StheData(SN);
                        USN = MSN;
                        USP = MSP;
                    end
                    save(fout, 'MTT','MPP','MSN','SN','USN','MSP','SP','USP','zID','slag','rellag')

            end

        end

        if strcmp(str, 'q')
            break
        end

    end
% 
%     if strcmp(str, 'q')
%         break
%     end
    ifg = cell(1,NS); % remove extra or add slag entries
    for i = ns
        if ns > 0
            ifg{i} = find(zID(:,2) == i);
            lslag =length(slag{1,i});
            lifg = length(ifg{i});
            if  lslag >= lifg
                slag{1,i} = slag{1,i}(1:length(ifg{1,i}));
                rellag{1,i} = rellag{1,i}(1:length(ifg{1,i}));
            else
                slag{1,i}(lslag+1 : lifg) = 0;
                rellag{1,i}(lslag+1 : lifg) = 0;
            end
        end
    end
    if ~exist('SN','var')
        SN = FtheData(MSN);
        SP = StheData(SN);
        USN = MSN;
        USP = MSP;
    end
    save(fout, 'MTT','MPP','MSN','SN','USN','MSP','SP','USP','zID','slag','rellag')
    if ns > 0 % not on exit
        fold =  [p.outRC,p.site,'_Realign'];
        fmiddle = [p.Year,p.Month,p.Day,'\',p.Hour];
        figna = fullfile(fold,fmiddle,['Figure',num2str(ns)]);
        disp(['Save Figure',num2str(ns)])
        savefig(figna)
    end
end
%

