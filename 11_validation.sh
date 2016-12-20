#! /bin/bash
# produce various validity indices

pipeline=$1
shift
WD=$1
shift
ROI=$1
shift
SUB=$1
shift
METHOD=$1
shift
VOX_SIZE=$1
shift
MAX_CL_NUM=$1
shift
N_ITER=$1
shift
POOLSIZE=$1
shift
GROUP_THRES=$1
shift
MPM_THRES=$1
shift
LEFT=$1
shift
RIGHT=$1
shift
split_half=$1
shift
pairwise=$1
shift
leave_one_out=$1
shift
cont=$1
shift
hi_vi=$1
shift
silhouette=$1
shift
tpd=$1


${COMMAND_MATLAB} -nodisplay -nosplash -r "addpath('${pipeline}');validation('${WD}','${ROI}','${SUB}','${METHOD}',${VOX_SIZE},${MAX_CL_NUM},${N_ITER},${POOLSIZE},${GROUP_THRES},${MPM_THRES},${LEFT},${RIGHT},${split_half},${pairwise},${leave_one_out},${cont},${hi_vi},${silhouette},${tpd});exit" 

