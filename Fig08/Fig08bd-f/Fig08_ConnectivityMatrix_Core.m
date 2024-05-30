function [] = Fig08_ConnectivityMatrix_Core()
% Code for plotting the connectivity matrix in Fig. 8b.

%% parameters
pIP10 = [13417,13038]; % pIP10 (L, R)
pMP2 = [11977,11987];
dPR1 = [10267,10300]; % dPR1
TN1A = [15521,16465,15148,12883,16207,...
    16113,14581,14810,15387,17640,...
    13945,14401,13928,16391,16042,...
    13155,13445,14277,14375,14779,...
    16690,15936,13727,13514];

Target = [pIP10,pMP2,dPR1,TN1A];

%% Load data
pathname = './UpSDws/';
FileNamesDwS = [];
for FileID=1:length(Target)
    FileNamesDwS = [FileNamesDwS;dir([pathname,num2str(Target(FileID)),'_DwS.csv'])];
end

Connections = zeros(length(Target));

InputAll = [];
OutputAll = [];

%% DwS
FileNames = FileNamesDwS;
for FileID=1:size(FileNames,1)
    buf = FileNames(FileID).name;
    BodyID = buf(1:5);
    BodyID = str2num(BodyID);

    T = readtable([pathname,buf]);

    BodyIDs = T{:,3};
    Weight = T{:,4};

    for i=1:length(Target)
        if ~isempty(find(BodyIDs==Target(i)))
            Connections(FileID,i) = Weight(find(BodyIDs==Target(i)));
        end
    end
end

%%
figure
imagesc(Connections,[0,100])
axis square
axis off
colormap(flipud(bone))
colorbar
