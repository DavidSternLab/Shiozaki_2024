function [] = Fig05_Example_AveSong()
% Code for plotting images for the example recordings in Fig. 5b.

GT = 'fruD';

switch GT
    case 'fruD'
        TargetDataID = 3;
        zrange = [2:9];
        ylimrange1 = [0,1];
        ylimrange2 = [-.3,.3];
        ylimrange3 = [0,.8];
        ylimrange4 = [-.3,.3];
        filename = 'F2d_20220124_03.mat';
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
Trans_Post = [74:75]-73;

OneTrialDur = 214; % 30 s (213.1329)

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

% ethogram
EventTiming_QtoP = {};
EventTiming_PtoS = {};
EventTiming_StoP = {};
nTrials_PtoS = 0;
nTrials_StoP = 0;
for trial=1:nTrials
    buf_DS_pulse = squeeze(Ethogram_comb_Img(DataID,1,:,trial));
    buf_DS_sine = squeeze(Ethogram_comb_Img(DataID,2,:,trial));
    buf_DS_quiet = squeeze(Ethogram_comb_Img(DataID,3,:,trial));
    buf_DS_flight = squeeze(Ethogram_comb_Img(DataID,4,:,trial));
    
    % quiet to pulse
    bufID = find(buf_DS_pulse>=Thre_pulse);
    bufID(bufID<=PreEventImg) = [];
    bufID(bufID+OnePeriodDur-PreEventImg>T) = [];
    RmvFlag = zeros(length(bufID),1);
    for i=1:length(bufID)
        if sum(buf_DS_quiet(bufID(i)-QuietDur:bufID(i)-1))~=QuietDur
            RmvFlag(i) = 1;
        elseif sum(buf_DS_flight([-FlightWindow:FlightWindow]+bufID(i)))>0
            RmvFlag(i) = 1;
        end
    end
    bufID(RmvFlag==1) = [];
    EventTiming_QtoP{trial} = bufID;
    
    % pulse to sine
    bufID = find(buf_DS_pulse>=Thre_pulse);
    bufID(bufID-1<=PreEventImg) = [];
    bufID(bufID+OnePeriodDur-PreEventImg-1>T) = [];
    bufID(buf_DS_pulse(bufID+1)>=Thre_pulse) = [];
    bufID(buf_DS_sine(bufID+1)<Thre_sine&buf_DS_sine(bufID+2)<Thre_sine) = [];
    RmvFlag = zeros(length(bufID),1);
    for i=1:length(bufID)
        if sum(buf_DS_flight([-FlightWindow:FlightWindow]+bufID(i)))>0
            RmvFlag(i) = 1;
        end
    end
    bufID(RmvFlag==1) = [];
    EventTiming_PtoS{trial} = bufID+1;
    nTrials_PtoS = nTrials_PtoS + length(bufID);
    
    % sine to pulse
    bufID = find(buf_DS_sine>=Thre_sine);
    bufID(bufID-1<=PreEventImg) = [];
    bufID(bufID+OnePeriodDur-PreEventImg-1>T) = [];
    bufID(buf_DS_sine(bufID+1)>=Thre_pulse) = [];
    bufID(buf_DS_pulse(bufID+1)<Thre_pulse&buf_DS_pulse(bufID+2)<Thre_pulse) = [];
    RmvFlag = zeros(length(bufID),1);
    for i=1:length(bufID)
        if sum(buf_DS_flight([-FlightWindow:FlightWindow]+bufID(i)))>0
            RmvFlag(i) = 1;
        end
    end
    bufID(RmvFlag==1) = [];
    EventTiming_StoP{trial} = bufID+1;
    nTrials_StoP = nTrials_StoP + length(bufID);
end
        
% DFF
bufEtho = squeeze(Ethogram_comb_Img(DataID,4,:,:));
bufF = zeros(d1DS,d2DS,d3);
Counter = 0;
for i=1:length(OptStimOnset_Img)
    for trial=1:nTrials
        bufFlight = bufEtho([-PreEventImg:0]+OptStimOnset_Img(i)-1,trial);
        if sum(bufFlight)==0
            bufF = bufF + mean(bufComb_F(:,:,:,[-PreEventImg:0]+OptStimOnset_Img(i)-1,trial),4);
            Counter = Counter + 1;
        end
    end
end
F = bufF/Counter;
DFF = (bufComb_F-F)./F;
clear bufComb_F

% pulse to sine
Data_comb = zeros(d1DS,d2DS,d3,2,nTrials_PtoS);
Counter = 1;
for trial=1:nTrials
    bufDFF = squeeze(DFF(:,:,:,:,trial));
    bufID = EventTiming_PtoS{trial};
    for i=1:length(bufID)
        Data_comb(:,:,:,1,Counter) = mean(bufDFF(:,:,:,bufID(i)+Trans_Pre),4);
        Data_comb(:,:,:,2,Counter) = mean(bufDFF(:,:,:,bufID(i)+Trans_Post),4);
        Counter = Counter + 1;
    end
end
Resp_PtoS = Data_comb;

% sine to pulse
Data_comb = zeros(d1DS,d2DS,d3,2,nTrials_StoP);
Counter = 1;
for trial=1:nTrials
    bufDFF = squeeze(DFF(:,:,:,:,trial));
    bufID = EventTiming_StoP{trial};
    for i=1:length(bufID)
        Data_comb(:,:,:,1,Counter) = mean(bufDFF(:,:,:,bufID(i)+Trans_Pre),4);
        Data_comb(:,:,:,2,Counter) = mean(bufDFF(:,:,:,bufID(i)+Trans_Post),4);
        Counter = Counter + 1;
    end
end
Resp_StoP = Data_comb;


%% average pulse sine
size(Resp_PtoS)
size(Resp_StoP)

P_PtoS = squeeze(Resp_PtoS(:,:,:,1,:));
P_PtoS = mean(P_PtoS,4);
P_PtoS = rot90(mean(P_PtoS(:,:,zrange),3),3);

S_PtoS = squeeze(Resp_PtoS(:,:,:,2,:));
S_PtoS = mean(S_PtoS,4);
S_PtoS = rot90(mean(S_PtoS(:,:,zrange),3),3);

S_StoP = squeeze(Resp_StoP(:,:,:,1,:));
S_StoP = mean(S_StoP,4);
S_StoP = rot90(mean(S_StoP(:,:,zrange),3),3);

P_StoP = squeeze(Resp_StoP(:,:,:,2,:));
P_StoP = mean(P_StoP,4);
P_StoP = rot90(mean(P_StoP(:,:,zrange),3),3);

figure
subplot(2,2,1)
imagesc(P_PtoS(1+Margin(1):end-Margin(2),1+Margin(3):end-Margin(4)),ylimrange1);
axis square
axis off
colormap('hot')
colorbar
subplot(2,2,2)
imagesc(S_PtoS(1+Margin(1):end-Margin(2),1+Margin(3):end-Margin(4)),ylimrange1);
axis square
axis off
colormap('hot')
colorbar
subplot(2,2,3)
imagesc(S_StoP(1+Margin(1):end-Margin(2),1+Margin(3):end-Margin(4)),ylimrange1);
axis square
axis off
colormap('hot')
colorbar
subplot(2,2,4)
imagesc(P_StoP(1+Margin(1):end-Margin(2),1+Margin(3):end-Margin(4)),ylimrange1);
axis square
axis off
colormap('hot')
colorbar

max(P_PtoS(:))
min(P_PtoS(:))
max(S_PtoS(:))
min(S_PtoS(:))
max(S_StoP(:))
min(S_StoP(:))
max(P_PtoS(:))
min(P_PtoS(:))

%% average diff
GaussSD = 1;

PtoS = squeeze(Resp_PtoS(:,:,:,2,:)-Resp_PtoS(:,:,:,1,:));
PtoS = mean(PtoS,4);
% PtoS = rot90(mean(PtoS(:,:,zrange),3),3);
PtoS = imgaussfilt(rot90(mean(PtoS(:,:,zrange),3),3),GaussSD,'FilterDomain','spatial');

StoP = squeeze(Resp_StoP(:,:,:,2,:)-Resp_StoP(:,:,:,1,:));
StoP = mean(StoP,4);
% StoP = rot90(mean(StoP(:,:,zrange),3),3);
StoP = imgaussfilt(rot90(mean(StoP(:,:,zrange),3),3),GaussSD,'FilterDomain','spatial');

figure
subplot(1,2,1)
imagesc(PtoS(1+Margin(1):end-Margin(2),1+Margin(3):end-Margin(4)),ylimrange2);
axis square
axis off
colormap('jet')
colorbar
subplot(1,2,2)
imagesc(StoP(1+Margin(1):end-Margin(2),1+Margin(3):end-Margin(4)),ylimrange2);axis square
axis off
colormap('jet')
colorbar

%% Combine P-to-S and S-to-P transitions
buf1 = cat(4,squeeze(Resp_PtoS(:,:,:,1,:)),squeeze(Resp_StoP(:,:,:,2,:)));
PulseComb = mean(buf1,4);
PulseComb = imgaussfilt(rot90(mean(PulseComb(:,:,zrange),3),3),GaussSD,'FilterDomain','spatial');

buf2 = cat(4,squeeze(Resp_PtoS(:,:,:,2,:)),squeeze(Resp_StoP(:,:,:,1,:)));
SineComb = mean(buf2,4);
SineComb = imgaussfilt(rot90(mean(SineComb(:,:,zrange),3),3),GaussSD,'FilterDomain','spatial');

PminusS = PulseComb-SineComb;

figure
subplot(1,2,1)
imagesc(PulseComb(1+Margin(1):end-Margin(2),1+Margin(3):end-Margin(4)),ylimrange3);
axis square
axis off
colormap('hot')
colorbar
subplot(1,2,2)
imagesc(SineComb(1+Margin(1):end-Margin(2),1+Margin(3):end-Margin(4)),ylimrange3);
axis square
axis off
colormap('hot')
colorbar

figure
imagesc(PminusS(1+Margin(1):end-Margin(2),1+Margin(3):end-Margin(4)),ylimrange4);
axis square
axis off
colormap('jet')
colorbar
