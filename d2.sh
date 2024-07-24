#!/bin/bash

# Loop over the number of nodes (since you have up to 5 nodes)
for nodes in 3; do
    # Loop over the number of GPUs per node (from 1 to 4, since you have 4 GPUs per node)
    for gpus_per_node in 3; do
        # Calculate the total number of GPUs used, which equals the number of tasks
		for batch_size in 4 8 16; do
			for prefetch in 1 2 4 8; do
				let ntasks=gpus_per_node*nodes
            	echo "Running on ${nodes} nodes, ${gpus_per_node} GPUs per node, batch ${batch_size}, prefetch ${prefetch}"
				srun python arg.py --nodes=${nodes} --gpus=${gpus_per_node} --ntasks=${gpus_per_node} --batch_size=${batch_size} --prefetch=${prefetch}
            	srun --nodes=${nodes} --gres=gpu:${gpus_per_node} --ntasks=${ntasks} --ntasks-per-node=${gpus_per_node} --gpus-per-task=1 python train.py -d --batch-size=${batch_size} --prefetch=${prefetch}
            
            	echo "Job completed"
			done
		done
    done
done

# End of script

