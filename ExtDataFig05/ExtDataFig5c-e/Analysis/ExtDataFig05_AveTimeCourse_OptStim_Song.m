function [] = ExtDataFig05_AveTimeCourse_OptStim_Song
% Code for plotting the tuning curves of pulse and sine songs induced by optogenetics in Extended Data Fig. 5c.

GT = 'TN1dsx';


switch GT
    case 'TN1dsx'
        CellFlagNonTrans = [0,1,0,0,1,0,1,0,0,1,0,0];
end

%% parameters
nTrials = 6;
nStim = 6;
T = 1370; % T

DAQrate = 10000;
x1 = [0:1/DAQrate:190-1/DAQrate];

PreDurImg = 10*DAQrate; % 10 s
OneTrialDur = 30*DAQrate; % 30 s

Opt_onset = [5+10:30:5+10+5*30]*DAQrate+1;

StimTarget = [3];

Thre_nTrialOpto = 1;

%% get file names
selpath = ['../Data/Summary_',GT,'/'];
switch GT
    case {'dPR1','dPR1NP','TN1SG','TN1SGNP','TN1dsx'}
        load([selpath,'FtimeCourseComb'])
    otherwise
        load([selpath,'StimComb'])
end

load([selpath,'EthogramCombPulseTrain'])
load('TS_Img')
load('TS_OptStimImg')

Stim_comb_org = Stim_comb;

%%
Data = Ethogram_comb;
Data_comb_pulse = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
Data_comb_sine = zeros(size(Data,1),OneTrialDur,nStim,nTrials);
RmvTrials_comb = zeros(size(Data,1),nStim,nTrials);

for DataID=1:size(Data,1)
    if CellFlagNonTrans(DataID)==1
        disp(['Data ID: ',num2str(DataID)])
        Stim_comb = Stim_comb_org{DataID};
        for trial=1:nTrials
            disp(['trial ',num2str(trial)])

            % pulse
            % downsample ethogram
            bufEtho = Data(DataID,:,trial);
            buf = zeros(size(bufEtho));
            buf(find(bufEtho==1)) = 1;
            for stim=1:nStim
                Data_comb_pulse(DataID,:,stim,trial) = buf([1:OneTrialDur]+Opt_onset(Stim_comb(:,trial)==stim)-PreDurImg-1);
            end

            % sine
            % downsample ethogram
            bufEtho = Data(DataID,:,trial);
            buf = zeros(size(bufEtho));
            buf(find(bufEtho==2)) = 1;
            for stim=1:nStim
                Data_comb_sine(DataID,:,stim,trial) = buf([1:OneTrialDur]+Opt_onset(Stim_comb(:,trial)==stim)-PreDurImg-1);
            end

            % flight
            buf = zeros(size(bufEtho));
            buf(find(bufEtho==3)) = 1;
            for stim=1:nStim
                bufFlight = buf([1:OneTrialDur]+Opt_onset(Stim_comb(:,trial)==stim)-PreDurImg-1);
                RmvTrials_comb(DataID,stim,trial) = sum(bufFlight)>0;
            end
        end
    end
end
FlagRmv = CellFlagNonTrans==0;
NonRmvID = find(CellFlagNonTrans==1);

Data_comb_pulse(FlagRmv==1,:,:,:) = [];
Data_comb_sine(FlagRmv==1,:,:,:) = [];

bufAve_pulse = zeros(size(Data_comb_pulse,1),OneTrialDur,nStim);
bufAve_sine = zeros(size(Data_comb_pulse,1),OneTrialDur,nStim);
for DataID=1:size(bufAve_pulse,1)
    for stim=1:nStim
        bufRmv = squeeze(RmvTrials_comb(NonRmvID(DataID),stim,:));
        buf = squeeze(Data_comb_pulse(DataID,:,stim,:));
        if size(buf,2)>=Thre_nTrialOpto
            bufAve_pulse(DataID,:,stim) = mean(buf,2);
        else
            bufAve_pulse(DataID,:,stim) = NaN;
        end
        buf = squeeze(Data_comb_sine(DataID,:,stim,:));
        if size(buf,2)>=Thre_nTrialOpto
            bufAve_sine(DataID,:,stim) = mean(buf,2);
        else
            bufAve_sine(DataID,:,stim) = NaN;
        end
    end
end

MovMeanWindow = 1000; % 100 ms
x = x1(1:OneTrialDur)-10;
x = downsample(x,MovMeanWindow);
x2 = [x, fliplr(x)];

figure('Position',[100,100,230,100])
for StimTarget=1:6
    subplot(1,6,StimTarget)
    hold on
    % pulse
    buf = bufAve_pulse(:,:,StimTarget);
    buf(isnan(buf(:,1)),:) = [];
    bufPlot = zeros(size(buf,1),length(x));
    for DataID=1:size(buf,1)
        bufPlot(DataID,:) = downsample(movmean(buf(DataID,:),MovMeanWindow),MovMeanWindow);
    end
    SEM = std(bufPlot)/sqrt(size(bufPlot,1));
    MEAN = mean(bufPlot,1);
    curve1 = MEAN + SEM;
    curve2 = MEAN - SEM;
    inBetween = [curve1, fliplr(curve2)];
    %     h = fill(x2, inBetween,'r','LineStyle','none','FaceAlpha',.5);
    h = fill(x2, inBetween,'r','LineStyle','none');
    plot(x,MEAN,'r','LineWidth',.5)
    nFly = size(buf,1)

    % sine
    buf = bufAve_sine(:,:,StimTarget);
    isnan(buf(:,1))
    buf(isnan(buf(:,1)),:) = [];
    bufPlot = zeros(size(buf,1),length(x));
    for DataID=1:size(buf,1)
        bufPlot(DataID,:) = downsample(movmean(buf(DataID,:),MovMeanWindow),MovMeanWindow);
    end
    SEM = std(bufPlot)/sqrt(size(bufPlot,1));
    MEAN = mean(bufPlot,1);
    curve1 = MEAN + SEM;
    curve2 = MEAN - SEM;
    inBetween = [curve1, fliplr(curve2)];
    %     h = fill(x2, inBetween,'b','LineStyle','none','FaceAlpha',.5);
    h = fill(x2, inBetween,'b','LineStyle','none');
    plot(x,MEAN,'b','LineWidth',.5)

    plot([0 10],[.5 .5]*1,'r','LineWidth',5)
    ylim([0 .6])
    xlim([-10 20])
    axis square

    %         set(gca,'XTick',[-5:5:15],'YTick',[0,0.25],'TickDir','out','XTickLabel',[],'YTickLabel',[])
    set(gca,'YTick',[0,0.3,0.6],'TickDir','out','YTickLabel',[])
    h = gca;
    h.XAxis.Visible = 'off';
end


figure('Position',[100,100,230,100])
for StimTarget=1:6
    subplot(1,6,StimTarget)
    hold on

    % relative sine
    buf = movmean(bufAve_sine(:,:,StimTarget),MovMeanWindow)./...
        (movmean(bufAve_pulse(:,:,StimTarget)+bufAve_sine(:,:,StimTarget),MovMeanWindow));
    bufPlot = zeros(size(buf,1),length(x));
    for DataID=1:size(buf,1)
        bufPlot(DataID,:) = downsample(movmean(buf(DataID,:),MovMeanWindow),MovMeanWindow);
    end
    SEM = std(bufPlot)/sqrt(size(bufPlot,1));
    MEAN = mean(bufPlot,1);
    curve1 = MEAN + SEM;
    curve2 = MEAN - SEM;
    inBetween = [curve1, fliplr(curve2)];
    %     h = fill(x2, inBetween,'b','LineStyle','none','FaceAlpha',.5);
    h = fill(x2, inBetween,'b','LineStyle','none');
    plot(x,MEAN,'b','LineWidth',.5)

    plot([0 10],[.5 .5]*1,'r','LineWidth',5)
    ylim([0 1])
    xlim([-10 20])
    axis square

    set(gca,'YTick',[0,0.5,1],'TickDir','out','YTickLabel',[])
    h = gca;
    h.XAxis.Visible = 'off';
end


function [x_up] = UpsampleData(x,UpSampleRate)
x_up = upsample(x,UpSampleRate,0);
for i=2:UpSampleRate
    x_up = x_up + upsample(x,UpSampleRate,i-1);
end
