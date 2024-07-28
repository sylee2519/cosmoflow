#!/bin/bash

# Define the number of node
NumNode=1024

######### Experiment 3: Multiple Kills #########
export BBPATH="/path/to/bb"
export MY_JOBID=0
export HVAC_SERVER_COUNT=${NumNode}

sh host.sh ${NumNode} # Create a hostfile
hostfile="hostfile"
NODELIST=$(awk '{print $1}' $hostfile | paste -sd, -)

declare -a kill_configs=(
  "8"
  "8 10"
  "8 10 12"
  "8 10 12 14"
  "8 10 12 14 16"
)

config_count=1

rm -rf ./.ports*
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh

for kill_config in "${kill_configs[@]}"; do
  # Version 1
  MY_JOBID=$(($config_count*1))
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr3/${NumNode}/v1_config${config_count}"
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR}
  srun --export=ALL,HVAC_LOG_DIR=${HVAC_LOG_DIR},HVAC_SERVER_COUNT=${NumNode},MY_JOBID=${MY_JOBID} --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver1/build/src/bin/hvac_server ${NumNode} &
  LD_PRELOAD=/path/to/hvac_ver1/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile hostfile env HVAC_LOG_DIR=${HVAC_LOG_DIR} HVAC_SERVER_COUNT=${NumNode} MY_JOBID=${MY_JOBID} python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times $(echo $kill_config | wc -w) --epochs-to-kill $kill_config 2>&1 | tee ${HVAC_LOG_DIR}/output_ver1_kill${config_count}.log
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh # Kill hvac_server && other possible processes
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB
  rm -rf ./.ports*
  #! EMPTY THE BB !#

  # Version 2
  MY_JOBID=$(($config_count*2))
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr3/${NumNode}/v2_config${config_count}"
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR}
  srun --export=ALL,HVAC_LOG_DIR=${HVAC_LOG_DIR},HVAC_SERVER_COUNT=${NumNode},MY_JOBID=${MY_JOBID} --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver2/build/src/bin/hvac_server ${NumNode} &
  LD_PRELOAD=/path/to/hvac_ver2/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile hostfile env HVAC_LOG_DIR=${HVAC_LOG_DIR} HVAC_SERVER_COUNT=${NumNode} MY_JOBID=${MY_JOBID} python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times $(echo $kill_config | wc -w) --epochs-to-kill $kill_config 2>&1 | tee ${HVAC_LOG_DIR}/output_ver2_kill${config_count}.log
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh # Kill hvac_server && other possible processes
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB
  rm -rf ./.ports*
  #! EMPTY THE BB !#
  config_count=$((config_count + 1))
done

# Re-define the number of node
NumNode=64
export HVAC_SERVER_COUNT=${NumNode}
sh host.sh ${NumNode} # Create a hostfile
NODELIST=$(awk '{print $1}' $hostfile | paste -sd, -)

config_count=1

for kill_config in "${kill_configs[@]}"; do
  # Version 1
  MY_JOBID=$(($config_count*1))
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr3/${NumNode}/v1_config${config_count}"
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR}
  srun --export=ALL,HVAC_LOG_DIR=${HVAC_LOG_DIR},HVAC_SERVER_COUNT=${NumNode},MY_JOBID=${MY_JOBID} --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver1/build/src/bin/hvac_server ${NumNode} &
  LD_PRELOAD=/path/to/hvac_ver1/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile hostfile env HVAC_LOG_DIR=${HVAC_LOG_DIR} HVAC_SERVER_COUNT=${NumNode} MY_JOBID=${MY_JOBID} python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times $(echo $kill_config | wc -w) --epochs-to-kill $kill_config 2>&1 | tee ${HVAC_LOG_DIR}/output_ver1_kill${config_count}.log
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh # Kill hvac_server && other possible processes
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB
  rm -rf ./.ports*
  #! EMPTY THE BB !#

  # Version 2
  MY_JOBID=$(($config_count*2))
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr3/${NumNode}/v2_config${config_count}"
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR}
  srun --export=ALL,HVAC_LOG_DIR=${HVAC_LOG_DIR},HVAC_SERVER_COUNT=${NumNode},MY_JOBID=${MY_JOBID} --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver2/build/src/bin/hvac_server ${NumNode} &
  LD_PRELOAD=/path/to/hvac_ver2/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile hostfile env HVAC_LOG_DIR=${HVAC_LOG_DIR} HVAC_SERVER_COUNT=${NumNode} MY_JOBID=${MY_JOBID} python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times $(echo $kill_config | wc -w) --epochs-to-kill $kill_config 2>&1 | tee ${HVAC_LOG_DIR}/output_ver2_kill${config_count}.log
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh # Kill hvac_server && other possible processes
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB
  rm -rf ./.ports*
  #! EMPTY THE BB !#
  config_count=$((config_count + 1))
done




