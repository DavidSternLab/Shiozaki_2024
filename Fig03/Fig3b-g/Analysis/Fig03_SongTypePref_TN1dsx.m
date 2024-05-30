function [] = Fig03_SongTypePref_TN1dsx()
% Code for plotting the distribution of song-type preference for TN1 neurons in Fig. 3c.

%% parameters
nTrials = 6;
nStim = 6;
T = 1370; % T
Thre_Trans = 6;
Thre_SongType = 0.05;

PreEventImg = 72; % 10 s (71.0443)
StimDurImg = 72; % 10 s (71.0443)
OneTrialDur = 214; % 30 s (213.1329)

Thre_pulse = 0.1;
Thre_sine = 0.6;
OnePeriodDur = 143; % 20 s (142.0886)
Trans_Pre = [72:73];
Trans_Post = [74:75];
nPermTestRep = 2000;

RiseTime_Pre = -5; % 5 s
RiseTime_Stim = 5; % 5 s

%% Song-type preference index (dPR1, TN1SG)
load(['../Data/Summary_TN1dsx/SongTypePrefIndex'])
Idx_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_PtoS(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_StoP(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
Idx_BidMod(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
P_SongType(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];
ID_comb(nEvents_comb(1,:)<Thre_Trans|nEvents_comb(2,:)<Thre_Trans) = [];

Idx_SongType_pulse = Idx_SongType(P_SongType<Thre_SongType&Idx_SongType<0);
Idx_SongType_sine = Idx_SongType(P_SongType<Thre_SongType&Idx_SongType>0);
Idx_SongType_none = Idx_SongType(P_SongType>=Thre_SongType);

% Song-type preference (high-to-low)
[~,I] = sort(Idx_SongType);
figure('Position',[100,100,70,70])
hold on
for i=1:length(Idx_SongType)
    if P_SongType(I(i))<Thre_SongType
        if Idx_SongType(I(i))<0
            plot(i,-Idx_SongType(I(i)),'ro','MarkerFaceColor','r','MarkerSize',1.5)
        else
            plot(i,-Idx_SongType(I(i)),'bo','MarkerFaceColor','b','MarkerSize',1.5)
        end
    else
        plot(i,-Idx_SongType(I(i)),'ko','MarkerFaceColor','k','MarkerSize',1.5)
    end
end
plot([.5,length(Idx_SongType)+.5],[0,0],'k:')
xlim([.5,length(Idx_SongType)+.5])
set(gca,'XTick',[],'YTick',[-1:1],'YTickLabel',[],'TickDir','out')
pbaspect([1,2,1])
