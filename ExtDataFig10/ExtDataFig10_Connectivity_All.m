function [] = ExtDataFig10_Connectivity_All()
% Code for making the color plots of synaptic input/output in Extended Data Fig. 10e,f.

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
FileNamesDwS = [];
for FileID=1:length(Target)
    FileNamesDwS = [FileNamesDwS;dir([pathname,num2str(Target(FileID)),'_DwS.csv'])];
end

pathname = './UpSDws/';
FileNamesUpS = [];
for FileID=1:length(Target)
    FileNamesUpS = [FileNamesUpS;dir([pathname,num2str(Target(FileID)),'_UpS.csv'])];
end

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

%% Downstream neurons (Extended Data Fig. 10f)
ConnectionsToAll = zeros(length(Target),length(TargetBodyID));
FileNames = FileNamesDwS;
for FileID=1:size(FileNames,1)
    if rem(FileID,100)==0
        disp(num2str(FileID))
    end

    buf = FileNames(FileID).name;

    T = readtable([pathname,buf]);

    BodyIDs = T{:,3};
    Weight = T{:,4};

    for i=1:length(BodyIDs)
        if Weight(i)>=ThreSynapse
            ConnectionsToAll(FileID,TargetBodyID==BodyIDs(i)) = Weight(i);
        end
    end
end

buf = sum(ConnectionsToAll,1);
ConnectionsToAll(:,buf==0) = [];

[~,I] = sort(-sum(ConnectionsToAll));
figure
imagesc(ConnectionsToAll(:,I),[0,300])
pbaspect([5,1,1])
axis off
colormap(flipud(bone))
colorbar

%% Upstream neurons (Extended Data Fig. 10d)
ConnectionsToAll = zeros(length(Target),length(TargetBodyID));
FileNames = FileNamesUpS;
for FileID=1:size(FileNames,1)
    if rem(FileID,100)==0
        disp(num2str(FileID))
    end

    buf = FileNames(FileID).name;

    T = readtable([pathname,buf]);

    BodyIDs = T{:,3};
    Weight = T{:,4};

    for i=1:length(BodyIDs)
        if Weight(i)>=ThreSynapse
            ConnectionsToAll(FileID,TargetBodyID==BodyIDs(i)) = Weight(i);
        end
    end
end

buf = sum(ConnectionsToAll,1);
ConnectionsToAll(:,buf==0) = [];

[~,I] = sort(-sum(ConnectionsToAll));
figure
imagesc(ConnectionsToAll(:,I),[0,300])
pbaspect([5,1,1])
axis off
colormap(flipud(bone))
colorbar