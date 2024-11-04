#!/bin/bash

#SBATCH -A stf008
#SBATCH -J cosmoflow
#SBATCH -o sy_cosmo4debug.out
#SBATCH -t 00:08:00
#SBATCH -q debug 
#SBATCH -N 4
#SBATCH -C nvme


# Define the number of node and the HVAC paths
NumNode=4
HVAC_V1_ServerPath="/lustre/orion/proj-shared/stf008/hvac/sylee/hvac_f/build/src/hvac_server"
#HVAC_V2_ServerPath="/path/to/hvac_ver2/build/src/bin/hvac_server"
HVAC_V1_ClientPath="/lustre/orion/proj-shared/stf008/hvac/sylee/hvac_f/build/src/libhvac_client.so"
#HVAC_V2_ClientPath="/path/to/hvac_ver2/build/src/libhvac_client.so"


export MPICH_OFI_CXI_COUNTER_REPORT=2
module load rocm/6.0.0
module load cray-pmi/6.1.13
module load cray-mpich/8.1.28


# Assign the input arguments to variables
# # Set environment variables
export MIOPEN_USER_DB_PATH="/mnt/bb/khana/"
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}
export OMP_NUM_THREADS=1
export PMI_RANK=1
export KMP_BLOCKTIME=1
export KMP_AFFINITY="granularity=fine,compact,1,0"
export HDF5_USE_FILE_LOCKING=FALSE
export CUDA_VISIBLE_DEVICES=0,1,2,3
export HIP_VISIBLE_DEVICES=0,1,2,3

########## Experiment 1: No Kill ##########
export HVAC_SERVER_COUNT=${NumNode}
export HVAC_LOG_LEVEL=800
export RDMAV_FORK_SAFE=1
export VERBS_LOG_LEVEL=4
export BBPATH=/mnt/bb/$USER
export MY_JOBID=1
export HVAC_DATA_DIR=/lustre/orion/proj-shared/stf008/hvac/cosmoflow-benchmark/data/cosmoUniverse_complete/cosmoUniverse_2019_05_4parE_tf_v2


#unset http_proxy
#unset https_proxy
#export http_proxy=http://proxy.ccs.ornl.gov:3128/
#export https_proxy=http://proxy.ccs.ornl.gov:3128/

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/lustre/orion/gen008/proj-shared/log4c-1.2.4/install/lib/pkgconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lustre/orion/gen008/proj-shared/log4c-1.2.4/install/lib
export PATH=/lustre/orion/gen008/proj-shared/mercury-2.0.1/build/bin:$PATH
export LD_LIBRARY_PATH=/lustre/orion/gen008/proj-shared/rlibrary/mercury2.0.1/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=/lustre/orion/gen008/proj-shared/rlibrary/mercury2.0.1/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=/lustre/orion/gen008/proj-shared/rlibrary/mercury2.0.1/include:$CPLUS_INCLUDE_PATH
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/lustre/orion/gen008/proj-shared/rlibrary/mercury2.0.1/lib/pkgconfig


source /lustre/orion/proj-shared/stf008/hvac/hsoon_venv/bin/activate

sh host.sh ${NumNode} # Create a hostfile

hostfile="hostfile"
NODELIST=$(awk '{print $1}' $hostfile | paste -sd, -)

#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh

# Without HVAC
#export HVAC_LOG_DIR="${BBPATH}/logdir/expr1/v0" # Must be inside BB path to minimize interference
#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR} # Each node create the LOGDIR in BB
#horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile ${hostfile} python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 1 --epochs-to-kill2 2>&1 | tee ${HVAC_LOG_DIR}/output_ver0.log

#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB

#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST rm -r ${BBPATH}/logdir 

# Version 1
export HVAC_LOG_DIR="/lustre/orion/proj-shared/stf008/hvac/sylee/cosmoflow/logdir/expr1/debug" # Must be inside BB path to minimize interference
#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR} # Each node create the LOGDIR in BB
srun --kill-on-bad-exit=0 --export=ALL,HVAC_LOG_DIR=${HVAC_LOG_DIR},HVAC_SERVER_COUNT=${NumNode},MY_JOBID=1 --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST ${HVAC_V1_ServerPath} 1 &
# This has to be run with horovodrun instead of srun (gloo - horovod elastic run for the cosmoflow to support fault tolerance)
LD_PRELOAD=${HVAC_V1_ClientPath}  horovodrun --start-timeout 3200 --gloo -np 16 --min-np 1 --hostfile ${hostfile} env HVAC_LOG_DIR=${HVAC_LOG_DIR} MY_JOBID=1 HVAC_SERVER_COUNT=${NumNode} python train2.py -d --batch-size=4 --prefetch=0 --seed=0 --n-train=128 --n-valid=128 --kill-times 1 --epochs-to-kill 2 

#2>&1 | tee ${HVAC_LOG_DIR}/output_ver1.log

#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST source kill.sh # Kill hvac_server && other possible processes
#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB
rm -rf ./.ports*
#! EMPTY THE BB !#

# Version 2
#export HVAC_LOG_DIR="${BBPATH}/logdir/expr1/v2" # Must be changed because log file names are the same
#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR} # Each node create the LOGDIR in BB
#srun --export=ALL,HVAC_LOG_DIR=${HVAC_LOG_DIR},HVAC_SERVER_COUNT=${NumNode},MY_JOBID=1 --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST ${HVAC_V2_ServerPath} ${NumNode} &
#LD_PRELOAD=${HVAC_V2_Client_Path} horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile hostfile env HVAC_LOG_DIR=${HVAC_LOG_DIR} HVAC_SERVER_COUNT=${NumNode} MY_JOBID=1 python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 0 --epochs-to-kill 0 2>&1 | tee ${HVAC_LOG_DIR}/output_ver2.log
#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh # Kill hvac_server && other possible processes
#srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB
#rm -rf ./.ports*
#! EMPTY THE BB !#
