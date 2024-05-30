function [] = Fig06_AveTimeCourseSongTrans_pIP10()
% Code for plotting calcium signals and song probabilities during song type transitions in Fig. 6d.

Target = 'pIP10_NR';

selpath = ['../Data/Summary_pIP10/'];
load([selpath,'Transitions'])

%%
switch Target
    case 'pIP10_NR'
        Ylim_1 = [.1 .45];
        Yhori_1 = [.1,.1];
        Yvert_1 = [.1 .2];
        Ylim_2 = [0.63 0.83];
        Yhori_2 = [.7 .7];
        Yvert_2 = [.7 .75];
        Ylim_3 = [0.63 0.83];
end

switch Target
    case 'pIP10_NR'
        Data_QtoP_comb = Data_QtoP_comb(:,ROI_QtoP==3);
        Data_PtoS_comb = Data_PtoS_comb(:,ROI_PtoS==3);
        Data_StoP_comb = Data_StoP_comb(:,ROI_StoP==3);
        Song_QtoP_comb_pulse = Song_QtoP_comb_pulse(:,ROI_QtoP==3);
        Song_QtoP_comb_sine = Song_QtoP_comb_sine(:,ROI_QtoP==3);
        Song_PtoS_comb_pulse = Song_PtoS_comb_pulse(:,ROI_PtoS==3);
        Song_PtoS_comb_sine = Song_PtoS_comb_sine(:,ROI_PtoS==3);
        Song_StoP_comb_pulse = Song_StoP_comb_pulse(:,ROI_StoP==3);
        Song_StoP_comb_sine = Song_StoP_comb_sine(:,ROI_StoP==3);
end

%% make figures
figure('Position',[100 100 177 177])

x = TS_Img(1:OnePeriodDur)-10.1345+mean(diff(TS_Img))/2;
x2 = [x, fliplr(x)];

% quiet to pulse
buf = Data_QtoP_comb;
subplot(2,3,1)
hold on
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'k','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'k','LineStyle','none');
xlim([-3 3])
ylim(Ylim_1)
plot([0 0],ylim,'k:')
plot([-3 -2],Yhori_1,'k','LineWidth',1)
plot([-3 -3],Yvert_1,'k','LineWidth',1)
axis square
axis off

% pulse to sine
buf = Data_PtoS_comb;
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
xlim([-1 1])
ylim(Ylim_2)
plot([0 0],ylim,'k:')
plot([-1 -.5],Yhori_2,'k','LineWidth',1)
plot([-1 -1],Yvert_2,'k','LineWidth',1)
axis square
axis off

% sine to pulse
buf = Data_StoP_comb;
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
xlim([-1 1])
ylim(Ylim_3)
plot([0 0],ylim,'k:')
axis square
axis off

%%
% quiet to pulse
bufpulse = Song_QtoP_comb_pulse;
bufsine = Song_QtoP_comb_sine;
subplot(2,3,4)
hold on
buf = bufpulse;
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine;
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim([-3 3])
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-3 -2],[0 0],'k','LineWidth',1)
axis square
set(gca,'YTick',[0,.5,1],'TickDir','out','YTickLabel',[])
h = gca;
h.XAxis.Visible = 'off';
        
% pulse to sine
bufpulse = Song_PtoS_comb_pulse;
bufsine = Song_PtoS_comb_sine;
subplot(2,3,5)
hold on
buf = bufpulse;
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine;
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim([-1 1])
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0],'k','LineWidth',1)
axis square
axis off

% sine to pulse
bufpulse = Song_StoP_comb_pulse;
bufsine = Song_StoP_comb_sine;
subplot(2,3,6)
hold on
buf = bufpulse;
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'r','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'r','LineStyle','none');
buf = bufsine;
SEM = std(buf')/sqrt(size(buf,2));
MEAN = mean(buf,2);
plot(x,MEAN,'b','LineWidth',.5)
curve1 = MEAN' + SEM;
curve2 = MEAN' - SEM;
inBetween = [curve1, fliplr(curve2)];
% h = fill(x2, inBetween, 'k','LineStyle','none','FaceAlpha',0.2);
h = fill(x2, inBetween, 'b','LineStyle','none');
xlim([-1 1])
ylim([0 1])
plot([0 0],ylim,'k:')
plot([-1 -.5],[0 0],'k','LineWidth',1)
axis square
axis off
