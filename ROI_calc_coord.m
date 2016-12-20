function ROI_calc_coord(WD,ROI,SUB_LIST,POOLSIZE,LEFT,RIGHT)

% Calculate coordinates of the voxels in the ROI in DTI space

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

parfor i = 1:length(SUB);

	if LEFT == 1
	roi_l = load_untouch_nii(strcat(WD,'/',SUB{i},'/',SUB{i},'_',ROI,'_L_DTI.nii.gz'));
	[nxl,nyl,nzl] = size(roi_l.img);
	fid_l = fopen(strcat(WD,'/',SUB{i},'/',SUB{i},'_',ROI,'_L_coord.txt'),'w');
	for zl = 1:nzl;
		[xl yl] = find(roi_l.img(:,:,zl) == 1);
		for j = 1:numel(xl);
			fprintf(fid_l,'%d %d %d\r\n',xl(j)-1,yl(j)-1,zl-1);
		end
	end
	disp(strcat(SUB{i},'_L',' Done!'));
	end
	
	if RIGHT == 1
	roi_r = load_untouch_nii(strcat(WD,'/',SUB{i},'/',SUB{i},'_',ROI,'_R_DTI.nii.gz'));
	[nxr,nyr,nzr] = size(roi_r.img);
	fid_r = fopen(strcat(WD,'/',SUB{i},'/',SUB{i},'_',ROI,'_R_coord.txt'),'w');
	for zr = 1:nzr;
		[xr yr] = find(roi_r.img(:,:,zr) == 1); 
		for j = 1:numel(xr);
			fprintf(fid_r,'%d %d %d\r\n',xr(j)-1,yr(j)-1,zr-1);
		end
	end
	disp(strcat(SUB{i},'_R',' Done!'));
	end
	
	
end

% close pool
if exist('parpool')
	delete(p);
else
	matlabpool close;
end


