#! /bin/bash
# transform parcellated ROI from DTI space to MNI space

PIPELINE=$1
shift
WD=$1
shift
ROI=$1
shift
SUB_LIST=$1
shift
MAX_CL_NUM=$1
shift
SPM=$1
shift
POOLSIZE=$1
shift
TEMPLATE=$1
shift
VOX_SIZE=$1
shift
METHOD=$1
shift
LEFT=$1
shift
RIGHT=$1

${COMMAND_MATLAB} -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${SPM}');ROI_toMNI_spm_xmm('${WD}','${ROI}','${SUB_LIST}',${MAX_CL_NUM},${POOLSIZE},'${TEMPLATE}',${VOX_SIZE},'${METHOD}',${LEFT},${RIGHT});exit"


for sub in `cat ${SUB_LIST}`
do
	mkdir -p ${WD}/${sub}/${sub}_${ROI}_L_${METHOD}/${VOX_SIZE}mm
	mkdir -p ${WD}/${sub}/${sub}_${ROI}_R_${METHOD}/${VOX_SIZE}mm
	for num in $(seq 2 ${MAX_CL_NUM})
	do
		if [ "${LEFT}" == "1" ]; then

			mv ${WD}/${sub}/${sub}_${ROI}_L_${METHOD}/w${ROI}_L_${num}.nii ${WD}/${sub}/${sub}_${ROI}_L_${METHOD}/${VOX_SIZE}mm/${VOX_SIZE}mm_${ROI}_L_${num}_MNI.nii
			gzip ${WD}/${sub}/${sub}_${ROI}_L_${METHOD}/${VOX_SIZE}mm/${VOX_SIZE}mm_${ROI}_L_${num}_MNI.nii
		fi
		if [ "${RIGHT}" == "1" ]; then
			mv ${WD}/${sub}/${sub}_${ROI}_R_${METHOD}/w${ROI}_R_${num}.nii ${WD}/${sub}/${sub}_${ROI}_R_${METHOD}/${VOX_SIZE}mm/${VOX_SIZE}mm_${ROI}_R_${num}_MNI.nii
			gzip ${WD}/${sub}/${sub}_${ROI}_R_${METHOD}/${VOX_SIZE}mm/${VOX_SIZE}mm_${ROI}_R_${num}_MNI.nii
		fi
	done
done
