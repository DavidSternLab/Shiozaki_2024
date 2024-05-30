function [] = ExtDataFig05_pIP10_AveTimeCourse_OptStim_Song
% Code for plotting the time course of and the proportions of pulse and sine song in Extended Data Fig. 5g.

GT = 'TN1dsx';

%% parameters
nTrials = 3;
nStim = 6;
T = 1370; % T

DAQrate = 10000;
x1 = [0:1/DAQrate:190-1/DAQrate];

PreDurImg = 10*DAQrate; % 10 s
OneTrialDur = 30*DAQrate; % 30 s

Opt_onset = [5+10:30:5+10+5*30]*DAQrate+1;

StimTarget = [4,5,6];

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
switch GT
    case {'dPR1','dPR1NP','TN1SG','TN1SGNP','TN1dsx'}
        load([selpath,'FtimeCourseComb'])
    otherwise
        load([selpath,'StimComb'])
end

load([selpath,'EthogramCombPulseTrain'])
load('TS_Img')
load('TS_OptStimImg')

Stim_comb_org = Stim_comb;

%%
Data = Ethogram_comb;
Data_comb_pulse = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
Data_comb_sine = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
RmvTrials_comb = zeros(size(Data,1),nStim,nTrials);

for DataID=3:size(Data,1)
    disp(['Data ID: ',num2str(DataID)])
    Stim_comb = Stim_comb_org{DataID};
    for trial=1:nTrials
        disp(['trial ',num2str(trial)])
        
        % pulse
        % downsample ethogram
        bufEtho = Data(DataID,:,trial);
        buf = zeros(size(bufEtho));
        buf(find(bufEtho==1)) = 1;
        for stim=1:nStim
            Data_comb_pulse(DataID,:,stim,trial) = buf([1:OneTrialDur]+Opt_onset(Stim_comb(:,trial)==stim)-PreDurImg-1);
        end
        
        % sine
        % downsample ethogram
        bufEtho = Data(DataID,:,trial);
        buf = zeros(size(bufEtho));
        buf(find(bufEtho==2)) = 1;
        for stim=1:nStim
            Data_comb_sine(DataID,:,stim,trial) = buf([1:OneTrialDur]+Opt_onset(Stim_comb(:,trial)==stim)-PreDurImg-1);
        end
        
        % flight
        buf = zeros(size(bufEtho));
        buf(find(bufEtho==3)) = 1;
        for stim=1:nStim
            bufFlight = buf([1:OneTrialDur]+Opt_onset(Stim_comb(:,trial)==stim)-PreDurImg-1);
            RmvTrials_comb(DataID,stim,trial) = sum(bufFlight)>0;
        end
    end
end
sum(RmvTrials_comb,3)

buf = sum(RmvTrials_comb,3);
FlagRmv = max(buf,[],2)>=5;
NonRmvID = find(FlagRmv==0);
FlagRmv([1,2]) = 1;

Data_comb_pulse(FlagRmv==1,:,:,:) = [];
Data_comb_sine(FlagRmv==1,:,:,:) = [];

bufAve_pulse = zeros(size(Data_comb_pulse,1),OneTrialDur,nStim);
bufAve_sine = zeros(size(Data_comb_pulse,1),OneTrialDur,nStim);
for DataID=1:size(bufAve_pulse,1)
    for stim=1:nStim
        bufRmv = squeeze(RmvTrials_comb(NonRmvID(DataID),stim,:));
        buf = squeeze(Data_comb_pulse(DataID,:,stim,:));
        buf(:,bufRmv==1) = [];
        bufAve_pulse(DataID,:,stim) = mean(buf,2);
        buf = squeeze(Data_comb_sine(DataID,:,stim,:));
        buf(:,bufRmv==1) = [];
        bufAve_sine(DataID,:,stim) = mean(buf,2);
    end
end

MovMeanWindow = 1000; % 100 ms
x = x1(1:OneTrialDur)-10;
x = downsample(x,MovMeanWindow);
x2 = [x, fliplr(x)];

figure('Position',[100,100,190,190]) % 160, 200
for stim=1:3
    subplot(1,3,stim)
    hold on
    % pulse
    buf = bufAve_pulse(:,:,StimTarget(stim));
    bufPlot = zeros(size(bufAve_pulse,1),length(x));
    for DataID=1:size(bufAve_pulse,1)
        bufPlot(DataID,:) = downsample(movmean(buf(DataID,:),MovMeanWindow),MovMeanWindow);
    end
    SEM = std(bufPlot)/sqrt(size(bufPlot,1));
    MEAN = mean(bufPlot,1);
    curve1 = MEAN + SEM;
    curve2 = MEAN - SEM;
    inBetween = [curve1, fliplr(curve2)];
    %     h = fill(x2, inBetween,'r','LineStyle','none','FaceAlpha',.5);
    h = fill(x2, inBetween,'r','LineStyle','none');
    plot(x,MEAN,'r','LineWidth',.5)
    
    % sine
    buf = bufAve_sine(:,:,StimTarget(stim));
    bufPlot = zeros(size(Data,1),length(x));
    for DataID=1:size(bufAve_sine,1)
        bufPlot(DataID,:) = downsample(movmean(buf(DataID,:),MovMeanWindow),MovMeanWindow);
    end
    SEM = std(bufPlot)/sqrt(size(bufPlot,1));
    MEAN = mean(bufPlot,1);
    curve1 = MEAN + SEM;
    curve2 = MEAN - SEM;
    inBetween = [curve1, fliplr(curve2)];
    %     h = fill(x2, inBetween,'b','LineStyle','none','FaceAlpha',.5);
    h = fill(x2, inBetween,'b','LineStyle','none');
    plot(x,MEAN,'b','LineWidth',.5)
    
    plot([0 10],[.5 .5]*1,'r','LineWidth',5)
    ylim([0 1])
    xlim([-10 20])
    axis square
    if stim==1
        set(gca,'YTick',[0,0.5,1],'TickDir','out','YTickLabel',[])
        h = gca;
        h.XAxis.Visible = 'off';
    else
        axis off
    end
    
end

function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
