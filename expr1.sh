#!/bin/bash

# Function to create directory on each node. This is necessary becaus log dir is located in the local NVMe.
create_directory_on_nodes() {
  local dir=$1
  local hostfile=$2
  while read -r line; do
    node=$(echo $line | awk '{print $1}')
    ssh $node << EOF
    cd $initial_pwd
    mkdir -p $dir
    exit
EOF
  done < $hostfile
}

# Remember the current working directory
initial_pwd=$(pwd)

# Experiment 1: No Kill
export BBPATH="/path/to/bb"
export HVAC_SERVER_COUNT=1024
export MY_JOBID=0

sh host.sh 1024 # Create a hostfile

hostfile="hostfile"
NODELIST=$(awk '{print $1}' $hostfile | paste -sd, -)


# Without HVAC
export HVAC_LOG_DIR="${BBPATH}/logdir/expr1/original" # Must be inside BB path to minimize interference
mkdir -p "${HVAC_LOG_DIR}" 
horovodrun --start-timeout 120 --gloo -np 1024 --min-np 1 --hostfile hostfile python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 0 --epochs-to-kill 0 | tee ${HVAC_LOG_DIR}/output_orig.log

# Version 1
export HVAC_LOG_DIR="${BBPATH}/logdir/expr1/v1" # Must be inside BB path to minimize interference
create_directory_on_nodes "${HVAC_LOG_DIR}" "$hostfile"
srun --export=ALL,HVAC_LOG_DIR="${BBPATH}/logdir/expr1/v1" --nodes=1024 --ntasks=1024 --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver1/build/src/bin/hvac_server 1024 &
# This has to be run with horovodrun instead of srun (gloo - horovod elastic run for the cosmoflow to support fault tolerance)
LD_PRELOAD=/path/to/hvac_ver1/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np 1024 --min-np 1 --hostfile hostfile env HVAC_LOG_DIR="${HVAC_LOG_DIR}" python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 0 --epochs-to-kill 0 | tee ${HVAC_LOG_DIR}/output_ver1.log
sh kill.sh #kill hvac_server
### COPY LOGDIR INTO THE SAFE PLACE && EMPTY THE BB ###

# Version 2
export HVAC_LOG_DIR="${BBPATH}/logdir/expr1/v2" # Must be changed because log file names are the same
create_directory_on_nodes "${HVAC_LOG_DIR}" "$hostfile"
srun --export=ALL,HVAC_LOG_DIR="${BBPATH}/logdir/expr1/v2" --nodes=1024 --ntasks=1024 --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver2/build/src/bin/hvac_server 1024 &
LD_PRELOAD=/path/to/hvac_ver2/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np 1024 --min-np 1 --hostfile hostfile env HVAC_LOG_DIR="${HVAC_LOG_DIR}" python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 0 --epochs-to-kill 0 | tee ${HVAC_LOG_DIR}/output_ver2.log
sh kill.sh #kill hvac_server
### COPY LOGDIR INTO THE SAFE PLACE && EMPTY THE BB ###
