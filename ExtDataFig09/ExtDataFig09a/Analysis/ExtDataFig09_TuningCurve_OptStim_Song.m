function [] = ExtDataFig09_TuningCurve_OptStim_Song
% Code for plotting the tuning curves of pulse and sine songs induced by optogenetics in Extended Data Fig. 9a.

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
    case 'w_LChr'
        Target = [11,12];
    case 'pIP10L_Chr'
        Target = [13,14];
    case 'pIP10L_w'
        Target = [15,16];
    case 'TN1_Chr'
        Target = [17,18];
    case 'TN1_w'
        Target = [19,20];
    case 'pMP2_Chr'
        Target = [21,22];
end

TargetPeriod = [0,10];
OptStim = [10,20,40,60,80,100];

%% get filenames
selpathOrg = ['../Data/Summary/'];
DataNames_OptStim = dir([selpathOrg,'/OptStim_*']);
CellFlag = readmatrix([selpathOrg,'dataset.csv']);
CellFlag(:,1) = []; % Gal4xChr, Gal4xw, wxChr
load([selpathOrg,['EthogramCombPulseTrain_',GT]])

%% genotypes
Target_File = CellFlag(Target(1),:);
Target_Channel = CellFlag(Target(2),:);
buf = isnan(Target_File);
Target_File(buf) = [];

%% parameters
nTrials = 6;
nStim = 6;

RecDur = 1320; % 1320 s = 22 min
DAQrate = 5000;
x1 = [0:1/DAQrate:RecDur-1/DAQrate];

PreDurImg = 10*DAQrate; % 10 s
OneTrialDur = 30*DAQrate; % 30 s

%%
Data = Ethogram_comb;
Data_comb_pulse = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
Data_comb_sine = zeros(size(Data,1),OneTrialDur,nStim,nTrials);

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
            for trial=1:nTrials
                Data_comb_pulse(DataID,:,stim,trial) = buf([1:OneTrialDur]+Opt_onset(stim+(trial-1)*nStim)-PreDurImg-1);
            end
        end
        
        % sine
        % downsample ethogram
        bufEtho = Data(DataID,:);
        buf = zeros(size(bufEtho));
        buf(find(bufEtho==2)) = 1;
        for stim=1:nStim
            for trial=1:nTrials
                Data_comb_sine(DataID,:,stim,trial) = buf([1:OneTrialDur]+Opt_onset(stim+(trial-1)*nStim)-PreDurImg-1);
            end
        end
end
bufAve_pulse = mean(Data_comb_pulse,4);
bufAve_sine = mean(Data_comb_sine,4);

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
xlim([0,110])
ylim([0,1])
pbaspect([1 1 1])
box off
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
xlim([0,110])
ylim([0,1])
pbaspect([1 1 1])
box off
set(gca,'YTick',[0,.5,1],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])
