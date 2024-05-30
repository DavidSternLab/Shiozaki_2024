function [] = ExtDataFig01_Example_TimeCourse_OptStim_Song_dPR1
% Code for plotting the example song trace during optogenetic stimulation in Extended Data Fig. 1f.

% TargetFileID = 6;
load('../Data/Summary/Mic_20211228_01_2.mat')
load('../Data/Summary/OptStim_20211228_01.mat')
TargetTrial = 2; % 4-5, 3-2

load('../Data/Summary/EthogramComb_dPR1_Chr.mat')

%% parameters
nStim = 6;

RecDur = 1320; % 1320 s = 22 min
DAQrate = 5000;

%%
TargetStim = 3; %4

trial = TargetTrial;

figure('Position',[100,100,90,90])
hold on
Target_Range = [2900:3650]+Opt_onset(TargetStim+(trial-1)*nStim)+0;
plot(DataMic_NoiseRemoved(Target_Range),'k','LineWidth',.25)
pbaspect([4,1,1])
axis off

figure('Position',[100,100,90,90])
hold on
Target_Range = [-2:1/DAQrate:12]*DAQrate+Opt_onset(TargetStim+(trial-1)*nStim)+0;
plot(DataMic_NoiseRemoved(Target_Range),'k','LineWidth',.25)
plot([0 5000],[1 1]*(-0.2),'k','LineWidth',1)
plot([10001,60001],[1,1]*.35,'r','LineWidth',2)
plot([12900,13650],[1 1]*(-0.2),'k','LineWidth',1)
pbaspect([1,1,1])
axis off
