#!/bin/bash

get_nodelist() {
  awk '{print $1}' hostfile | paste -sd, -
}


# Experiment 3: Multiple Kills
export BBPATH="/path/to/bb"
export MY_JOBID=0

# 1024 nodes
export HVAC_SERVER_COUNT=1024
sh host.sh 1024 # Create a hostfile
NODELIST=$(get_nodelist)

declare -a kill_configs=(
  "8"
  "8 10"
  "8 10 12"
  "8 10 12 14"
  "8 10 12 14 16"
)

for kill_config in "${kill_configs[@]}"; do
  # Version 1
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr3/v1_kill${kill_config// /_}"
  mkdir -p "${HVAC_LOG_DIR}"
  srun --nodes=1024 --ntasks=1024 --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver1/build/src/bin/hvac_server 1024 &
  LD_PRELOAD=/path/to/hvac_ver1/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np 1024 --min-np 1 --hostfile hostfile_horovod python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times $(echo $kill_config | wc -w) --epochs-to-kill $kill_config | tee ${HVAC_LOG_DIR}/output_ver1_kill${kill_config// /_}.log
  sh kill.sh #kill hvac_server
  ### COPY LOGDIR INTO THE SAFE PLACE && EMPTY THE BB ###

  # Version 2
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr3/v2_kill${kill_config// /_}"
  mkdir -p "${HVAC_LOG_DIR}"
  srun --nodes=1024 --ntasks=1024 --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver2/build/src/bin/hvac_server 1024 &
  LD_PRELOAD=/path/to/hvac_ver2/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np 1024 --min-np 1 --hostfile hostfile_horovod python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times $(echo $kill_config | wc -w) --epochs-to-kill $kill_config | tee ${HVAC_LOG_DIR}/output_ver2_kill${kill_config// /_}.log
  sh kill.sh #kill hvac_server
  ### COPY LOGDIR INTO THE SAFE PLACE && EMPTY THE BB ###
done

# 64 nodes
export HVAC_SERVER_COUNT=64
sh host.sh 64 # Create a hostfile
NODELIST=$(get_nodelist)

for kill_config in "${kill_configs[@]}"; do
  # Version 1
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr3/v1_kill${kill_config// /_}_64"
  mkdir -p "${HVAC_LOG_DIR}"
  srun --nodes=64 --ntasks=64 --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /scratch/s5104a21/hvac_ver1/build/src/bin/hvac_server 64 &
  LD_PRELOAD=/scratch/s5104a21/hvac_ver1/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np 64 --min-np 1 -H gpu33:1,gpu36:1,gpu38:1,... python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times $(echo $kill_config | wc -w) --epochs-to-kill $kill_config | tee ${HVAC_LOG_DIR}/output_ver1_kill${kill_config// /_}_64.log
  sh kill.sh #kill hvac_server
  ### COPY LOGDIR INTO THE SAFE PLACE && EMPTY THE BB ###

  # Version 2
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr3/v2_kill${kill_config// /_}_64"
  mkdir -p "${HVAC_LOG_DIR}"
  srun --nodes=64 --ntasks=64 --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /scratch/s5104a21/hvac_ver2/build/src/bin/hvac_server 64 &
  LD_PRELOAD=/scratch/s5104a21/hvac_ver2/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np 64 --min-np 1 -H gpu33:1,gpu36:1,gpu38:1,... python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times $(echo $kill_config | wc -w) --epochs-to-kill $kill_config | tee ${HVAC_LOG_DIR}/output_ver2_kill${kill_config// /_}_64.log
  sh kill.sh #kill hvac_server
  ### COPY LOGDIR INTO THE SAFE PLACE && EMPTY THE BB ###
done

