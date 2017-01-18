#! /bin/bash
# generate probabilistic tractography for each voxel in ROI

WD=$1
shift
DATA_DIR=$1
shift
ROI=$1
shift
SUB_LIST=$1
shift
N_SAMPLES=$1
shift
DIS_COR=$1
shift
LEN_STEP=$1
shift
N_STEPS=$1
shift
CUR_THRES=$1
shift
LEFT=$1
shift
RIGHT=$1

# create a directory to check the status
if [ -d ${WD}/probtrackx_jobdone ]
then
	rm -rf ${WD}/probtrackx_jobdone
	mkdir -p ${WD}/probtrackx_jobdone
else
	mkdir -p ${WD}/probtrackx_jobdone
fi


for sub in $(cat ${SUB_LIST})
do
# single voxel probtrackx
if [ "${LEFT}" = "1" ]; then
	job_id=$(${COMMAND_FSLSUB} -l ${WD}/log ${COMMAND_PROBTRACKX} --mode=simple --seedref=${DATA_DIR}/${sub}/DTI.bedpostX/nodif_brain_mask -o ${ROI}_L -x ${WD}/${sub}/${sub}_${ROI}_L_coord.txt -l ${DIS_COR} -c ${CUR_THRES} -S ${N_STEPS} --steplength=${LEN_STEP} -P ${N_SAMPLES} --forcedir --opd -s ${DATA_DIR}/${sub}/DTI.bedpostX/merged -m ${DATA_DIR}/${sub}/DTI.bedpostX/nodif_brain_mask --dir=${WD}/${sub}/${sub}_${ROI}_L_probtrackx &)
	echo "${sub}_L probtrackx is running...! job_ID is ${job_id}"
	mute=$(${COMMAND_FSLSUB} -j ${job_id} -N running... -l ${WD}/log touch ${WD}/probtrackx_jobdone/${sub}_L.jobdone)
fi

if [ "${RIGHT}" = "1" ]; then
	job_id=$(${COMMAND_FSLSUB} -l ${WD}/log ${COMMAND_PROBTRACKX} --mode=simple --seedref=${DATA_DIR}/${sub}/DTI.bedpostX/nodif_brain_mask -o ${ROI}_R -x ${WD}/${sub}/${sub}_${ROI}_R_coord.txt -l ${DIS_COR} -c ${CUR_THRES} -S ${N_STEPS} --steplength=${LEN_STEP} -P ${N_SAMPLES} --forcedir --opd -s ${DATA_DIR}/${sub}/DTI.bedpostX/merged -m ${DATA_DIR}/${sub}/DTI.bedpostX/nodif_brain_mask --dir=${WD}/${sub}/${sub}_${ROI}_R_probtrackx &)
	echo "${sub}_R probtrackx is running...! job_ID is ${job_id}"
	mute=$(${COMMAND_FSLSUB} -j ${job_id} -N running... -l ${WD}/log touch ${WD}/probtrackx_jobdone/${sub}_R.jobdone)
fi
	
done


# check whether the tasks are finished or not
N=$(cat ${SUB_LIST}|wc -l)
if [ "${LEFT}" = "1" -a "${RIGHT}" = "0" ]
then
	while [ "$(ls ${WD}/probtrackx_jobdone|wc -l)" != "${N}"  ]
	do
		sleep 30s
	done	
fi

if [ "${LEFT}" = "0" -a "${RIGHT}" = "1" ]
then
	while [ "$(ls ${WD}/probtrackx_jobdone|wc -l)" != "${N}"  ]
	do
		sleep 30s
	done	
fi

if [ "${LEFT}" = "1" -a "${RIGHT}" = "1" ]
then
	while [ "$(ls ${WD}/probtrackx_jobdone|wc -l)" != "$((${N}*2))"  ]
	do
		sleep 30s
	done	
fi

echo "====== Finally Probtrackx All Done!! ======"
