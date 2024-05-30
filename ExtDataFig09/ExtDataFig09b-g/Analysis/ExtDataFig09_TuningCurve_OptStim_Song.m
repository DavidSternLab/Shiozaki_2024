function [] = ExtDataFig09_TuningCurve_OptStim_Song
% Code for plotting the tuning curves in Extended Data Fig. 9b,c.

% GT = 'w_Chr';
GT = 'pIP10_Chr';
% GT = 'dPR1_Chr';
% GT = 'TN1_Chr';
% GT = 'pMP2_Chr';

switch GT
    case 'w_Chr'
        Target = [1,2];
    case 'pIP10_Chr'
        Target = [3,4];
    case 'pIP10_w'
        Target = [5,6];
    case 'dPR1_Chr'
        Target = [7,8];
    case 'dPR1_w'
        Target = [9,10];
    case 'TN1_Chr'
        Target = [11,12];
    case 'TN1_w'
        Target = [13,14];
    case 'pIP10_Chr_Weak'
        Target = [15,16];
    case 'pIP10_w_Weak'
        Target = [17,18];
    case 'dPR1_Chr_Weak'
        Target = [19,20];
    case 'dPR1_w_Weak'
        Target = [21,22];
    case 'TN1_Chr_Weak'
        Target = [23,24];
    case 'TN1_w_Weak'
        Target = [25,26];
    case 'pIP10_Chr_Solo'
        Target = [27,28];
    case 'pIP10_Chr_Weak_Solo'
        Target = [29,30];
    case 'dPR1_Chr_Solo'
        Target = [31,32];
    case 'dPR1_Chr_Weak_Solo'
        Target = [33,34];
    case 'TN1_Chr_Solo'
        Target = [35,36];
    case 'TN1_Chr_Weak_Solo'
        Target = [37,38];
    case 'pMP2_Chr'
        Target = [39,40];
end

%% get filenames
selpathOrg = ['../Data/Summary/'];
DataNames_OptStim = dir([selpathOrg,'/OptStim_*']);
CellFlag = readmatrix([selpathOrg,'dataset.csv']);
CellFlag(:,1) = []; % Gal4xChr, Gal4xw, wxChr
load([selpathOrg,['EthogramCombPulseTrain_',GT]])

%% genotypes
Target_File = CellFlag(Target(1),:);
buf = isnan(Target_File);
Target_File(buf) = [];

%% parameters
nTrials = 6*4;
nStim = 3;

RecDur = 1320; % 1320 s = 22 min
DAQrate = 5000;
x1 = [0:1/DAQrate:RecDur-1/DAQrate];

PreDurImg = 5*DAQrate; % 5 s
OneTrialDur = 15*DAQrate; % 15 s

TargetPeriod = [0,5];
PrePeriod = [-5,0];
OptStim = [10,20,30];

OptStimID = zeros(nTrials*nStim,1);
for stim=1:nStim
    OptStimID([1:3:length(OptStimID)]+stim-1) = stim;
end
if strcmp(GT,'pIP10_Chr')==1
    OptStimID([1:12:length(OptStimID)]) = 2;
end

%%
Data = Ethogram_comb;
Data_comb_pulse = [];
Data_comb_sine = [];

for DataID=1:size(Data,1)
    disp(['Data ID: ',num2str(DataID)])
    name = DataNames_OptStim(Target_File(DataID)).name;
    load([selpathOrg,name])

    % pulse
    % downsample ethogram
    bufEtho = Data(DataID,:);
    buf = zeros(size(bufEtho));
    buf(find(bufEtho==1)) = 1;
    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_pulse{DataID,stim} = bufData;
    end

    % sine
    % downsample ethogram
    bufEtho = Data(DataID,:);
    buf = zeros(size(bufEtho));
    buf(find(bufEtho==2)) = 1;
    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_sine{DataID,stim} = bufData;
    end
end

bufAve_pulse = zeros(size(Data,1),OneTrialDur,nStim);
bufAve_sine = zeros(size(Data,1),OneTrialDur,nStim);
for stim=1:nStim
    for DataID=1:size(Data,1)
        buf = Data_comb_pulse{DataID,stim};
        bufAve_pulse(DataID,:,stim) = mean(buf,2);
        buf = Data_comb_sine{DataID,stim};
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
        Prob_pulse(DataID,stim) = mean(buf(TargetPeriod(1)<=xx&xx<=TargetPeriod(2))) - mean(buf(PrePeriod(1)<=xx&xx<PrePeriod(2)));
        buf = mean(bufAve_sine(DataID,:,stim)',2);
        Prob_sine(DataID,stim) = mean(buf(TargetPeriod(1)<=xx&xx<=TargetPeriod(2))) - mean(buf(PrePeriod(1)<=xx&xx<PrePeriod(2)));
    end
end

xx = zeros(size(Prob_pulse));
for stim=1:nStim
    xx(:,stim) = OptStim(stim);
end

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_pulse(:),4,'r','filled','jitter','on','jitterAmount',1)
for stim=1:nStim
    Mean = mean(Prob_pulse(:,stim));
    SD = std(Prob_pulse(:,stim));
    plot([1,1]*OptStim(stim)+4,[-1,1]*SD+Mean,'r-','LineWidth',.5)
    plot([-1,1]+OptStim(stim)+4,[1,1]*Mean,'r-','LineWidth',.5)
end
plot([0,40],[0,0],'k:','LineWidth',.5)
xlim([0,40])
ylim([-.7,.7])
pbaspect([.7 1 1])
box off
set(gca,'YTick',[-.7,0,.7],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_sine(:),4,'b','filled','jitter','on','jitterAmount',1)
for stim=1:nStim
    Mean = mean(Prob_sine(:,stim));
    SD = std(Prob_sine(:,stim));
    plot([1,1]*OptStim(stim)+4,[-1,1]*SD+Mean,'b-','LineWidth',.5)
    plot([-1,1]+OptStim(stim)+4,[1,1]*Mean,'b-','LineWidth',.5)
end
plot([0,40],[0,0],'k:','LineWidth',.5)
xlim([0,40])
ylim([-.7,.7])
pbaspect([.7 1 1])
box off
set(gca,'YTick',[-.7,0,.7],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])
