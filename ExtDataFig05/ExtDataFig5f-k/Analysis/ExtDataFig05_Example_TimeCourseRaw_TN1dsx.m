function [] = ExtDataFig05_Example_TimeCourseRaw_TN1dsx()
% Code for plotting the time courses of delta F/F for TN1 neurons and simultaneously recorded song in Extended Data Fig. 5f.

GT = 'TN1dsx';

Target_FileID = 5;
Target_ROI = 1;
Target_Trial = 3;
FileID = Target_FileID;
Target_WithinTrialID = 4; % 4-4
TargetMic = 1;

Xrange = [44 58];

%% parameters
RecDur = 190;
DownSampleRate = 10;

nTrials = 3;
nStim = 6;
T = 1370; % T
DAQrate = 10000;
x1 = [0:1/DAQrate:190-1/DAQrate];

PreEventImg = 72; % 10 s (71.0443)
OneTrialDur = 214; % 30 s (213.1329)

Words = [{'pulse'},{'sine'},{'flight'},{'other'},{'ambient'},{'ipi'}];

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb']) % FileID,nROIs,T,nTrials
load([selpath,'EthogramComb']) % FileID,T,nTrials (1: pulse, 2: sine)
load([selpath,'EthogramCombImg']) % FileID,T,nTrials (1: pulse, 2: sine)
load([selpath,'ResponseIndex']) 
load('TS_Img')
load('TS_OptStimImg')

%%
F_comb = F_comb{Target_FileID};
F_comb_DFF = zeros(size(F_comb,1),size(F_comb,2));

nROIs = size(F_comb,1);
figure('Position',[100,100,150,150])
for Target_ROI=1:nROIs
    trial = Target_Trial;
    bufEtho = squeeze(Ethogram_comb_Img(Target_FileID,4,:,:));
    buf = squeeze(F_comb(Target_ROI,:,:));
    bufF = [];
    for i=1:length(OptStimOnset_Img)
        for trial=1:nTrials
            bufFlight = bufEtho([-PreEventImg:0]+OptStimOnset_Img(i)-1,trial);
            if sum(bufFlight)==0
                bufF = [bufF,buf([-PreEventImg:0]+OptStimOnset_Img(i)-1,trial)];
            end
        end
    end
    F = mean(bufF(:));
    DFF = (buf-F)/F;
    
    trial = Target_Trial;
    
    bufF = DFF(:,trial);
    bufEtho = Ethogram_comb(Target_FileID,:,trial);
    F_comb_DFF(Target_ROI,:) = bufF;
    
    subplot(3,1,2)
    hold on
    plot(TS_Img,bufF,'k','LineWidth',.5)
    xlim(Xrange)
    plot([Xrange(1)+1,Xrange(2)],[3 3],'r','LineWidth',1)
    plot([1 1]*Xrange(1),[0 1],'k','LineWidth',1)
    plot([0 .5]+Xrange(1),[0 0],'k','LineWidth',1)
    axis off
end


subplot(3,1,1)
hold on
plot(x1(bufEtho==1),bufEtho(bufEtho==1),'r.','MarkerSize',.1)
plot(x1(bufEtho==2),bufEtho(bufEtho==2),'b.','MarkerSize',.1)
xlim(Xrange)
axis off

%%
DAQrate = 10000;
x1 = [0:1/DAQrate:190*nTrials-1/DAQrate];
EthogramRate = 625;
x2 = [0:1/EthogramRate:(712485-1)*(1/EthogramRate)]; % 712485 samples
UpSampleRate = 16;
x2_up = UpsampleData(x2,UpSampleRate);
x1(length(x2_up)+1:end) = [];

FileNames_wav = dir(['../Data/Summary_',GT,'/SongExplorer/',num2str(FileID,'groundtruth-data-%02i'),'/MicStereo/*.wav']);
RmvFlag = zeros(size(FileNames_wav,1),1);
for i=1:length(RmvFlag)
    buf = FileNames_wav(i).name;
    if length(buf)~=29
        RmvFlag(i) = 1;
    end
end
FileNames_wav(RmvFlag==1) = [];
FileNames{1} = FileNames_wav;
for word=1:length(Words)
    FileNames{1+word} = dir(['../Data/Summary_',GT,'/SongExplorer/',num2str(FileID,'groundtruth-data-%02i'),'/MicStereo/*',Words{word},'.wav']);
end

buf = FileNames{1};
[y,Fs] = audioread( [buf.folder,'/',buf.name]);
data_wav = y;
data_wav(length(x2_up)+1:end,:) = [];

x1_comb = [0:1/DAQrate:190*6-1/DAQrate];
TargetRange = find((Target_Trial-1)*190+Xrange(1)<=x1_comb&x1_comb<(Target_Trial-1)*190+Xrange(2));
Target_data_wav = data_wav(TargetRange,TargetMic);

subplot(3,1,3)
plot(x1(1:length(Target_data_wav)),Target_data_wav,'k','LineWidth',.25)
xlim([x1(1),x1(length(Target_data_wav))])
axis off

%% main loop
prediction = Ethogram_comb(FileID,:,trial);

figure('Position',[100,100,150,150])
subplot(3,1,3)
hold on

% Ethogram
TargetRange = find(Xrange(1)+(trial-1)*RecDur<=x1&x1<Xrange(2)+(trial-1)*RecDur);

% prediction
Target_prediction = prediction(find(Xrange(1)<=x1&x1<Xrange(2)));

buf = data_wav(TargetRange,TargetMic)*5+0.5;

TargetRange = downsample(TargetRange,DownSampleRate);
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

xlim([0,14]/DownSampleRate)
axis off

%% heatmap
bufRange = [314,344];
buf = mean(F_comb_DFF(:,bufRange),2);
[B,I] = sort(buf);
PlotOrder = flipud(I);
bufRange = [314,413];
figure('Position',[100,100,150,150])
subplot(3,1,1)
imagesc(F_comb_DFF(PlotOrder,:),[-1,5])
xlim([314,413])
axis off
colorbar

function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
