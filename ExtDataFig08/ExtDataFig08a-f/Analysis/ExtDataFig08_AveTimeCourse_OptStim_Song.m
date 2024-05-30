function [] = ExtDataFig08_AveTimeCourse_OptStim_Song
% Code for plotting the time course of and the proportions of pulse and sine song in Extended Data Fig. 8a,d.

GT = 'pIP10'; % Extended Data Fig. 8a
% GT = 'pMP2'; % Extended Data Fig. 8d

switch GT
    case 'pIP10'
        CellFlagNonTrans = [1,1,1,1,1,1,1,1,1];
    case 'pMP2'
        CellFlagNonTrans = [1,1,1,1,1,0,1,0,1];
end
%% parameters
nTrials = 6;
nStim = 6;
T = 1370; % T

DAQrate = 10000;
x1 = [0:1/DAQrate:190-1/DAQrate];

PreDurImg = 10*DAQrate; % 10 s
OneTrialDur = 30*DAQrate; % 30 s

Opt_onset = [5+10:30:5+10+5*30]*DAQrate+1;

StimTarget = [6];

Thre_nTrialOpto = 1;

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb'])

load([selpath,'EthogramCombPulseTrain'])
load('TS_Img')
load('TS_OptStimImg')

Stim_comb_org = Stim_comb;

%%
Data = Ethogram_comb;
Data_comb_pulse = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
Data_comb_sine = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
RmvTrials_comb = zeros(size(Data,1),nStim,nTrials);

for DataID=1:size(Data,1)
    if CellFlagNonTrans(DataID)==1
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
end
FlagRmv = CellFlagNonTrans==0;
NonRmvID = find(CellFlagNonTrans==1);

Data_comb_pulse(FlagRmv==1,:,:,:) = [];
Data_comb_sine(FlagRmv==1,:,:,:) = [];

bufAve_pulse = zeros(size(Data_comb_pulse,1),OneTrialDur,nStim);
bufAve_sine = zeros(size(Data_comb_pulse,1),OneTrialDur,nStim);
for DataID=1:size(bufAve_pulse,1)
    for stim=1:nStim
        bufRmv = squeeze(RmvTrials_comb(NonRmvID(DataID),stim,:));
        buf = squeeze(Data_comb_pulse(DataID,:,stim,:));
        buf(:,bufRmv==1) = [];
        if size(buf,2)>=Thre_nTrialOpto
            bufAve_pulse(DataID,:,stim) = mean(buf,2);
        else
            bufAve_pulse(DataID,:,stim) = NaN;
        end
        buf = squeeze(Data_comb_sine(DataID,:,stim,:));
        buf(:,bufRmv==1) = [];
        if size(buf,2)>=Thre_nTrialOpto
            bufAve_sine(DataID,:,stim) = mean(buf,2);
        else
            bufAve_sine(DataID,:,stim) = NaN;
        end
    end
end

MovMeanWindow = 1000; % 100 ms
x = x1(1:OneTrialDur)-10;
x = downsample(x,MovMeanWindow);
x2 = [x, fliplr(x)];

figure('Position',[100,100,50,50]) % 60

hold on
% pulse
buf = bufAve_pulse(:,:,StimTarget);
buf(isnan(buf(:,1)),:) = [];
bufPlot = zeros(size(buf,1),length(x));
for DataID=1:size(buf,1)
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
nFly = size(buf,1)

% sine
buf = bufAve_sine(:,:,StimTarget);
buf(isnan(buf(:,1)),:) = [];
bufPlot = zeros(size(buf,1),length(x));
for DataID=1:size(buf,1)
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

set(gca,'YTick',[0,0.5,1],'TickDir','out','YTickLabel',[])
h = gca;
h.XAxis.Visible = 'off';


function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
