function [PP,SN,USN,SP,USP] = GetDetEditDataX(dn1,dn2,iMTT,detno)
% READ raw data from XWav file and make Det Edit Data
% uses timing for each 'raw'file within Xwav
% can read multiple snippets based on the
% number of iMTT
%JAH 3-2022
global PARAMS p
fname = fullfile(PARAMS.inpath,PARAMS.infile);
dnumStart = PARAMS.raw.dnumStart;
dnumEnd = PARAMS.raw.dnumEnd;
byte_loc = PARAMS.xhd.byte_loc;
byte_length = PARAMS.xhd.byte_length;

% spectra parameters
durt = p.nsec; % sec
fs = PARAMS.fs;
durs = durt * fs; % number samples for snippet
nfft = durs;
window = hanning(nfft);
overlap = p.overlap;
noverlap = round((overlap/100)*nfft);
%
PP = [];    % pp [dB re counts] of detected pulse
SN = [];    % snippet timeseries of each detection
SP = [];    % spectra of each detection
USN = [];   % unfiltered snippet
USP = [];   % unfiltered spectra
%
for n = 1:length(iMTT)
    %     k = iMTT(n);
    ta = dn1(n) - datenum([2000 0 0 0 0 0]);
    tb = dn2(n) - datenum([2000 0 0 0 0 0]);
    %     dname = char(fd(k));
    %     dname = [char(drl(k)),char(fd(k))];
    if length(iMTT) > 1
        disp(['Event ',num2str(n),'  ',datestr(ta,31),'  ',datestr(tb,31)])
    else
        disp(['Event ',num2str(detno),'  ',datestr(ta,31),'  ',datestr(tb,31)])
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % find raw files during time period (clicking bout)
    %     I = find(ta <= dnumStart & tb > dnumStart);
    I = [];
    Ia = find(dnumStart <= ta  ,1,'last');
    Ib = find(dnumStart > tb  ,1,'first');
    I = [Ia , Ib-1];
    I = unique(I);
    if isempty(I)
        disp('Error: times not in file ')
        return
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %[Data,fData] = GetDat(I,fname,byte_loc,byte_length,ir,fa,fs);
    [Data] = GetDat(I,fname,byte_loc,byte_length);
    % Data = [];
    % for im = 1: length(I)
    %     Data = [Data, gData(im,:)];
    % end
    sData = size(Data);
    if sData(1) > 1
        Data = reshape(Data.', 1, []);
    end
    lData = length(Data);
    datastart = dnumStart(I(1)); dataend = dnumStart(I(end)+1);
    t = linspace(datastart, dataend, lData);
    id = find(ta <= t & tb >= t);
    lid = length(id);
    while lid ~= durs
        if lid < durs
            next_id = id(end) + 1;
            if next_id > lData
                warning('Cannot extend id: would exceed data length (%d)', lData);
                break
            end
            id = [id, next_id];
        elseif lid > durs
            id(end) = [];
        end
    end

    % Trim or pad id to exactly match durs
    if length(id) < durs
        needed = durs - length(id);
        last_idx = id(end);

        % Try extending using valid indices from Data
        extra_idx = (last_idx+1):(last_idx+needed);
        extra_idx(extra_idx > length(Data)) = [];  % trim if beyond data

        id = [id, extra_idx];

        % If still short, pad with last value or mean
        if length(id) < durs
            pad_vals = repmat(last_idx, 1, durs - length(id));  % repeat last valid index
            id = [id, pad_vals];
        end
    elseif length(id) > durs
        id = id(1:durs);
    end

    % Now safe to index
    fData = FtheData(Data);
    SN(n,:) = fData(id);  % id now has length durs

    USN(n,:) = Data(id);
    [SP(n,:),f] = pwelch(SN(n,:),window,noverlap,nfft,fs);
    [USP(n,:),f] = pwelch(USN(n,:),window,noverlap,nfft,fs);
    PP(n,1) = max(SN(n,:)) - min(SN(n,:));
end
