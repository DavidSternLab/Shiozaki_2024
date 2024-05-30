function [] = ExtDataFig05_Example_SongPrefIdx_dPR1()
% Code for showing how to calculate a song type preference n Extended Data Fig. 5a.

GT = 'dPR1';
TargetFileID = 2;
TargetROI = 1;

%% parameters
Thre_pulse = 0.1;
Thre_sine = 0.6;
Thre_Resp = 0.05;

nTrials = 6;
T = 1370; % T

PreEventImg = 72; % 10 s (71.0443)
OnePeriodDur = 143; % 20 s (142.0886)
QuietDur = 15; % 2 s (14.2089)
FlightWindow = 7; % 1 s (7.1044)

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb']) % FileID,nROIs,T,nTrials
load([selpath,'EthogramCombImg']) % FileID,T,nTrials (1: pulse, 2: sine)
load('TS_Img')
load('TS_OptStimImg')
load([selpath,'ResponseIndex'])

Period_Pre = zeros(size(TS_Img));
for i=1:length(OptStimOnset_Img)
    Period_Pre([1:PreEventImg]+OptStimOnset_Img(i)-1-PreEventImg) = 1;
end

F_comb_org = F_comb;

%% main loop
Data_QtoP_comb = [];
nTrials_QtoP_comb = zeros(size(F_comb,1),1);
Data_PtoS_comb = [];
nTrials_PtoS_comb = zeros(size(F_comb,1),1);
Data_StoP_comb = [];
nTrials_StoP_comb = zeros(size(F_comb,1),1);
nROIs_total = 0;

for FileID=TargetFileID:TargetFileID
    disp(['File ID: ',num2str(FileID)])
    
    % ethogram
    disp('ethogram')
    EventTiming_QtoP = {};
    EventTiming_PtoS = {};
    EventTiming_StoP = {};
    
    for trial=1:nTrials
        buf_DS_pulse = squeeze(Ethogram_comb_Img(FileID,1,:,trial));
        buf_DS_sine = squeeze(Ethogram_comb_Img(FileID,2,:,trial));
        buf_DS_quiet = squeeze(Ethogram_comb_Img(FileID,3,:,trial));
        buf_DS_flight = squeeze(Ethogram_comb_Img(FileID,4,:,trial));
        
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
    end
    
    % main
    F_comb = F_comb_org{FileID};
    nROIs = size(F_comb,1);
    bufRespIdx = ResponseIdx(ResponseIdx_FlyID==FileID);
    bufEtho = squeeze(Ethogram_comb_Img(FileID,4,:,:));
    for ROIID=1:nROIs
        if bufRespIdx(ROIID)<Thre_Resp
            % DFF
            buf = squeeze(F_comb(ROIID,:,:));
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
            
            % quiet to pulse
            Data_comb = [];
            for trial=1:nTrials
                bufDFF = DFF(:,trial);
                bufID = EventTiming_QtoP{trial};
                for i=1:length(bufID)
                    buf = bufDFF([1:OnePeriodDur]+bufID(i)-1-PreEventImg);
                    Data_comb = [Data_comb,buf];
                end
            end
            Data_QtoP_comb = [Data_QtoP_comb,Data_comb];
            if ROIID==1
                nTrials_QtoP_comb(FileID) = size(Data_comb,2);
            end
            
            % pulse to sine
            Data_comb = [];
            for trial=1:nTrials
                bufDFF = DFF(:,trial);
                bufID = EventTiming_PtoS{trial};
                for i=1:length(bufID)
                    buf = bufDFF([1:OnePeriodDur]+bufID(i)-1-PreEventImg);
                    Data_comb = [Data_comb,buf];
                end
            end
            Data_PtoS_comb = [Data_PtoS_comb,Data_comb];
            if ROIID==1
                nTrials_PtoS_comb(FileID) = size(Data_comb,2);
            end
            
            % sine to pulse
            Data_comb = [];
            for trial=1:nTrials
                bufDFF = DFF(:,trial);
                bufID = EventTiming_StoP{trial};
                for i=1:length(bufID)
                    buf = bufDFF([1:OnePeriodDur]+bufID(i)-1-PreEventImg);
                    Data_comb = [Data_comb,buf];
                end
            end
            Data_StoP_comb = [Data_StoP_comb,Data_comb];
            if ROIID==1
                nTrials_StoP_comb(FileID) = size(Data_comb,2);
            end
        end
    end
end

%% make figures
figure('Position',[100 100 177 177])
x = TS_Img(1:OnePeriodDur)-TS_Img(PreEventImg+1)+mean(diff(TS_Img))/2;
x2 = [x, fliplr(x)];

% pulse to sine
buf = Data_PtoS_comb;
subplot(1,3,1)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',2)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
h = fill(x2, inBetween, 'r','LineStyle','none');
xlim([-1 1])
ylim([1.9 2.7])
plot([0 0],ylim,'k--')
plot([-1 -.5],[3.2 3.2],'k','LineWidth',2)
plot([-1 -1],[3.2 3.4],'k','LineWidth',2)
axis square
axis off

% sine to pulse
buf = Data_StoP_comb;
subplot(1,3,2)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',2)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
h = fill(x2, inBetween, 'r','LineStyle','none');
xlim([-1 1])
ylim([1.9 2.7])
plot([0 0],ylim,'k--')
axis square
axis off

%%
figure('Position',[100 100 177 177])

TargetRange = [72:76];
x = TS_Img(1:OnePeriodDur)-TS_Img(PreEventImg+1)+mean(diff(TS_Img))/2;
x = x(TargetRange);
x2 = [x, fliplr(x)];

% pulse to sine
buf = Data_PtoS_comb(TargetRange,:);
subplot(1,3,1)
hold on
plot(x,buf,'y')
plot(x,mean(buf,2),'r','LineWidth',.5)
xlim([-1 1])
ylim([0 6])
plot([0 0],ylim,'k--')
axis square
axis off

% sine to pulse
buf = Data_StoP_comb(TargetRange,:);
subplot(1,3,2)
hold on
plot(x,buf,'y')
plot(x,mean(buf,2),'r','LineWidth',.5)
xlim([-1 1])
ylim([0 6])
plot([0 0],ylim,'k--')
axis square
axis off

%%
figure('Position',[100 100 50 50])

TargetRange = [72:76];
buf = Data_PtoS_comb(TargetRange,:);
buf_PtoS = mean(buf([4:5],:)) - mean(buf([1:2],:));
buf = Data_StoP_comb(TargetRange,:);
buf_StoP = mean(buf([4:5],:)) - mean(buf([1:2],:));

edges = [-2:0.2:2];
h1 = histogram(buf_PtoS,edges,'FaceColor','b','FaceAlpha',1);
hold on
h2 = histogram(buf_StoP,edges,'FaceColor','r','FaceAlpha',1);
box off
xlim([edges(1),edges(end)])
ylim([0,150])
plot([0,0],ylim,'k:')
pbaspect([1,1,1])
set(gca,'XTick',[-1.5:1.5:1.5],'YTick',[0:50:150],'TickDir','out','XTickLabel',[],'YTickLabel',[])

scores = [buf_PtoS,buf_StoP];
labels = [zeros(size(buf_PtoS)),ones(size(buf_StoP))];
[X,Y,~,AUC] = perfcurve(labels,scores,0);
Idx_SongType = (AUC-0.5)*2
