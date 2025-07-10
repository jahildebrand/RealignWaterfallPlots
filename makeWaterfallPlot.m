function [miss] = makeWaterfallPlot(X, tstamp, slag, g, fs)
% Make waterfall plot of signals in X, associated with timestamp tstamp,
% shifted by lag defined in slag. fs is sample rate. 
% associated with 0 line on plot (i.e. first time stamp in data)
% THIS IS DESIGNED TO HAVE SCALE IN SAMPLES FOR EASE OF ADJUSTMENT
% OF THE LAGS
% set(gca,'NextPlot','replacechildren')
% set(axes,'YLimMode','manual')
tdefault = 1:1:size(X, 2);
% mmx = max(max(X));
X = g*X;
% slag(1) = 0;
tst0 = tstamp(1) - slag(1)/(fs*24*60*60); 
for n = 1:size(X,1)
    
    t = tdefault + slag(n); %  all in samples
    tst = tstamp(n) - slag(n)/(fs*24*60*60); %
    yshift = (tst-tst0)*6e3;
    yt(size(X,1) - n + 1) = -yshift;
    dateout = newdatstr(tst,n);
    ytl{size(X,1) - n + 1} = dateout;
    plot(t, X(n,:)-yshift, 'k')
    hold on
end
% test for missing pulse
miss = round((0.5 + yshift/4.45) - n +1);
hold off
xlabel('SAMPLES')
ylabel('Normalized Amplitude')
yticklabels(ytl)
yticks(yt)
grid on
ylim([-(tstamp(end) - tst0)*6e3 - 1, 1])
