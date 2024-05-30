function [] = Fig05_SongTypeRespDiffHist_shuffle()
% Same as Fig05_SongTypeRespDiffHist.m but for trial shuffled data.

GT = 'fruD'; % Fig. 5d
% GT = 'fru'; % Fig. 5f

%% parameters
Thre_SongType = 0.001;

switch GT
    case 'fruD'
        DataFlag_Song = [1,0,1,1,0,1,1,0,0,0,1];
        xlimrange = [-1 1];
        ylimrange0 = [0,.3];
        ylimrange1 = [0,200];
        ylimrange = [0,0.02];
    case 'fru'
        DataFlag_Song = [1,0,0,1,1,0,1,0,0,0,1];
        xlimrange = [-1 1];
        ylimrange0 = [0,.2];
        ylimrange1 = [0,150];
        ylimrange = [0,0.02];
end

d1DS = 128;
d2DS = 128;
d3 = 10;

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
load([selpath,'SongTypeP_shuffle'])

%% main loop
Data_comb = [];
Data_comb_pulse = [];
Data_comb_sine = [];

Pulse_comb = zeros(d1DS,d2DS,d3);
Sine_comb = zeros(d1DS,d2DS,d3);

for FileID=1:length(DataFlag_Song)
    if DataFlag_Song(FileID)==1
        disp(['File ID: ',num2str(FileID)])
        
        Data_org = Data_org_comb{FileID};
        Data_p = Data_p_comb{FileID};
        
        h = zeros(size(Data_p));
        h(Data_p<Thre_SongType) = 1;
        h(Data_p>1-Thre_SongType&Data_p~=2) = 1;

        bufData = Data_org(h==1);
        sum(h(:))

        Data_comb = [Data_comb;bufData];
        Data_comb_pulse = [Data_comb_pulse;Data_org(Data_p<Thre_SongType)];
        Data_comb_sine = [Data_comb_sine;Data_org(Data_p>1-Thre_SongType&Data_p~=2)];
        
        Pulse_comb = Pulse_comb + Data_p<Thre_SongType;
        Sine_comb = Sine_comb + Data_p>1-Thre_SongType&Data_p~=2;
    end
end

Pulse_comb = Pulse_comb/sum(DataFlag_Song);
Sine_comb = Sine_comb/sum(DataFlag_Song);

%% voxel histogram
edges = [xlimrange(1):.05:xlimrange(2)];
centers = edges(1:end-1) + (edges(2)-edges(1))/2;
[N1,edges] = histcounts(Data_comb_pulse,edges);
[N2,edges] = histcounts(Data_comb_sine,edges);

% mean N of pixels per fly
N1 = N1/sum(DataFlag_Song);
N2 = N2/sum(DataFlag_Song);

figure('Position',[100,100,50,50])
bar(centers,N1,'FaceColor','r','EdgeColor','none')
hold on
bar(centers,N2,'FaceColor','b','EdgeColor','none')
plot([0 0],ylimrange1,'k--')
xlim(xlimrange)
box off
ylim(ylimrange1)
axis square
set(gca,'XTick',[xlimrange(1):0:xlimrange(2)],'XTickLabel',[],'YTick',[0,ylimrange1(2)/2,ylimrange1(2)],'YTickLabel',[],'TickDir','out')

%% spatial distribution
Margin_clip = [7,13,10,10];
GaussSD = 1;

figure
subplot(1,2,1)
buf = rot90(mean(Pulse_comb,3),3);
buf = imgaussfilt(buf,GaussSD,'FilterDomain','spatial');
imagesc(buf(1+Margin_clip(1):end-Margin_clip(2),1+Margin_clip(3):end-Margin_clip(4)),ylimrange)
axis square
axis off
subplot(1,2,2)
buf = rot90(mean(Sine_comb,3),3);
buf = imgaussfilt(buf,GaussSD,'FilterDomain','spatial');
imagesc(buf(1+Margin_clip(1):end-Margin_clip(2),1+Margin_clip(3):end-Margin_clip(4)),ylimrange)
axis square
axis off
colormap('hot')
colorbar