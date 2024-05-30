function [] = ExtDataFig06_AveSong()
% Code for plotting the population averaged ΔF/F for pulse and sine song around song-type in Extended Data Fig. 6b,d.

%% parameters
GT = 'nsybD'; % Extended Data Fig. 6b
% GT = 'nsyb'; % Extended Data Fig. 6d

switch GT
    case 'nsybD'
        DataFlag = [1,1,1,1,1,0,1,1,1,1];
        crange = [-1 1]*.2;
    case 'nsyb'    
        DataFlag = [0,0,0,1,0,0,0,0,0,0,1,0,0,1];
        crange = [-1 1]*.12;
end

Margin_clip = [7,13,10,10];

%% get filenames
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'AveSong'])

GaussSD = 1;

figure
subplot(1,2,1)
buf = imgaussfilt(rot90(mean(buf2D_PtoS(:,:,DataFlag==1),3),3),GaussSD,'FilterDomain','spatial');
imagesc(buf(1+Margin_clip(1):end-Margin_clip(2),1+Margin_clip(3):end-Margin_clip(4)),crange)
axis square
axis off
colormap(jet)
colorbar

subplot(1,2,2)
buf = imgaussfilt(rot90(mean(buf2D_StoP(:,:,DataFlag==1),3),3),GaussSD,'FilterDomain','spatial');
imagesc(buf(1+Margin_clip(1):end-Margin_clip(2),1+Margin_clip(3):end-Margin_clip(4)),crange)
axis square
axis off
colormap(jet)
colorbar
