function validation_indi_hi_vi(PWD,ROI,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,POOLSIZE,GROUP_THRES,MPM_THRES,LorR)

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

indi_hi=zeros(sub_num,MAX_CL_NUM);
indi_vi=zeros(sub_num,MAX_CL_NUM);

parfor ti=1:sub_num
    temp_hi=zeros(1,MAX_CL_NUM);
    temp_vi=zeros(1,MAX_CL_NUM);
    for kc=3:MAX_CL_NUM
        disp(['indi_group_hi_vi: ',ROI,'_',LR,' kc= ',num2str(kc-1),'->',num2str(kc),' ',num2str(ti)]);

        mpm_file1=strcat(PWD,'/',sub{ti},'/',sub{ti},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc-1),'_MNI_relabel_group.nii.gz');
        mpm1=load_untouch_nii(mpm_file1);
        mpmimg1=double(mpm1.img);
        mpmimg1(isnan(mpmimg1))=0;
        mpm_file2=strcat(PWD,'/',sub{ti},'/',sub{ti},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii.gz');
        mpm2=load_untouch_nii(mpm_file2);
        mpmimg2=double(mpm2.img);
        mpmimg2(isnan(mpmimg2))=0;
        mpmimg1=mpmimg1.*MASK;
        mpmimg2=mpmimg2.*MASK;

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
        temp_hi(kc) = nanmean(xi);
        [nminfo,temp_vi(kc)]=v_nmi(mpmimg1,mpmimg2);
    end
    indi_hi(ti,:)=temp_hi;
    indi_vi(ti,:)=temp_vi;
end

if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_indi_hi.mat'),'indi_hi','indi_vi');

fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_indi_hi_vi.txt'),'at');
if fp
    for kc=3:MAX_CL_NUM
        fprintf(fp,'cluster_num: %d -> %d\navg_indi_hi: %f\nstd_indi_hi: %f\nmedian_indi_hi: %f\navg_indi_vi: %f\nstd_indi_vi: %f\nmedian_indi_vi: %f\n\n',kc-1,kc,nanmean(indi_hi(:,kc)),nanstd(indi_hi(:,kc)),nanmedian(indi_hi(:,kc)),nanmean(indi_vi(:,kc)),nanstd(indi_vi(:,kc)),nanmedian(indi_vi(:,kc)));
    end
end
fclose(fp);

