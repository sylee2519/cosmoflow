#!/bin/bash

#SBATCH -A stf008
#SBATCH -J cosmoflow
#SBATCH -o sogang_cosmo.out
#SBATCH -t 00:10:00
#SBATCH -q debug
#SBATCH -N 8
#SBATCH -C nvme

cd /lustre/orion/proj-shared/stf008/hvac/pdsw-ft/cosmoflow/

export MPICH_OFI_CXI_COUNTER_REPORT=2

source /lustre/orion/proj-shared/stf008/hvac/hsoon_venv/bin/activate
# Assign the input arguments to variables
#
module load rocm/6.0.0
module load cray-pmi/6.1.13
module load cray-mpich/8.1.28

# # Set environment variables
export TF_CPP_MIN_LOG_LEVEL=3
export OMP_NUM_THREADS=1
export PMI_RANK=1
export KMP_BLOCKTIME=1
export KMP_AFFINITY="granularity=fine,compact,1,0"
export HDF5_USE_FILE_LOCKING=FALSE
export MIOPEN_USER_DB_PATH="/mnt/bb/khana/"
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}
export CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
export HIP_VISIBLE_DEVICES=0,1,2,3,4,5,6,7
# Define the number of node and the HVAC paths

NumNode=8
#HVAC_V1_ServerPath="/path/to/hvac_ver1/build/src/bin/hvac_server"
#HVAC_V2_ServerPath="/path/to/hvac_ver2/build/src/bin/hvac_server"
#HVAC_V1_ClientPath="/path/to/hvac_ver1/build/src/libhvac_client.so"
#HVAC_V2_ClientPath="/path/to/hvac_ver2/build/src/libhvac_client.so"


########## Experiment 1: No Kill ##########
export BBPATH="/mnt/bb/khana/"
export HVAC_SERVER_COUNT=${NumNode}
export MY_JOBID=0

sh host.sh ${NumNode} # Create a hostfile

hostfile="hostfile"
NODELIST=$(awk '{print $1}' $hostfile | paste -sd, -)

#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh

# Without HVAC
export HVAC_LOG_DIR="${BBPATH}/logdir/expr1/v0" # Must be inside BB path to minimize interference
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR} # Each node create the LOGDIR in BB
horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile ${hostfile} python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 0 --epochs-to-kill 0 2>&1 | tee ${HVAC_LOG_DIR}/output_ver0.log

