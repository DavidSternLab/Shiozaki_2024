function [] = ExtDataFig08_AveTimeCourse_OptStim_Neuron()
% Code for plotting the time course of ΔF/F in Extended Data Fig. 8a,d.

GT = 'pIP10'; Target = 'pIP10_NR'; % Extended Data Fig. 8a
% GT = 'pMP2'; Target = 'pMP2_NR'; % Extended Data Fig. 8d

switch Target
    case 'pIP10_NR'
        TargetROI = 3;
        ylimrange1 = [0 .5];
        ylimrange2 = [-.2 1];
    case 'pMP2_NR'
        TargetROI = [5,6];
        ylimrange1 = [0 .2];
        ylimrange2 = [-.3 .7];
end

%% parameters
nTrials = 6;
nStim = 6;
T = 1370; % T

PreEventImg = 72; % 10 s (71.0443)
OneTrialDur = 214; % 30 s (213.1329)

StimTarget = [6];

Thre_nTrialOpto = 1;

Thre_Resp = 0.05;

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb'])
load([selpath,'EthogramComb'])
load([selpath,'EthogramCombImg'])
load([selpath,'ResponseIndex'])
load('TS_Img')
load('TS_OptStimImg')

F_comb_org = F_comb;
Stim_comb_org = Stim_comb;

Dataset = readtable([selpath,'Dataset.csv']);
if strcmp(GT,'pIP10')
    DataFlag = Dataset{:,2:7};
    DataFlag(:,3) = [];
elseif strcmp(GT,'pMP2')
    DataFlag = Dataset{:,2:9};
end

%%
Data_comb = [];
Counter = 1;

for DataID=1:length(F_comb_org)
    F_comb = F_comb_org{DataID};
    Stim_comb = Stim_comb_org{DataID};
    nROIs = size(F_comb,1);
    bufEtho = squeeze(Ethogram_comb_Img(DataID,4,:,:));
    bufResponseIdx = ResponseIdx(ResponseIdx_FlyID==DataID);
    for ROI=1:nROIs
        if ismember(ROI,TargetROI) & DataFlag(DataID,ROI)==1
            if bufResponseIdx(ROI) < Thre_Resp
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
                    if sum(RmvTrials(stim,:)==0)>=Thre_nTrialOpto
                        bufAve(:,stim) = mean(buf_Data_comb(:,stim,RmvTrials(stim,:)==0),3);
                    else
                        bufAve(:,stim) = NaN;
                    end
                end

                Data_comb(Counter,:,:) = bufAve;
                Counter = Counter + 1;
            end
        end
    end
end

%% plot
x = TS_Img(1:OneTrialDur)-10.1345;

x2 = [x, fliplr(x)];

figure('Position',[100,100,52,52])
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

nNeurons = size(buf,2)
