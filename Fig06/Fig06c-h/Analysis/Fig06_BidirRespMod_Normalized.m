function [] = Fig06_BidirRespMod_Normalized()
% Code for plotting the mean change in ΔF/F after song-type transitions relative to ΔF/F before the transitions in Fig. 6e,h,.

GT = 'pIP10'; Target = 'pIP10_NR'; % Fig. 6e
% GT = 'pMP2'; Target = 'pMP2_NR'; % Fig. 6h

switch Target
    case 'pIP10_NR'
        TargetROI = 3;
        ylimrange1 = [-.4 .7];
        ylimrange2 = [-1 1];
    case 'pMP2_NR'
        TargetROI = [5,6];
        ylimrange1 = [-.4 .7];
        ylimrange2 = [-.3 .6];
end

%% parameters
Thre_Trans = 6;
Thre_Resp = 0.05;

%% Song-type preference index
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'SongTypePrefIndex'])
load([selpath,'ResponseIndex'])

Idx_PtoS(ResponseIdx>=Thre_Resp) = [];
Pre_PtoS(ResponseIdx>=Thre_Resp) = [];
Idx_StoP(ResponseIdx>=Thre_Resp) = [];
Pre_StoP(ResponseIdx>=Thre_Resp) = [];
ROIID_comb(ResponseIdx>=Thre_Resp) = [];

Idx_PtoS = Idx_PtoS./Pre_PtoS;
Idx_StoP = Idx_StoP./Pre_StoP;

Idx_SongType(~ismember(ROIID_comb,TargetROI)) = [];
Idx_PtoS(~ismember(ROIID_comb,TargetROI)) = [];
Idx_StoP(~ismember(ROIID_comb,TargetROI)) = [];
Idx_BidMod(~ismember(ROIID_comb,TargetROI)) = [];
P_SongType(~ismember(ROIID_comb,TargetROI)) = [];

% 
buf_Idx = [Idx_PtoS; Idx_StoP];
xx = [1*ones(length(Idx_PtoS),1);2*ones(length(Idx_StoP),1)];

figure('Position',[100,100,50,50])
hold on
scatter(xx,buf_Idx,4,'k','filled','jitter','on','jitterAmount',.15)
for cond=1:2
    Mean = mean(buf_Idx([1:length(Idx_PtoS)]+(cond-1)*length(Idx_PtoS)));
    SD = std(buf_Idx([1:length(Idx_PtoS)]+(cond-1)*length(Idx_PtoS)));
    plot([1,1]*cond+.3,[-1,1]*SD+Mean,'k-','LineWidth',.5)
    plot([-.1,.1]+cond+.3,[1,1]*Mean,'k-','LineWidth',.5)
end
xlim([.5,2.5])
plot(xlim,[0,0],'k:')
ylim(ylimrange1)
pbaspect([1 1 1])
box off
set(gca,'YTick',[ylimrange1(1),0,ylimrange1(2)],'XTick',[1:2],'TickDir','out','XTickLabel',[],'YTickLabel',[])

[h,p1] = ttest(Idx_PtoS)
[h,p2] = ttest(Idx_StoP)
