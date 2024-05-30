function [] = ExtDataFig08_OptStim_TuningCurve_Song
% Code for plotting the tuning curves of pulse and sine songs induced by optogenetics in Extended Data Fig. 8c,f.

GT = 'pIP10'; Target = 'pIP10_NR'; % Extended Data Fig. 8c
% GT = 'pMP2'; Target = 'pMP2_NR'; % Extended Data Fig. 8f

switch Target
    case 'pIP10_NR'
        TargetROI = 3;
        ylimrange = [-.3 1.2];
    case 'pMP2_NR'
        TargetROI = [5,6];
        ylimrange = [-.3 1.2];
end

TargetPeriod = [0,10];

%% parameters
nTrials = 6;
nStim = 6;
T = 1370; % T

DAQrate = 10000;
x1 = [0:1/DAQrate:190-1/DAQrate];

PreDurImg = 10*DAQrate; % 10 s
OneTrialDur = 30*DAQrate; % 30 s

Opt_onset = [5+10:30:5+10+5*30]*DAQrate+1;

Thre_nTrialOpto = 1;

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb'])

load([selpath,'EthogramCombPulseTrain.mat'])
load('TS_Img')
load('TS_OptStimImg')

Dataset = readtable([selpath,'Dataset.csv']);
if strcmp(GT,'pIP10')
    DataFlag = Dataset{:,2:7};
    DataFlag(:,3) = [];
elseif strcmp(GT,'pMP2')
    DataFlag = Dataset{:,2:9};
elseif strcmp(GT,'pMP2_DR')
    DataFlag = Dataset{:,10:11};
end

Stim_comb_org = Stim_comb;

%%
Data = Ethogram_comb;
Data_comb_pulse = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
Data_comb_sine = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
RmvTrials_comb = zeros(size(Data,1),nStim,nTrials);

for DataID=1:size(Data,1)
    FlagRmv(DataID) = sum(DataFlag(DataID,TargetROI))==0;
    if FlagRmv(DataID)==0
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

Data_comb_pulse(FlagRmv==1,:,:,:) = [];
Data_comb_sine(FlagRmv==1,:,:,:) = [];

bufAve_pulse = zeros(size(Data_comb_pulse,1),OneTrialDur,nStim);
bufAve_sine = zeros(size(Data_comb_pulse,1),OneTrialDur,nStim);
for DataID=1:size(bufAve_pulse,1)
    for stim=1:nStim
        buf = squeeze(Data_comb_pulse(DataID,:,stim,:));
        if size(buf,2)>=Thre_nTrialOpto
            bufAve_pulse(DataID,:,stim) = mean(buf,2);
        else
            bufAve_pulse(DataID,:,stim) = NaN;
        end
        buf = squeeze(Data_comb_sine(DataID,:,stim,:));
        if size(buf,2)>=Thre_nTrialOpto
            bufAve_sine(DataID,:,stim) = mean(buf,2);
        else
            bufAve_sine(DataID,:,stim) = NaN;
        end
    end
end

%%
Data = bufAve_pulse;
xx = x1(1:OneTrialDur)-PreDurImg/DAQrate;
Prob_pulse = zeros(size(Data,1),nStim);
Prob_sine = zeros(size(Data,1),nStim);

for DataID=1:size(Data,1)
    for stim=1:nStim
        buf = mean(bufAve_pulse(DataID,:,stim)',2);
        Prob_pulse(DataID,stim) = mean(buf(TargetPeriod(1)<=xx&xx<=TargetPeriod(2)));
        buf = mean(bufAve_sine(DataID,:,stim)',2);
        Prob_sine(DataID,stim) = mean(buf(TargetPeriod(1)<=xx&xx<=TargetPeriod(2)));
    end
end

xx = zeros(size(Prob_pulse));
for stim=1:nStim
    xx(:,stim) = stim;
end

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_pulse(:),4,'r','filled','jitter','on','jitterAmount',.2)
for stim=1:nStim
    buf = Prob_pulse(:,stim);
    Mean = mean(buf(~isnan(buf)));
    SD = std(buf(~isnan(buf)));
    plot([1,1]*stim+.3,[-1,1]*SD+Mean,'r-','LineWidth',.5)
    plot([-.1,.1]+stim+.3,[1,1]*Mean,'r-','LineWidth',.5)
    nFly = sum(~isnan(buf))
end
xlim([.5,6.5])
ylim([0,1])
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[0,.5,1],'XTick',[0:nStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_sine(:),4,'b','filled','jitter','on','jitterAmount',.2)
for stim=1:nStim
    buf = Prob_sine(:,stim);
    Mean = mean(buf(~isnan(buf)));
    SD = std(buf(~isnan(buf)));
    plot([1,1]*stim+.3,[-1,1]*SD+Mean,'b-','LineWidth',.5)
    plot([-.1,.1]+stim+.3,[1,1]*Mean,'b-','LineWidth',.5)
end
xlim([.5,6.5])
ylim([0,1])
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[0,.5,1],'XTick',[0:nStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])


function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
