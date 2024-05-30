function [] = ExtDataFig07_AveSong()
% Code for plotting the population averaged ΔF/F for pulse and sine song around song-type in Extended Data Fig. 7c,e,h,j.

%% parameters
% GT = 'fruD'; % Extended Data Fig. 7c
% GT = 'fru'; % Extended Data Fig. 7e
GT = 'nsybDnonfru'; % Extended Data Fig. 7h
% GT = 'nsybnonfru'; % Extended Data Fig. 7j

switch GT
    case 'fruD'
        DataFlag = [1,0,1,1,0,1,1,0,0,0,1];
        crange = [-1 1]*.2;
    case 'fru'
        DataFlag = [1,0,0,1,1,0,1,0,0,0,1];
        crange = [-1 1]*.2;
    case 'nsybDnonfru'
        DataFlag = [0,1,0,0,1,0,1,1,1];
        crange = [-1 1]*.2;
     case 'nsybnonfru'
        DataFlag = [0,1,0,0,0,0,0,1,1,0];
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
