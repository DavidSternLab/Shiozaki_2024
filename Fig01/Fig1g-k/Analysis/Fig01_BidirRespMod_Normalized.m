function [] = Fig01_BidirRespMod_Normalized()
% Code for plotting the mean change in ΔF/F after song-type transitions relative to ΔF/F before the transitions in Fig. 1j,m.

GT = 'dPR1NPTN1SGNP'; % Fig. 1j,m

switch GT
    case 'dPR1TN1SG'
        ylimrange1 = [-.3 .6];
        ylimrange2 = [-.3 .6];
    case 'dPR1NPTN1SGNP'
        ylimrange1 = [-.5 1];
        ylimrange2 = [-.5 1];
end

%% parameters
Thre_Trans = 6;

%% Song-type preference index (dPR1, TN1SG)
switch GT
    case 'dPR1TN1SG'
        load(['../Data/Summary_dPR1/SongTypePrefIndex'])
    case 'dPR1NPTN1SGNP'
        load(['../Data/Summary_dPR1NP/SongTypePrefIndex'])
end

Idx_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_BidMod(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
P_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Pre_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Pre_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];

Idx_SongType_dPR1 = Idx_SongType;
P_SongType_dPR1 = P_SongType;
Idx_BidMod_dPR1 = Idx_BidMod;
Idx_PtoS_dPR1 = Idx_PtoS./Pre_PtoS;
Idx_StoP_dPR1 = Idx_StoP./Pre_StoP;

switch GT
    case 'dPR1TN1SG'
        load(['../Data/Summary_TN1SG/SongTypePrefIndex'])
    case 'dPR1NPTN1SGNP'
        load(['../Data/Summary_TN1SGNP/SongTypePrefIndex'])
end

Idx_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_BidMod(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
P_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Pre_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Pre_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];

Idx_SongType_TN1SG = Idx_SongType;
P_SongType_TN1SG = P_SongType;
Idx_BidMod_TN1SG = Idx_BidMod;
Idx_PtoS_TN1SG = Idx_PtoS./Pre_PtoS;
Idx_StoP_TN1SG = Idx_StoP./Pre_StoP;

% dPR1
buf_Idx = [Idx_PtoS_dPR1; Idx_StoP_dPR1];
xx = [1*ones(length(Idx_PtoS_dPR1),1);2*ones(length(Idx_StoP_dPR1),1)];

figure('Position',[100,100,50,50])
hold on
scatter(xx,buf_Idx,4,'k','filled','jitter','on','jitterAmount',.15)
for cond=1:2
    Mean = mean(buf_Idx([1:length(Idx_PtoS_dPR1)]+(cond-1)*length(Idx_PtoS_dPR1)));
    SD = std(buf_Idx([1:length(Idx_PtoS_dPR1)]+(cond-1)*length(Idx_PtoS_dPR1)));
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

[h,p1] = ttest(Idx_PtoS_dPR1)
[h,p2] = ttest(Idx_StoP_dPR1)

% TN1A
buf_Idx = [Idx_PtoS_TN1SG; Idx_StoP_TN1SG];
xx = [1*ones(length(Idx_PtoS_TN1SG),1);2*ones(length(Idx_StoP_TN1SG),1)];

figure('Position',[100,100,50,50])
hold on
scatter(xx,buf_Idx,4,'k','filled','jitter','on','jitterAmount',.2)
for cond=1:2
    Mean = mean(buf_Idx([1:length(Idx_PtoS_TN1SG)]+(cond-1)*length(Idx_PtoS_TN1SG)));
    SD = std(buf_Idx([1:length(Idx_PtoS_TN1SG)]+(cond-1)*length(Idx_PtoS_TN1SG)));
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

[h,p1] = ttest(Idx_PtoS_TN1SG)
[h,p2] = ttest(Idx_StoP_TN1SG)