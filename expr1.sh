#!/bin/bash

# Define the number of node
NumNode=1024

########## Experiment 1: No Kill ##########
export BBPATH="/path/to/bb"
export HVAC_SERVER_COUNT=${NumNode}
export MY_JOBID=0

sh host.sh ${NumNode} # Create a hostfile

hostfile="hostfile"
NODELIST=$(awk '{print $1}' $hostfile | paste -sd, -)

srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh

# Without HVAC
export HVAC_LOG_DIR="${BBPATH}/logdir/expr1/v0" # Must be inside BB path to minimize interference
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR} # Each node create the LOGDIR in BB
horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile hostfile python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 0 --epochs-to-kill 0 2>&1 | tee ${HVAC_LOG_DIR}/output_orig.log
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB

# Version 1
export HVAC_LOG_DIR="${BBPATH}/logdir/expr1/v1" # Must be inside BB path to minimize interference
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR} # Each node create the LOGDIR in BB
srun --export=ALL,HVAC_LOG_DIR=${HVAC_LOG_DIR},HVAC_SERVER_COUNT=${NumNode},MY_JOBID=0 --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver1/build/src/bin/hvac_server ${NumNode} &
# This has to be run with horovodrun instead of srun (gloo - horovod elastic run for the cosmoflow to support fault tolerance)
LD_PRELOAD=/path/to/hvac_ver1/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile hostfile env HVAC_LOG_DIR=${HVAC_LOG_DIR} MY_JOBID=0 HVAC_SERVER_COUNT=${NumNode} python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 0 --epochs-to-kill 0 2>&1 | tee ${HVAC_LOG_DIR}/output_ver1.log
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh # Kill hvac_server && other possible processes
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB
rm -rf ./.ports*
#! EMPTY THE BB !#

# Version 2
export HVAC_LOG_DIR="${BBPATH}/logdir/expr1/v2" # Must be changed because log file names are the same
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST mkdir -p ${HVAC_LOG_DIR} # Each node create the LOGDIR in BB
srun --export=ALL,HVAC_LOG_DIR=${HVAC_LOG_DIR},HVAC_SERVER_COUNT=${NumNode},MY_JOBID=1 --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST /path/to/hvac_ver2/build/src/bin/hvac_server ${NumNode} &
LD_PRELOAD=/path/to/hvac_ver2/build/src/libhvac_client.so horovodrun --start-timeout 120 --gloo -np ${NumNode} --min-np 1 --hostfile hostfile env HVAC_LOG_DIR=${HVAC_LOG_DIR} HVAC_SERVER_COUNT=${NumNode} MY_JOBID=1 python train2.py -d --batch-size=16 --prefetch=2 --seed=0 --kill-times 0 --epochs-to-kill 0 2>&1 | tee ${HVAC_LOG_DIR}/output_ver2.log
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST sh kill.sh # Kill hvac_server && other possible processes
srun --nodes=${NumNode} --ntasks=${NumNode} --gres=gpu:0 --ntasks-per-node=1 --gpus-per-task=0 --nodelist=$NODELIST cp -r ${BBPATH}/logdir ./ # Copy LOGDIR outof BB
rm -rf ./.ports*
#! EMPTY THE BB !#
