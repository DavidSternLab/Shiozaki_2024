function [] = Fig02_QtoP_dPR1TN1A()
% Code for plotting the mean change in ΔF/F after quiet-to-pulse transitions relative to ΔF/F before the transitions in Fig. 2e,h.

%% Song-type preference index (dPR1, TN1SG)
load(['../Data/Summary_dPR1/QtoPIndex'])
Idx_QtoP_dPR1 = Idx_QtoP;

load(['../Data/Summary_TN1SG/QtoPIndex'])
Idx_QtoP_TN1SG = Idx_QtoP;

% dPR1
buf_Idx = [Idx_QtoP_dPR1];
xx = [1*ones(length(Idx_QtoP_dPR1),1)];

figure('Position',[100,100,50,50])
hold on
scatter(xx,buf_Idx,4,'k','filled','jitter','on','jitterAmount',.2)
Mean = mean(buf_Idx([1:length(Idx_QtoP_dPR1)]));
SD = std(buf_Idx([1:length(Idx_QtoP_dPR1)]));
plot([1,1]+.3,[-1,1]*SD+Mean,'k-','LineWidth',.5)
plot([-.1,.1]+1.3,[1,1]*Mean,'k-','LineWidth',.5)
xlim([.5,1.5])
plot(xlim,[0,0],'k:')
ylim([-4,4])
pbaspect([.5 1 1])
box off
% axis square
set(gca,'YTick',[-4:4:4],'XTick',[1:2],'TickDir','out','XTickLabel',[],'YTickLabel',[])

% TN1A
buf_Idx = [Idx_QtoP_TN1SG];
xx = [1*ones(length(Idx_QtoP_TN1SG),1)];

figure('Position',[100,100,50,50])
hold on
scatter(xx,buf_Idx,4,'k','filled','jitter','on','jitterAmount',.2)
Mean = mean(buf_Idx([1:length(Idx_QtoP_TN1SG)]));
SD = std(buf_Idx([1:length(Idx_QtoP_TN1SG)]));
plot([1,1]+.3,[-1,1]*SD+Mean,'k-','LineWidth',.5)
plot([-.1,.1]+1.3,[1,1]*Mean,'k-','LineWidth',.5)
xlim([.5,1.5])
plot(xlim,[0,0],'k:')
ylim([-1,1])
pbaspect([.5 1 1])
box off
% axis square
set(gca,'YTick',[-1:1:1],'XTick',[1:2],'TickDir','out','XTickLabel',[],'YTickLabel',[])

