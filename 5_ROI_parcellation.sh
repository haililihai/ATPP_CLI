#! /bin/bash
# ROI parcellation using spectral clustering, to generate 2 to max cluster number subregion

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
POOLSIZE=$1
shift
NIFTI=$1
shift
METHOD=$1
shift
LEFT=$1
shift
RIGHT=$1

${COMMAND_MATLAB} -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_parcellation('${WD}','${ROI}','${SUB_LIST}',${MAX_CL_NUM},${POOLSIZE},'${METHOD}',${LEFT},${RIGHT});exit"
