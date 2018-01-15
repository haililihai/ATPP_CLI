function validation_pairwise(PWD,ROI,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,POOLSIZE,GROUP_THRES,MPM_THRES,LorR)

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

GROUP_THRES=GROUP_THRES*100;
MASK_FILE=strcat(PWD,'/group_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_roimask_thr',num2str(GROUP_THRES),'.nii.gz');
MASK_NII=load_untouch_nii(MASK_FILE);
MASK=double(MASK_NII.img);
MASK(isnan(MASK))=0;

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

dice=zeros(sub_num,sub_num,MAX_CL_NUM);
nminfo=zeros(sub_num,sub_num,MAX_CL_NUM);
vi=zeros(sub_num,sub_num,MAX_CL_NUM);
cv=zeros(sub_num,sub_num,MAX_CL_NUM);

parfor kc=2:MAX_CL_NUM
    dice_k=zeros(sub_num,sub_num);
    nminfo_k=zeros(sub_num,sub_num);
    vi_k=zeros(sub_num,sub_num);
    cv_k=zeros(sub_num,sub_num);

    for ti=1:sub_num-1
        vnii_ref_file=strcat(PWD,'/',sub{ti},'/',sub{ti},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii.gz');
        vnii_ref=load_untouch_nii(vnii_ref_file);
        mpm_cluster1=double(vnii_ref.img);
        mpm_cluster1(isnan(mpm_cluster1))=0;
        mpm_cluster1=mpm_cluster1.*MASK;

        for tn=ti+1:sub_num
            disp(['pairwise: ',ROI,'_',LR,' kc=',num2str(kc),' ',num2str(ti),'<->',num2str(tn)]);

            vnii_ref1_file=strcat(PWD,'/',sub{tn},'/',sub{tn},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii.gz');
            vnii_ref1=load_untouch_nii(vnii_ref1_file);
            mpm_cluster2=double(vnii_ref1.img);
            mpm_cluster2(isnan(mpm_cluster2))=0;
            mpm_cluster2=mpm_cluster2.*MASK;

            %compute dice coefficent
            dice_k(ti,tn)=v_dice(mpm_cluster1,mpm_cluster2);
        
            %compute the normalized mutual information and variation of information
            [nminfo_k(ti,tn),vi_k(ti,tn)]=v_nmi(mpm_cluster1,mpm_cluster2);
        
            %compute cramer V
            cv_k(ti,tn)=v_cramerv(mpm_cluster1,mpm_cluster2);
        end
    end

    dice(:,:,kc)=dice_k;
    nminfo(:,:,kc)=nminfo_k;
    vi(:,:,kc)=vi_k;
    cv(:,:,kc)=cv_k;
end
% matlabpool close

if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'))
    mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));
end
save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_pairwise.mat'),'dice','nminfo','cv','vi');

fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_pairwise.txt'),'at');
if fp
    for kc=2:MAX_CL_NUM
        col_cv=cv(:,:,kc);
        col_cv=col_cv(find(col_cv~=0));
        col_dice=dice(:,:,kc);
        col_dice=col_dice(find(col_dice~=0));
        col_nmi=nminfo(:,:,kc); 
        col_nmi=col_nmi(find(col_nmi~=0));
        col_vi=vi(:,:,kc); 
        col_vi=col_vi(find(col_vi~=0)); 
        fprintf(fp,'cluster_num: %d\nmcv: %f, std_cv: %f\nmdice: %f, std_dice: %f\nnminfo: %f,std_nminfo: %f\nmvi: %f,std_vi: %f\n\n',kc,nanmean(col_cv),nanstd(col_cv),nanmean(col_dice),nanstd(col_dice),nanmean(col_nmi),nanstd(col_nmi),nanmean(col_vi),nanstd(col_vi));
    end
end
fclose(fp);


