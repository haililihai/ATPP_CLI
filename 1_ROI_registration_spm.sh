#! /bin/bash
# ROI registration, from MNI space to DTI space, using spm batch

PIPELINE=$1
shift
WD=$1
shift
ROI=$1
shift
SUB_LIST=$1
shift
POOLSIZE=$1
shift
SPM=$1
shift
NIFTI=$1
shift
TEMPLATE=$1
shift
LEFT=$1
shift
RIGHT=$1


${COMMAND_MATLAB} -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${SPM}');addpath('${NIFTI}');ROI_registration_spm('${WD}','${ROI}','${SUB_LIST}',${POOLSIZE},'${TEMPLATE}',${LEFT},${RIGHT});exit"


for sub in `cat ${SUB_LIST}`
do
	if [ "${LEFT}" == "1" ]; then
		mv ${WD}/${sub}/w${ROI}_L.nii ${WD}/${sub}/${sub}_${ROI}_L_DTI.nii
		gzip ${WD}/${sub}/${sub}_${ROI}_L_DTI.nii
	fi
	if [ "${RIGHT}" == "1" ]; then
		mv ${WD}/${sub}/w${ROI}_R.nii ${WD}/${sub}/${sub}_${ROI}_R_DTI.nii
        gzip ${WD}/${sub}/${sub}_${ROI}_R_DTI.nii
	fi
done


