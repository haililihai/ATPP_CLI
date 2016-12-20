function validation_group_cont(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,LorR)

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

    % group-level continuity
    group_cont=zeros(1,MAX_CL_NUM);
    for kc=2:MAX_CL_NUM
        disp(['group_cont: ',ROI,'_',LR,' kc=',num2str(kc)]);

        mpm_file=strcat(PWD,'/MPM_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
        mpm=load_untouch_nii(mpm_file);
        tempimg=double(mpm.img);
        cont=cell(kc,1);
        sum=0;
        for i=1:kc
            tmp=tempimg;
            tmp(tempimg~=i)=0;
            [L,NUM]=spm_bwlabel(tmp,6); % 6 surface, 18 edge, 26 corner
            tmp1=zeros(NUM,1);
            tmp_total=length(find(L~=0));
            for j=1:NUM
                tmp_num=length(find(L==j));
                tmp1(j)=tmp_num/tmp_total;
            end
            cont{i}=tmp1;
            sum=sum+max(cont{i});
        end
        group_cont(kc)=sum/kc;
    end

    if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_group_continuity.mat'),'group_cont');

    fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_group_continuity.txt'),'at');
    if fp
        for kc=2:MAX_CL_NUM
            fprintf(fp,'cluster_num: %d\ngroup_continuity: %f\n\n',kc,group_cont(kc));
        end
    end
    fclose(fp);


