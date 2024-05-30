function [] = ExtDataFig03_DecayRateComparison_PtoS_OptOffset()
% Code for comparing half decay time of the dPR1 neurite GCaMP signals during pulse-to-sine transitions and after the offset of the song driver stimulation in Extended Data Fig. 3g.

GT = 'dPR1NP';

%% pulse-to-sine transitions
DurThre_sine = 5;
DecayRange_PtoS = [73:78];

Xlim_post = [-.5,1.5];

selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'Transitions'])

Ylim_1 = [0.4 0.85];
Yvert_1 = [0.4 0.5];

x = TS_Img(1:OnePeriodDur)-10.1345+mean(diff(TS_Img))/2;
x2 = [x, fliplr(x)];

TargetData = Data_PtoS_comb;
TargetSong = Song_PtoS_comb_sine;
bufpulse = Song_PtoS_comb_pulse;
bufsine = Song_PtoS_comb_sine;

buf_dur = zeros(size(TargetData,2),1);
for i=1:length(buf_dur)
    j = 1;
    while TargetSong(73+j,i)==1
        j = j + 1;
    end
    buf_dur(i) = j;
end

buf = TargetData(:,buf_dur>DurThre_sine);
MEAN_PtoS = mean(buf,2);
SEM_PtoS = std(buf')/sqrt(size(buf,2));
buf = bufpulse(:,buf_dur>DurThre_sine);
MEANSong_PtoS_pulse = mean(buf,2);
SEMSong_PtoS_pulse = std(buf')/sqrt(size(buf,2));
buf = bufsine(:,buf_dur>DurThre_sine);
MEANSong_PtoS_sine = mean(buf,2);
SEMSong_PtoS_sine = std(buf')/sqrt(size(buf,2));

h1 = figure('Position',[100 100 255 100]);
subplot(1,4,2)
plot(x,MEAN_PtoS,'k','LineWidth',.5)
hold on
curve1 = MEAN_PtoS' + SEM_PtoS;
curve2 = MEAN_PtoS' - SEM_PtoS;
inBetween = [curve1, fliplr(curve2)];
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim(Xlim_post)
ylim(Ylim_1)
plot([x(DecayRange_PtoS(1)),x(DecayRange_PtoS(end))],[0 0]+Ylim_1(1),'r','LineWidth',.5)
plot([0 0],ylim,'k:')
plot([-.5 0],[0 0]+Ylim_1(1),'k','LineWidth',1)
plot([-.5 -.5],Yvert_1,'k','LineWidth',1)
axis square
axis off

subplot(1,4,3)
plot(x,MEANSong_PtoS_pulse,'r','LineWidth',.5)
hold on
curve1 = MEANSong_PtoS_pulse' + SEMSong_PtoS_pulse;
curve2 = MEANSong_PtoS_pulse' - SEMSong_PtoS_pulse;
inBetween = [curve1, fliplr(curve2)];
h = fill(x2, inBetween, 'r','LineStyle','none');
plot(x,MEANSong_PtoS_sine,'b','LineWidth',.5)
curve1 = MEANSong_PtoS_sine' + SEMSong_PtoS_sine;
curve2 = MEANSong_PtoS_sine' - SEMSong_PtoS_sine;
inBetween = [curve1, fliplr(curve2)];
h = fill(x2, inBetween, 'b','LineStyle','none');
plot([x(DecayRange_PtoS(1)),x(DecayRange_PtoS(end))],[0 0],'r','LineWidth',.5)
xlim(Xlim_post)
plot([0 0],ylim,'k:')
axis square
axis off

f = fit(x(DecayRange_PtoS)',MEAN_PtoS(DecayRange_PtoS),'exp1')

%% offset of optogenetic stimulation
CellFlagNonTrans = [1,1,0,1,1,1,1,1,1,1,0,0,1];

Ylim_2 = [-.1 1.0];
Yvert_2 = [-.1 .1];
Ylim_3 = [0.05 0.5];
Yvert_3 = [0.05 0.15];

% parameters
nTrials = 6;
nStim = 6;

PreEventImg = 72; % 10 s (71.0443)
OneTrialDur = 214; % 30 s (213.1329)

Thre_nTrialOpto = 1;

% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb'])
load([selpath,'EthogramComb'])
load([selpath,'EthogramCombImg'])
load('TS_Img')
load('TS_OptStimImg')

F_comb_org = F_comb;
Stim_comb_org = Stim_comb;

% extract data
Data_comb = [];
Data_comb_pulse = [];
Data_comb_sine = [];
Counter = 1;
Counter_song = 1;

for DataID=1:length(F_comb_org)
    if CellFlagNonTrans(DataID)==1
        F_comb = F_comb_org{DataID};
        Stim_comb = Stim_comb_org{DataID};
        nROIs = size(F_comb,1);
        bufEtho = squeeze(Ethogram_comb_Img(DataID,4,:,:));
        bufEtho_pulse = squeeze(Ethogram_comb_Img(DataID,1,:,:)); % 1: pulse, 2: sine
        bufEtho_sine = squeeze(Ethogram_comb_Img(DataID,2,:,:)); % 1: pulse, 2: sine
        for ROI=1:nROIs
            % trial average
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
                bufAve(:,stim) = mean(buf_Data_comb(:,stim,RmvTrials(stim,:)==0),3);
            end

            Data_comb(Counter,:,:) = bufAve;
            Counter = Counter + 1;

            if ROIID==1
                buf_Data_pulse_comb = zeros(OneTrialDur,nStim,nTrials);
                buf_Data_sine_comb = zeros(OneTrialDur,nStim,nTrials);
                for trial=1:nTrials
                    for stim=1:nStim
                        ID = find(Stim_comb(:,trial)==stim);
                        % pulse
                        bufData = bufEtho_pulse([1:OneTrialDur]+OptStimOnset_Img(ID)-PreEventImg-1,trial);
                        buf_Data_pulse_comb(:,stim,trial) = bufData;
                        % sine
                        bufData = bufEtho_sine([1:OneTrialDur]+OptStimOnset_Img(ID)-PreEventImg-1,trial);
                        buf_Data_sine_comb(:,stim,trial) = bufData;
                    end
                end

                % averaging
                bufP = [];
                bufS = [];
                for trial=1:nStim
                    for stim=1:nStim
                        bufP = [bufP,buf_Data_pulse_comb(:,stim,trial)];
                        bufS = [bufS,buf_Data_sine_comb(:,stim,trial)];
                    end
                end
                Data_comb_pulse(Counter_song,:) = mean(bufP,2);
                Data_comb_sine(Counter_song,:) = mean(bufS,2);

                Counter_song = Counter_song + 1;
            end

        end
    end
end

bufMEAN_Offset = [];
bufMEAN_Offset_pulse = Data_comb_pulse';
bufMEAN_Offset_sine = Data_comb_sine';
for DataID=1:size(Data_comb,1)
    buf = squeeze(Data_comb(DataID,:,:));
    buf(:,isnan(buf(1,:))) = [];
    bufMEAN_Offset = [bufMEAN_Offset,mean(buf,2)];
end
MEAN_Offset = mean(bufMEAN_Offset,2);
SEM_Offset = std(bufMEAN_Offset')/sqrt(size(bufMEAN_Offset,2));
MEAN_Offset_pulse = mean(bufMEAN_Offset_pulse,2);
SEM_Offset_pulse = std(bufMEAN_Offset_pulse')/sqrt(size(bufMEAN_Offset_pulse,2));
MEAN_Offset_sine = mean(bufMEAN_Offset_sine,2);
SEM_Offset_sine = std(bufMEAN_Offset_sine')/sqrt(size(bufMEAN_Offset_sine,2));

OneTrialDur = 214; % 30 s (213.1329)
x = TS_Img(1:OneTrialDur)-10.1345;

DecayRange_OptOffset = [149:154];

x = TS_Img(1:OneTrialDur)-10.1345+mean(diff(TS_Img))/2;
x2 = [x, fliplr(x)];

h2 = figure('Position',[100 100 250 100]);
subplot(1,4,1)
plot(x,MEAN_Offset,'k','LineWidth',.5)
hold on
curve1 = MEAN_Offset' + SEM_Offset;
curve2 = MEAN_Offset' - SEM_Offset;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim([-5,15])
ylim(Ylim_2)
plot([x(DecayRange_OptOffset(1)),x(DecayRange_OptOffset(end))],[0 0]+Ylim_2(1),'r','LineWidth',.5)
plot([0,10],[0 0]+Ylim_2(2),'r','LineWidth',.5)
plot([-5 0],[0 0]+Ylim_2(1),'k','LineWidth',1)
plot([-5 -5],Yvert_2,'k','LineWidth',1)
axis square
axis off

subplot(1,4,2)
plot(x,MEAN_Offset,'k','LineWidth',.5)
hold on
curve1 = MEAN_Offset' + SEM_Offset;
curve2 = MEAN_Offset' - SEM_Offset;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim([10,12])
ylim(Ylim_3)
plot([x(DecayRange_OptOffset(1)),x(DecayRange_OptOffset(end))],[0 0]+Ylim_3(1),'r','LineWidth',.5)
plot([10 10.5],[0 0]+Ylim_3(1),'k','LineWidth',1)
plot([10 10],Yvert_3,'k','LineWidth',1)
axis square
axis off

subplot(1,4,3)
hold on
plot(x,MEAN_Offset_pulse,'r','LineWidth',.5)
curve1 = MEAN_Offset_pulse' + SEM_Offset_pulse;
curve2 = MEAN_Offset_pulse' - SEM_Offset_pulse;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
plot(x,MEAN_Offset_sine,'b','LineWidth',.5)
curve1 = MEAN_Offset_sine' + SEM_Offset_sine;
curve2 = MEAN_Offset_sine' - SEM_Offset_sine;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
plot([x(DecayRange_OptOffset(1)),x(DecayRange_OptOffset(end))],[.2,.2],'r','LineWidth',.5)
plot([0,10],[.2,.2],'r','LineWidth',.5)
xlim([-5,15])
ylim([0,.5])
axis square
axis off


f = fit(x(DecayRange_OptOffset)',MEAN_Offset(DecayRange_OptOffset),'exp1')
