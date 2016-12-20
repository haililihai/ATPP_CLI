function symmetry_group(PWD,ROI,SUB_LIST,MAX_CL_NUM,VOX,THRES)
% relabel the cluster among the subjects

SUB = textread(SUB_LIST,'%s');
num=length(SUB);

for CL_NUM=2:MAX_CL_NUM

    %if ~exist(strcat(PWD,'/',ROI,'/','group_',num2str(num),'_',num2str(VOX),'mm/',num2str(VOX),'mm_',ROI,'_R_',num2str(CL_NUM),'_',num2str(THRES*100),'_group.nii.gz'))
        nii_L=load_untouch_nii(strcat(PWD,'/group_',num2str(num),'_',num2str(VOX),'mm/',num2str(VOX),'mm_',ROI,'_L_',num2str(CL_NUM),'_',num2str(THRES*100),'_group.nii.gz'));
        img_L= nii_L.img;
        nii_R=load_untouch_nii(strcat(PWD,'/group_',num2str(num),'_',num2str(VOX),'mm/',num2str(VOX),'mm_',ROI,'_R_',num2str(CL_NUM),'_',num2str(THRES*100),'_group.nii.gz'));
        img_R= nii_R.img;
        [xr,yr,zr]=size(img_R);
        img_R_mirror=img_R;
        img_R_mirror(:,:,:)=0;
        for x=1:xr
          for y=1:yr
            for z=1:zr   
    	if img_R(x,y,z)~=0
               img_R_mirror(xr-x+1,y,z)=img_R(x,y,z);
            end
    	end
          end
        end        

        overlay=zeros(CL_NUM,CL_NUM);
        
        for ki=1:CL_NUM
            for kj=1:CL_NUM
                  tmp=(img_L==ki).*(img_R_mirror==kj);
                  overlay(ki,kj)=sum(tmp(:));
            end
        end

        [cind,max]=munkres(-overlay);

        tmp_img=img_R;
        
        for ki=1:CL_NUM
            tmp_img(img_R==cind(ki))=ki;
        end
        nii_R.img=tmp_img;

        movefile(strcat(PWD,'/group_',num2str(num),'_',num2str(VOX),'mm/',num2str(VOX),'mm_',ROI,'_R_',num2str(CL_NUM),'_',num2str(THRES*100),'_group.nii.gz'),strcat(PWD,'/group_',num2str(num),'_',num2str(VOX),'mm/',num2str(VOX),'mm_',ROI,'_R_',num2str(CL_NUM),'_',num2str(THRES*100),'_group.nii.gz.old'));
        save_untouch_nii(nii_R,strcat(PWD,'/group_',num2str(num),'_',num2str(VOX),'mm/',num2str(VOX),'mm_',ROI,'_R_',num2str(CL_NUM),'_',num2str(THRES*100),'_group.nii.gz'));

        disp(strcat('symmetrized CL_NUM_',num2str(CL_NUM)));
    %else
    %    disp(strcat('symmetrized CL_NUM_',num2str(CL_NUM)));
    %end
end
