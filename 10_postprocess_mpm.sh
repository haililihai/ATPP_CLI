#! /bin/bash
# smooth the mpm image

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
NIFTI=$1
shift
MPM_THRES=$1
shift
VOX_SIZE=$1
shift
LEFT=$1
shift
RIGHT=$1

${COMMAND_MATLAB} -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');postprocess_mpm_group_xmm('${WD}','${ROI}','${SUB_LIST}',${MAX_CL_NUM},${MPM_THRES},${VOX_SIZE},${LEFT},${RIGHT});exit"
