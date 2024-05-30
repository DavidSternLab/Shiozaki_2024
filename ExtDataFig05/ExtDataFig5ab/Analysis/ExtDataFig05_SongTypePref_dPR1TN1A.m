function [] = ExtDataFig05_SongTypePref_dPR1TN1A()
% Code for plotting the distribution of song-type preference for dPR1 and TN1A neurons in Extended Data Fig. 5b.

%% parameters
Thre_Trans = 6;

%% Song-type preference index (dPR1, TN1SG)
load(['../Data/Summary_dPR1/SongTypePrefIndex'])
Idx_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_BidMod(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
P_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];

Idx_SongType_dPR1 = Idx_SongType;
P_SongType_dPR1 = P_SongType;
Idx_BidMod_dPR1 = Idx_BidMod;
Idx_PtoS_dPR1 = Idx_PtoS;
Idx_StoP_dPR1 = Idx_StoP;

load(['../Data/Summary_TN1SG/SongTypePrefIndex'])
Idx_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_BidMod(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
P_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];

Idx_SongType_TN1SG = Idx_SongType;
P_SongType_TN1SG = P_SongType;
Idx_BidMod_TN1SG = Idx_BidMod;
Idx_PtoS_TN1SG = Idx_PtoS;
Idx_StoP_TN1SG = Idx_StoP;

% Song-type preference
figure('Position',[100,100,50,50])
hold on
scatter(1*ones(length(Idx_SongType_dPR1),1),-Idx_SongType_dPR1,4,'r','filled','jitter','on','jitterAmount',.2)
buf = -Idx_SongType_dPR1;
Mean = mean(buf);
SD = std(buf);
plot([1,1]*1+.3,[-1,1]*SD+Mean,'r-','LineWidth',.5)
plot([-.1,.1]+1+.3,[1,1]*Mean,'r-','LineWidth',.5)

scatter(2*ones(length(Idx_SongType_TN1SG),1),-Idx_SongType_TN1SG,4,'b','filled','jitter','on','jitterAmount',.2)
buf = -Idx_SongType_TN1SG;
Mean = mean(buf);
SD = std(buf);
plot([1,1]*2+.3,[-1,1]*SD+Mean,'b-','LineWidth',.5)
plot([-.1,.1]+2+.3,[1,1]*Mean,'b-','LineWidth',.5)

plot([.5,2.5],[0,0],'k:')
xlim([.5,2.5])
ylim([-1,1])

pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[-1,0,1],'XTick',[1:2],'TickDir','out','XTickLabel',[],'YTickLabel',[])
