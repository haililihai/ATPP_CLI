function validation_group_tpd(PWD,ROI,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,MPM_THRES)

    sub=textread(SUB_LIST,'%s');
    sub_num=length(sub);

    if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
        MPM_THRES=0.25;
    end

    group_tpd=zeros(1,MAX_CL_NUM);
    for kc=2:MAX_CL_NUM
        disp(['group_tpd: ',ROI, ' kc=',num2str(kc)]);

        mpm_file1=strcat(PWD,'/MPM_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_L_',num2str(kc),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
        mpm1=load_untouch_nii(mpm_file1);
        img1=mpm1.img;
        img1(isnan(img1))=0;
        mpm_file2=strcat(PWD,'/MPM_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_R_',num2str(kc),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
        mpm2=load_untouch_nii(mpm_file2);
        img2=mpm2.img;
        img2(isnan(img2))=0;

        se=strel(ones(3,3,3));

        for i=1:kc
            mat{i}=img1;mat{i}(img1~=i)=0;
        end
        con1=zeros(kc,kc);
        for i=1:kc
            for j=1:kc
                if i~=j
                    tmp=mat{i};tmp=imdilate(tmp,se);tmp=tmp.*mat{j};con1(j,i)=length(find(tmp~=0));
                end
            end
        end
        sum1=sum(con1,2);
        if kc~=2 con1=con1./sum1(:,ones(1,kc));end;

        for i=1:kc
            mat{i}=img2;mat{i}(img2~=i)=0;
        end
        con2=zeros(kc,kc);
        for i=1:kc
            for j=1:kc
                if i~=j
                    tmp=mat{i};tmp=imdilate(tmp,se);tmp=tmp.*mat{j};con2(j,i)=length(find(tmp~=0));
                end
            end
        end
        sum2=sum(con2,2);
        if kc~=2 con2=con2./sum2(:,ones(1,kc));end

        v_con1=reshape(con1',1,[]);
        v_con2=reshape(con2',1,[]);
        group_tpd(1,kc)=pdist([v_con1;v_con2],'cosine');

    end

    if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_index_group_tpd.mat'),'group_tpd');

    fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_index_group_tpd.txt'),'at');
    if fp
        for kc=2:MAX_CL_NUM
            fprintf(fp,'cluster_num: %d \ngroup_tpd: %f\n\n',kc,group_tpd(1,kc));
        end
    end
    fclose(fp);

