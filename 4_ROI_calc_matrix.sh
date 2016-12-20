#! /bin/bash
# calculate connectivity matrix between each voxel in ROI and the remain voxels of whole brain 
# and correlation matrix among voxels in ROI

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
NIFTI=$1
shift
VAL_THRES=$1
shift
DOWN_SIZE=$1
shift
LEFT=$1
shift
RIGHT=$1


${COMMAND_MATLAB} -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_calc_matrix('${WD}','${ROI}','${SUB_LIST}',${POOLSIZE},${VAL_THRES},${DOWN_SIZE},${LEFT},${RIGHT});exit"
