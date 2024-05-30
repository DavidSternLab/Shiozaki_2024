function [] = Fig08_Plot_InputOutputHist_Single_dPR1()
% Code for plotting the histogram in Fig. 8d.

%% parameters
pIP10 = [13417,13038]; % pIP10 (L, R)
pMP2 = [11977,11987];
dPR1 = [10267,10300]; % dPR1
TN1A1 = [15521,16465,15148,12883,16207,...
    16113,14581,14810,15387,17640];
TN1A2 = [13945,14401,13928,16391,16042,...
    13155,13445,14277,14375,14779,...
    16690,15936,13727,13514];

Target = [dPR1(2)];
% Target = [TN1A(1)];

FlagUpS = 1;
FlagDwS = 1;

% weight threshold
WeightThre = 50;

%% Load data
pathname = './UpSDws/';

FileNamesUpS = [];
FileNamesDwS = [];
for FileID=1:length(Target)
    FileNamesUpS = [FileNamesUpS;dir([pathname,num2str(Target(FileID)),'_UpS.csv'])];
    FileNamesDwS = [FileNamesDwS;dir([pathname,num2str(Target(FileID)),'_DwS.csv'])];
end

Connections = [];

InputAll = [];
OutputAll = [];

buf = readmatrix('MANC_wing_MN_list_HC.csv');
MN_ID = buf(:,3);

%% UpS
if FlagUpS==1
    FileNames = FileNamesUpS;
    for FileID=1:size(FileNames,1)
        buf = FileNames(FileID).name;
        BodyID = buf(1:5);
        BodyID = str2num(BodyID);

        T = readtable([pathname,buf]);

        BodyIDs = T{:,3};
        Weight = T{:,4};
        TargetBodyIDs = BodyIDs(Weight>=WeightThre);
        TargetWeight = Weight(Weight>=WeightThre);


        bufType = buf(end-9:end-4);

        buf = ones(length(TargetBodyIDs),1)*BodyID;

        if strcmp(bufType(end-2:end),'DwS')
            bufConenctions = [buf,TargetBodyIDs,TargetWeight];
        elseif strcmp(bufType(end-2:end),'UpS')
            bufConenctions = [TargetBodyIDs,buf,TargetWeight];
        end

        Connections = [Connections;bufConenctions];

        InputAll{FileID} = [TargetBodyIDs,TargetWeight];
    end
end

%% DwS
if FlagDwS==1
    FileNames = FileNamesDwS;
    for FileID=1:size(FileNames,1)
        buf = FileNames(FileID).name;
        BodyID = buf(1:5);
        BodyID = str2num(BodyID);

        T = readtable([pathname,buf]);

        BodyIDs = T{:,3};
        Weight = T{:,4};
        TargetBodyIDs = BodyIDs(Weight>=WeightThre);
        TargetWeight = Weight(Weight>=WeightThre);


        bufType = buf(end-9:end-4);

        buf = ones(length(TargetBodyIDs),1)*BodyID;

        if strcmp(bufType(end-2:end),'DwS')
            bufConenctions = [buf,TargetBodyIDs,TargetWeight];
        elseif strcmp(bufType(end-2:end),'UpS')
            bufConenctions = [TargetBodyIDs,buf,TargetWeight];
        end

        Connections = [Connections;bufConenctions];

        OutputAll{FileID} = [TargetBodyIDs,TargetWeight];
    end
end

%% input
Data = InputAll;
SynapticPartners = [];
WeightProp = [];
for FileID=1:size(FileNames,1)
    data = Data{FileID};
    SynapticPartners = [SynapticPartners;data(:,1)];
    WeightProp = [WeightProp;data(:,2)/sum(data(:,2))];
end
SynapticPartnersUnq = unique(SynapticPartners);
WeightUnq = zeros(size(SynapticPartnersUnq));
for i=1:length(SynapticPartnersUnq)
    buf = WeightProp(find(SynapticPartners==SynapticPartnersUnq(i)));
    WeightUnq(i) = max(buf);
end
[~,I] = sort(-WeightUnq);
SynapticPartners = SynapticPartnersUnq(I);
plotData = zeros(size(FileNames,1),length(SynapticPartners));
for FileID=1:size(FileNames,1)
    data = Data{FileID};
    data(:,2) = data(:,2)/sum(data(:,2));
    for i=1:length(data(:,1))
        plotData(FileID,find(SynapticPartners==data(i,1))) = data(i,2);
    end
end
% figure
% imagesc(plotData,[0,0.05])


for FileID=1:size(FileNames,1)
    figure('Position',[100,100,200,50])
    %     figure('Position',[100,100,150,150])
    data = Data{FileID};
    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        plotData(find(SynapticPartners==data(i,1))) = data(i,2);
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'k')
    hold on

    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        if ismember(data(i,1),dPR1)
            plotData(find(SynapticPartners==data(i,1))) = data(i,2);
        end
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'r')

    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        if ismember(data(i,1),TN1A1)
            plotData(find(SynapticPartners==data(i,1))) = data(i,2);
        end
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'b')

    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        if ismember(data(i,1),TN1A2)
            plotData(find(SynapticPartners==data(i,1))) = data(i,2);
        end
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'m')

    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        if ismember(data(i,1),pMP2)
            plotData(find(SynapticPartners==data(i,1))) = data(i,2);
        end
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'g')

    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        if ismember(data(i,1),pIP10)
            plotData(find(SynapticPartners==data(i,1))) = data(i,2);
        end
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'y')

    box off
    xlim([1-1,length(plotData)+1])
    if FileID<3
        ylim([9,1000])
    else
        ylim([9,200])
    end
    %     set(gca,'TickDir','out','XTick',[1,length(plotData)],'YScale','log','XTickLabel',[],'YTickLabel',[])
    set(gca,'TickDir','out','XTick',[1,length(plotData)],'YTick',[0,300,600],'XTickLabel',[],'YTickLabel',[])
    ylim([0 600])
    pbaspect([3,1,1])
    %     axis square
end
% close all

%% output
Data = OutputAll;
SynapticPartners = [];
WeightProp = [];
for FileID=1:size(FileNames,1)
    data = Data{FileID};
    SynapticPartners = [SynapticPartners;data(:,1)];
    WeightProp = [WeightProp;data(:,2)/sum(data(:,2))];
end
SynapticPartnersUnq = unique(SynapticPartners);
WeightUnq = zeros(size(SynapticPartnersUnq));
for i=1:length(SynapticPartnersUnq)
    buf = WeightProp(find(SynapticPartners==SynapticPartnersUnq(i)));
    WeightUnq(i) = max(buf);
end
[~,I] = sort(-WeightUnq);
SynapticPartners = SynapticPartnersUnq(I);

for FileID=1:size(FileNames,1)
    figure('Position',[100,100,550,70])
    data = Data{FileID};
    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        plotData(find(SynapticPartners==data(i,1))) = data(i,2);
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'k')
    hold on

    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        if ismember(data(i,1),dPR1)
            plotData(find(SynapticPartners==data(i,1))) = data(i,2);
        end
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'r')

    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        if ismember(data(i,1),TN1A1)
            plotData(find(SynapticPartners==data(i,1))) = data(i,2);
        end
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'b')

    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        if ismember(data(i,1),TN1A2)
            plotData(find(SynapticPartners==data(i,1))) = data(i,2);
        end
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'m')

    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        if ismember(data(i,1),pMP2)
            plotData(find(SynapticPartners==data(i,1))) = data(i,2);
        end
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'g')

    plotData = zeros(length(SynapticPartners),1);
    for i=1:length(data(:,1))
        if ismember(data(i,1),pIP10)
            plotData(find(SynapticPartners==data(i,1))) = data(i,2);
        end
    end
    %     subplot(size(FileNames,1),1,FileID)
    bar(plotData,'y')

    box off
    xlim([1-.5,length(plotData)+.5])
    if FileID<3
        ylim([9,1000])
    else
        ylim([9,300])
    end
    set(gca,'TickDir','out','XTick',[1,length(plotData)],'YScale','log','XTickLabel',[],'YTickLabel',[])
end

