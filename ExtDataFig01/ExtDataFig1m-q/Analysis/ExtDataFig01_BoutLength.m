function [] = ExtDataFig01_BoutLength()
% Code for plotting histograms of pulse and sine song bouts in Extended Data Fig. 1o.

Cond = 'intact'; % Extended Data Fig. 1o

switch Cond
    case 'intact'
        Target = [3,5,7,9];
end

%% get filenames
selpathOrg = ['../Data/Summary/'];
DataNames_Mic = dir([selpathOrg,'/Mic_*']);
load([selpathOrg,['EthogramCombPulseTrain']])
load([selpathOrg,['StimComb']])

%%
nTrials = 6;
DAQrate = 10000;
Data = Ethogram_comb(Target,:,:);
PulseDurTotal = [];
SineDurTotal = [];

for DataID=1:size(Data,1)
    disp(['Data ID: ',num2str(DataID)])
    
    for trial=1:nTrials
        bufEtho = squeeze(Data(DataID,:,trial));
        
        % pulse
        PulseTimes = bufEtho==1;
        bufDiff = diff(PulseTimes);
        Onset = find(bufDiff==1);
        Offset = find(bufDiff==-1);
        PulseDur = Offset-Onset;
        PulseDurTotal = [PulseDurTotal,PulseDur/DAQrate];

        % sine
        SineTimes = bufEtho==2;
        bufDiff = diff(SineTimes);
        Onset = find(bufDiff==1);
        Offset = find(bufDiff==-1);
        SineDur = Offset-Onset;
        SineDurTotal = [SineDurTotal,SineDur/DAQrate];
    end
end

figure
subplot(2,1,1)
histogram(PulseDurTotal)
subplot(2,1,2)
histogram(SineDurTotal)

PulseDurTotal_SongDriver = PulseDurTotal;
SineDurTotal_SongDriver = SineDurTotal;

load('BoutLength_WT')

PulseTrunctate = 1;
PulseDurTotal_SongDriver(PulseDurTotal_SongDriver>PulseTrunctate) = PulseTrunctate;
PulseDurTotal(PulseDurTotal>PulseTrunctate) = PulseTrunctate;
SineTrunctate = 4;
SineDurTotal_SongDriver(SineDurTotal_SongDriver>SineTrunctate) = SineTrunctate;
SineDurTotal(SineDurTotal>SineTrunctate) = SineTrunctate;

figure
subplot(2,2,1)
hold on
edges = [0:0.05:2];
h1 = histogram(PulseDurTotal_SongDriver,edges);
h1.Normalization = 'probability';
h1.FaceColor = 'r';
h1.FaceAlpha = 1;
h2 = histogram(PulseDurTotal,edges);
h2.Normalization = 'probability';
h2.FaceColor = 'b';
h2.FaceAlpha = 1;
xlim([0,1])
set(gca,'XTick',[0,.5,1],'YTick',[0,.3,.6],'TickDir','out')
axis square

subplot(2,2,2)
hold on
edges = [0:0.2:7];
h1 = histogram(SineDurTotal_SongDriver,edges);
h1.Normalization = 'probability';
h1.FaceColor = 'r';
h1.FaceAlpha = 1;
h2 = histogram(SineDurTotal,edges);
h2.Normalization = 'probability';
h2.FaceColor = 'b';
h2.FaceAlpha = 1;
xlim([0,4])
set(gca,'XTick',[0,2,4],'YTick',[0,.2,.4],'TickDir','out')
axis square

subplot(2,2,3)
hold on
edges = [0:0.05:2];
h1 = histogram(PulseDurTotal_SongDriver,edges);
h1.Normalization = 'probability';
h1.FaceColor = 'r';
h1.FaceAlpha = 1;
h2 = histogram(PulseDurTotal,edges);
h2.Normalization = 'probability';
h2.FaceColor = 'b';
h2.FaceAlpha = 1;
xlim([0,1.05])
set(gca,'XTick',[0,.5,1],'YTick',[0,.3,.6],'TickDir','out')
axis square

subplot(2,2,4)
hold on
edges = [0:0.2:7];
h1 = histogram(SineDurTotal_SongDriver,edges);
h1.Normalization = 'probability';
h1.FaceColor = 'r';
h1.FaceAlpha = 1;
h2 = histogram(SineDurTotal,edges);
h2.Normalization = 'probability';
h2.FaceColor = 'b';
h2.FaceAlpha = 1;
xlim([0,4.2])
set(gca,'XTick',[0,2,4],'YTick',[0,.2,.4],'TickDir','out')
axis square
