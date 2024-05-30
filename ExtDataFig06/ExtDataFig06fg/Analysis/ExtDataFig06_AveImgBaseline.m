function [] = ExtDataFig06_AveImgBaseline()
% Code for plotting the baseline F images in Extended Data Fig. 6f,g.

%% parameters
GT = 'dPR1_nsyb'; % Extended Data Fig. 6f
% GT = 'TN1A_nsyb'; % Extended Data Fig. 6g

zVentral = [1:15];
zDorsal = [16:30];

Margin = 40;

d1DS = 512/2;
d2DS = 512/2;
d3 = 30;

Thre_Comb_DP = 2;

%% get filenames
selpath = ['../Data/Summary_',GT];
DirNames_DP = dir([selpath,'/DataPixels*reformat1.nrrd']);

nFiles = length(DirNames_DP);

%% Average Baseline
AveComb_Ventral = zeros(d1DS,d2DS);
AveComb_Dorsal = zeros(d1DS,d2DS);

DirNames = dir([selpath,'/F_Baseline_*_reformat1.nrrd']);

Comb = zeros(d1DS,d2DS,d3,nFiles);
Comb_DP = zeros(d1DS,d2DS,d3);
for FileID=1:size(DirNames,1)
    name = DirNames(FileID).name;
    bufNRRD = nhdr_nrrd_read([selpath,'/',name],1);
    bufData = double(bufNRRD.data);
    name = DirNames_DP(FileID).name;
    bufNRRD_DP = nhdr_nrrd_read([selpath,'/',name],1);
    bufData_DP = double(bufNRRD_DP.data);
    bufData(bufData_DP==0) = 0;
    Comb = Comb + bufData;
    Comb_DP = Comb_DP + bufData_DP;
end
CombAve = zeros(d1DS,d2DS,d3);
for x=1:d1DS
    for y=1:d2DS
        for z=1:d3
            if Comb_DP(x,y,z)>Thre_Comb_DP
                CombAve(x,y,z) = sum(Comb(x,y,z,:))/Comb_DP(x,y,z);
            end
        end
    end
end

bufComb = zeros(d1DS,d2DS);
for x=1:d1DS
    for y=1:d2DS
        if sum(Comb_DP(x,y,zVentral))>0
            bufComb(x,y) = sum(CombAve(x,y,zVentral))/sum(Comb_DP(x,y,zVentral));
        end
    end
end
AveComb_Ventral(:,:) = bufComb;


bufComb = zeros(d1DS,d2DS);
for x=1:d1DS
    for y=1:d2DS
        if sum(Comb_DP(x,y,zVentral))>0
            bufComb(x,y) = sum(CombAve(x,y,zDorsal))/sum(Comb_DP(x,y,zDorsal));
        end
    end
end
AveComb_Dorsal(:,:) = bufComb;

% DEBUG
figure
subplot(1,2,1)
imagesc(AveComb_Ventral(:,:))
subplot(1,2,2)
imagesc(AveComb_Dorsal(:,:))
colormap('gray')


figure
subplot(2,1,1)
imagesc(fliplr(AveComb_Ventral(1+Margin:end-Margin,1+Margin:end-Margin)),[0,1200])
axis square
axis off
subplot(2,1,2)
imagesc(fliplr(AveComb_Dorsal(1+Margin:end-Margin,1+Margin:end-Margin)),[0,400])
axis square
axis off
colormap('gray')