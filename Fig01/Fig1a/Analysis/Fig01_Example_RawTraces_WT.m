function [] = Fig01_Example_RawTraces_WT
% Fig01_Example_RawTraces_WT.m: Code for plotting the example song trace in Fig. 1a.

load('Mic_20210923_02_1.mat')

%% parameters
RecDur = 1320; % 1320 s = 22 min
DAQrate = 5000;

%%
Target_Range = [0:5000*6.15]+5757000; % 6.15 s

figure('Position',[100,100,180,180])
hold on
plot(DataMic_NoiseRemoved(Target_Range),'k','LineWidth',.25)
plot([0 5000/2],[1 1]*(-0.1),'k','LineWidth',1) % 0.5 s time scale bar
plot([5000*1.87,5000*2.02],[1 1]*(-0.1),'k','LineWidth',1) % 0.15 s window
plot([5000*3.44,5000*3.59],[1 1]*(-0.1),'k','LineWidth',1) % 0.15 s window
pbaspect([2,1,1])
axis off

figure('Position',[100,100,90,90])
hold on
plot(DataMic_NoiseRemoved(Target_Range([5000*1.87:5000*2.02])),'k','LineWidth',.25)
pbaspect([4,1,1])
axis off

figure('Position',[100,100,90,90])
hold on
plot(DataMic_NoiseRemoved(Target_Range([5000*3.44:5000*3.59])),'k','LineWidth',.25)
pbaspect([4,1,1])
axis off