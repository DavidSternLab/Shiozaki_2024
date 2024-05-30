function [] = ExtDataFig10_NT()
% Code for plotting neurotransmitter predictions in Extended Data Fig. 10a.

%% parameters
pIP10 = [13417,13038]; % pIP10 (L, R)
pMP2 = [11977,11987];
dPR1 = [10267,10300]; % dPR1
TN1A = [15521,16465,15148,12883,16207,...
    16113,14581,14810,15387,17640,...
    13945,14401,13928,16391,16042,...
    13155,13445,14277,14375,14779,...
    16690,15936,13727,13514];
Targets = [pIP10,pMP2,dPR1,TN1A];

load('Comb_NT.mat')

NT_comb = [NT_Ach,NT_Gaba,NT_Glu,NT_Neither];

[M,NT_pred] = max(NT_comb,[],2);

NT_pred_comb = zeros(length(Targets),4);

for DataID=1:length(Targets)
    disp([num2str(Targets(DataID)),':',num2str(NT_pred(NT_BodyID==Targets(DataID)))])
    disp([num2str(Targets(DataID)),':',num2str(M(NT_BodyID==Targets(DataID)))])
    NT_pred_comb(DataID,:) = NT_comb(NT_BodyID==Targets(DataID),:);
end

figure('Position',[100,100,150,75])
bar(NT_pred_comb,.6,'stacked')
xlim([.5,length(Targets)+.5])
ylim([0,1])
box off
set(gca,'TickDir','out','XTick',[1,length(Targets)],'YTick',[0,.5,1],'XTickLabel',[],'YTickLabel',[])


