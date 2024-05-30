function [] = Fig05_AveSongComb()
% Code for plotting the population averaged ΔF/F for the difference between pulse and sine song around song-type in Fig. 5c,e.

%% parameters
GT = 'fruD'; % Fig. 5c
% GT = 'fru'; % Fig. 5e

switch GT
    case 'fruD'
        DataFlag = [1,0,1,1,0,1,1,0,0,0,1];
        crange = [-1 1]*.15;
    case 'fru'
        DataFlag = [1,0,0,1,1,0,1,0,0,0,1];
        crange = [-1 1]*.15;
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