#!/bin/bash

# Define the number of node and the HVAC paths
NumNode=1024
HVAC_V1_ServerPath="/path/to/hvac_ver1/build/src/bin/hvac_server"
HVAC_V2_ServerPath="/path/to/hvac_ver2/build/src/bin/hvac_server"
HVAC_V1_ClientPath="/path/to/hvac_ver1/build/src/libhvac_client.so"
HVAC_V2_ClientPath="/path/to/hvac_ver2/build/src/libhvac_client.so"

######### Experiment 2: Kill at Specific Epochs #########
export BBPATH="/path/to/bb"
export HVAC_SERVER_COUNT=${NumNode}
export MY_JOBID=0

sh host.sh ${NumNode} # Create a hostfile
hostfile="hostfile"
NODELIST=$(awk '{print $1}' $hostfile | paste -sd, -)

declare -a epochs=(3 8 13 18) # Epochs to kill

rm -rf ./.ports*
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh

for epoch in "${epochs[@]}"; do
  # Version 1
  MY_JOBID=$((epoch * 1))
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr2/${epoch}/v1" # Must be inside BB path to minimize interference
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR}  
  srun --export=ALL,HVAC_LOG_DIR=${HVAC_LOG_DIR},HVAC_SERVER_COUNT=${NumNode},MY_JOBID=${MY_JOBID} --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST ${HVAC_V1_ServerPath} ${NumNode} &
  LD_PRELOAD=${HVAC_V1_ClientPath} horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile ${hostfile} env HVAC_LOG_DIR=${HVAC_LOG_DIR} HVAC_SERVER_COUNT=${NumNode} MY_JOBID=${MY_JOBID} python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 1 --epochs-to-kill $epoch 2>&1 | tee ${HVAC_LOG_DIR}/output_ver1_epoch${epoch}.log
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh # Kill hvac_server && other possible processes
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB
  rm -rf ./.ports*
  #! EMPTY THE BB !#

  # Version 2
  MY_JOBID=$((epoch * 2))
  export HVAC_LOG_DIR="${BBPATH}/logdir/expr2/${epoch}/v2" 
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR}
  srun --export=ALL,HVAC_LOG_DIR=${HVAC_LOG_DIR},HVAC_SERVER_COUNT=${NumNode},MY_JOBID=${MY_JOBID} --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST ${HVAC_V2_ServerPath} ${NumNode} &
  LD_PRELOAD=${HVAC_V2_ClientPath} horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile ${hostfile} env HVAC_LOG_DIR=${HVAC_LOG_DIR} HVAC_SERVER_COUNT=${NumNode} MY_JOBID=${MY_JOBID} python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 1 --epochs-to-kill $epoch 2>&1 | tee ${HVAC_LOG_DIR}/output_ver2_epoch${epoch}.log
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh # Kill hvac_server && other possible processes
  srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB
  rm -rf ./.ports*
  #! EMPTY THE BB !#

done

