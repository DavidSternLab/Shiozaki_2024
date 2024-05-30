function [] = ExtDataFig05_AveTimeCourse_OptStim_Neuron()
% Code for plotting the time course of ΔF/F recorded from TN1 in Extended Data Fig. 5c.

GT = 'TN1dsx';

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
load([selpath,'ResponseIndex'])
load([selpath,'SongTypePrefIndex'])
load('TS_Img')
load('TS_OptStimImg')

CellFlagNonTrans = [0,1,0,0,1,0,1,0,0,1,0,0];

F_comb_org = F_comb;
Stim_comb_org = Stim_comb;

Thre_Resp = 0.05;
Thre_SongType = 0.05;

%%
Data_comb_pulsePref = [];
Counter_pulsePref = 1;
Data_comb_sinePref = [];
Counter_sinePref = 1;
Data_comb_noPref = [];
Counter_noPref = 1;

for DataID=1:length(F_comb_org)
    if CellFlagNonTrans(DataID)==1
        bufRespIdx = ResponseIdx(ResponseIdx_FlyID==DataID);
        bufIdx_SongType = Idx_SongType(ID_comb==DataID);
        bufP_SongType = P_SongType(ID_comb==DataID);
        
        F_comb = F_comb_org{DataID};
        Stim_comb = Stim_comb_org{DataID};
        nROIs = size(F_comb,1);
        bufEtho = squeeze(Ethogram_comb_Img(DataID,4,:,:));
        CounterROI = 1;
        for ROI=1:nROIs
            if bufRespIdx(ROI)<Thre_Resp
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
                
                if bufP_SongType(CounterROI)<Thre_SongType
                    % pulse
                    if bufIdx_SongType(CounterROI)<0
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
                        
                        Data_comb_pulsePref(Counter_pulsePref,:,:) = bufAve;
                        Counter_pulsePref = Counter_pulsePref + 1;
                    end
                    
                    % sine
                    if bufIdx_SongType(CounterROI)>0
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
                        
                        Data_comb_sinePref(Counter_sinePref,:,:) = bufAve;
                        Counter_sinePref = Counter_sinePref + 1;
                    end
                    
                else
                    % no
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
                    
                    Data_comb_noPref(Counter_noPref,:,:) = bufAve;
                    Counter_noPref = Counter_noPref + 1;
                end
                CounterROI = CounterROI + 1;
            end
        end
    end
end


%% plot
x = TS_Img(1:OneTrialDur)-10.1345;
x2 = [x, fliplr(x)];

% pulse
Data_comb = Data_comb_pulsePref;
figure('Position',[100,100,48,48])
hold on
buf = Data_comb(:,:,StimTarget)';
buf(:,isnan(buf(1,:))) = [];
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
%     h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');

plot([0 10],[1 1]*0,'r','LineWidth',1)
plot([-10 0],[1 1]*1,'k','LineWidth',1)
plot([-10 -10],[0 1],'k','LineWidth',1)
ylim([-0.5 3])
xlim([-10 20])
pbaspect([1,1,1])
axis off

nPulseNeurons = size(buf,2)

% sine
Data_comb = Data_comb_sinePref;
figure('Position',[100,100,48,48])
hold on
buf = Data_comb(:,:,StimTarget)';
buf(:,isnan(buf(1,:))) = [];
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
%     h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');

plot([0 10],[1 1]*0,'r','LineWidth',1)
plot([-10 0],[1 1]*1,'k','LineWidth',1)
plot([-10 -10],[0 1],'k','LineWidth',1)
ylim([-0.5 3])
xlim([-10 20])
pbaspect([1,1,1])
axis off

nSineNeurons = size(buf,2)