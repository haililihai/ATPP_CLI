function calc_mpm_group_xmm(PWD,ROI,SUB_LIST,MAX_CL_NUM,POOLSIZE,METHOD,MPM_THRES,VOX_SIZE,LEFT,RIGHT)
% generate the probabilistic maps and the maximum probabilistic map

SUB = textread(SUB_LIST,'%s');

% modify temporary dir
temp_dir=tempname();
mkdir(temp_dir);
if exist('parcluster')
    pc=parcluster('local');
    pc.JobStorageLocation=temp_dir;
else
    sched=findResource('scheduler','type','local');
    sched.DataLocation=temp_dir;
end

% open pool
if exist('parpool')
    p=parpool('local',POOLSIZE);
else
    matlabpool('local',POOLSIZE);
end

if LEFT == 1
    calc_mpm(PWD,ROI,SUB,MAX_CL_NUM,POOLSIZE,METHOD,MPM_THRES,VOX_SIZE,1)
end

if RIGHT == 1
    calc_mpm(PWD,ROI,SUB,MAX_CL_NUM,POOLSIZE,METHOD,MPM_THRES,VOX_SIZE,0)
end

% close pool
if exist('parpool')
    delete(p);
else
    matlabpool close;
end

function calc_mpm(PWD,ROI,SUB,MAX_CL_NUM,POOLSIZE,METHOD,MPM_THRES,VOX_SIZE,LorR)
    
if LorR == 1
    LR='L';
elseif LorR == 0
    LR='R';
end

REFER = strcat(PWD,'/',SUB{1},'/',SUB{1},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(2),'_MNI_relabel_group.nii.gz');
vnii_ref = load_untouch_nii(REFER);
ref_img=vnii_ref.img;
IMGSIZE=size(ref_img);


probpath = strcat(PWD,'/MPM_',num2str(length(SUB)),'_',num2str(VOX_SIZE),'mm/');
if ~exist(probpath,'dir')
    mkdir(probpath);
end

parfor CL_NUM=2:MAX_CL_NUM
    %if ~exist(strcat(probpath,num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(CL_NUM),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii'))
    prob_cluster=zeros([IMGSIZE,CL_NUM]);
    sumimg = zeros(IMGSIZE);

    sub_num = length(SUB);
    for i=1:sub_num
        sub_file=strcat(PWD,'/',SUB{i},'/',SUB{i},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(CL_NUM),'_MNI_relabel_group.nii.gz');
        vnii=load_untouch_nii(sub_file);
        tha_seg_result= vnii.img;   
        dataimg = vnii.img;
        dataimg(dataimg>0) = 1;
        sumimg = sumimg + dataimg;

        %computering the probabilistic maps
        for ki=1:CL_NUM
            tmp_ind=(tha_seg_result==ki);
            prob_cluster(:,:,:,ki) = prob_cluster(:,:,:,ki) + tmp_ind;  
        end
    end

    indeximg = sumimg;
    indeximg(indeximg<MPM_THRES*sub_num) = 0;
    indeximg(indeximg>0) = 1;
    sumimg=sumimg.*indeximg;

    index=find(indeximg>0);
    [xi,yi,zi]=ind2sub(IMGSIZE,index);
    no_voxel=length(index);

    %write the probabilistic maps
    for ki=1:CL_NUM
        prob_cluster(:,:,:,ki) = prob_cluster(:,:,:,ki).*indeximg;
        filename_re=strcat(probpath,num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(CL_NUM),'_',num2str(ki),'.nii.gz');
        vnii.img = zeros(IMGSIZE);
        probclki = zeros(IMGSIZE);
        probclki = prob_cluster(:,:,:,ki);
        vnii.img(index) = (probclki(index)./sumimg(index))*100;
        save_untouch_nii(vnii,filename_re);
    end
    disp(strcat(' <',ROI,'_',LR,'_',num2str(CL_NUM),'> probabilistic maps done!'));

    %generate maximum probabilistic map
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

    filename_re2=strcat(probpath,num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(CL_NUM),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
    vnii.img=mpm_cluster;
    save_untouch_nii(vnii,filename_re2);
    disp(strcat(' <',ROI,'_',LR,'_',num2str(CL_NUM),'> maximum probabilistic map done!'));
    %end
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
