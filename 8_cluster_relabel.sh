#! /bin/bash
# cluster relabeling according to the group reference image

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
POOLSIZE=$1
shift
GROUP_THRES=$1
shift
METHOD=$1
shift
VOX_SIZE=$1
shift
LEFT=$1
shift
RIGHT=$1

${COMMAND_MATLAB} -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');cluster_relabel_group_xmm('${WD}','${ROI}','${SUB_LIST}',${MAX_CL_NUM},${POOLSIZE},${GROUP_THRES},'${METHOD}',${VOX_SIZE},${LEFT},${RIGHT});exit"
