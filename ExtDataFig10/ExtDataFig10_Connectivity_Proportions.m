function [] = ExtDataFig10_Connectivity_Proportions()
% Code for plotting the input/output cell types in Extended Data Fig. 10c,e.

%% parameters
pIP10 = [13417,13038]; % pIP10 (L, R)
pMP2 = [11977,11987];
dPR1 = [10267,10300]; % dPR1
TN1A = [15521,16465,15148,12883,16207,...
    16113,14581,14810,15387,17640,...
    13945,14401,13928,16391,16042,...
    13155,13445,14277,14375,14779,...
    16690,15936,13727,13514];

Target = [dPR1,TN1A];

ThreSynapse = 10;

%% Load data
pathname = './UpSDws/';
FileNamesUpS = [];
FileNamesDwS = [];
for FileID=1:length(Target)
    FileNamesUpS = [FileNamesUpS;dir([pathname,num2str(Target(FileID)),'_UpS.csv'])];
    FileNamesDwS = [FileNamesDwS;dir([pathname,num2str(Target(FileID)),'_DwS.csv'])];
end

load('CellTypeList.mat')

%% Target
T = readtable('PrePost100.csv'); % new neurons
TraceStatus = T{:,7};
TraceStatusFlag = zeros(length(TraceStatus),1);
for i=1:length(TraceStatus)
    TraceStatusFlag(i) = strcmp(TraceStatus{i},'Traced');
end

TargetBodyID = T{:,2};
TargetType = T{:,3};
TargetBodyID(TraceStatusFlag==0) = [];
TargetType(TraceStatusFlag==0) = [];

%% UpS
FileNames = FileNamesUpS;

ConnectionsToDN = zeros(length(Target),1);
ConnectionsToAN = zeros(length(Target),1);
ConnectionsToIN = zeros(length(Target),1);
ConnectionsToMN = zeros(length(Target),1);
ConnectionsToSN = zeros(length(Target),1);
ConnectionsToUND = zeros(length(Target),1);

for FileID=1:size(FileNames,1)
    if rem(FileID,100)==0
        disp(num2str(FileID))
    end

    buf = FileNames(FileID).name;

    T = readtable([pathname,buf]);

    BodyIDs = T{:,3};
    Weight = T{:,4};

    BodyIDs(Weight<ThreSynapse) = [];
    Weight(Weight<ThreSynapse) = [];
    for i=1:length(BodyIDs)
        if ismember(BodyIDs(i),DN_ID)
            ConnectionsToDN(FileID) = ConnectionsToDN(FileID) + Weight(i);
        elseif ismember(BodyIDs(i),AN_ID)
            ConnectionsToAN(FileID) = ConnectionsToAN(FileID) + Weight(i);
        elseif ismember(BodyIDs(i),IN_ID)
            ConnectionsToIN(FileID) = ConnectionsToIN(FileID) + Weight(i);
        elseif ismember(BodyIDs(i),MN_ID)
            ConnectionsToMN(FileID) = ConnectionsToMN(FileID) + Weight(i);
        elseif ismember(BodyIDs(i),SN_ID)
            ConnectionsToSN(FileID) = ConnectionsToSN(FileID) + Weight(i);
        else
            ConnectionsToUND(FileID) = ConnectionsToUND(FileID) + Weight(i);
        end
    end
end

bufTotal = ConnectionsToDN + ConnectionsToAN + ConnectionsToIN + ConnectionsToMN + ConnectionsToSN;

ConnectionsToDN./bufTotal;
ConnectionsToAN./bufTotal;
ConnectionsToIN./bufTotal;
ConnectionsToMN./bufTotal;
ConnectionsToSN./bufTotal; % no input from motor neurons
ConnectionsToUND./bufTotal;

figure('Position',[100,100,150,75])
bar([ConnectionsToDN,ConnectionsToAN,ConnectionsToIN,ConnectionsToSN]./bufTotal,'stacked')
xlim([0,27])
ylim([0,1])
pbaspect([2,1,1])
set(gca,'XTick',[],'YTick',[0,.5,1],'YTickLabel','','TickDir','out')
box off

%% DwS
FileNames = FileNamesDwS;

ConnectionsToDN = zeros(length(Target),1);
ConnectionsToAN = zeros(length(Target),1);
ConnectionsToIN = zeros(length(Target),1);
ConnectionsToMN = zeros(length(Target),1);
ConnectionsToSN = zeros(length(Target),1);
ConnectionsToUND = zeros(length(Target),1);

for FileID=1:size(FileNames,1)
    if rem(FileID,100)==0
        disp(num2str(FileID))
    end

    buf = FileNames(FileID).name;

    T = readtable([pathname,buf]);

    BodyIDs = T{:,3};
    Weight = T{:,4};

    BodyIDs(Weight<ThreSynapse) = [];
    Weight(Weight<ThreSynapse) = [];
    
    for i=1:length(BodyIDs)
        if ismember(BodyIDs(i),DN_ID)
            ConnectionsToDN(FileID) = ConnectionsToDN(FileID) + Weight(i);
        elseif ismember(BodyIDs(i),AN_ID)
            ConnectionsToAN(FileID) = ConnectionsToAN(FileID) + Weight(i);
        elseif ismember(BodyIDs(i),IN_ID)
            ConnectionsToIN(FileID) = ConnectionsToIN(FileID) + Weight(i);
        elseif ismember(BodyIDs(i),MN_ID)
            ConnectionsToMN(FileID) = ConnectionsToMN(FileID) + Weight(i);
        elseif ismember(BodyIDs(i),SN_ID)
            ConnectionsToSN(FileID) = ConnectionsToSN(FileID) + Weight(i);
        else
            ConnectionsToUND(FileID) = ConnectionsToUND(FileID) + Weight(i);
        end
    end
end

bufTotal = ConnectionsToDN + ConnectionsToAN + ConnectionsToIN + ConnectionsToMN + ConnectionsToSN;

ConnectionsToDN./bufTotal;
ConnectionsToAN./bufTotal;
ConnectionsToIN./bufTotal;
ConnectionsToMN./bufTotal; % no input from motor neurons
ConnectionsToSN./bufTotal; % no input from motor neurons
ConnectionsToUND./bufTotal;

figure('Position',[100,100,150,75])
bar([ConnectionsToDN,ConnectionsToAN,ConnectionsToIN,ConnectionsToMN,ConnectionsToSN]./bufTotal,'stacked')
xlim([0,27])
ylim([0,1])
pbaspect([2,1,1])
set(gca,'XTick',[],'YTick',[0,.5,1],'YTickLabel','','TickDir','out')
box off
