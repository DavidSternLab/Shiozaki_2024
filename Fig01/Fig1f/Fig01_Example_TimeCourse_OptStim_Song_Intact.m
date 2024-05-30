function [] = Fig01_Example_TimeCourse_OptStim_Song_Intact
% Code for plotting the example song trace during optogenetic stimulation of the song driver in Fig. 1f.

TargetFileID = 7;
load('Mic_20210318_01.mat')
load('EthogramComb')

TargetTrial = 6;
TargetStim = 5;

DAQrate = 10000;
Opt_onset = [5+10:30:5+10+5*30]*DAQrate+1;

DownSampleRate = 10;
x1 = [0:1/DAQrate:190-1/DAQrate];

Target_Range_org = [-2*DAQrate+1:12*DAQrate]+Opt_onset(TargetStim)+0;
TargetData = MicL_NoiseRemoved(:,TargetTrial);

Ethogram = Ethogram_comb(TargetFileID,:,TargetTrial);

%% plot
figure('Position',[100,100,180,180])
hold on
plot(TargetData(Target_Range_org),'k','LineWidth',.25)
plot([0,1]*DAQrate,[1 1]*(-10),'k','LineWidth',1)
plot([2,12]*DAQrate,[1,1]*20,'r','LineWidth',2)
plot([1,1500]+3.385*DAQrate,[1 1]*(-10),'k','LineWidth',1)
plot([1,1500]+7.001*DAQrate,[1 1]*(-10),'k','LineWidth',1)
pbaspect([2,1,1])
axis off

figure('Position',[100,100,180,180])
hold on
Target_prediction = Ethogram(Target_Range_org);
buf = MicL_NoiseRemoved(Target_Range_org,TargetTrial);

TargetRange = downsample(Target_Range_org,DownSampleRate);
Target_prediction = downsample(Target_prediction,DownSampleRate);
buf = downsample(buf,DownSampleRate);

ChangePoints = find(diff(Target_prediction)~=0);
switch Target_prediction(1)
    case 0
        linecolor = [.5 .5 .5];
    case 1
        linecolor = 'r';
    case 2
        linecolor = 'b';
    case 3
        linecolor = 'k';
end
plot(x1(1:ChangePoints(1)),buf(1:ChangePoints(1)),'Color',linecolor,'LineWidth',.25);
for i=1:length(ChangePoints)-1
    switch Target_prediction(ChangePoints(i)+1)
        case 0
            linecolor = [.5 .5 .5];
        case 1
            linecolor = 'r';
        case 2
            linecolor = 'b';
        case 3
            linecolor = 'k';
    end
    plot(x1(ChangePoints(i):ChangePoints(i+1)),buf(ChangePoints(i):ChangePoints(i+1)),'Color',linecolor,'LineWidth',.25);
end
switch Target_prediction(ChangePoints(end)+1)
    case 0
        linecolor = [.5 .5 .5];
    case 1
        linecolor = 'r';
    case 2
        linecolor = 'b';
    case 3
        linecolor = 'k';
end
plot(x1(ChangePoints(end):length(Target_prediction)),buf(ChangePoints(end):end),'Color',linecolor,'LineWidth',.25);

pbaspect([2,1,1])
axis off


figure('Position',[100,100,90,90])
hold on
plot(TargetData(Target_Range_org([1:1500]+3.385*DAQrate)),'k','LineWidth',.25)
pbaspect([4,1,1])
axis off

figure('Position',[100,100,90,90])
hold on
plot(TargetData(Target_Range_org([1:1500]+7.001*DAQrate)),'k','LineWidth',.25)
pbaspect([4,1,1])
axis off
