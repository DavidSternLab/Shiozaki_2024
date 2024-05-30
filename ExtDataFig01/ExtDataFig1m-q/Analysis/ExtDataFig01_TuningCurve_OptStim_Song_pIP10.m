function [] = ExtDataFig01_TuningCurve_OptStim_Song_pIP10
% Code for plotting the tuning curves of pulse and sine songs induced by optogenetics in Extended Data Fig. 1r.

Target = [1,2,3,4,6]; % not enough data from 5 due to flight

TargetPeriod = [0,10];
OptStim = [10,20,30,40,50,60];

%% get filenames
selpathOrg = ['../Data/Summary_pIP10/'];
DataNames_Mic = dir([selpathOrg,'/Mic_*']);
load([selpathOrg,['EthogramCombPulseTrain']])
load([selpathOrg,['StimComb']])

%% parameters
nTrials = 6;
nStim = 6;

RecDur = 1140; % 190*6 s = 1140 s
DAQrate = 10000;
x1 = [0:1/DAQrate:RecDur-1/DAQrate];

PreDurImg = 10*DAQrate; % 10 s
OneTrialDur = 30*DAQrate; % 30 s

Opt_onset = [5+10:30:5+10+5*30]*DAQrate+1;

%%
Data = Ethogram_comb(Target,:,:);
Data_comb_pulse = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
Data_comb_sine = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
RmvTrials_comb = zeros(size(Data,1),nStim,nTrials);

for DataID=1:size(Data,1)
    disp(['Data ID: ',num2str(DataID)])
    Opt_onset_ID = Stim_comb{Target(DataID)};
    
    for trial=1:nTrials
        bufEtho = squeeze(Data(DataID,:,trial));
        
        % pulse
        buf = zeros(size(bufEtho));
        buf(find(bufEtho==1)) = 1;
        for stim=1:nStim
            Data_comb_pulse(DataID,:,stim,trial) = buf([1:OneTrialDur]+Opt_onset(Opt_onset_ID(:,trial)==stim)-PreDurImg-1);
        end
        
        % sine
        buf = zeros(size(bufEtho));
        buf(find(bufEtho==2)) = 1;
        for stim=1:nStim
            Data_comb_sine(DataID,:,stim,trial) = buf([1:OneTrialDur]+Opt_onset(Opt_onset_ID(:,trial)==stim)-PreDurImg-1);
        end
        
        % flight
        buf = zeros(size(bufEtho));
        buf(find(bufEtho==3)) = 1;
        for stim=1:nStim
            bufFlight = buf([1:OneTrialDur]+Opt_onset(Opt_onset_ID(:,trial)==stim)-PreDurImg-1);
            RmvTrials_comb(DataID,stim,trial) = sum(bufFlight)>0;
        end
    end
end
sum(RmvTrials_comb,3)

bufAve_pulse = zeros(size(Data_comb_pulse,1),OneTrialDur,nStim);
bufAve_sine = zeros(size(Data_comb_pulse,1),OneTrialDur,nStim);
for DataID=1:size(Data,1)
    for stim=1:nStim
        bufRmv = squeeze(RmvTrials_comb(DataID,stim,:));
        buf = squeeze(Data_comb_pulse(DataID,:,stim,:));
        buf(:,bufRmv==1) = [];
        bufAve_pulse(DataID,:,stim) = mean(buf,2);
        buf = squeeze(Data_comb_sine(DataID,:,stim,:));
        buf(:,bufRmv==1) = [];
        bufAve_sine(DataID,:,stim) = mean(buf,2);
    end
end

%%
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
    xx(:,stim) = OptStim(stim);
end

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_pulse(:),4,'r','filled','jitter','on','jitterAmount',2)
for stim=1:nStim
    Mean = mean(Prob_pulse(:,stim));
    SD = std(Prob_pulse(:,stim));
    plot([1,1]*OptStim(stim)+5,[-1,1]*SD+Mean,'r-','LineWidth',.5)
    plot([-1,1]+OptStim(stim)+5,[1,1]*Mean,'r-','LineWidth',.5)
end
xlim([0,70])
ylim([0,1])
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[0,.5,1],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_sine(:),4,'b','filled','jitter','on','jitterAmount',2)
for stim=1:nStim
    Mean = mean(Prob_sine(:,stim));
    SD = std(Prob_sine(:,stim));
    plot([1,1]*OptStim(stim)+5,[-1,1]*SD+Mean,'b-','LineWidth',.5)
    plot([-1,1]+OptStim(stim)+5,[1,1]*Mean,'b-','LineWidth',.5)
end
xlim([0,70])
ylim([0,1])
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[0,.5,1],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])
