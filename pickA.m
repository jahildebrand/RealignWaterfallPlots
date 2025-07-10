function [slag,rellag,detno] = pickA(ns,xs,ys,slag,rellag,nmiss)
% pick arrivals
% ns is which ship, N is number of detections for that ship
detno = round(0.5-ys/4.45); % based on scale of plot NEEDS MOD for other plots
[udet,id] = unique(detno);
check = 'n';
nmiss = 0;
while check == 'n'
    check = input(['First pulse ',num2str(detno(1) - nmiss), ' y or n '],'s');
    if check == 'n'
        nmiss = input('Number to remove: ');
    end
end
detno = udet - nmiss;
xs = xs(id);  ys = ys(id);
% leave top trace alone , shifts others
sslag = size(slag{1,ns});
if (length(detno) > 1)
    detnomax = detno(1) + length(detno) -1;
    if detnomax <= sslag(1)
        detno = detno(1) : detnomax;
        for n = 1 : length(detno) -1
            shift = round(xs(n) - xs(n+1));
            disp(['detno ',num2str(detno(n+1)),' shift ',num2str(shift)]);
            %     hold off
            rellag{1,ns}(detno(n+1)) = rellag{1,ns}(detno(n+1)) + shift;
            slag{1,ns}(detno(n+1):end) = slag{1,ns}(detno(n+1):end) + shift;

            %           slag{ns}(detno:end) = slag{ns}(detno:end) + shiftAmount;
            %                     rellag{ns}(detno) = rellag{ns}(detno) + shiftAmount;
        end
    else
        disp('Exceeds array size')
    end
end