function [] = ExtDataFig08_BidirRespMod_Normalized_vPR9()
% Code for plotting the mean change in ΔF/F after song-type transitions relative to ΔF/F before the transitions in Extended Data Fig. 8i,l.

load(['../Data/Summary_vPR9NP_SS1/SongTypePrefIndex'])
ylimrange1 = [-.5 1];
ylimrange2 = [-.5 1];

%% parameters
Thre_Trans = 6;

%% Song-type preference index (dPR1, TN1SG)
load(['../Data/Summary_vPR9NP_SS1/SongTypePrefIndex'])


Idx_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_BidMod(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
P_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Pre_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Pre_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];

Idx_SongType_vPR9_SS1 = Idx_SongType;
P_SongType_vPR9_SS1 = P_SongType;
Idx_BidMod_vPR9_SS1 = Idx_BidMod;
Idx_PtoS_vPR9_SS1 = Idx_PtoS./Pre_PtoS;
Idx_StoP_vPR9_SS1 = Idx_StoP./Pre_StoP;

load(['../Data/Summary_vPR9NP_SS3/SongTypePrefIndex'])

Idx_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_BidMod(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
P_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Pre_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Pre_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];

Idx_SongType_vPR9_SS3 = Idx_SongType;
P_SongType_vPR9_SS3 = P_SongType;
Idx_BidMod_vPR9_SS3 = Idx_BidMod;
Idx_PtoS_vPR9_SS3 = Idx_PtoS./Pre_PtoS;
Idx_StoP_vPR9_SS3 = Idx_StoP./Pre_StoP;

% vPR9-SS1
buf_Idx = [Idx_PtoS_vPR9_SS1; Idx_StoP_vPR9_SS1];
xx = [1*ones(length(Idx_PtoS_vPR9_SS1),1);2*ones(length(Idx_StoP_vPR9_SS1),1)];

figure('Position',[100,100,50,50])
hold on
scatter(xx,buf_Idx,4,'k','filled','jitter','on','jitterAmount',.15)
for cond=1:2
    Mean = mean(buf_Idx([1:length(Idx_PtoS_vPR9_SS1)]+(cond-1)*length(Idx_PtoS_vPR9_SS1)));
    SD = std(buf_Idx([1:length(Idx_PtoS_vPR9_SS1)]+(cond-1)*length(Idx_PtoS_vPR9_SS1)));
    plot([1,1]*cond+.3,[-1,1]*SD+Mean,'k-','LineWidth',.5)
    plot([-.1,.1]+cond+.3,[1,1]*Mean,'k-','LineWidth',.5)
end
xlim([.5,2.5])
plot(xlim,[0,0],'k:')
ylim(ylimrange1)
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[ylimrange1(1),0,ylimrange1(2)],'XTick',[1:2],'TickDir','out','XTickLabel',[],'YTickLabel',[])

[h,p1] = ttest(Idx_PtoS_vPR9_SS1)
[h,p2] = ttest(Idx_StoP_vPR9_SS1)

% vPR9-SS3
buf_Idx = [Idx_PtoS_vPR9_SS3; Idx_StoP_vPR9_SS3];
xx = [1*ones(length(Idx_PtoS_vPR9_SS3),1);2*ones(length(Idx_StoP_vPR9_SS3),1)];

figure('Position',[100,100,50,50])
hold on
scatter(xx,buf_Idx,4,'k','filled','jitter','on','jitterAmount',.2)
for cond=1:2
    Mean = mean(buf_Idx([1:length(Idx_PtoS_vPR9_SS3)]+(cond-1)*length(Idx_PtoS_vPR9_SS3)));
    SD = std(buf_Idx([1:length(Idx_PtoS_vPR9_SS3)]+(cond-1)*length(Idx_PtoS_vPR9_SS3)));
    plot([1,1]*cond+.3,[-1,1]*SD+Mean,'k-','LineWidth',.5)
    plot([-.1,.1]+cond+.3,[1,1]*Mean,'k-','LineWidth',.5)
end
xlim([.5,2.5])
plot(xlim,[0,0],'k:')
ylim(ylimrange2)
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[ylimrange2(1),0,ylimrange2(2)],'XTick',[1:2],'TickDir','out','XTickLabel',[],'YTickLabel',[])

[h,p1] = ttest(Idx_PtoS_vPR9_SS3)
[h,p2] = ttest(Idx_StoP_vPR9_SS3)