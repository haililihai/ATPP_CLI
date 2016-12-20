#! /bin/bash
# generate working directory for ATPP
#
# Directory structure:
#	  Working_dir
#     |-- sub1
#     |   |-- T1_sub1.nii
#     |   `-- b0_sub1.nii
#     |-- ...
#     |-- subN
#     |   |-- T1_subN.nii
#     |   `-- b0_subN.nii
#     |-- ROI
#     |   |-- ROI_L.nii
#     |   `-- ROI_R.nii
#     `-- log 
#
# !! Please modify the following codes to organzie these files according to the above structure


WD=$1
shift
DATA_DIR=$1
shift
ROI=$1
shift
SUB_LIST=$1
shift
ROI_DIR=$1

# generate ROI directory
mkdir -p ${WD}/ROI
mkdir -p ${WD}/log

# unzip ROIs if they are in gz format 
gunzip ${ROI_DIR}/${ROI}_L.nii.gz
gunzip ${ROI_DIR}/${ROI}_R.nii.gz

# copy ROIs from ROI_DIR to ROI directory in working directory
cp -vrt ${WD}/ROI ${ROI_DIR}/${ROI}_L.nii ${ROI_DIR}/${ROI}_R.nii

# copy T1 and b0 files from DATA_DIR for each subject
for sub in `cat ${SUB_LIST}`
do
    mkdir -p ${WD}/${sub} 
	cp -vrt ${WD}/${sub} ${DATA_DIR}/${sub}/T1_brain.nii.gz ${DATA_DIR}/${sub}/DTI/nodif_brain.nii.gz
	gunzip ${WD}/${sub}/nodif_brain.nii.gz
	gunzip ${WD}/${sub}/T1_brain.nii.gz
	mv -v ${WD}/${sub}/T1_brain.nii ${WD}/${sub}/T1_${sub}.nii	
	mv -v ${WD}/${sub}/nodif_brain.nii ${WD}/${sub}/b0_${sub}.nii	
done
