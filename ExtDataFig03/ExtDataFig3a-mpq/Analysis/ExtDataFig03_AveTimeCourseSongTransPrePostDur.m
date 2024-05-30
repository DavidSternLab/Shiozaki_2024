function [] = ExtDataFig03_AveTimeCourseSongTransPrePostDur()
% Code for plotting calcium signals and song probabilities during song type transitions separately for short and long song bouts in Extended Data Fig. 3f,m.

GT = 'dPR1NP'; % Extended Data Fig. 3f
% GT = 'TN1SGNP'; % Extended Data Fig. 3m

DurThre_sine = 5;
DurThre_pulse = 3;

Xlim_post = [-.5,1.5];
Xlim_pre = [-1.0,.5];

selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'Transitions'])

%%
switch GT
    case 'dPR1NP'
        Ylim_1 = [0.5 0.9];
        Yvert_1 = [0.5 0.6];
        Ylim_2 = [0.4 0.8];
        Yvert_2 = [0.4 0.5];
        Ylim_3 = [0.5 1.0];
        Yvert_3 = [0.5 0.6];
        Ylim_4 = [0.5 1.0];
        Yvert_4 = [0.5 0.6];
        Ylim_5 = [0.5 0.8];
        Yvert_5 = [0.5 0.6];
        Ylim_6 = [0.6 0.9];
        Yvert_6 = [0.6 0.7];
        Ylim_7 = [0.6 1.1];
        Yvert_7 = [0.6 0.7];
        Ylim_8 = [0.4 0.9];
        Yvert_8 = [0.4 0.5];
    case 'TN1SGNP'
        Ylim_1 = [0.1 0.3];
        Yvert_1 = [0.1 0.15];
        Ylim_2 = [0.2 0.4];
        Yvert_2 = [0.2 0.25];
        Ylim_3 = [0.2 0.4];
        Yvert_3 = [0.2 0.25];
        Ylim_4 = [0.05 0.25];
        Yvert_4 = [0.05 0.1];
        Ylim_5 = [0.15 0.35];
        Yvert_5 = [0.15 0.2];
        Ylim_6 = [0.05 0.25];
        Yvert_6 = [0.05 0.1];
        Ylim_7 = [0.1 0.3];
        Yvert_7 = [0.1 0.15];
        Ylim_8 = [0.25 0.45];
        Yvert_8 = [0.25 0.3];
end

x = TS_Img(1:OnePeriodDur)-10.1345+mean(diff(TS_Img))/2;
x2 = [x, fliplr(x)];

%% make figures
%% pulse to sine, sine durations
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

figure('Position',[100 100 177 177])

% neuron
buf = TargetData(:,buf_dur<=DurThre_sine); size(buf,2)
subplot(2,3,2)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim(Xlim_post)
ylim(Ylim_1)
plot([0 0],ylim,'k:')
plot([-.5 0],[0 0]+Ylim_1(1),'k','LineWidth',1)
plot([-.5 -.5],Yvert_1,'k','LineWidth',1)
axis square
axis off

buf = TargetData(:,buf_dur>DurThre_sine); size(buf,2)
subplot(2,3,3)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim(Xlim_post)
ylim(Ylim_2)
plot([0 0],ylim,'k:')
plot([-.5 0],[0 0]+Ylim_2(1),'k','LineWidth',1)
plot([-.5 -.5],Yvert_2,'k','LineWidth',1)
axis square
axis off

% song
subplot(2,3,5)
hold on
buf = bufpulse(:,buf_dur<=DurThre_sine);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine(:,buf_dur<=DurThre_sine);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim(Xlim_post)
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0],'k','LineWidth',1)
% plot([-3 -3],[1 1.5],'k','LineWidth',1)
axis square
axis off

subplot(2,3,6)
hold on
buf = bufpulse(:,buf_dur>DurThre_sine);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine(:,buf_dur>DurThre_sine);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim(Xlim_post)
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0],'k','LineWidth',1)
% plot([-3 -3],[1 1.5],'k','LineWidth',1)
axis square
axis off

%% sine to pulse, pulse durations
TargetData = Data_StoP_comb;
TargetSong = Song_StoP_comb_pulse;
bufpulse = Song_StoP_comb_pulse;
bufsine = Song_StoP_comb_sine;

buf_dur = zeros(size(TargetData,2),1);
for i=1:length(buf_dur)
    j = 1;
    while TargetSong(73+j,i)==1
        j = j + 1;
    end
    buf_dur(i) = j;
end

figure('Position',[100 100 177 177])

% neuron
buf = TargetData(:,buf_dur<=DurThre_pulse); size(buf,2)
subplot(2,3,2)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim(Xlim_post)
ylim(Ylim_3)
plot([0 0],ylim,'k:')
plot([-.5 0],[0 0]+Ylim_3(1),'k','LineWidth',1)
plot([-.5 -.5],Yvert_3,'k','LineWidth',1)
axis square
axis off

buf = TargetData(:,buf_dur>DurThre_pulse); size(buf,2)
subplot(2,3,3)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim(Xlim_post)
ylim(Ylim_4)
plot([0 0],ylim,'k:')
plot([-.5 0],[0 0]+Ylim_4(1),'k','LineWidth',1)
plot([-.5 -.5],Yvert_4,'k','LineWidth',1)
axis square
axis off

% song
subplot(2,3,5)
hold on
buf = bufpulse(:,buf_dur<=DurThre_pulse);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine(:,buf_dur<=DurThre_pulse);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim(Xlim_post)
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0],'k','LineWidth',1)
% plot([-3 -3],[1 1.5],'k','LineWidth',1)
axis square
axis off

subplot(2,3,6)
hold on
buf = bufpulse(:,buf_dur>DurThre_pulse);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine(:,buf_dur>DurThre_pulse);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim(Xlim_post)
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0],'k','LineWidth',1)
% plot([-3 -3],[1 1.5],'k','LineWidth',1)
axis square
axis off


%% pulse to sine, pulse durations
TargetData = Data_PtoS_comb;
TargetSong = Song_PtoS_comb_pulse;
bufpulse = Song_PtoS_comb_pulse;
bufsine = Song_PtoS_comb_sine;

buf_dur = zeros(size(TargetData,2),1);
for i=1:length(buf_dur)
    j = 1;
    while TargetSong(73-j,i)==1
        j = j + 1;
    end
    buf_dur(i) = j;
end

figure('Position',[100 100 177 177])

% neuron
buf = TargetData(:,buf_dur<=DurThre_pulse); size(buf,2)
subplot(2,3,2)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim(Xlim_pre)
ylim(Ylim_5)
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0]+Ylim_5(1),'k','LineWidth',1)
plot([-1 -1],Yvert_5,'k','LineWidth',1)
axis square
axis off

buf = TargetData(:,buf_dur>DurThre_pulse); size(buf,2)
subplot(2,3,3)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim(Xlim_pre)
ylim(Ylim_6)
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0]+Ylim_6(1),'k','LineWidth',1)
plot([-1 -1],Yvert_6,'k','LineWidth',1)
axis square
axis off

% song
subplot(2,3,5)
hold on
buf = bufpulse(:,buf_dur<=DurThre_pulse);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine(:,buf_dur<=DurThre_pulse);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim(Xlim_pre)
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0],'k','LineWidth',1)
% plot([-3 -3],[1 1.5],'k','LineWidth',1)
axis square
axis off

subplot(2,3,6)
hold on
buf = bufpulse(:,buf_dur>DurThre_pulse);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine(:,buf_dur>DurThre_pulse); 
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim(Xlim_pre)
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0],'k','LineWidth',1)
% plot([-3 -3],[1 1.5],'k','LineWidth',1)
axis square
axis off


%% sine to pulse, sine durations
TargetData = Data_StoP_comb;
TargetSong = Song_StoP_comb_sine;
bufpulse = Song_StoP_comb_pulse;
bufsine = Song_StoP_comb_sine;

buf_dur = zeros(size(TargetData,2),1);
for i=1:length(buf_dur)
    j = 1;
    while TargetSong(73-j,i)==1
        j = j + 1;
    end
    buf_dur(i) = j;
end

figure('Position',[100 100 177 177])

% neuron
buf = TargetData(:,buf_dur<=DurThre_sine); size(buf,2)
subplot(2,3,2)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim(Xlim_pre)
ylim(Ylim_7)
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0]+Ylim_7(1),'k','LineWidth',1)
plot([-1 -1],Yvert_7,'k','LineWidth',1)
axis square
axis off

buf = TargetData(:,buf_dur>DurThre_sine); size(buf,2)
subplot(2,3,3)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim(Xlim_pre)
ylim(Ylim_8)
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0]+Ylim_8(1),'k','LineWidth',1)
plot([-1 -1],Yvert_8,'k','LineWidth',1)
axis square
axis off

% song
subplot(2,3,5)
hold on
buf = bufpulse(:,buf_dur<=DurThre_sine);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine(:,buf_dur<=DurThre_sine);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim(Xlim_pre)
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0],'k','LineWidth',1)
% plot([-3 -3],[1 1.5],'k','LineWidth',1)
axis square
axis off

subplot(2,3,6)
hold on
buf = bufpulse(:,buf_dur>DurThre_sine);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine(:,buf_dur>DurThre_sine);
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim(Xlim_pre)
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0],'k','LineWidth',1)
% plot([-3 -3],[1 1.5],'k','LineWidth',1)
axis square
axis off

