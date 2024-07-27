#!/bin/bash

get_nodelist() {
  awk '{print $1}' hostfile | paste -sd, -
}

# Experiment 2: Kill at Specific Epochs
export BBPATH="/path/to/bb"
export HVAC_SERVER_COUNT=1024
export MY_JOBID=0

sh host.sh 1024 # Create a hostfile
NODELIST=$(get_nodelist)

declare -a epochs=(3 8 13 18)

for epoch in "${epochs[@]}"; do
  # Version 1
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr2/${epoch}/v1" # Must be inside BB path to minimize interference
  mkdir -p "${HVAC_LOG_DIR}" 
  srun --nodes=1024 --ntasks=1024 --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver1/build/src/bin/hvac_server 1024 &
  LD_PRELOAD=/path/to/hvac_ver1/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np 1024 --min-np 1 --hostfile hostfile python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 1 --epochs-to-kill $epoch | tee ${HVAC_LOG_DIR}/output_ver1_epoch${epoch}.log
  sh kill.sh #kill hvac_server
  ### COPY LOGDIR INTO THE SAFE PLACE && EMPTY THE BB ###

  # Version 2
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr2/${epoch}/v2" 
  mkdir -p "${HVAC_LOG_DIR}" 
  srun --nodes=1024 --ntasks=1024 --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver2/build/src/bin/hvac_server 1024 &
  LD_PRELOAD=/path/to/hvac_ver2/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np 1024 --min-np 1 --hostfile hostfile python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 1 --epochs-to-kill $epoch | tee ${HVAC_LOG_DIR}/output_ver2_epoch${epoch}.log
  sh kill.sh #kill hvac_server
  ### COPY LOGDIR INTO THE SAFE PLACE && EMPTY THE BB ###
done

