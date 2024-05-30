function [] = ExtDataFig01_GrandAveTimeCourse_OptStim_Song_pIP10
% Code for plotting the time course of pulse and sine song during optogenetic stimulation of the pIP10 split-Gal4 in Extended Data Fig. 1p.

Target = [1,2,3,4,6]; % not enough data from 5 due to flight

%% get filenames
selpathOrg = ['../Data/Summary_pIP10/'];
DataNames_Mic = dir([selpathOrg,'/Mic_*']);
load([selpathOrg,['EthogramCombPulseTrain']])
load([selpathOrg,['StimComb']])

%% parameters
nTrials = 6;
nStim = 6;
TargetStim = 5;

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

bufAve_pulse = bufAve_pulse(:,:,TargetStim);
bufAve_sine = bufAve_sine(:,:,TargetStim);

MovMeanWindow = 1000; % 100 ms
x = x1(1:OneTrialDur)-10;
x = downsample(x,MovMeanWindow);
x2 = [x, fliplr(x)];

% figure
figure('Position',[100,100,50,50])
hold on

% pulse
buf = bufAve_pulse;
bufPlot = zeros(size(Data,1),length(x));
for DataID=1:size(Data,1)
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
buf = bufAve_sine;
bufPlot = zeros(size(Data,1),length(x));
for DataID=1:size(Data,1)
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
xlim([-5 15])
set(gca,'XTick',[-5:5:15],'YTick',[0,0.5,1],'TickDir','out','XTickLabel',[],'YTickLabel',[])
axis square

function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
