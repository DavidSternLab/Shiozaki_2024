function [] = Fig03_Bidir_TN1dsx_Normalized()
% Code for plotting the mean change in ΔF/F after song-type transitions relative to ΔF/F before the transitions in Fig. 3e,g.

%% parameters
T = 1370; % T
Thre_Trans = 6;
Thre_SongType = 0.05;
Thre_Pre = 0.1;

%% Song-type preference index (dPR1, TN1SG)
load(['../Data/Summary_TN1dsx/SongTypePrefIndex'])
Idx_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_BidMod(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
P_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Pre_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Pre_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];

Idx_SongType_pulse = Idx_SongType(P_SongType<Thre_SongType&Idx_SongType<0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
P_SongType_pulse = P_SongType(P_SongType<Thre_SongType&Idx_SongType<0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
Idx_BidMod_pulse = Idx_BidMod(P_SongType<Thre_SongType&Idx_SongType<0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
Idx_PtoS_pulse = Idx_PtoS(P_SongType<Thre_SongType&Idx_SongType<0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
Idx_StoP_pulse = Idx_StoP(P_SongType<Thre_SongType&Idx_SongType<0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
Pre_PtoS_pulse = Pre_PtoS(P_SongType<Thre_SongType&Idx_SongType<0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
Pre_StoP_pulse = Pre_StoP(P_SongType<Thre_SongType&Idx_SongType<0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);

Idx_SongType_sine = Idx_SongType(P_SongType<Thre_SongType&Idx_SongType>0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
P_SongType_sine = P_SongType(P_SongType<Thre_SongType&Idx_SongType>0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
Idx_BidMod_sine = Idx_BidMod(P_SongType<Thre_SongType&Idx_SongType>0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
Idx_PtoS_sine = Idx_PtoS(P_SongType<Thre_SongType&Idx_SongType>0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
Idx_StoP_sine = Idx_StoP(P_SongType<Thre_SongType&Idx_SongType>0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
Pre_PtoS_sine = Pre_PtoS(P_SongType<Thre_SongType&Idx_SongType>0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);
Pre_StoP_sine = Pre_StoP(P_SongType<Thre_SongType&Idx_SongType>0&Pre_PtoS'>Thre_Pre&Pre_StoP'>Thre_Pre);

Idx_PtoS_pulse = Idx_PtoS_pulse./Pre_PtoS_pulse;
Idx_StoP_pulse = Idx_StoP_pulse./Pre_StoP_pulse;
Idx_PtoS_sine = Idx_PtoS_sine./Pre_PtoS_sine;
Idx_StoP_sine = Idx_StoP_sine./Pre_StoP_sine;

% pulse
buf_Idx = [Idx_PtoS_pulse; Idx_StoP_pulse];
xx = [1*ones(length(Idx_PtoS_pulse),1);2*ones(length(Idx_StoP_pulse),1)];

figure('Position',[100,100,50,50])
hold on
scatter(xx,buf_Idx,4,'k','filled','jitter','on','jitterAmount',.15)
for cond=1:2
    Mean = mean(buf_Idx([1:length(Idx_PtoS_pulse)]+(cond-1)*length(Idx_PtoS_pulse)));
    SD = std(buf_Idx([1:length(Idx_PtoS_pulse)]+(cond-1)*length(Idx_PtoS_pulse)));
    plot([1,1]*cond+.3,[-1,1]*SD+Mean,'k-','LineWidth',.5)
    plot([-.1,.1]+cond+.3,[1,1]*Mean,'k-','LineWidth',.5)
end
xlim([.5,2.5])
plot(xlim,[0,0],'k:')
ylim([-1,1])
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[-1,0,1],'XTick',[1:2],'TickDir','out','XTickLabel',[],'YTickLabel',[])

[h,p1] = ttest(Idx_PtoS_pulse)
[h,p2] = ttest(Idx_StoP_pulse)

% sine
buf_Idx = [Idx_PtoS_sine; Idx_StoP_sine];
xx = [1*ones(length(Idx_PtoS_sine),1);2*ones(length(Idx_StoP_sine),1)];

figure('Position',[100,100,50,50])
hold on
scatter(xx,buf_Idx,4,'k','filled','jitter','on','jitterAmount',.15)
for cond=1:2
    Mean = mean(buf_Idx([1:length(Idx_PtoS_sine)]+(cond-1)*length(Idx_PtoS_sine)));
    SD = std(buf_Idx([1:length(Idx_PtoS_sine)]+(cond-1)*length(Idx_PtoS_sine)));
    plot([1,1]*cond+.3,[-1,1]*SD+Mean,'k-','LineWidth',.5)
    plot([-.1,.1]+cond+.3,[1,1]*Mean,'k-','LineWidth',.5)
end
xlim([.5,2.5])
plot(xlim,[0,0],'k:')
ylim([-1,1])
pbaspect([1 1 1])
box off
% axis square
set(gca,'YTick',[-1,0,1],'XTick',[1:2],'TickDir','out','XTickLabel',[],'YTickLabel',[])

[h,p1] = ttest(Idx_PtoS_sine)
[h,p2] = ttest(Idx_StoP_sine)
