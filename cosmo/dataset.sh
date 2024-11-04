#!/bin/bash

# Loop over the number of nodes (since you have up to 5 nodes)
for nodes in 2; do
    # Loop over the number of GPUs per node (from 1 to 4, since you have 4 GPUs per node)
    for gpus_per_node in 2; do
        # Calculate the total number of GPUs used, which equals the number of tasks
		for batch_size in 1 4 16; do
			for prefetch in 4 8; do
				let ntasks=gpus_per_node*nodes
            	echo "Running on ${nodes} nodes, ${gpus_per_node} GPUs per node, batch ${batch_size}, prefetch ${prefetch}"
				srun --nodes=1 --gres=gpu:0 --ntasks=1 --ntasks-per-node=1 --gpus-per-task=0 --cpus-per-task=1 python arg.py --nodes=${nodes} --gpus=${gpus_per_node} --ntasks=${gpus_per_node} --batch_size=${batch_size} --prefetch=${prefetch}
            	LD_PRELOAD=/scratch/s5104a21/hvactest/build/src/libhvac_client.so srun --nodes=${nodes} --gres=gpu:${gpus_per_node} --ntasks=${ntasks} --ntasks-per-node=${gpus_per_node} --gpus-per-task=1 --cpus-per-task=2 python train.py -d --batch-size=${batch_size} --prefetch=${prefetch}
            	rm -rf hvac_intercept_log.*
            	echo "Job completed"
			done
		done
    done
done

# End of script

