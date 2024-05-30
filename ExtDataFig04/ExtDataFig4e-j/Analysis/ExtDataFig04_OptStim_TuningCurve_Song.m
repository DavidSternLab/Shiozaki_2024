function [] = ExtDataFig04_OptStim_TuningCurve_Song
% Code for plotting the tuning curves of calcium signals of each neuron induced by optogenetics in Extended Data Fig. 4f,i.

GT = 'dPR1'; % Extended Data Fig. 4f
% GT = 'TN1SG'; % Extended Data Fig. 4i

TargetPeriod = [0,10];

%% parameters
nTrials = 3;
nStim = 6;
T = 1370; % T

DAQrate = 10000;
x1 = [0:1/DAQrate:190-1/DAQrate];

PreDurImg = 10*DAQrate; % 10 s
OneTrialDur = 30*DAQrate; % 30 s

Opt_onset = [5+10:30:5+10+5*30]*DAQrate+1;

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
switch GT
    case {'dPR1','dPR1NP','TN1SG','TN1SGNP','TN1dsx'}
        load([selpath,'FtimeCourseComb'])
    otherwise
        load([selpath,'StimComb'])
end

load([selpath,'EthogramCombPulseTrain.mat'])
load('TS_Img')
load('TS_OptStimImg')

Stim_comb_org = Stim_comb;

%%
Data = Ethogram_comb;
Data_comb_pulse = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
Data_comb_sine = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
RmvTrials_comb = zeros(size(Data,1),nStim,nTrials);

for DataID=1:size(Data,1)
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
    Mean = mean(Prob_pulse(:,stim));
    SD = std(Prob_pulse(:,stim));
    plot([1,1]*stim+.3,[-1,1]*SD+Mean,'r-','LineWidth',.5)
    plot([-.1,.1]+stim+.3,[1,1]*Mean,'r-','LineWidth',.5)
end
xlim([.5,6.5])
ylim([0,.6])
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[0,.3,.6],'XTick',[0:nStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_sine(:),4,'b','filled','jitter','on','jitterAmount',.2)
for stim=1:nStim
    Mean = mean(Prob_sine(:,stim));
    SD = std(Prob_sine(:,stim));
    plot([1,1]*stim+.3,[-1,1]*SD+Mean,'b-','LineWidth',.5)
    plot([-.1,.1]+stim+.3,[1,1]*Mean,'b-','LineWidth',.5)
end
xlim([.5,6.5])
ylim([0,.6])
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[0,.3,.6],'XTick',[0:nStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])


function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
