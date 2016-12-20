function validation_indi_cont(PWD,ROI,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,POOLSIZE,GROUP_THRES,MPM_THRES,LorR)

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

% individual-level continuity
indi_cont=zeros(sub_num,MAX_CL_NUM);

parfor ti=1:sub_num
    temp_cont=zeros(1,MAX_CL_NUM);
    for kc=2:MAX_CL_NUM
        disp(['indi_cont: ',ROI,'_',LR,' kc=',num2str(kc),' ',num2str(ti)]);

        nii_file=strcat(PWD,'/',sub{ti},'/',sub{ti},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(kc),'_MNI_relabel_group.nii.gz');
        nii=load_untouch_nii(nii_file);
        nii.img=double(nii.img).*MASK;
        tempimg=double(nii.img);
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
        temp_cont(kc)=sum/kc;
    end
    indi_cont(ti,:)=temp_cont;
end

if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));end
save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_indi_continuity.mat'),'indi_cont');

fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_indi_continuity.txt'),'at');
if fp
    for kc=2:MAX_CL_NUM
        fprintf(fp,'cluster_num: %d\navg_indi_continuity: %f\nstd_indi_continuity: %f\nmedian_indi_continuity: %f\n\n',kc,nanmean(indi_cont(:,kc)),nanstd(indi_cont(:,kc)),nanmedian(indi_cont(:,kc)));
    end
end
fclose(fp);


