function [] = ExtDataFig06_AveImgEachStim()
% Code for plotting the images for the difference in F between pre- and during-stimulation in Extended Data Fig. 6f,g.

%% parameters
GT = 'dPR1_nsyb'; % Extended Data Fig. 6f
% GT = 'TN1A_nsyb'; % Extended Data Fig. 6g

TargetStim = [1:6];

zVentral = [1:15];
zDorsal = [16:30];

Margin = 40;

d1DS = 512/2;
d2DS = 512/2;
d3 = 30;

nStim = 6;

boost = 10;
boost_DFF = 1000;
const_DF = 1500;
const_DFF = 10;

%% get filenames
selpath = ['../Data/Summary_',GT];
DirNames_DP = dir([selpath,'/DataPixels*reformat1.nrrd']);

nFiles = length(DirNames_DP);

%% Average DF
AveComb_Ventral = zeros(d1DS,d2DS,length(TargetStim));
AveComb_Dorsal = zeros(d1DS,d2DS,length(TargetStim));
for target=1:length(TargetStim)
    DirNames = dir([selpath,'/F_Diff_*',num2str(TargetStim(target)),'_reformat1.nrrd']);
    
    Comb = zeros(d1DS,d2DS,d3,nFiles);
    Comb_DP = zeros(d1DS,d2DS,d3);
    for FileID=1:size(DirNames,1)
        name = DirNames(FileID).name;
        bufNRRD = nhdr_nrrd_read([selpath,'/',name],1);
        bufData = double(bufNRRD.data) - const_DF*boost;
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
                if Comb_DP(x,y,z)>0
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
    AveComb_Ventral(:,:,target) = bufComb;
    
    
    bufComb = zeros(d1DS,d2DS);
    for x=1:d1DS
        for y=1:d2DS
            if sum(Comb_DP(x,y,zVentral))>0
                bufComb(x,y) = sum(CombAve(x,y,zDorsal))/sum(Comb_DP(x,y,zDorsal));
            end
        end
    end
    AveComb_Dorsal(:,:,target) = bufComb;
end

figure
for stim=1:nStim
    subplot(2,nStim,stim)
    imagesc(fliplr(AveComb_Ventral(1+Margin:end-Margin,1+Margin:end-Margin,stim)),[0,2500])
    axis square
    axis off
    subplot(2,nStim,stim+nStim)
    imagesc(fliplr(AveComb_Dorsal(1+Margin:end-Margin,1+Margin:end-Margin,stim)),[0,1200])
    axis square
    axis off
    colormap('hot')
end
