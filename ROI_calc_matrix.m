function ROI_calc_matrix(PWD,ROI,SUB_LIST,POOLSIZE,VAL_THRES,DOWN_SIZE,LEFT,RIGHT)
% calculate the connectivity and correlation matrix
% load_nii_hdr modified to support .gz files

SUB=textread(SUB_LIST,'%s');

threshold = VAL_THRES; 
resampflag = 1;
NewVoxSize = [DOWN_SIZE DOWN_SIZE DOWN_SIZE];
method = 1;

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

parfor i = 1:length(SUB)
    subCreateMatrix(PWD,SUB{i},ROI,LEFT,RIGHT,threshold,resampflag,NewVoxSize,method)
end

% close pool
if exist('parpool')
	delete(p);
else
	matlabpool close;
end

function subCreateMatrix(PWD,SUBi,ROI,LEFT,RIGHT,threshold,resampflag,NewVoxSize,method)
	if LEFT == 1
	coord_L = load(strcat(PWD,'/',SUBi,'/',SUBi,'_',ROI,'_L_coord.txt'));
	imgfolder_L = strcat(PWD,'/',SUBi,'/',SUBi,'_',ROI,'_L_probtrackx');
	outfolder_L = strcat(PWD,'/',SUBi,'/',SUBi,'_',ROI,'_L_matrix/');
	if ~exist(outfolder_L,'dir') mkdir(outfolder_L);end
 	f_Create_Matrix_v3(imgfolder_L,outfolder_L,coord_L,threshold,resampflag,NewVoxSize,method);
	end

	if RIGHT == 1
	coord_R = load(strcat(PWD,'/',SUBi,'/',SUBi,'_',ROI,'_R_coord.txt'));
	imgfolder_R = strcat(PWD,'/',SUBi,'/',SUBi,'_',ROI,'_R_probtrackx');
	outfolder_R = strcat(PWD,'/',SUBi,'/',SUBi,'_',ROI,'_R_matrix/');
	if ~exist(outfolder_R,'dir') mkdir(outfolder_R);end
	f_Create_Matrix_v3(imgfolder_R,outfolder_R,coord_R,threshold,resampflag,NewVoxSize,method);
	end
