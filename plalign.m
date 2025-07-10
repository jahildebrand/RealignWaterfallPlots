function [slag,rellag,detno] = plalign(ns,xs,ys,slag,rellag)
lpl = length(xs); lyn = []; detno = [];
xnew = cell(lpl,1);
ynew = cell(lpl,1);

for i =  1: lpl % switch the order and count
    if ~isempty(xs{lpl+1-i,1})
     xnew{i,1} = xs{lpl+1-i,1};
     ynew{i,1} = ys{lpl+1-i,1};
     lyn(i) = length(ynew{i,1});
     detno = [detno,i];
    end
end
% leave top trace alone , shifts others
for n = detno(2) : detno(end)-2
    if (length(ynew{n,1}) > 10)
        [xc, lags] = xcov(ynew{n+1,1},ynew{n,1});
             figure(101);
             plot(lags, xc)
             hold on
        [pks, locs] = findpeaks(xc, 'NPeaks', 1, 'SortStr', 'descend');
        %     stem(lags(locs), pks)
            disp(['detno ',num2str(n+1),' shift',num2str(lags(locs))]);
        %     hold off
        rellag{1,ns}(n+1) = rellag{1,ns}(n+1) - lags(locs);
        slag{1,ns}(n+1:end) = slag{1,ns}(n+1:end) - lags(locs);
        
    end
end              
  