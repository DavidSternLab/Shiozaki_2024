function [] = ExtDataFig05_QtoP_TN1dsx()
% Code for plotting changes in ΔF/F from quiet to pulse transitions in Extended Data Fig. 5k.

%% Song-type preference index (dPR1, TN1SG)
load(['../Data/Summary_TN1dsx/QtoPIndex'])

buf_Idx = Idx_QtoP;
xx = [1*ones(length(Idx_QtoP),1)];

figure('Position',[100,100,50,50])
hold on
scatter(xx,buf_Idx,4,'k','filled','jitter','on','jitterAmount',.2)
Mean = mean(buf_Idx);
SD = std(buf_Idx);
plot([1,1]+.3,[-1,1]*SD+Mean,'k-','LineWidth',.5)
plot([-.1,.1]+1.3,[1,1]*Mean,'k-','LineWidth',.5)
xlim([.5,1.5])
plot(xlim,[0,0],'k:')
ylim([-2,2])
pbaspect([.5 1 1])
box off
% axis square
set(gca,'YTick',[-2:2:2],'XTick',[1:2],'TickDir','out','XTickLabel',[],'YTickLabel',[])
