function [] = Fig04_Example_TimeCourseRaw_frames_nsybD()
% Code for plotting example frames in Fig. 4c.

GT = 'nsybD';

Target_FileID = 10;
Target_Trial = 1;
FileID = Target_FileID;

Periods = [1170:1173]; % Pre
Periods = [Periods;[1189:1192]]; % Pulse 1
Periods = [Periods;[1196:1199]]; % Sine 1
Periods = [Periods;[1202:1205]]; % Pulse 2
Periods = [Periods;[1210:1213]]; % Sine 2
Periods = [Periods;[1215:1218]]; % Pulse 3

AveZRange = [2:9];

%% parameters
nTrials = 6;
nStim = 6;
T = 1370; % T
d1DS = 128;
d2DS = 128;
d3 = 10;
DAQrate = 10000;
x1 = [0:1/DAQrate:190-1/DAQrate];

PreEventImg = 72; % 10 s (71.0443)
OneTrialDur = 214; % 30 s (213.1329)

Thre_F = 50;

RecDur = 190;
DownSampleRate = 10;

GaussSD = 1;

Words = [{'pulse'},{'sine'},{'flight'},{'other'},{'ambient'},{'ipi'}];

%% get file names
selpath = ['../Data/Summary_',GT,i'/'];
load([selpath,'EthogramComb'])
load([selpath,'EthogramCombImg'])
% load([selpath,'PopResp_PCA_single'])
load('TS_Img')
load('TS_OptStimImg')
load([selpath,'ResponseIndex'])
DirNamesF2d = dir([selpath,'F2d*']);
load([selpath,'StimComb'])
Stim_comb_org = Stim_comb;

%%
filename = 'F2d_20220126_02.mat'; %DirNamesF2d(FileID).name;
load([selpath,filename])
Stim_comb = Stim_comb_org{FileID};

F_count = 0;
bufEtho = squeeze(Ethogram_comb_Img(Target_FileID,4,:,:));
F = zeros(d1DS,d2DS,d3);
RmvTrials = zeros(nStim,nTrials);
for trial=1:nTrials
    for stim=1:nStim
        ID = find(Stim_comb(:,trial)==stim);
        bufFlight = bufEtho([1:OneTrialDur]+OptStimOnset_Img(ID)-PreEventImg-1,trial);
        if sum(bufFlight)==0
            Pre = mean(bufComb_F(:,:,:,[-PreEventImg:0]+OptStimOnset_Img(ID)-1,trial),4);
            F = F + Pre;
            F_count = F_count + 1;
        end
    end
end
F = F/F_count;
DFF_2 = (bufComb_F-F)./F;

DFF = bufComb_F;
clear bufComb_F

trial = Target_Trial;

bufF = DFF(:,:,AveZRange,:,trial);
bufDFF = DFF_2(:,:,AveZRange,:,trial);
bufEtho = Ethogram_comb(Target_FileID,:,trial);

figure('Position',[100,100,150,150])
subplot(3,1,1)
hold on
plot(downsample(x1(bufEtho==1),DownSampleRate),downsample(bufEtho(bufEtho==1),DownSampleRate),'r.','MarkerSize',.1)
plot(downsample(x1(bufEtho==2),DownSampleRate),downsample(bufEtho(bufEtho==2),DownSampleRate),'b.','MarkerSize',.1)
plot(164+[1,10],[4,4],'r-')
plot(164+[0,.5],[2,2],'k-')
for i=1:size(Periods,1)
    plot([TS_Img(Periods(i,1)),TS_Img(Periods(i,end))],[0,0],'g')
end
xlim([164 173])
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
TargetRange = find(164<=x1&x1<173); % 73 88
Target_data_wav = data_wav(TargetRange,1);

subplot(3,1,3)
hold on
plot(x1(1:length(Target_data_wav)),Target_data_wav,'k','LineWidth',.25)
xlim([x1(1),x1(length(Target_data_wav))])
axis off

%% ethogram
prediction = Ethogram_comb(FileID,:,trial);

figure('Position',[100,100,150,150])
subplot(3,1,3)
hold on

% Ethogram
TargetRange = find(164+(trial-1)*RecDur<=x1&x1<173+(trial-1)*RecDur);

% prediction
Target_prediction = prediction(find(164<=x1&x1<173));

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

%% frames
DataPixels = zeros(size(Img_Mean));
DataPixels(Img_Mean>=Thre_F) = 1;
DataPixels = DataPixels(:,:,AveZRange);

% F
bufFrame = zeros(d1DS,d2DS,size(Periods,1));
for i=1:size(Periods,1)
    for x=1:d1DS
        for y=1:d2DS
            if sum(DataPixels(x,y,:)==1)>1
                bufFrame(x,y,i) = mean(mean(bufF(x,y,DataPixels(x,y,:)==1,Periods(i,:)),4),3);
            elseif sum(DataPixels(x,y,:)==1)==1
                bufFrame(x,y,i) = mean(bufF(x,y,DataPixels(x,y,:)==1,Periods(i,:)),4);
            else
%                 bufFrame(x,y,i) = NaN;
                bufFrame(x,y,i) = 0;
            end
        end
    end
    bufFrame(:,:,i) = rot90(imgaussfilt(bufFrame(:,:,i),GaussSD,'FilterDomain','spatial'),3);
end

Margin_clip = [7,13,10,10];
crange = [0,800];
figure
for i=1:size(Periods,1)
    subplot(1,size(Periods,1),i)
    imagesc(bufFrame(1+Margin_clip(1):end-Margin_clip(2),1+Margin_clip(3):end-Margin_clip(4),i),crange)
    axis square
    axis off    
end
colorbar
colormap('gray')

% DF
bufFrameBaseline = bufFrame(:,:,1);
for i=1:size(Periods,1)
    bufFrame(:,:,i) = bufFrame(:,:,i) - bufFrameBaseline;
end

Margin_clip = [7,13,10,10];
crange = [0,400];
figure
for i=1:size(Periods,1)
    subplot(1,size(Periods,1),i)
    imagesc(bufFrame(1+Margin_clip(1):end-Margin_clip(2),1+Margin_clip(3):end-Margin_clip(4),i),crange)
    axis square
    axis off    
end
colorbar
colormap('hot')


Margin_clip = [48,42,45,45];
crange = [0,400];
figure
for i=1:size(Periods,1)
    subplot(1,size(Periods,1),i)
    imagesc(bufFrame(1+Margin_clip(1):end-Margin_clip(2),1+Margin_clip(3):end-Margin_clip(4),i),crange)
    pbaspect([d1DS-(Margin_clip(1)+Margin_clip(2)),d2DS-(Margin_clip(3)+Margin_clip(4)),1])
    axis off    
end
colorbar
colormap('hot')

function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
