function validation_group_hi_vi(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,LorR)

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

    group_hi=zeros(1,MAX_CL_NUM);
    group_vi=zeros(1,MAX_CL_NUM);
    for kc=3:MAX_CL_NUM
        disp(['group_hi_vi: ',ROI,'_',LR,' kc= ',num2str(kc-1),'->',num2str(kc)]);

        mpm_file1=strcat(PWD,'/MPM_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc-1),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
        mpm1=load_untouch_nii(mpm_file1);
        mpmimg1=mpm1.img;
        mpmimg1(isnan(mpmimg1))=0;
        mpm_file2=strcat(PWD,'/MPM_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
        mpm2=load_untouch_nii(mpm_file2);
        mpmimg2=mpm2.img;
        mpmimg2(isnan(mpmimg2))=0;

        xmatrix = zeros(kc,kc-1);
        xi = zeros(kc,1);
        for i = 1:kc
            index_kc = mpmimg2==i;
            for j = 1:kc-1
                index_ij = find(mpmimg1(index_kc)==j);
                xmatrix(i,j) = length(index_ij);
            end
            xi(i,1) = max(xmatrix(i,:))/sum(xmatrix(i,:));
        end
        group_hi(1,kc) = nanmean(xi);

        [nminfo,group_vi(1,kc)]=v_nmi(mpmimg1,mpmimg2);
    end

    if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_group_hi.mat'),'group_hi','group_vi');

    fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_group_hi_vi.txt'),'at');
    if fp
        for kc=3:MAX_CL_NUM
            fprintf(fp,'cluster_num: %d -> %d \ngroup_hierarchy_index: %f\ngroup_variation_of_info: %f\n\n',kc-1,kc,group_hi(1,kc),group_vi(1,kc));
        end
    end
    fclose(fp);


