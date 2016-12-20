function f_Create_Matrix_v3(imgfolder,outfolder,coord,threshold,...
    resampflag,NewVoxSize,method)
%-------------------------------------------------------------------------%
%
% imgfolder * - prename_x_y_z.imgtype
% outfolder   - output directory
% threshold   - threshold probtrackx result
% resampflag  - 0-no, 1-yes
% NewVoxSize  - Voxel size of resampled images
% method      -	1, 2, or 3
%               1:  for Trilinear interpolation
%               2:  for Nearest Neighbor interpolation
%               3:  for Fischer's Bresenham interpolation
%               'method' is 1 if it is default or empty.
%      
%-------------------------------------------------------------------------%

if nargin < 6 , method =1 ;  
if nargin < 5 , NewVoxSize = [5,5,5];
if nargin < 4 , resampflag = 0;
if nargin < 3 , threshold = 10 ; 
if nargin < 2 , outfolder = './matrix/';
if nargin < 1 , error('You must input the image folder!!');
end;end;end;end;end;end;

if imgfolder(end) ~= '/' && imgfolder(end) ~= '\', 
    imgfolder = strcat(imgfolder,'/'); 
end;
if outfolder(end) ~= '/' && outfolder(end) ~= '\', 
    outfolder = strcat(outfolder,'/'); 
end;
imgtype = 'nii.gz';
 

filedir = dir(strcat(imgfolder,'*_*_*.',imgtype));
nimg = length(filedir);
if nimg<1
    error('No image in the imgfolder !');
end
xyz = zeros(nimg,3);
tnii = f_load_nii_no_xform(strcat(imgfolder,filedir(1).name));
if resampflag == 0
    con_matrix=sparse(nimg,...
        size(tnii.img,1)*size(tnii.img,2)*size(tnii.img,3));
else 
    old_M = tnii.hdr.hist.old_affine;
    [timg] = affine(tnii.img,old_M,NewVoxSize,0,0,method);
    con_matrix=sparse(nimg,size(timg,1)*size(timg,2)*size(timg,3));
end


for iimg = 1:nimg
    fprintf('Process %s ...\n',filedir(iimg).name);
   
    tname = regexp(filedir(iimg).name,'\d+(?#)','match');
    
    xyz(iimg,1)=str2double(tname{end-2});
    xyz(iimg,2)=str2double(tname{end-1});
    xyz(iimg,3)=str2double(tname{end});
    
    if ismember(xyz(iimg,:),coord,'rows')
        imgname = strcat(imgfolder,filedir(iimg).name);
        nii = load_untouch_nii(imgname);
        if resampflag ==0
            con_matrix(iimg,:) = reshape(nii.img,1,[]);
        else
            [reimg] = affine(nii.img,old_M,NewVoxSize,0,0,method);
            con_matrix(iimg,:) = reshape(reimg,1,[]);
        end
    else
        con_matrix(iimg,:) = 0;
    end
end


fprintf('Remove 0 or NaN columns ...\n');
con_matrix(isnan(con_matrix) | isinf(con_matrix)) = 0;
d = ~(max(con_matrix) == 0 & min(con_matrix) == 0);
con_matrix = con_matrix(:,d>0);
fprintf('Full matrix ...\n');
con_matrix = full(con_matrix);

if ~exist(outfolder) mkdir(outfolder);end;


fprintf('Create connection_matrix...\n');
matrix = con_matrix;
output = strcat(outfolder,'connection_matrix.mat');
save(output,'matrix','xyz','-v7.3');
clear matrix;


fprintf('Create correlation_matrix...\n');
con_matrix(con_matrix < threshold )=0; 
cor_matrix = con_matrix*con_matrix';
matrix = cor_matrix;
output = strcat(outfolder,'correlation_matrix.mat');
save(output,'matrix','xyz','-v7.3');
clear matrix;

%% =========================================================== %%
function [nii] = f_load_nii_no_xform(filename)
img_idx = []; 
old_RGB = 0;

[nii.hdr,nii.filetype,nii.fileprefix,nii.machine] = load_nii_hdr_gz(filename);
[nii.img,nii.hdr] = load_nii_img(nii.hdr,nii.filetype,...
    nii.fileprefix,nii.machine,img_idx,'','','',old_RGB);
hdr = nii.hdr;

useForm=[];				
if hdr.hist.sform_code > 0
    useForm='s';
elseif hdr.hist.qform_code > 0
    useForm='q';
end

   if isequal(useForm,'s')
      R = [hdr.hist.srow_x(1:3)
           hdr.hist.srow_y(1:3)
           hdr.hist.srow_z(1:3)];

      T = [hdr.hist.srow_x(4)
           hdr.hist.srow_y(4)
           hdr.hist.srow_z(4)];

      nii.hdr.hist.old_affine = [ [R;[0 0 0]] [T;1] ];

   elseif isequal(useForm,'q')
      b = hdr.hist.quatern_b;
      c = hdr.hist.quatern_c;
      d = hdr.hist.quatern_d;

      if 1.0-(b*b+c*c+d*d) < 0
         if abs(1.0-(b*b+c*c+d*d)) < 1e-5
            a = 0;
         else
            error('Incorrect quaternion values in this NIFTI data.');
         end
      else
         a = sqrt(1.0-(b*b+c*c+d*d));
      end

      qfac = hdr.dime.pixdim(1);
      i = hdr.dime.pixdim(2);
      j = hdr.dime.pixdim(3);
      k = qfac * hdr.dime.pixdim(4);

      R = [a*a+b*b-c*c-d*d     2*b*c-2*a*d        2*b*d+2*a*c
           2*b*c+2*a*d         a*a+c*c-b*b-d*d    2*c*d-2*a*b
           2*b*d-2*a*c         2*c*d+2*a*b        a*a+d*d-c*c-b*b];

      T = [hdr.hist.qoffset_x
           hdr.hist.qoffset_y
           hdr.hist.qoffset_z];

      nii.hdr.hist.old_affine = [ [R * diag([i j k]);[0 0 0]] [T;1] ];

   elseif nii.filetype == 0 && exist([nii.fileprefix '.mat'],'file')
      load([nii.fileprefix '.mat']);	% old SPM affine matrix
      R=M(1:3,1:3);
      T=M(1:3,4);
      T=R*ones(3,1)+T;
      M(1:3,4)=T;
      nii.hdr.hist.old_affine = M;

   else
      M = diag(hdr.dime.pixdim(2:5));
      M(1:3,4) = -M(1:3,1:3)*(hdr.hist.originator(1:3)-1)';
      M(4,4) = 1;
      nii.hdr.hist.old_affine = M;
   end

   return					% load_nii_no_xform
%% ============================================================ %%
