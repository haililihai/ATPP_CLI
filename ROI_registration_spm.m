function ROI_registration_spm(WD,ROI,SUB_LIST,POOLSIZE,TEMPLATE,LEFT,RIGHT)
%-----------------------------------------------------------------------
% transform ROIs from MNI space to DTI(b0) space
%-----------------------------------------------------------------------

SUB = textread(SUB_LIST,'%s');
ROI_L=[WD,'/ROI/',ROI,'_L.nii'];
ROI_R=[WD,'/ROI/',ROI,'_R.nii'];

% make ROIs be proper datatype, default double
roi_l=load_untouch_nii(ROI_L);
roi_l.hdr.dime.datatype=64;
roi_l.hdr.dime.bitpix=64;
roi_l.img=double(roi_l.img);
save_untouch_nii(roi_l,ROI_L);
roi_r=load_untouch_nii(ROI_R);
roi_r.hdr.dime.datatype=64;
roi_r.hdr.dime.bitpix=64;
roi_r.img=double(roi_r.img);
save_untouch_nii(roi_r,ROI_R);


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


% coregister T1 to b0 space
parfor i=1:length(SUB)
	spm_coreg_ew(WD,SUB,i)
end
matlabbatch=[];


% coregistered T1 image from b0 to MNI space
parfor i=1:length(SUB)
	spm_norm_e(WD,SUB,i,TEMPLATE)
end 
matlabbatch=[];


% ROIs from MNI space to b0 space using inverse matrix
if LEFT == 1
	parfor i=1:length(SUB)
		spm_util_deform(WD,SUB,i,ROI_L)
	end 
	matlabbatch=[];
end

if RIGHT == 1
	parfor i=1:length(SUB)
		spm_util_deform(WD,SUB,i,ROI_R)
	end 
	matlabbatch=[];
end

% close pool
if exist('parpool')
	delete(p);
else
	matlabpool close;
end


function spm_coreg_ew(WD,SUB,i)
	sourcepath = strcat(WD,'/',SUB{i});
	disp(sourcepath);
	b0refimg = strcat(sourcepath,'/b0_',SUB{i},'.nii');
	T1sourceimg = strcat(sourcepath,'/T1_',SUB{i},'.nii');

	spm('defaults','fmri');
	spm_jobman('initcfg');

 	matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {b0refimg};
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = {T1sourceimg};
    matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.002 0.002 0.002 0.0001 0.0001 0.0001 0.001 0.001 0.001 0.0001 0.0001 0.0001];
	matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 1;
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
	matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

	spm_jobman('run',matlabbatch)


function spm_norm_e(WD,SUB,i,TEMPLATE)
	sourcepath = strcat(WD,'/',SUB{i});
    disp(sourcepath);
	sourceimg = strcat(sourcepath,'/rT1_',SUB{i},'.nii');

	spm('defaults','fmri');
	spm_jobman('initcfg');
	
	matlabbatch{1}.spm.spatial.normalise.est.subj.source = {sourceimg};
    matlabbatch{1}.spm.spatial.normalise.est.subj.wtsrc = '';
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.template = {TEMPLATE};
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.weight = '';
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.smosrc = 8;
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.smoref = 0;
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.regtype = 'mni';
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.cutoff = 25;
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.nits = 16;
	matlabbatch{1}.spm.spatial.normalise.est.eoptions.reg = 1; 

	spm_jobman('run',matlabbatch)


function spm_util_deform(WD,SUB,i,ROI)
	sourcepath = strcat(WD,'/',SUB{i});
    disp(sourcepath);
	roimat = strcat(sourcepath,'/rT1_',SUB{i},'_sn.mat');
   	refimg = strcat(sourcepath,'/rT1_',SUB{i},'.nii');

	spm('defaults','fmri');
	spm_jobman('initcfg');
	
   	matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = {roimat};
	matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {refimg};
	matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox = [NaN NaN NaN];
	matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb = [NaN NaN NaN
       	                                                      	  NaN NaN NaN];
	matlabbatch{1}.spm.util.defs.ofname = '';
	matlabbatch{1}.spm.util.defs.fnames = {ROI};
	matlabbatch{1}.spm.util.defs.savedir.saveusr = {sourcepath};
	matlabbatch{1}.spm.util.defs.interp = 0;

	spm_jobman('run',matlabbatch)

