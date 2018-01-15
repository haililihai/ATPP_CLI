function validation_split_half(PWD,ROI,SUB_LIST,METHOD,VOX_SIZE,MAX_CL_NUM,N_ITER,POOLSIZE,GROUP_THRES,MPM_THRES,LorR)
% split half strategy

if LorR == 1
    LR='L';
elseif LorR == 0
    LR='R';
end

sub=textread(SUB_LIST,'%s');
sub_num=length(sub);

if ~exist('N_ITER','var') | isempty(N_ITER)
    N_ITER=100;
end
if ~exist('MPM_THRES','var') | isempty(MPM_THRES)
    MPM_THRES=0.25;
end

GROUP_THRES=GROUP_THRES*100;
MASK_FILE=strcat(PWD,'/group_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_roimask_thr',num2str(GROUP_THRES),'.nii.gz');
MASK_NII=load_untouch_nii(MASK_FILE);
MASK=double(MASK_NII.img); 
MASK(isnan(MASK))=0;

half=floor(sub_num/2);

dice=zeros(N_ITER,MAX_CL_NUM);
nminfo=zeros(N_ITER,MAX_CL_NUM);
vi=zeros(N_ITER,MAX_CL_NUM);
cv=zeros(N_ITER,MAX_CL_NUM);

% Parallel Computing Toolbox settings
% 2014a removed findResource, replaced by parcluster
% 2016b removed matlabpool, replaced by parpool

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
    pcp=gcp('nocreate');
    if isempty(pcp) 
        p=parpool('local',POOLSIZE);
    end
else
    if matlabpool('size')==0
        matlabpool('local',POOLSIZE);
    end
end

parfor ti=1:N_ITER
    tmp=randperm(sub_num);
    list1_sub={sub{tmp(1:half)}}';
    list2_sub={sub{tmp(half+1:sub_num)}}';
    
    temp_dice=zeros(1,MAX_CL_NUM);
    temp_nmi=zeros(1,MAX_CL_NUM);
    temp_vi=zeros(1,MAX_CL_NUM);
    temp_cv=zeros(1,MAX_CL_NUM);
    
    for kc=2:MAX_CL_NUM
        disp(['split_half: ',ROI,'_',LR,' kc=',num2str(kc),' ',num2str(ti),'/',num2str(N_ITER)]);

        mpm_cluster1=cluster_mpm_validation(PWD,ROI,list1_sub,METHOD,VOX_SIZE,kc,MPM_THRES,LorR);
        mpm_cluster2=cluster_mpm_validation(PWD,ROI,list2_sub,METHOD,VOX_SIZE,kc,MPM_THRES,LorR);
        mpm_cluster1=mpm_cluster1.*MASK;
        mpm_cluster2=mpm_cluster2.*MASK;
        
        %compute dice coefficent
        temp_dice(kc)=v_dice(mpm_cluster1,mpm_cluster2);
        
        %compute the normalized mutual information and variation of information
        [temp_nmi(kc),temp_vi(kc)]=v_nmi(mpm_cluster1,mpm_cluster2);
        
        %compute cramer V
        temp_cv(kc)=v_cramerv(mpm_cluster1,mpm_cluster2);
    end

    dice(ti,:)=temp_dice;
    nminfo(ti,:)=temp_nmi;
    vi(ti,:)=temp_vi;
    cv(ti,:)=temp_cv;
end


if ~exist(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm')) 
    mkdir(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm'));
end
save(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_split_half.mat'),'dice','nminfo','cv','vi');

fp=fopen(strcat(PWD,'/validation_',num2str(sub_num),'_',num2str(VOX_SIZE),'mm/',ROI,'_',LR,'_index_split_half.txt'),'at');
if fp
    for kc=2:MAX_CL_NUM
        fprintf(fp,'%s','cluster num = ');
        fprintf(fp,'%d',kc);
        fprintf(fp,'\n');
        fprintf(fp,'%s','  dice: mean = ');
        fprintf(fp,'%f  %f',nanmean(dice(:,kc)));
        fprintf(fp,'%s',' , std = ');
        fprintf(fp,'%f  %f',nanstd(dice(:,kc)));
        fprintf(fp,'\n');
        fprintf(fp,'%s','  normalized mutual info: mean = ');
        fprintf(fp,'%f  %f',nanmean(nminfo(:,kc)));
        fprintf(fp,'%s',' , std = ');
        fprintf(fp,'%f  %f',nanstd(nminfo(:,kc)));
        fprintf(fp,'\n');
        fprintf(fp,'%s','  variation of info: mean = ');
        fprintf(fp,'%f  %f',nanmean(vi(:,kc)));
        fprintf(fp,'%s',' , std = ');
        fprintf(fp,'%f  %f',nanstd(vi(:,kc)));
        fprintf(fp,'\n');
        fprintf(fp,'%s','  cramer V: mean = ');
        fprintf(fp,'%f  %f',nanmean(cv(:,kc)));
        fprintf(fp,'%s',' , std = ');
        fprintf(fp,'%f  %f',nanstd(cv(:,kc)));
        fprintf(fp,'\n');
        fprintf(fp,'\n');
    end
end
fclose(fp);


