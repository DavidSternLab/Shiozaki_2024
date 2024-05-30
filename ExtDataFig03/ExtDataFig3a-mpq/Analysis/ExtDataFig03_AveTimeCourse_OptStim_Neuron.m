function [] = ExtDataFig03_AveTimeCourse_OptStim_Neuron()
% Code for plotting the time course of ΔF/F recorded from dPR1 and TN1A neurite in Extended Data Fig. 3a,h.Code for plotting the time course of ΔF/F recorded from dPR1 and TN1A neurite in Extended Data Fig. 3a,h.Code for plotting the time course of ΔF/F recorded from dPR1 and TN1A neurite in Extended Data Fig. 3a,h.

GT = 'dPR1NP'; % Extended Data Fig. 3a
% GT = 'TN1SGNP'; % Extended Data Fig. 3h

switch GT
    case 'dPR1NP'
        ylimrange1 = [0 .2];
        ylimrange2 = [-.1 .9];
        CellFlagNonTrans = [1,1,0,1,1,1,1,1,1,1,0,0,1];
    case 'TN1SGNP'
        ylimrange1 = [0 .1];
        ylimrange2 = [-0.05 0.4];
        CellFlagNonTrans = [1,1,1,0,0,0,1,0,1,1];
end

%% parameters
nTrials = 6;
nStim = 6;
T = 1370; % T

PreEventImg = 72; % 10 s (71.0443)
OneTrialDur = 214; % 30 s (213.1329)

StimTarget = [3];

Thre_nTrialOpto = 1;

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb'])
load([selpath,'EthogramComb'])
load([selpath,'EthogramCombImg'])
load('TS_Img')
load('TS_OptStimImg')

F_comb_org = F_comb;
Stim_comb_org = Stim_comb;

%%
Data_comb = [];
Counter = 1;

for DataID=1:length(F_comb_org)
    if CellFlagNonTrans(DataID)==1
        F_comb = F_comb_org{DataID};
        Stim_comb = Stim_comb_org{DataID};
        nROIs = size(F_comb,1);
        if strcmp(GT,'TN1SGNP')==1
            nROIs = 1; % 1: top part of the triangle, 2, bottom
        end
        bufEtho = squeeze(Ethogram_comb_Img(DataID,4,:,:));
        for ROI=1:nROIs
            %% trial average
            buf = squeeze(F_comb(ROI,:,:));
            bufF = [];
            for i=1:length(OptStimOnset_Img)
                for trial=1:nTrials
                    bufFlight = bufEtho([-PreEventImg:0]+OptStimOnset_Img(i)-1,trial);
                    if sum(bufFlight)==0
                        bufF = [bufF,buf([-PreEventImg:0]+OptStimOnset_Img(i)-1,trial)];
                    end
                end
            end
            F = mean(bufF(:));
            DFF = (buf-F)/F;

            buf_Data_comb = zeros(OneTrialDur,nStim,nTrials);
            RmvTrials = zeros(nStim,nTrials);
            for trial=1:nTrials
                for stim=1:nStim
                    ID = find(Stim_comb(:,trial)==stim);
                    bufData = DFF([1:OneTrialDur]+OptStimOnset_Img(ID)-PreEventImg-1,trial);
                    buf_Data_comb(:,stim,trial) = bufData;

                    % flight
                    bufFlight = bufEtho([1:OneTrialDur]+OptStimOnset_Img(ID)-PreEventImg-1,trial);
                    RmvTrials(stim,trial) = sum(bufFlight)>0;
                end
            end

            bufAve = zeros(OneTrialDur,nStim);
            for stim=1:nStim
                bufAve(:,stim) = mean(buf_Data_comb(:,stim,:),3);
            end

            Data_comb(Counter,:,:) = bufAve;
            Counter = Counter + 1;
        end
    end
end

%% plot
x = TS_Img(1:OneTrialDur)-10.1345;

x2 = [x, fliplr(x)];

figure('Position',[100,100,350,100])
for StimTarget=1:6
    subplot(1,6,StimTarget)
    hold on
    buf = Data_comb(:,:,StimTarget)';
    buf(:,isnan(buf(1,:))) = [];
    SEM = std(buf')/sqrt(size(buf,2));
    MEAN = mean(buf,2);
    plot(x,MEAN,'k','LineWidth',.5)
    curve1 = MEAN' + SEM;
    curve2 = MEAN' - SEM;
    inBetween = [curve1, fliplr(curve2)];
    h = fill(x2, inBetween, 'k','LineStyle','none');

    plot([0 10],[1 1]*0,'r','LineWidth',1)
    plot([-10 0],[1 1]*1,'k','LineWidth',1)
    plot([-10 -10],ylimrange1,'k','LineWidth',1)

    ylim(ylimrange2)
    xlim([-10 20])
    pbaspect([1,1,1])
    axis off
end
nNeurons = size(buf,2)
