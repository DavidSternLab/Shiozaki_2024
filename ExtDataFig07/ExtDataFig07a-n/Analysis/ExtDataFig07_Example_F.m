function [] = ExtDataFig07_Example_F()
% Code for plotting images for the example images in Extended Data Fig. 7a.

GT = 'fruD';
% GT = 'fru';

switch GT
    case 'fruD'
        TargetDataID = 11;
        zrange = [2:9];
        ylimrange = [0,300];
        filename = 'F2d_20220207_01.mat';
    case 'fru'
        TargetDataID = 7;
        zrange = [2:9];
        ylimrange = [0,600];
        filename = 'F2d_20220128_02.mat';
end

Margin = [7,13,10,10];
        
Thre_F = 50;

%% parameters
nTrials = 6;
nStim = 6;
T = 1370; % T
d1DS = 128;
d2DS = 128;
d3 = 10;
StimDurImg = 72; % 10 s (71.0443)
PreEventImg = 72; % 10 s (71.0443)

OnePeriodDur_PCA = 4; % 1 s (7.1044)
PreEventImg_PCA = 1; % 0.5 s (3.5522)

QuietDur = 15; % 2 s (14.2089)
FlightWindow = 7; % 1 s (7.1044)

Thre_pulse = 0.1;
Thre_sine = 0.6;
OnePeriodDur = 143; % 20 s (142.0886)
Trans_Pre = [72:73]-73;
Trans_Post = [75:76]-73;

OneTrialDur = 214; % 30 s (213.1329)

TargetStim = [3:6];

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'StimComb'])
load([selpath,'EthogramComb'])
load([selpath,'EthogramCombImg']) % FileID,T,nTrials (1: pulse, 2: sine)
load('TS_Img')
load('TS_OptStimImg')

Stim_comb_org = Stim_comb;

%% PCA single
DataID = TargetDataID;

disp(['File ID: ',num2str(DataID)])
load([selpath,filename])
Stim_comb = Stim_comb_org{DataID};

DataPixels = zeros(size(Img_Mean));
DataPixels(Img_Mean>=Thre_F) = 1;
        
% DFF
bufEtho = squeeze(Ethogram_comb_Img(DataID,4,:,:));

% extract Stim - Pre
buf_Data_comb = zeros(d1DS,d2DS,d3,2,nStim,nTrials);
RmvTrials = zeros(nStim,nTrials);
for trial=1:nTrials
    for stim=1:nStim
        ID = find(Stim_comb(:,trial)==stim);
        Pre = mean(bufComb_F(:,:,:,[-PreEventImg:0]+OptStimOnset_Img(ID)-1,trial),4);
        Stim = mean(bufComb_F(:,:,:,[0:StimDurImg]+OptStimOnset_Img(ID)-1,trial),4);
        buf_Data_comb(:,:,:,1,stim,trial) = Pre;
        buf_Data_comb(:,:,:,2,stim,trial) = Stim;
        
        % flight
        bufFlight = bufEtho([1:OneTrialDur]+OptStimOnset_Img(ID)-PreEventImg-1,trial);
        RmvTrials(stim,trial) = sum(bufFlight)>0;
    end
end
if sum(sum(RmvTrials,2)>=5)>0
    disp('too many flight trials')
    keyboard
end

% combine target stimuli
RmvTrials_new = RmvTrials(TargetStim(1),:);
buf_Data_comb_new = buf_Data_comb(:,:,:,:,TargetStim(1),:);
for stim=2:length(TargetStim)
    RmvTrials_new = [RmvTrials_new,RmvTrials(TargetStim(stim),:)];
    buf_Data_comb_new = cat(6,buf_Data_comb_new,buf_Data_comb(:,:,:,:,TargetStim(stim),:));
end

AveData = zeros(d1DS,d2DS,d3,2);
AveData(:,:,:,1) = mean(buf_Data_comb_new(:,:,:,1,1,RmvTrials_new==0),6);
AveData(:,:,:,2) = mean(buf_Data_comb_new(:,:,:,2,1,RmvTrials_new==0),6);

%% average
buf1 = rot90(mean(AveData(:,:,zrange,2),3),3);

figure
imagesc(buf1(1+Margin(1):end-Margin(2),1+Margin(3):end-Margin(4)),ylimrange);
axis square
axis off
colormap('gray')
colorbar

max(buf1(:))
min(buf1(:))
