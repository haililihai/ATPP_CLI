function validation_group_silhouette(PWD,ROI,SUB_LIST,VOX_SIZE,MAX_CL_NUM,MPM_THRES,LorR)

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


    % group-level silhouette
    group_sil=zeros(1,MAX_CL_NUM);
    for kc=2:MAX_CL_NUM
        disp(['group_silhouette: ',ROI,'_',LR,' kc=',num2str(kc)]);

        mpm_file=strcat(PWD,'/MPM_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc),'_MPM_thr',num2str(MPM_THRES*100),'_group.nii.gz');
        mpm=load_untouch_nii(mpm_file);
        tempimg=mpm.img;
        tempimg(isnan(tempimg))=0;
        [xx,yy,zz]=size(tempimg);
        data=zeros(length(find(tempimg~=0 & ~isnan(tempimg))),4);
        n=1;
        for x=1:xx
            for y=1:yy
                for z=1:zz
                    if tempimg(x,y,z)~=0 && ~isnan(tempimg(x,y,z))
                        data(n,1)=x;data(n,2)=y;data(n,3)=z;data(n,4)=tempimg(x,y,z);
                        n=n+1;
                    end
                end
            end
        end
        coord=data(:,1:3);
        label=data(:,4);
        s=silhouette(data,label);
        %group_sil(1,kc)=mean(s(~isnan(s)));
        group_sil(1,kc)=nanmean(s);
    end


    if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
    save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_group_silhouette.mat'),'group_sil');

    fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_group_silhouette.txt'),'at');
    if fp
        for kc=2:MAX_CL_NUM
            fprintf(fp,'cluster_num: %d\naverage_group_silhouette: %f\n\n',kc,group_sil(kc));
        end
    end
    fclose(fp);


