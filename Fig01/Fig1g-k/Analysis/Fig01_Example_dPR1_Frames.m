function [] = Fig01_Example_dPR1_Frames()
% Code for plotting example frames of a recording from dPR1 in Fig. 1g.

Target_FileID = 2;
Margin = 10;

figure('Position',[100 100 1600 1200])

%% behavior
TargetStim = 1;
nFrames_10s = 71; % 71.0443 frames
nFrames_1s = 7;

%% imaging
nTrials = 6;
d1 = 256; % Y
d2 = 256; % X
d3 = 10; % Z
d3_discard = 2;
T = 1370; % T
nStim = 6;

Y = read_file('file_00021.tif'); % read the file (optional, you can also pass the path in the function instead of Y)
Y(:,:,[2:2:size(Y,3)]) = []; % remove the red channel
Y(Y<0) = 0; % some pixel values are <0 because of the PMT setting, should be converted to 0
Y = reshape(Y,d1,d2,d3+d3_discard,T); % [Y X Z T]
Y(:,:,[end-d3_discard+1:end],:) = [];
Y = single(Y); % convert to single precision

options_rigid = NoRMCorreSetParms('d1',d1,'d2',d2,'d3',1,...
    'grid_size',[256,256,1],'overlap_pre',[16,16,1],'min_patch_size',[16,16,1],'min_diff',[8,8,1],'mot_uf',[4,4,1],'overlap_post',[16,16,1],'max_shift',30,...
    'upd_template',false,'init_batch',260,'boundary',NaN);

load('F2d_20210604_02')
AveZRange = [min([AveZRange1,AveZRange2]):max([AveZRange1,AveZRange2])];
M = Y;

M_2D_buf = squeeze(mean(M(:,:,AveZRange,:),3));
[M_2D,~,~,~] = normcorre_batch(M_2D_buf,options_rigid);
M_2D(M_2D<0) = 0;

load('TS_Img')
load('TS_OptStimImg.mat')

%%          
Pre = mean(M_2D(:,:,[1:nFrames_1s]-nFrames_1s+OptStimOnset_Img(TargetStim)-1),3);
Stim = mean(M_2D(:,:,[1:nFrames_1s]+OptStimOnset_Img(TargetStim)-1),3);

Pre(1:Margin,:) = [];
Pre(end-Margin:end,:) = [];
Pre(:,1:Margin) = [];
Pre(:,end-Margin:end) = [];
  
Stim(1:Margin,:) = [];
Stim(end-Margin:end,:) = [];
Stim(:,1:Margin) = [];
Stim(:,end-Margin:end) = [];

figure
subplot(1,2,1)
imagesc(rot90(Pre,3),[0,150])
axis square
axis off
subplot(1,2,2)
imagesc(rot90(Stim,3),[0,150])
axis square
axis off
colormap('gray')
colorbar

%
buf = Stim-Pre;
nnY = quantile(buf(:),0.005);
mmY = quantile(buf(:),0.995);

figure
imagesc(rot90(buf,3),[0,100])
axis square
axis off
colormap('hot')
colorbar
