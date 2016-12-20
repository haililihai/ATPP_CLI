function [mpm_cluster]=cluster_mpm_validation(PWD,ROI,SUB,METHOD,VOX_SIZE,kc,MPM_THRES,LorR)

    if LorR == 1
        LR='L';
    elseif LorR == 0
        LR='R';
    end

    sub=SUB;
    sub_num=length(SUB);
    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end

    vnii_ref=load_untouch_nii(strcat(PWD,'/',sub{1},'/',sub{1},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii.gz'));
    ref_img=double(vnii_ref.img);
    IMGSIZE=size(ref_img);
    sumimg=zeros(IMGSIZE);

    prob_cluster=zeros([IMGSIZE,kc]);
    for subi=1:sub_num
        sub_file=strcat(PWD,'/',sub{subi},'/',sub{subi},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii.gz');
        vnii=load_untouch_nii(sub_file);
        tha_seg_result= vnii.img;   
        dataimg=double(vnii.img);
        dataimg(dataimg>0)=1;
        sumimg=sumimg+dataimg;

    %computing the probabilistic maps
        for ki=1:kc
            tmp_ind=(tha_seg_result==ki);
            prob_cluster(:,:,:,ki) = prob_cluster(:,:,:,ki) + tmp_ind;
        end
    end

    indeximg=sumimg;
    indeximg(indeximg<MPM_THRES*sub_num)=0;
    indeximg(indeximg>0)=1;

    for ki=1:kc
        prob_cluster(:,:,:,ki)=prob_cluster(:,:,:,ki).*indeximg;
    end

    index=find(indeximg>0);
    [xi,yi,zi]=ind2sub(IMGSIZE,index);
    no_voxel=length(index);

    mpm_cluster=zeros(IMGSIZE);
    for vi=1:no_voxel
        prob=(prob_cluster(xi(vi),yi(vi),zi(vi),:)/sumimg(xi(vi),yi(vi),zi(vi)))*100;
        [tmp_prob,tmp_ind]=sort(-prob);
        if prob(tmp_ind(1))-prob(tmp_ind(2))>0
            mpm_cluster(index(vi))=tmp_ind(1);
        else
            mean1=connect6mean(prob_cluster(:,:,:,tmp_ind(1)),xi(vi),yi(vi),zi(vi));
            mean2=connect6mean(prob_cluster(:,:,:,tmp_ind(2)),xi(vi),yi(vi),zi(vi));
            [null_var,label]=max([mean1,mean2]);
            mpm_cluster(index(vi))=tmp_ind(label);
        end
    end

function out=connect6mean(img,i,j,k)
    val=zeros(6,1);
    val(1,1)=img(i-1,j,k);
    val(2,1)=img(i+1,j,k);
    val(3,1)=img(i,j-1,k);
    val(4,1)=img(i,j+1,k);
    val(5,1)=img(i,j,k-1);
    val(6,1)=img(i,j,k+1);
    out=mean(val);
