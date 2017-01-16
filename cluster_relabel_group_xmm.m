function cluster_relabel_group_xmm(PWD,ROI,SUB_LIST,MAX_CL_NUM,POOLSIZE,GROUP_THRES,METHOD,VOX_SIZE,LEFT,RIGHT)
% relabel the cluster among the subjects

SUB = textread(SUB_LIST,'%s');

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
    p=parpool('local',POOLSIZE);
else
    matlabpool('local',POOLSIZE);
end

if LEFT == 1
	cluster_relabel(PWD,ROI,SUB,MAX_CL_NUM,POOLSIZE,GROUP_THRES,METHOD,VOX_SIZE,1)
end

if RIGHT == 1
	cluster_relabel(PWD,ROI,SUB,MAX_CL_NUM,POOLSIZE,GROUP_THRES,METHOD,VOX_SIZE,0)
end

% close pool
if exist('parpool')
    delete(p);
else
    matlabpool close;
end


function cluster_relabel(PWD,ROI,SUB,MAX_CL_NUM,POOLSIZE,GROUP_THRES,METHOD,VOX_SIZE,LorR)

if LorR == 1
	LR='L';
elseif LorR == 0
	LR='R';
end

GROUP_THRES=GROUP_THRES*100;

parfor CL_NUM=2:MAX_CL_NUM
    disp(strcat(ROI,'_',LR,'_cluster_',num2str(CL_NUM),' processing...'));
    REFER = strcat(PWD,'/group_',num2str(length(SUB)),'_',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(CL_NUM),'_',num2str(GROUP_THRES),'_group.nii.gz');
    vnii_stand = load_untouch_nii(REFER); 
    standard_cluster= vnii_stand.img; 
    sub_num=length(SUB);

    for i=1:sub_num
        %if ~exist(strcat(PWD,'/',SUB{i},'/',SUB{i},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(CL_NUM),'_MNI_relabel_group.nii.gz'),'file')
            vnii=load_untouch_nii(strcat(PWD,'/',SUB{i},'/',SUB{i},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(CL_NUM),'_MNI.nii.gz')); 
            tha_seg_result= vnii.img;   
            tmp_overlay=zeros(CL_NUM,CL_NUM);

            for ki=1:CL_NUM
                for kj=1:CL_NUM
                      tmp=(standard_cluster==ki).*(tha_seg_result==kj);
                      tmp_overlay(ki,kj)=sum(tmp(:));
                end
            end

            [cind,max]=munkres(-tmp_overlay);

            tmp_matrix=tha_seg_result;

            for ki=1:CL_NUM
                tmp_matrix(tha_seg_result==cind(ki))=ki;
            end
            vnii.img=tmp_matrix;
            save_untouch_nii(vnii,strcat(PWD,'/',SUB{i},'/',SUB{i},'_',ROI,'_',LR,'_',METHOD,'/',num2str(VOX_SIZE),'mm/',num2str(VOX_SIZE),'mm_',ROI,'_',LR,'_',num2str(CL_NUM),'_MNI_relabel_group.nii.gz'));

            disp(strcat('relabeled for subject : ',SUB{i},'_',LR,' kc=',num2str(CL_NUM)));
        %else
        %    disp(strcat('relabeled for subject : ',SUB{i},'_',LR,' kc=',num2str(CL_NUM)));
        %end
    end
end
