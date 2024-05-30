function [] = Fig02_Example_TimeCourse_OptStim_Song_pIP10L
% Code for plotting the example trace during optogenetic activation of the pIP10 split-LexA in isolated male flies in Fig. 2b.

TargetFileID = 11;
load('Mic_20211103_01_4.mat')
load('OptStim_20211103_01.mat')
TargetTrial = 1;

load('EthogramComb_pIP10L_Chr.mat')

%% parameters
nStim = 6;

RecDur = 1320; % 1320 s = 22 min
DAQrate = 5000;

%%
TargetStim = 6;

trial = TargetTrial;

figure('Position',[100,100,90,90])
hold on
Target_Range = [-2:1/DAQrate:12]*DAQrate+Opt_onset(TargetStim+(trial-1)*nStim)+0;
plot(DataMic_NoiseRemoved(Target_Range),'k','LineWidth',.25)
plot([0 5000],[1 1]*(-0.2),'k','LineWidth',1)
% plot([-1250,3750]+10000,[1 1]*(-0.2),'g','LineWidth',1)
plot([10001,60001],[1,1]*.35,'r','LineWidth',2)
plot([11900,12650],[1 1]*(-0.2),'g','LineWidth',1)
pbaspect([1,1,1])
axis off

figure('Position',[100,100,90,90])
hold on
plot(DataMic_NoiseRemoved([911019:911769]),'k','LineWidth',.25)
pbaspect([4,1,1])
axis off

