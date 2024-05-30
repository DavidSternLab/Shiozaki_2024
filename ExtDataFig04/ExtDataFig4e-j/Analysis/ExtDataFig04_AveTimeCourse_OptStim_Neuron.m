function [] = ExtDataFig04_AveTimeCourse_OptStim_Neuron()
% Code for plotting the time course of ΔF/F recorded from dPR1 and TN1A in Extended Data Fig. 4e,h.

GT = 'dPR1'; % Extended Data Fig. 4e
% GT = 'TN1SG'; % Extended Data Fig. 4h

%% parameters
nTrials = 3;
nStim = 6;
T = 1370; % T

FlightTrialThre = 3;

PreEventImg = 72; % 10 s (71.0443)
OneTrialDur = 214; % 30 s (213.1329)

StimTarget = [2,4,6];
%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb'])
load([selpath,'EthogramComb'])
load([selpath,'EthogramCombImg'])
load('TS_Img')
load('TS_OptStimImg')

switch GT
    case 'dPR1'
        CellFlagNonFlight = [1,1,1,1,1,1];
    case 'TN1SG'
        CellFlagNonFlight = [1,1,1,1,1,1];
end

F_comb_org = F_comb;
Stim_comb_org = Stim_comb;

%%
Data_comb = [];
Counter = 1;

for DataID=1:length(F_comb_org)
    if CellFlagNonFlight(DataID)==1
        F_comb = F_comb_org{DataID};
        Stim_comb = Stim_comb_org{DataID};
        nROIs = size(F_comb,1);
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
            if sum(sum(RmvTrials,2)>=FlightTrialThre)>0
                disp('too many flight trials')
                keyboard
            end
            
            bufAve = zeros(OneTrialDur,nStim);
            for stim=1:nStim
                bufAve(:,stim) = mean(buf_Data_comb(:,stim,RmvTrials(stim,:)==0),3);
            end
            
            Data_comb(Counter,:,:) = bufAve;
            Counter = Counter + 1;
        end
    end
end


%% plot
switch GT
    case 'dPR1'
        yscalebar = [0,1];
        ylimrange = [-0.5 5];
    case 'TN1SG'
        yscalebar = [0,.5];
        ylimrange = [-0.2 1.2];
end

x = TS_Img(1:OneTrialDur)-10.1345;
x2 = [x, fliplr(x)];


switch GT
    case 'dPR1'
        figure('Position',[100,100,160,160])
    case 'TN1SG'
        figure('Position',[100,100,188,188]) % 180<,185< 9.782, <190 10.481
end

for stim=1:3
    subplot(1,3,stim)
    hold on
    buf = Data_comb(:,:,StimTarget(stim))';
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