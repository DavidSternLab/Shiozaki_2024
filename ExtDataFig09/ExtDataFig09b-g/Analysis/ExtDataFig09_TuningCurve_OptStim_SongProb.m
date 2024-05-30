function [] = ExtDataFig09_TuningCurve_OptStim_SongProb
% Code for plotting the tuning curves in Extended Data Fig. 9e-g.

GT = 'pIP10_Chr';
% GT = 'dPR1_Chr';
% GT = 'TN1_Chr';
% GT = 'pMP2_Chr';

switch GT
    case 'w_Chr'
        Target = [1,2];
    case 'pIP10_Chr'
        Target = [3,4];
        ylim1 = [-0.03,0.03];
        ylim2 = [-0.01,0.01];
        ylim3 = [-0.1,0.1];
    case 'pIP10_w'
        Target = [5,6];
    case 'dPR1_Chr'
        Target = [7,8];
        ylim1 = [-0.01,0.01];
        ylim2 = [-0.014,0.014];
        ylim3 = [-0.03,0.03];
    case 'dPR1_w'
        Target = [9,10];
    case 'TN1_Chr'
        Target = [11,12];
        ylim1 = [-0.02,0.02];
        ylim2 = [-0.012,0.012];
        ylim3 = [-0.01,0.01];
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
        ylim1 = [-0.01,0.01];
        ylim2 = [-0.01,0.01];
        ylim3 = [-0.01,0.01];
end

TargetPeriod = [0,5];
PrePeriod = [-5,0];
OptStim = [10,20,30];

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

%% song initiation probability
xx = x1(1:OneTrialDur)-PreDurImg/DAQrate;

Prob_QtoP = zeros(size(Data,1),nStim);
Prob_QtoS = zeros(size(Data,1),nStim);

for DataID=1:size(Data,1)
    for stim=1:nStim
        % Pre
        buf1 = mean(bufAve_QtoQ(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        buf2 = mean(bufAve_QtoP(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        buf3 = mean(bufAve_QtoS(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        divfact = buf1+buf2+buf3;
        Pre_QtoQ = buf1/divfact;
        Pre_QtoP = buf2/divfact;
        Pre_QtoS = buf3/divfact;

        % Stim
        buf1 = mean(bufAve_QtoQ(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        buf2 = mean(bufAve_QtoP(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        buf3 = mean(bufAve_QtoS(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        divfact = buf1+buf2+buf3;
        Stim_QtoQ = buf1/divfact;
        Stim_QtoP = buf2/divfact;
        Stim_QtoS = buf3/divfact;

        Prob_QtoP(DataID,stim) = Stim_QtoP - Pre_QtoP;
        Prob_QtoS(DataID,stim) = Stim_QtoS - Pre_QtoS;
    end
end

xx = zeros(size(Prob_QtoP));
for stim=1:nStim
    xx(:,stim) = OptStim(stim);
end

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_QtoP(:),4,'r','filled','jitter','on','jitterAmount',1)
for stim=1:nStim
    Mean = mean(Prob_QtoP(:,stim));
    SD = std(Prob_QtoP(:,stim));
    plot([1,1]*OptStim(stim)+4,[-1,1]*SD+Mean,'r-','LineWidth',.5)
    plot([-1,1]+OptStim(stim)+4,[1,1]*Mean,'r-','LineWidth',.5)
end
plot([0,40],[0,0],'k:','LineWidth',.5)
xlim([0,40])
ylim(ylim1)
pbaspect([.7 1 1])
box off
set(gca,'YTick',[ylim1(1),0,ylim1(2)],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_QtoS(:),4,'b','filled','jitter','on','jitterAmount',1)
for stim=1:nStim
    Mean = mean(Prob_QtoS(:,stim));
    SD = std(Prob_QtoS(:,stim));
    plot([1,1]*OptStim(stim)+4,[-1,1]*SD+Mean,'b-','LineWidth',.5)
    plot([-1,1]+OptStim(stim)+4,[1,1]*Mean,'b-','LineWidth',.5)
end
plot([0,40],[0,0],'k:','LineWidth',.5)
xlim([0,40])
ylim(ylim1)
pbaspect([.7 1 1])
box off
set(gca,'YTick',[ylim1(1),0,ylim1(2)],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])

%% song transition probability
xx = x1(1:OneTrialDur)-PreDurImg/DAQrate;

Prob_StoP = zeros(size(Data,1),nStim);
Prob_PtoS = zeros(size(Data,1),nStim);

for DataID=1:size(Data,1)
    for stim=1:nStim
        % Pre (P to S)
        buf1 = mean(bufAve_PtoQ(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        buf2 = mean(bufAve_PtoP(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        buf3 = mean(bufAve_PtoS(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        divfact = buf1+buf2+buf3;
        Pre_PtoQ = buf1/divfact;
        Pre_PtoP = buf2/divfact;
        Pre_PtoS = buf3/divfact;

        % Stim (P to S)
        buf1 = mean(bufAve_PtoQ(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        buf2 = mean(bufAve_PtoP(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        buf3 = mean(bufAve_PtoS(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        divfact = buf1+buf2+buf3;
        Stim_PtoQ = buf1/divfact;
        Stim_PtoP = buf2/divfact;
        Stim_PtoS = buf3/divfact;

        Prob_PtoS(DataID,stim) = Stim_PtoS - Pre_PtoS;

        % Pre (S to P)
        buf1 = mean(bufAve_StoQ(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        buf2 = mean(bufAve_StoP(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        buf3 = mean(bufAve_StoS(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        divfact = buf1+buf2+buf3;
        Pre_StoQ = buf1/divfact;
        Pre_StoP = buf2/divfact;
        Pre_StoS = buf3/divfact;

        % Stim (S to P)
        buf1 = mean(bufAve_StoQ(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        buf2 = mean(bufAve_StoP(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        buf3 = mean(bufAve_StoS(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        divfact = buf1+buf2+buf3;
        Stim_StoQ = buf1/divfact;
        Stim_StoP = buf2/divfact;
        Stim_StoS = buf3/divfact;

        Prob_StoP(DataID,stim) = Stim_StoP - Pre_StoP;
    end
end

xx = zeros(size(Prob_StoP));
for stim=1:nStim
    xx(:,stim) = OptStim(stim);
end

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_StoP(:),4,'r','filled','jitter','on','jitterAmount',1)
for stim=1:nStim
    Mean = mean(Prob_StoP(:,stim));
    SD = std(Prob_StoP(:,stim));
    plot([1,1]*OptStim(stim)+4,[-1,1]*SD+Mean,'r-','LineWidth',.5)
    plot([-1,1]+OptStim(stim)+4,[1,1]*Mean,'r-','LineWidth',.5)
end
plot([0,40],[0,0],'k:','LineWidth',.5)
xlim([0,40])
ylim(ylim2)
pbaspect([.7 1 1])
box off
set(gca,'YTick',[ylim2(1),0,ylim2(2)],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_PtoS(:),4,'b','filled','jitter','on','jitterAmount',1)
for stim=1:nStim
    Mean = mean(Prob_PtoS(:,stim));
    SD = std(Prob_PtoS(:,stim));
    plot([1,1]*OptStim(stim)+4,[-1,1]*SD+Mean,'b-','LineWidth',.5)
    plot([-1,1]+OptStim(stim)+4,[1,1]*Mean,'b-','LineWidth',.5)
end
plot([0,40],[0,0],'k:','LineWidth',.5)
xlim([0,40])
ylim(ylim2)
pbaspect([.7 1 1])
box off
set(gca,'YTick',[ylim2(1),0,ylim2(2)],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])

%% song termination probability
xx = x1(1:OneTrialDur)-PreDurImg/DAQrate;

Prob_PtoQ = zeros(size(Data,1),nStim);
Prob_StoQ = zeros(size(Data,1),nStim);

for DataID=1:size(Data,1)
    for stim=1:nStim
        % Pre (P to Q)
        buf1 = mean(bufAve_PtoQ(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        buf2 = mean(bufAve_PtoP(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        buf3 = mean(bufAve_PtoS(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        divfact = buf1+buf2+buf3;
        Pre_PtoQ = buf1/divfact;
        Pre_PtoP = buf2/divfact;
        Pre_PtoS = buf3/divfact;

        % Stim (P to Q)
        buf1 = mean(bufAve_PtoQ(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        buf2 = mean(bufAve_PtoP(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        buf3 = mean(bufAve_PtoS(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        divfact = buf1+buf2+buf3;
        Stim_PtoQ = buf1/divfact;
        Stim_PtoP = buf2/divfact;
        Stim_PtoS = buf3/divfact;

        Prob_PtoQ(DataID,stim) = Stim_PtoQ - Pre_PtoQ;

        % Pre (S to Q)
        buf1 = mean(bufAve_StoQ(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        buf2 = mean(bufAve_StoP(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        buf3 = mean(bufAve_StoS(DataID,PrePeriod(1)<=xx&xx<PrePeriod(2),stim));
        divfact = buf1+buf2+buf3;
        Pre_StoQ = buf1/divfact;
        Pre_StoP = buf2/divfact;
        Pre_StoS = buf3/divfact;

        % Stim (S to Q)
        buf1 = mean(bufAve_StoQ(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        buf2 = mean(bufAve_StoP(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        buf3 = mean(bufAve_StoS(DataID,TargetPeriod(1)<=xx&xx<=TargetPeriod(2),stim));
        divfact = buf1+buf2+buf3;
        Stim_StoQ = buf1/divfact;
        Stim_StoP = buf2/divfact;
        Stim_StoS = buf3/divfact;

        Prob_StoQ(DataID,stim) = Stim_StoQ - Pre_StoQ;
    end
end

xx = zeros(size(Prob_PtoQ));
for stim=1:nStim
    xx(:,stim) = OptStim(stim);
end

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_PtoQ(:),4,'r','filled','jitter','on','jitterAmount',1)
for stim=1:nStim
    Mean = mean(Prob_PtoQ(:,stim));
    SD = std(Prob_PtoQ(:,stim));
    plot([1,1]*OptStim(stim)+4,[-1,1]*SD+Mean,'r-','LineWidth',.5)
    plot([-1,1]+OptStim(stim)+4,[1,1]*Mean,'r-','LineWidth',.5)
end
plot([0,40],[0,0],'k:','LineWidth',.5)
xlim([0,40])
ylim(ylim3)
pbaspect([.7 1 1])
box off
set(gca,'YTick',[ylim3(1),0,ylim3(2)],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),Prob_StoQ(:),4,'b','filled','jitter','on','jitterAmount',1)
for stim=1:nStim
    Mean = mean(Prob_StoQ(:,stim));
    SD = std(Prob_StoQ(:,stim));
    plot([1,1]*OptStim(stim)+4,[-1,1]*SD+Mean,'b-','LineWidth',.5)
    plot([-1,1]+OptStim(stim)+4,[1,1]*Mean,'b-','LineWidth',.5)
end
plot([0,40],[0,0],'k:','LineWidth',.5)
xlim([0,40])
ylim(ylim3)
pbaspect([.7 1 1])
box off
set(gca,'YTick',[ylim3(1),0,ylim3(2)],'XTick',[0,OptStim],'TickDir','out','XTickLabel',[],'YTickLabel',[])


function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
