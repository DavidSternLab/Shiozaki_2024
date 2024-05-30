function [] = Fig01_AveTimeCourse_OptStim_Song
% Code for plotting the average time course of pulse and sine song during optogenetic activation of dPR1 and TN1A neurons in isolated male flies in Fig. 1c,d.

GT = 'dPR1_Chr'; % Fig. 1c: dPR1 > CsChrimson
% GT = 'TN1_Chr'; % Fig. 1d: TN1A > CsChrimson

switch GT
    case 'dPR1_Chr'
        Target = [7,8];
    case 'TN1_Chr'
        Target = [17,18];
end

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

figure
for stim=1:nStim
    subplot(1,6,stim)
    hold on
    plot(x1(1:OneTrialDur)-PreDurImg/DAQrate,mean(bufAve_pulse(:,:,stim)',2),'b','LineWidth',2)
    plot(x1(1:OneTrialDur)-PreDurImg/DAQrate,mean(bufAve_sine(:,:,stim)',2),'r','LineWidth',2)
    plot([0 10],[1 1]*1,'r','LineWidth',5)
    ylim([0 1])
    xlim([-10 20])
    set(gca,'XTick',[0,10],'YTick',[0,0.5,1])
    axis square
end

MovMeanWindow = 500; % 100 ms
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
    
    plot([0 10],[1 1]*1,'r','LineWidth',5)
    ylim([0 1])
    xlim([-5 15])
    set(gca,'XTick',[-5:5:15],'YTick',[0,0.5,1],'TickDir','out','XTickLabel',[],'YTickLabel',[])
    axis square
end

function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
