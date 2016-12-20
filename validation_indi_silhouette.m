function validation_indi_silhouette(PWD,ROI,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,POOLSIZE,MPM_THRES,LorR)

if LorR == 1
    LR='L';
elseif LorR == 0
    LR='R';
end

sub=textread(SUB_LIST,'%s');
sub_num=length(sub);

if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
    MPM_THRES=0.25;
end

% open pool
if exist('parpool')
    pcp=gcp('nocreate');
    if isempty(pcp) 
        p=parpool('local',POOLSIZE);
    end
else
    if matlabpool('size')==0
        matlabpool('local',POOLSIZE);
    end
end 

% individual-level silhouette
indi_sil=zeros(sub_num,MAX_CL_NUM);
parfor ti=1:sub_num
    matrix_file=strcat(PWD,'/',sub{ti},'/',sub{ti},'_',ROI,'_',LR,'_matrix/connection_matrix.mat');
    con_matrix=load(matrix_file);
    sum_matrix=sum(con_matrix.matrix,2);
    matrix=con_matrix.matrix./sum_matrix(:,ones(1,size(con_matrix.matrix,2)));
    distance=pdist(con_matrix.matrix,'cosine');

    temp=zeros(1,MAX_CL_NUM);
    for kc=2:MAX_CL_NUM
        disp(['indi_silhouette: ',ROI,'_',LR,' kc=',num2str(kc),' ',num2str(ti)]);

        nii_file=strcat(PWD,'/',sub{ti},'/',sub{ti},'_',ROI,'_',LR,'_',METHOD,'/',ROI,'_',LR,'_',num2str(kc),'.nii');
        nii=load_untouch_nii(nii_file);
        tempimg=double(nii.img);
        [xx,yy,zz]=size(tempimg);    
        label=zeros(length(con_matrix.xyz),1);
        for n=1:length(con_matrix.xyz)
            label(n,1)=tempimg(con_matrix.xyz(n,1)+1,con_matrix.xyz(n,2)+1,con_matrix.xyz(n,3)+1);
        end
        s=silhouette([],label,distance);
        temp(kc)=nanmean(s);
    end
    indi_sil(ti,:)=temp;
end


if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_indi_silhouette.mat'),'indi_sil');

fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_indi_silhouette.txt'),'at');
if fp for kc=2:MAX_CL_NUM
        fprintf(fp,'cluster_num: %d\navg_indi_silhouette: %f\nstd_indi_silhouette: %f\nmedian_indi_silhouette: %f\n\n',kc,nanmean(indi_sil(:,kc)),nanstd(indi_sil(:,kc)),nanmedian(indi_sil(:,kc)));
    end
end
fclose(fp);


