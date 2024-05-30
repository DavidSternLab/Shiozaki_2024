function [] = ExtDataFig03_Example_TimeCourseRaw_dPR1_all()
% Code for plotting example traces for dPR1 ΔF/F in Extended Data Fig. 3b.

GT = 'dPR1';

Target_FileID = 2;
Target_Trial = 6;
FileID = Target_FileID;

%% parameters
Thre_pulse = 0.1;
Thre_sine = 0.6;

RecDur = 190;
DownSampleRate = 10;

nTrials = 6;
nStim = 6;
T = 1370; % T
DAQrate = 10000;
x1 = [0:1/DAQrate:190-1/DAQrate];

switch GT
    case 'dPR1'
        nROIs = 2;
end

PreEventImg = 72; % 10 s (71.0443)
OneTrialDur = 214; % 30 s (213.1329)

Words = [{'pulse'},{'sine'},{'flight'},{'other'},{'ambient'},{'ipi'}];

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb']) % FileID,nROIs,T,nTrials
load([selpath,'EthogramComb']) % FileID,T,nTrials (1: pulse, 2: sine)
load([selpath,'EthogramCombImg']) % FileID,T,nTrials (1: pulse, 2: sine)
load('TS_Img')
load('TS_OptStimImg')
CellFlag = readmatrix([selpath,'Dataset.csv']);
CellFlag(:,1) = [];

%%
F_comb = F_comb{Target_FileID};

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
    
    subplot(3,1,2)
    hold on
    plot(TS_Img,bufF,'k','LineWidth',.5)
    xlim([14 23])
    plot([15 23],[3 3],'r','LineWidth',1)
    plot([14 14],[0 1],'k','LineWidth',1)
    plot([14 14.5],[0 0],'k','LineWidth',1)
    axis off
end

subplot(3,1,1)
hold on
plot(downsample(x1(bufEtho==1),DownSampleRate),downsample(bufEtho(bufEtho==1),DownSampleRate),'r.','MarkerSize',.1)
plot(downsample(x1(bufEtho==2),DownSampleRate),downsample(bufEtho(bufEtho==2),DownSampleRate),'b.','MarkerSize',.1)
xlim([14 23])
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
TargetRange = find(964<=x1_comb&x1_comb<973);
Target_data_wav = data_wav(TargetRange,1);

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
TargetRange = find(14+(trial-1)*RecDur<=x1&x1<23+(trial-1)*RecDur);

% prediction
Target_prediction = prediction(find(14<=x1&x1<23));

buf = data_wav(TargetRange,1)*5+0.5;

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

xlim([0 9]/DownSampleRate)
axis off

function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
