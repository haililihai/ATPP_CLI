#! /bin/bash

# Automatic Tractography-based Parcellation Pipeline (ATPP)
# global configuration file that includes all the variables
# Hai Li (hai.li@nlpr.ia.ac.cn)


#===============================================================================
# global paths and variables settings
#===============================================================================

# pipeline directory
PIPELINE=/DATA/233/hli/ATPP_V2.0/ATPP_CLI

# ROI directory which contains ROI files, e.g., Amyg_L.nii
ROI_DIR=/DATA/233/hli/test/ROI

# the number of parallel workers for MATLAB programs, default 7
POOLSIZE=7

#===============================================================================
# global switches for the pipeline
#===============================================================================

# switches for each step,
# a step will NOT run if its number is NOT in the following array
SWITCH=(0 1 2 3)

# switch for processing left hemisphere, 1--yes, 0--no
LEFT=1

# switch for processing right hemisphere, 1--yes, 0--no
RIGHT=1

#===============================================================================
# specific variables for some steps
#===============================================================================

# 1_ROI_registration_spm, 6_ROI_toMNI_spm, template image
TEMPLATE=${PIPELINE}/MNI152_T1_1mm_brain.nii

# 1_ROI_registration_spm, SPM directory
SPM=/DATA/233/hli/toolbox/spm8

# 2_ROI_calc_coord, NIFTI toolbox directory
NIFTI=${PIPELINE}/NIfTI_20130306

# 3_ROI_probtrackx, Number of samples, default 5000
N_SAMPLES=5000

# 3_ROI_probtrackx, distance correction, yes--(--pd), no--( )space
DIS_COR=--pd

# 3_ROI_probtrackx, the length of each step, default 0.5 mm
LEN_STEP=0.5

# 3_ROI_probtrackx, maximum number of steps, default 2000
N_STEPS=2000

# 3_ROI_probtrackx, curvature threshold (cosine of degree), default 0.2
CUR_THRES=0.2

# 4_ROI_calc_matrix, value threshold, default 10
VAL_THRES=10

# 4_ROI_calc_matrix, downsampling, new voxel size, e.g. 5*5*5. default 5
DOWN_SIZE=5

# 5_ROI_parcellation, clustering method, e.g. spectral clustering, default sc (available methods: kmeans, sc, simlr)
METHOD=sc

# 6_ROI_toMNI_spm, new voxel size, default 1*1*1
VOX_SIZE=1

# 7_group_refer, group threshold, default 0.25
GROUP_THRES=0.25

# 9_calc_mpm, mpm threshold, default 0.25
MPM_THRES=0.25

# 11_validation, the number of iteration, default 100
N_ITER=100

# 11_validation, the switch of calculating CV/Dice/NMI using split_half strategy, 1--yes, 0--no
split_half=1;

# 11_validation, the switch of calculating CV/Dice/NMI using pairwise strategy, 1--yes, 0--no
pairwise=1;

# 11_validation, the switch of calculating CV/Dice/NMI using leave_one_out strategy, 1--yes, 0--no
leave_one_out=1;

# 11_validation, the switch of calculating hierachical index (hi) and variation of information (vi) index, 1--yes, 0--no
hi_vi=1;

# 11_validation, the switch of calculating topology distance (TpD) index, 1--yes, 0--no
tpd=1;

# 11_validation, the switch of calculating silhouette index, 1--yes, 0--no
silhouette=1;

# 11_validation, the switch of calculating continuity index, 1--yes, 0--no
cont=1;


#===============================================================================
# environment variables that should be added or modified if necessary
#===============================================================================

# absolute path of command matlab
if command -v matlab > /dev/null 2>&1; then
	export COMMAND_MATLAB=$(command -v matlab)
else
	echo "Commmand 'matlab' is not found! Please set it in config.sh!"
	exit 1
fi

# absolute path of command qsub
if command -v qsub > /dev/null 2>&1; then
	export COMMAND_QSUB=$(command -v qsub)
else
	echo "Commmand 'qsub' is not found! Please set it in config.sh!"
	exit 1
fi

# absolute path of command fsl_sub
if command -v fsl_sub > /dev/null 2>&1; then
	export COMMAND_FSLSUB=$(command -v fsl_sub)
else
	echo "Commmand 'fsl_sub' is not found! Please set it in config.sh!"
	exit 1
fi

# absolute path of command probtrackx
if command -v probtrackx > /dev/null 2>&1; then
	export COMMAND_PROBTRACKX=$(command -v probtrackx)
else
	echo "Commmand 'probtrackx' is not found! Please set it in config.sh!"
	exit 1
fi	
