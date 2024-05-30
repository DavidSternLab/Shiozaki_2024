function [] = Fig04_AveSongComb()
% Code for plotting the population averaged ΔF/F for the difference between pulse and sine song around song-type in Fig. 4d,f.

%% parameters
GT = 'nsybD'; % Fig. 4d
% GT = 'nsyb'; % Fig. 4f

switch GT
    case 'nsybD'
        DataFlag = [1,1,1,1,1,0,1,1,1,1];
        crange = [-1 1]*.2;
    case 'nsyb'    
        DataFlag = [0,0,0,1,0,0,0,0,0,0,1,0,0,1];
        crange = [-1 1]*.1;
end

Margin_clip = [7,13,10,10]

%% get filenames
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'AveSongComb'])

%% plot
GaussSD = 1;

figure
buf = imgaussfilt(rot90(mean(buf2D_PminusS(:,:,DataFlag==1),3),3),GaussSD,'FilterDomain','spatial');
imagesc(buf(1+Margin_clip(1):end-Margin_clip(2),1+Margin_clip(3):end-Margin_clip(4)),crange)
axis square
axis off
colormap(jet)
colorbar