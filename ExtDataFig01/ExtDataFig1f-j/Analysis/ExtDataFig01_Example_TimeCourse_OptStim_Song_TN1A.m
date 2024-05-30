function [] = ExtDataFig01_Example_TimeCourse_OptStim_Song_TN1A

% TargetFileID = 2;
load('../Data/Summary/Mic_20211129_02_3.mat')
load('../Data/Summary/OptStim_20211129_02.mat')
TargetTrial = 1; % 4-2, 3-1, 3-5

load('../Data/Summary/EthogramComb_dPR1_Chr.mat')

%% parameters
nStim = 6;

RecDur = 1320; % 1320 s = 22 min
DAQrate = 5000;

%%
TargetStim = 3;
trial = TargetTrial;

figure('Position',[100,100,95,95])
hold on
Target_Range = [6000:2:7500]/2+Opt_onset(TargetStim+(trial-1)*nStim)+0;
plot(DataMic_NoiseRemoved(Target_Range),'k','LineWidth',.25)
pbaspect([4,1,1])
axis off

figure('Position',[100,100,90,90])
hold on
Target_Range = [-2:1/DAQrate:12]*DAQrate+Opt_onset(TargetStim+(trial-1)*nStim)+0;
plot(DataMic_NoiseRemoved(Target_Range),'k','LineWidth',.25)
plot([0 5000],[1 1]*(-0.05),'k','LineWidth',1)
plot([10001,60001],[1,1]*.05,'r','LineWidth',2)
plot([13000,13750],[1 1]*(-0.05),'k','LineWidth',1)
pbaspect([1,1,1])
axis off
