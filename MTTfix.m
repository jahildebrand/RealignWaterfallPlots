function [MTTout,imtt] = MTTfix(MTT)
% make MTT be Nx1
smtt = size(MTT);
[MTT,imtt] = sort(MTT);
if smtt(1) < smtt(2)
    MTTout = MTT';
else 
    MTTout = MTT;
end