#!/bin/bash

num_nodes=$1
if [ -z "$num_nodes" ]; then
  echo "Usage: $0 <number_of_nodes>"
  exit 1
fi

# Generate hostfile for horovodrun and srun
horovod_hostfile="hostfile_horovod"
srun_hostfile="hostfile_srun"
> $horovod_hostfile
> $srun_hostfile

# Get the first 'num_nodes' nodes from the allocated nodes
nodes_list=$(scontrol show hostnames $SLURM_JOB_NODELIST | head -n $num_nodes)

# Write to horovod hostfile
echo "$nodes_list" | while read -r hostname; do
  echo "${hostname}:1" >> $horovod_hostfile
done

# Write to srun hostfile
echo "$nodes_list" | while read -r hostname; do
  echo "${hostname} slots=1" >> $srun_hostfile
done
