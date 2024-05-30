function [] = ExtDataFig09_AveTimeCourse_OptStim_SongProb
% Code for plotting the time courses of song transition probabilities in Extended Data Fig. 9d.

% GT = 'pIP10_Chr';
GT = 'dPR1_Chr';
% GT = 'TN1_Chr';
% GT = 'pMP2_Chr';

switch GT
    case 'pIP10_Chr'
        Target = [3,4];
        TargetStim = 2;
        ylim1 = [0,0.014];
        ylim2 = [0,0.012];
        ylim3 = [0,0.03];
    case 'dPR1_Chr'
        Target = [7,8];
        TargetStim = 3;
        ylim1 = [0,0.014];
        ylim2 = [0,0.012];
        ylim3 = [0,0.03];
    case 'TN1_Chr'
        Target = [11,12]
        TargetStim = 1;
        ylim1 = [0,0.014];
        ylim2 = [0,0.012];
        ylim3 = [0,0.03];
    case 'pMP2_Chr'
        Target = [39,40];
        TargetStim = 3;
        ylim1 = [0,0.014];
        ylim2 = [0,0.012];
        ylim3 = [0,0.03];
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

ProbWindow = 1500; % 500: 0.1 s, 1000: 0.2 s

%%
UpSampleRate = 8;

Data = Ethogram_comb;
Data_comb_QtoP = [];
Data_comb_PtoP = [];
Data_comb_StoP = [];
Data_comb_QtoS = [];
Data_comb_PtoS = [];
Data_comb_StoS = [];
Data_comb_QtoQ = [];
Data_comb_PtoQ = [];
Data_comb_StoQ = [];

for DataID=1:size(Data,1)
    disp(['Data ID: ',num2str(DataID)])

    name = DataNames_OptStim(Target_File(DataID)).name;
    load([selpathOrg,name])

    % downsample ethogram
    bufEtho = Data(DataID,:);
    bufEtho = downsample(bufEtho,UpSampleRate);

    % quiet to pulse
    buf = zeros(size(bufEtho));
    buf0 = zeros(size(bufEtho));
    buf1 = zeros(size(bufEtho));
    bufbuf = find(bufEtho==0)-1;
    if bufbuf(1)==0
        bufbuf(1) = [];
    end
    buf0(bufbuf) = 1;
    buf1(find(bufEtho==1)) = 1;
    buf(buf0==1&buf1==1) = 1;
    buf = UpsampleData(buf,UpSampleRate);

    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_QtoP{DataID,stim} = bufData;
    end

    % pulse to pulse
    buf = zeros(size(bufEtho));
    buf0 = zeros(size(bufEtho));
    buf1 = zeros(size(bufEtho));
    bufbuf = find(bufEtho==1)-1;
    if bufbuf(1)==0
        bufbuf(1) = [];
    end
    buf0(bufbuf) = 1;
    buf1(find(bufEtho==1)) = 1;
    buf(buf0==1&buf1==1) = 1;
    buf = UpsampleData(buf,UpSampleRate);

    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_PtoP{DataID,stim} = bufData;
    end

    % sine to pulse
    buf = zeros(size(bufEtho));
    buf0 = zeros(size(bufEtho));
    buf1 = zeros(size(bufEtho));
    bufbuf = find(bufEtho==2)-1;
    if bufbuf(1)==0
        bufbuf(1) = [];
    end
    buf0(bufbuf) = 1;
    buf1(find(bufEtho==1)) = 1;
    buf(buf0==1&buf1==1) = 1;
    buf = UpsampleData(buf,UpSampleRate);

    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_StoP{DataID,stim} = bufData;
    end

    % quiet to sine
    buf = zeros(size(bufEtho));
    buf0 = zeros(size(bufEtho));
    buf1 = zeros(size(bufEtho));
    bufbuf = find(bufEtho==0)-1;
    if bufbuf(1)==0
        bufbuf(1) = [];
    end
    buf0(bufbuf) = 1;
    buf1(find(bufEtho==2)) = 1;
    buf(buf0==1&buf1==1) = 1;
    buf = UpsampleData(buf,UpSampleRate);

    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_QtoS{DataID,stim} = bufData;
    end

    % pulse to sine
    buf = zeros(size(bufEtho));
    buf0 = zeros(size(bufEtho));
    buf1 = zeros(size(bufEtho));
    bufbuf = find(bufEtho==1)-1;
    if bufbuf(1)==0
        bufbuf(1) = [];
    end
    buf0(bufbuf) = 1;
    buf1(find(bufEtho==2)) = 1;
    buf(buf0==1&buf1==1) = 1;
    buf = UpsampleData(buf,UpSampleRate);

    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_PtoS{DataID,stim} = bufData;
    end

    % sine to sine
    buf = zeros(size(bufEtho));
    buf0 = zeros(size(bufEtho));
    buf1 = zeros(size(bufEtho));
    bufbuf = find(bufEtho==2)-1;
    if bufbuf(1)==0
        bufbuf(1) = [];
    end
    buf0(bufbuf) = 1;
    buf1(find(bufEtho==2)) = 1;
    buf(buf0==1&buf1==1) = 1;
    buf = UpsampleData(buf,UpSampleRate);

    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_StoS{DataID,stim} = bufData;
    end


    % quiet to quiet
    buf = zeros(size(bufEtho));
    buf0 = zeros(size(bufEtho));
    buf1 = zeros(size(bufEtho));
    bufbuf = find(bufEtho==0)-1;
    if bufbuf(1)==0
        bufbuf(1) = [];
    end
    buf0(bufbuf) = 1;
    buf1(find(bufEtho==0)) = 1;
    buf(buf0==1&buf1==1) = 1;
    buf = UpsampleData(buf,UpSampleRate);

    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_QtoQ{DataID,stim} = bufData;
    end

    % pulse to quiet
    buf = zeros(size(bufEtho));
    buf0 = zeros(size(bufEtho));
    buf1 = zeros(size(bufEtho));
    bufbuf = find(bufEtho==1)-1;
    if bufbuf(1)==0
        bufbuf(1) = [];
    end
    buf0(bufbuf) = 1;
    buf1(find(bufEtho==0)) = 1;
    buf(buf0==1&buf1==1) = 1;
    buf = UpsampleData(buf,UpSampleRate);

    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_PtoQ{DataID,stim} = bufData;
    end

    % sine to quiet
    buf = zeros(size(bufEtho));
    buf0 = zeros(size(bufEtho));
    buf1 = zeros(size(bufEtho));
    bufbuf = find(bufEtho==2)-1;
    if bufbuf(1)==0
        bufbuf(1) = [];
    end
    buf0(bufbuf) = 1;
    buf1(find(bufEtho==0)) = 1;
    buf(buf0==1&buf1==1) = 1;
    buf = UpsampleData(buf,UpSampleRate);

    for stim=1:nStim
        bufTarget = find(OptStimID==stim);
        bufData = zeros(OneTrialDur,length(bufTarget));
        for i=1:length(bufTarget)
            bufData(:,i) = buf([1:OneTrialDur]+Opt_onset(bufTarget(i))-PreDurImg-1);
        end
        Data_comb_StoQ{DataID,stim} = bufData;
    end
end

bufAve_QtoP = zeros(size(Data,1),OneTrialDur,nStim);
bufAve_PtoP = zeros(size(Data,1),OneTrialDur,nStim);
bufAve_StoP = zeros(size(Data,1),OneTrialDur,nStim);
bufAve_QtoS = zeros(size(Data,1),OneTrialDur,nStim);
bufAve_PtoS = zeros(size(Data,1),OneTrialDur,nStim);
bufAve_StoS = zeros(size(Data,1),OneTrialDur,nStim);
bufAve_QtoQ = zeros(size(Data,1),OneTrialDur,nStim);
bufAve_PtoQ = zeros(size(Data,1),OneTrialDur,nStim);
bufAve_StoQ = zeros(size(Data,1),OneTrialDur,nStim);
for stim=1:nStim
    for DataID=1:size(Data,1)
        buf = Data_comb_QtoP{DataID,stim};
        bufAve_QtoP(DataID,:,stim) = mean(buf,2);
        buf = Data_comb_PtoP{DataID,stim};
        bufAve_PtoP(DataID,:,stim) = mean(buf,2);
        buf = Data_comb_StoP{DataID,stim};
        bufAve_StoP(DataID,:,stim) = mean(buf,2);

        buf = Data_comb_QtoS{DataID,stim};
        bufAve_QtoS(DataID,:,stim) = mean(buf,2);
        buf = Data_comb_PtoS{DataID,stim};
        bufAve_PtoS(DataID,:,stim) = mean(buf,2);
        buf = Data_comb_StoS{DataID,stim};
        bufAve_StoS(DataID,:,stim) = mean(buf,2);

        buf = Data_comb_QtoQ{DataID,stim};
        bufAve_QtoQ(DataID,:,stim) = mean(buf,2);
        buf = Data_comb_PtoQ{DataID,stim};
        bufAve_PtoQ(DataID,:,stim) = mean(buf,2);
        buf = Data_comb_StoQ{DataID,stim};
        bufAve_StoQ(DataID,:,stim) = mean(buf,2);
    end
end

%%
x = x1(1:OneTrialDur)-PreDurImg/DAQrate;
x = downsample(x,ProbWindow);
x2 = [x, fliplr(x)];

stim = TargetStim;

%% song initiation probability
buf1 = zeros(size(bufAve_QtoQ,2)/ProbWindow,1);
buf2 = zeros(size(bufAve_QtoP,2)/ProbWindow,1);
buf3 = zeros(size(bufAve_QtoS,2)/ProbWindow,1);
for i=1:(15*DAQrate)/ProbWindow
    buf1(i) = mean(mean(bufAve_QtoQ(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    buf2(i) = mean(mean(bufAve_QtoP(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    buf3(i) = mean(mean(bufAve_QtoS(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    divfact = buf1(i) + buf2(i) + buf3(i);
    buf1(i) = buf1(i)/divfact;
    buf2(i) = buf2(i)/divfact;
    buf3(i) = buf3(i)/divfact;
end
bufQP = buf2;
bufQS = buf3;

figure('Position',[100,100,50,50])
hold on

plot(x,bufQP,'r','LineWidth',.5) % quiet to pulse
plot(x,bufQS,'b','LineWidth',.5) % quiet to sine

plot([0 5],[1 1]*ylim1(2),'r','LineWidth',5)
ylim(ylim1)
xlim([-5 10])
set(gca,'XTick',[-5:5:10],'YTick',[0,ylim1(2)/2,ylim1(2)],'TickDir','out','XTickLabel',[],'YTickLabel',[])
axis square

%% song transition probability
buf1 = zeros(size(bufAve_PtoQ,2)/ProbWindow,1);
buf2 = zeros(size(bufAve_PtoQ,2)/ProbWindow,1);
buf3 = zeros(size(bufAve_PtoQ,2)/ProbWindow,1);
for i=1:(15*DAQrate)/ProbWindow
    buf1(i) = mean(mean(bufAve_PtoQ(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    buf2(i) = mean(mean(bufAve_PtoP(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    buf3(i) = mean(mean(bufAve_PtoS(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    divfact = buf1(i) + buf2(i) + buf3(i);
    buf1(i) = buf1(i)/divfact;
    buf2(i) = buf2(i)/divfact;
    buf3(i) = buf3(i)/divfact;
end
bufPS = buf3;

buf1 = zeros(size(bufAve_StoQ,2)/ProbWindow,1);
buf2 = zeros(size(bufAve_StoQ,2)/ProbWindow,1);
buf3 = zeros(size(bufAve_StoQ,2)/ProbWindow,1);
for i=1:(15*DAQrate)/ProbWindow
    buf1(i) = mean(mean(bufAve_StoQ(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    buf2(i) = mean(mean(bufAve_StoP(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    buf3(i) = mean(mean(bufAve_StoS(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    divfact = buf1(i) + buf2(i) + buf3(i);
    buf1(i) = buf1(i)/divfact;
    buf2(i) = buf2(i)/divfact;
    buf3(i) = buf3(i)/divfact;
end
bufSP = buf2;

figure('Position',[100,100,50,50])
hold on
plot(x,bufPS,'b','LineWidth',.5) % pulse to sine
plot(x,bufSP,'r','LineWidth',.5) % sine to pulse

plot([0 5],[1 1]*ylim2(2),'r','LineWidth',5)
ylim(ylim2)
xlim([-5 10])
set(gca,'XTick',[-5:5:10],'YTick',[0,ylim2(2)/2,ylim2(2)],'TickDir','out','XTickLabel',[],'YTickLabel',[])
axis square

%% song termination probability
buf1 = zeros(size(bufAve_PtoQ,2)/ProbWindow,1);
buf2 = zeros(size(bufAve_PtoQ,2)/ProbWindow,1);
buf3 = zeros(size(bufAve_PtoQ,2)/ProbWindow,1);
for i=1:(15*DAQrate)/ProbWindow
    buf1(i) = mean(mean(bufAve_PtoQ(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    buf2(i) = mean(mean(bufAve_PtoP(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    buf3(i) = mean(mean(bufAve_PtoS(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    divfact = buf1(i) + buf2(i) + buf3(i);
    buf1(i) = buf1(i)/divfact;
    buf2(i) = buf2(i)/divfact;
    buf3(i) = buf3(i)/divfact;
end
bufPQ = buf1;

buf1 = zeros(size(bufAve_StoQ,2)/ProbWindow,1);
buf2 = zeros(size(bufAve_StoQ,2)/ProbWindow,1);
buf3 = zeros(size(bufAve_StoQ,2)/ProbWindow,1);
for i=1:(15*DAQrate)/ProbWindow
    buf1(i) = mean(mean(bufAve_StoQ(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    buf2(i) = mean(mean(bufAve_StoP(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    buf3(i) = mean(mean(bufAve_StoS(:,[1:ProbWindow]+(i-1)*ProbWindow,stim)));
    divfact = buf1(i) + buf2(i) + buf3(i);
    buf1(i) = buf1(i)/divfact;
    buf2(i) = buf2(i)/divfact;
    buf3(i) = buf3(i)/divfact;
end
bufSQ = buf1;

figure('Position',[100,100,50,50])
hold on

plot(x,bufPQ,'r','LineWidth',.5) % pulse to quiet
plot(x,bufSQ,'b','LineWidth',.5) % sine to quiet

plot([0 5],[1 1]*ylim3(2),'r','LineWidth',5)
ylim(ylim3)
xlim([-5 10])
set(gca,'XTick',[-5:5:10],'YTick',[0,ylim3(2)/2,ylim3(2)],'TickDir','out','XTickLabel',[],'YTickLabel',[])
axis square


function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
