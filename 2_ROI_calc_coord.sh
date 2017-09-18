#! /bin/bash
# calculate ROI coordinates in DTI space

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
LEFT=$1
shift
RIGHT=$1

${COMMAND_MATLAB} -nodisplay -nosplash -r "addpath('${PIPELINE}');addpath('${NIFTI}');ROI_calc_coord('${WD}','${ROI}','${SUB_LIST}',${POOLSIZE},${LEFT},${RIGHT});exit"
