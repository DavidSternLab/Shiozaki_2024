function [] = Fig07_AveTimeCourse_OptStim_Song
% Code for plotting the time courses of pulse and sine song in Fig. 7c.

% GT = 'pIP10_Chr';
GT = 'dPR1_Chr';
% GT = 'TN1_Chr';
% GT = 'pMP2_Chr';

switch GT
    case 'pIP10_Chr'
        Target = [3,4];
    case 'dPR1_Chr'
        Target = [7,8];
    case 'TN1_Chr'
        Target = [11,12];
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

figure
for stim=1:nStim
    subplot(1,3,stim)
    hold on
    for DataID=1:size(Data,1)
        plot(x1(1:OneTrialDur)-PreDurImg/DAQrate,movmean(bufAve_sine(DataID,:,stim),500),'r');
        plot(x1(1:OneTrialDur)-PreDurImg/DAQrate,movmean(bufAve_pulse(DataID,:,stim),500),'b');
    end
    
    plot(x1(1:OneTrialDur)-PreDurImg/DAQrate,mean(bufAve_pulse(:,:,stim)',2),'b','LineWidth',2)
    plot(x1(1:OneTrialDur)-PreDurImg/DAQrate,mean(bufAve_sine(:,:,stim)',2),'r','LineWidth',2)
    plot([0 5],[1 1]*1,'r','LineWidth',5)
    ylim([0 1])
    xlim([-5 10])
    set(gca,'XTick',[0,10],'YTick',[0,0.5,1])
    axis square
end

MovMeanWindow = 500;
x = x1(1:OneTrialDur)-PreDurImg/DAQrate;
x = downsample(x,MovMeanWindow);
x2 = [x, fliplr(x)];

for stim=1:nStim
    figure('Position',[100,100,50,50])
    hold on
    
    % pulse
    buf = bufAve_pulse(:,:,stim);
    bufPlot = zeros(size(Data,1),length(x));
    for DataID=1:size(Data,1)
        bufPlot(DataID,:) = downsample(movmean(buf(DataID,:),MovMeanWindow),MovMeanWindow);
    end
    SEM = std(bufPlot)/sqrt(size(bufPlot,1));
    MEAN = mean(bufPlot,1);
    curve1 = MEAN + SEM;
    curve2 = MEAN - SEM;
    inBetween = [curve1, fliplr(curve2)];
    h = fill(x2, inBetween,'r','LineStyle','none');
    plot(x,MEAN,'r','LineWidth',.5)
    
    % sine
    buf = bufAve_sine(:,:,stim);
    bufPlot = zeros(size(Data,1),length(x));
    for DataID=1:size(Data,1)
        bufPlot(DataID,:) = downsample(movmean(buf(DataID,:),MovMeanWindow),MovMeanWindow);
    end
    SEM = std(bufPlot)/sqrt(size(bufPlot,1));
    MEAN = mean(bufPlot,1);
    curve1 = MEAN + SEM;
    curve2 = MEAN - SEM;
    inBetween = [curve1, fliplr(curve2)];
    h = fill(x2, inBetween,'b','LineStyle','none');
    plot(x,MEAN,'b','LineWidth',.5)
    
    plot([0 5],[1 1]*1,'r','LineWidth',5)
    ylim([0 1])
    xlim([-5 10])
    set(gca,'XTick',[-5:5:10],'YTick',[0,0.5,1],'TickDir','out','XTickLabel',[],'YTickLabel',[])
    axis square
end


function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
