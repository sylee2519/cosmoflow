#!/bin/bash

num_nodes=$1
if [ -z "$num_nodes" ]; then
  echo "Usage: $0 <number_of_nodes>"
  exit 1
fi

# Generate hostfile
hostfile="hostfile"
> $hostfile

# Get the first 'num_nodes' nodes from the allocated nodes
nodes_list=$(scontrol show hostnames $SLURM_JOB_NODELIST | head -n $num_nodes)

# Write to hostfile
echo "$nodes_list" | while read -r hostname; do
  echo "${hostname} slots=1" >> $hostfile
done

