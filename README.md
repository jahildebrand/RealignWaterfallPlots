# RealignWaterfallPlots
Precisely align the pulse selections of RainbowClick using a Waterfall Plot

RealignWaterfallPlots 
JAH began 2021; on github 2025
code used to more precisely align the pulse selections of RainbowClick

1)	start by moving the DE file from RCout folder to a “Realign” folder the top level is
site¬Realign, subfolder YEARMNDY, subfolder HR, 
within this keep the original _de file and make a copy _deC, the later will be modified, the former is a backup in case of problems with the modification
2)	Two parameter files are now needed; a) the getRCParams that you used for Rainbow click and b) getLOCParams that will also be used for localization
The time of the analysis in the getRCParms file should be adjusted to reflect the name of the de file – which refers to the last time of the analysis, so it will be necessary to change at least params.Hour, params.Min and Params.Sec.  If you haven’t already, make sure that there is a link to a HARP data summary xls sheet under params.hdatasum.
3)	Run RealignWaterfallPlots and you must verify the working site (y or n) and the name of the x.wav file to be used (y or n). The next question is whether you will work on aligning the DE data already in the file, or import timing data from another site (y or n).   if using another site as the model – move the DE file from the already analyzed site and then change the name to reflect the site that is being analyzed.  You may need to create a new subfolder as per 1) above. The program will make an estimate of the tie shift required to apply the imported timing to the new site.  You can accept the estimate or enter another value, along with the value for slope (compensates for the direction the ship is moving relative to the site).  You will know that the values for time shift and slope are correct when a well aligned (but not perfect) plot appears.  After you are satisfied with the imported data proceed to step 4).
4)	Goal is to align first brake with 6000 sample point
MSN is 8 sec long = 16000 samples at 2kHz or 40000 at 5 kHz
MTT is the time in the middle = 4 sec of MSN (det Edit convention). But the picks are at 3 sec rather than in the middle at 4 sec.> 
Note that the first arrival for ranges < 50 km may be the Array element localization signal at ~800 Hz
5)	When you are done with one ship, the ‘n’ command will allow you to select the next ship for alignment. If another import is needed, exit the program by typing ship 0. Then go back to step 3).

Alignment Command Cheat Sheet:
0 – auto - calculate offsets by Xcorrelation for the entire dataset
1 – shift the entire dataset by specificed number of samples
a – add a new detection [#, time after in sec]
d - delete a detection
m – move detection to another ship
> - increase gain on plot
< - decrease gain on plot
e - manually align a single trace - ala Eric
g – set amplitude on plot
x – xcor a section of data - after x, select window for picking and then hit space bar
p – paint to align data
c – click to align data
I - import time from another site
R – retrieve new data aligned to 0
r- retrieve data for one trace with specified shift – next before – or after +
f – filter data
s - save data
u - undo last change
n – next ship (first step to exiting program)
v - make velocity plot




