function validation_indi_tpd(PWD,ROI,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,POOLSIZE,GROUP_THRES,MPM_THRES)

sub=textread(SUB_LIST,'%s');
sub_num=length(sub);

if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
    MPM_THRES=0.25;
end

GROUP_THRES=GROUP_THRES*100;

MASK_L_FILE=strcat(PWD,'/group_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_L_roimask_thr',num2str(GROUP_THRES),'.nii.gz');
MASK_L_NII=load_untouch_nii(MASK_L_FILE);
MASK_L=double(MASK_L_NII.img);
MASK_L(isnan(MASK_L))=0;

MASK_R_FILE=strcat(PWD,'/group_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_R_roimask_thr',num2str(GROUP_THRES),'.nii.gz');
MASK_R_NII=load_untouch_nii(MASK_R_FILE);
MASK_R=double(MASK_R_NII.img);
MASK_R(isnan(MASK_R))=0;

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

indi_tpd=zeros(sub_num,MAX_CL_NUM);
parfor ti=1:sub_num
    temp_tpd=zeros(1,MAX_CL_NUM);

    for kc=2:MAX_CL_NUM
        disp(['indi_tpd: ',ROI,' kc=',num2str(kc),' ',num2str(ti)]);

        mpm_file1=strcat(PWD,'/',sub{ti},'/',sub{ti},'_',ROI,'_L_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_L_',num2str(kc),'_MNI_relabel_group.nii.gz');
        mpm1=load_untouch_nii(mpm_file1);
        img1=double(mpm1.img);
        img1(isnan(img1))=0;
        mpm_file2=strcat(PWD,'/',sub{ti},'/',sub{ti},'_',ROI,'_R_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_R_',num2str(kc),'_MNI_relabel_group.nii.gz');
        mpm2=load_untouch_nii(mpm_file2);
        img2=double(mpm2.img);
        img2(isnan(img2))=0;
        img1=img1.*MASK_L;
        img2=img2.*MASK_R;

        se=strel(ones(3,3,3));

        mat=cell(kc,1);
        for i=1:kc
            mat{i}=img1;
            mat{i}(img1~=i)=0;
        end
        con1=zeros(kc,kc);
        for i=1:kc
            for j=1:kc
                if i~=j
                    tmp=mat{i};
                    tmp=imdilate(tmp,se);
                    tmp=tmp.*mat{j};
                    con1(j,i)=length(find(tmp~=0));
                end
            end
        end

        sum1=sum(con1,2);
        if kc~=2 con1=con1./sum1(:,ones(1,kc));end

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
        temp_tpd(kc)=pdist([v_con1;v_con2],'cosine');
    end
    indi_tpd(ti,:)=temp_tpd;
end

if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_index_indi_tpd.mat'),'indi_tpd');

fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_index_indi_tpd.txt'),'at');
if fp
    for kc=2:MAX_CL_NUM
        fprintf(fp,'cluster_num: %d \navg_indi_tpd: %f\nstd_indi_tpd: %f\nmedian_indi_tpd: %f\n\n',kc,nanmean(indi_tpd(:,kc)),nanstd(indi_tpd(:,kc)),nanmedian(indi_tpd(:,kc)));
    end
end
fclose(fp);
