function [] = ExtDataFig05_pIP10_OptStim_TuningCurve_Neuron()
% Code for plotting the tuning curves of calcium signals of each neuron induced by optogenetics in Extended Data Fig. 5h.

GT = 'TN1dsx';

switch GT
    case 'TN1dsx'
        ylimrange = [-1,4];
end

%% parameters
nTrials = 3;
nStim = 6;
T = 1370; % T

Thre_nTrialOpto = 1;

PreEventImg = 72; % 10 s (71.0443)
OneTrialDur = 214; % 30 s (213.1329)

StimTarget = [1,2,3];
TargetPeriod = [0,10];

Thre_RespIdx = 0.05;

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb'])
load([selpath,'EthogramComb'])
load([selpath,'EthogramCombImg'])
load('TS_Img')
load('TS_OptStimImg')
load([selpath,'ResponseIndex'])

switch GT
    case 'TN1dsx'
        CellFlagNonFlight = [1,1,1,1,1,1];
    case 'TN1SG'
        CellFlagNonFlight = [1,1,1,1,1,1];
end

F_comb_org = F_comb;
Stim_comb_org = Stim_comb;

%%
Data_comb = [];
Counter = 1;

for DataID=3:length(F_comb_org)
    if CellFlagNonFlight(DataID)==1
        F_comb = F_comb_org{DataID};
        Stim_comb = Stim_comb_org{DataID};
        nROIs = size(F_comb,1);
        bufEtho = squeeze(Ethogram_comb_Img(DataID,4,:,:));
        bufResponseIdx = ResponseIdx(ResponseIdx_FlyID==DataID);
        for ROI=1:nROIs
            if bufResponseIdx(ROI) < Thre_RespIdx
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

NeuroResp = zeros(size(Data_comb,1),nStim);
for DataID=1:size(Data_comb,1)
    for stim=1:nStim
        buf = Data_comb(DataID,:,stim);
        NeuroResp(DataID,stim) = mean(buf(TargetPeriod(1)<=x&x<=TargetPeriod(2)));
    end
end

xx = zeros(size(NeuroResp));
for stim=1:nStim
    xx(:,stim) = stim;
end

figure('Position',[100,100,50,50])
hold on
scatter(xx(:),NeuroResp(:),4,'k','filled','jitter','on','jitterAmount',.2)
for stim=1:nStim
    Mean = mean(NeuroResp(:,stim));
    SD = std(NeuroResp(:,stim));
    plot([1,1]*stim+.3,[-1,1]*SD+Mean,'k-','LineWidth',.5)
    plot([-.1,.1]+stim+.3,[1,1]*Mean,'k-','LineWidth',.5)
end
xlim([.5,6.5])
ylim(ylimrange)
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[-1:5],'XTick',[1:stim],'TickDir','out','XTickLabel',[],'YTickLabel',[])
