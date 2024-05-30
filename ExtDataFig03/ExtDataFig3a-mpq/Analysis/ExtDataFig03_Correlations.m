function [] = ExtDataFig03_Correlations()
% Code for plotting the histogram of the Pearson’s correlation coefficients between pairs of neurons recorded simultaneously in Extended Data Fig. 3c,j.

GT = 'dPR1'; % Extended Data Fig. 3c
% GT = 'TN1SG'; % Extended Data Fig. 3j

switch GT
    case 'dPR1'
        ylimrange = [0,10];
        CellFlagNonTrans = [1,1,0,1,1,1,1,1,1,1,0,0,1];
    case 'TN1SG'
        ylimrange = [0,15];
        CellFlagNonTrans = [0,0,1,1,1,1,0,0,0,0,0];
end

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'FtimeCourseComb']) % FileID,nROIs,T,nTrials

nTrials = 6;
%%
Corr_comb = [];
nFlies = 0;
for DataID=1:size(F_comb,2)
    if CellFlagNonTrans(DataID)==1
        data = F_comb{DataID};
        nROIs = size(data,1);
        if nROIs>=2
            nFlies = nFlies + 1;
            for data1=1:nROIs-1
                for data2=data1+1:nROIs
                    bufCorr = zeros(nTrials,1);
                    for trial=1:nTrials
                        bufCorr(trial) = corr(data(data1,:,trial)',data(data2,:,trial)');
                    end
                    Corr_comb = [Corr_comb;mean(bufCorr)];
                end
            end
        end
    end
end

figure('Position',[100,100,50,50])
edges = [-1:.1:1];
h = histogram(Corr_comb,edges);
h.FaceColor = [.5 .5 .5];
h.FaceAlpha = 1;
hold on
plot([0,0],ylimrange,'k--')
xlim([-1,1])
box off
ylim(ylimrange)
axis square
set(gca,'XTick',[-1:.5:1],'XTickLabel',[],'YTick',[0:5:40],'YTickLabel',[],'TickDir','out')

nPairs = length(Corr_comb)
nFlies
