function [] = ExtDataFig10_Connectivity_ToMN()
% Code for making the color plot of synaptic output to motor neurons in Extended Data Fig. 10g.

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

load('CellTypeList.mat')

ConnectionsToMN = zeros(length(Target),length(MN_ID));

%% DwS
FileNames = FileNamesDwS;
for FileID=1:size(FileNames,1)
    buf = FileNames(FileID).name;

    T = readtable([pathname,buf]);

    BodyIDs = T{:,3};
    Weight = T{:,4};

    for i=1:length(MN_ID)
        if ~isempty(find(BodyIDs==MN_ID(i)))
            ConnectionsToMN(FileID,i) = Weight(find(BodyIDs==MN_ID(i)));
        end
    end
end

buf = sum(ConnectionsToMN>=ThreSynapse,1);
MN_ID(buf>0)
MN_Name(buf>0)
ConnectionsToMN(:,buf==0) = [];

[~,I] = sort(-sum(ConnectionsToMN));
bufMN_Name = MN_Name(buf>0);
bufMN_Name(I);
bufMN_ID = MN_ID(buf>0);
bufMN_ID(I);

bufMN_Name_1 = bufMN_Name(I);
bufMN_ID_1 = bufMN_ID(I);

figure
imagesc(ConnectionsToMN(:,I),[0,300])
pbaspect([1,1,1])
axis off
colormap(flipud(bone))
colorbar