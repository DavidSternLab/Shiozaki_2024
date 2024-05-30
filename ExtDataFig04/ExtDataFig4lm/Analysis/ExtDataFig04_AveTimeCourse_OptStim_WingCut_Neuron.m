function [] = ExtDataFig04_AveTimeCourse_OptStim_WingCut_Neuron()
% Code for plotting the tuning curves of calcium signals of each neuron induced by optogenetics in Extended Data Fig. 4l,m.

GT = 'WingCut_dPR1'; % Extended Data Fig. 4l
% GT = 'WingCut_TN1SG'; % Extended Data Fig. 4m

switch GT
    case 'WingCut_dPR1'
        WingCutID = [0,1,0,1,0,1,0,1,1,0,1];
    case 'WingCut_TN1SG'
        WingCutID = [1,1,1,1,1,1,0,0,0,0,0,0];
end

%% parameters
nTrials = 2;
nStim = 6;
T = 1370; % T

PreEventImg = 72; % 10 s (71.0443)
OneTrialDur = 214; % 30 s (213.1329)

StimTarget = [1:6];

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb'])
load('TS_Img')
load('TS_OptStimImg')

F_comb_org = F_comb;
Stim_comb_org = Stim_comb;

%% Before wing cut
Data_comb_WingCut_BeforeCut = [];
Data_comb_WingCut_AfterCut = [];
Counter_WingCut = 1;
Data_comb_NoWingCut_BeforeCut = [];
Data_comb_NoWingCut_AfterCut = [];
Counter_NoWingCut = 1;

for DataID=1:length(F_comb_org)
    F_comb = F_comb_org{DataID};
    Stim_comb = Stim_comb_org{DataID};
    nROIs = size(F_comb,1);
    for ROI=1:nROIs
        if ~(strcmp(GT,'WingCut_dPR1')&DataID==3&ROI==2) % the right dPR1 in Data ID of 3 not recorded
            %% trial average (before cut)
            buf = squeeze(F_comb(ROI,:,:));
            bufF = [];
            for i=1:length(OptStimOnset_Img)
                for trial=1:nTrials
                    bufF = [bufF,buf([-PreEventImg:0]+OptStimOnset_Img(i)-1,trial)];
                end
            end
            F = mean(bufF(:));
            DFF = (buf-F)/F;

            buf_Data_comb = zeros(OneTrialDur,nStim,nTrials);
            for trial=1:nTrials
                for stim=1:nStim
                    ID = find(Stim_comb(:,trial)==stim);
                    bufData = DFF([1:OneTrialDur]+OptStimOnset_Img(ID)-PreEventImg-1,trial);
                    buf_Data_comb(:,stim,trial) = bufData;
                end
            end

            bufAve = zeros(OneTrialDur,nStim);
            for stim=1:nStim
                bufAve(:,stim) = mean(buf_Data_comb(:,stim,:),3);
            end

            if WingCutID(DataID)==1
                Data_comb_WingCut_BeforeCut(Counter_WingCut,:,:) = bufAve;
            else
                Data_comb_NoWingCut_BeforeCut(Counter_NoWingCut,:,:) = bufAve;
            end

            %% trial average (after cut)
            buf = squeeze(F_comb(ROI,:,:));
            bufF = [];
            for i=1:length(OptStimOnset_Img)
                for trial=1:nTrials
                    bufF = [bufF,buf([-PreEventImg:0]+OptStimOnset_Img(i)-1,trial+2)];
                end
            end
            F = mean(bufF(:));
            DFF = (buf-F)/F;

            buf_Data_comb = zeros(OneTrialDur,nStim,nTrials);
            for trial=1:nTrials
                for stim=1:nStim
                    ID = find(Stim_comb(:,trial+2)==stim);
                    bufData = DFF([1:OneTrialDur]+OptStimOnset_Img(ID)-PreEventImg-1,trial+2);
                    buf_Data_comb(:,stim,trial) = bufData;
                end
            end

            bufAve = zeros(OneTrialDur,nStim);
            for stim=1:nStim
                bufAve(:,stim) = mean(buf_Data_comb(:,stim,:),3);
            end

            if WingCutID(DataID)==1
                Data_comb_WingCut_AfterCut(Counter_WingCut,:,:) = bufAve;
                Counter_WingCut = Counter_WingCut + 1;
            else
                Data_comb_NoWingCut_AfterCut(Counter_NoWingCut,:,:) = bufAve;
                Counter_NoWingCut = Counter_NoWingCut + 1;
            end
        end
    end
end


%% plot
switch GT
    case 'WingCut_dPR1'
        yscalebar1 = [0,.5];
        ylimrange1 = [-.2 2.2];
        yscalebar2 = [0,.5];
        ylimrange2 = [-.2 2.2];
    case 'WingCut_TN1SG'
        yscalebar1 = [0,.5];
        ylimrange1 = [-.4 2.2];
        yscalebar2 = [0,.5];
        ylimrange2 = [-.2 1.0];
end

x = TS_Img(1:OneTrialDur)-10.1345;
x2 = [x, fliplr(x)];

figure('Position',[100,100,400,120])

% wing cut
for stim=1:6
    subplot(2,6,stim)
    hold on

    buf = Data_comb_WingCut_BeforeCut(:,:,StimTarget(stim))';
    SEM = std(buf')/sqrt(size(buf,2));
    MEAN = mean(buf,2);
    plot(x,MEAN,'k','LineWidth',.5)
    curve1 = MEAN' + SEM;
    curve2 = MEAN' - SEM;
    inBetween = [curve1, fliplr(curve2)];
    h = fill(x2, inBetween, 'k','LineStyle','none');

    buf = Data_comb_WingCut_AfterCut(:,:,StimTarget(stim))';
    SEM = std(buf')/sqrt(size(buf,2));
    MEAN = mean(buf,2);
    plot(x,MEAN,'r','LineWidth',.5)
    curve1 = MEAN' + SEM;
    curve2 = MEAN' - SEM;
    inBetween = [curve1, fliplr(curve2)];
    h = fill(x2, inBetween, 'r','LineStyle','none');

    plot([0 10],[1 1]*0,'r','LineWidth',1)
    if stim==1
        plot([-10 0],[.5 .5]*1,'k','LineWidth',1)
        plot([-10 -10],yscalebar1,'k','LineWidth',1)
    end
    ylim(ylimrange1)
    xlim([-10 20])
    pbaspect([1,1,1])
    axis off
end

% no wing cut
for stim=1:6
    subplot(2,6,stim+6)
    hold on

    buf = Data_comb_NoWingCut_BeforeCut(:,:,StimTarget(stim))';
    SEM = std(buf')/sqrt(size(buf,2));
    MEAN = mean(buf,2);
    plot(x,MEAN,'k','LineWidth',.5)
    curve1 = MEAN' + SEM;
    curve2 = MEAN' - SEM;
    inBetween = [curve1, fliplr(curve2)];
    h = fill(x2, inBetween, 'k','LineStyle','none');

    buf = Data_comb_NoWingCut_AfterCut(:,:,StimTarget(stim))';
    SEM = std(buf')/sqrt(size(buf,2));
    MEAN = mean(buf,2);
    plot(x,MEAN,'r','LineWidth',.5)
    curve1 = MEAN' + SEM;
    curve2 = MEAN' - SEM;
    inBetween = [curve1, fliplr(curve2)];
    h = fill(x2, inBetween, 'r','LineStyle','none');

    plot([0 10],[1 1]*0,'r','LineWidth',1)
    if stim==1
        plot([-10 0],[.5 .5]*1,'k','LineWidth',1)
        plot([-10 -10],yscalebar2,'k','LineWidth',1)
    end
    ylim(ylimrange2)
    xlim([-10 20])
    pbaspect([1,1,1])
    axis off
end
