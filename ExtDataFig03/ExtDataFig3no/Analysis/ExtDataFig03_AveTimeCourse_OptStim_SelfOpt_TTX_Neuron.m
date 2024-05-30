function [] = ExtDataFig03_AveTimeCourse_OptStim_SelfOpt_TTX_Neuron()
% Code for plotting the time course of ΔF/F recorded from dPR1 and TN1A neurons in Extended Data Fig. 3n,o.

GT = 'dPR1'; % Extended Data Fig. 3n
% GT = 'TN1A'; % Extended Data Fig. 3o

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
Data_comb_BeforeTTX = [];
Data_comb_AfterTTX = [];
Counter = 1;

for DataID=1:length(F_comb_org)
    F_comb = F_comb_org{DataID};
    Stim_comb = Stim_comb_org{DataID};
    nROIs = size(F_comb,1);
    
    for ROI=1:nROIs
        %% trial average (before TTX)
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

        Data_comb_BeforeTTX(Counter,:,:) = bufAve;

        %% trial average (after TTX)
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

        Data_comb_AfterTTX(Counter,:,:) = bufAve;
        Counter = Counter + 1;
    end
end

%% plot
switch GT
    case 'dPR1'
        yscalebar = [0 .2];
        ylimrange = [-.1 .8];
    case 'TN1A'
        yscalebar = [0,.2];
        ylimrange = [-.05 0.6];
end

x = TS_Img(1:OneTrialDur)-10.1345;
x2 = [x, fliplr(x)];

% After TTX
figure('Position',[100,100,350,100])
for stim=1:6
    subplot(1,6,stim)
    hold on

    buf = Data_comb_AfterTTX(:,:,StimTarget(stim))';
    SEM = std(buf')/sqrt(size(buf,2));
    MEAN = mean(buf,2);
    plot(x,MEAN,'k','LineWidth',.5)
    curve1 = MEAN' + SEM;
    curve2 = MEAN' - SEM;
    inBetween = [curve1, fliplr(curve2)];
    h = fill(x2, inBetween, 'k','LineStyle','none');

    plot([0 10],[1 1]*0,'r','LineWidth',1)
    if stim==1
        plot([-10 0],[.5 .5]*1,'k','LineWidth',1)
        plot([-10 -10],yscalebar,'k','LineWidth',1)
    end
    ylim(ylimrange)
    xlim([-10 20])
    pbaspect([1,1,1])
    axis off
end

bufData = mean(Data_comb_AfterTTX(:,:,5));
DecayRange_OptOffset = [149:154];

f = fit(x(DecayRange_OptOffset)',bufData(DecayRange_OptOffset)','exp1')
figure
plot(f,x(DecayRange_OptOffset)',bufData(DecayRange_OptOffset))
