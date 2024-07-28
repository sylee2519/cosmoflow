# Fault-tolerant HVAC Performance Testing Experiments

This document outlines the experimental setup designed to evaluate the performance and fault tolerance of two versions of the HVAC system (ver1 and ver2) using Horovod with Elastic Run on a distributed GPU cluster. The experiments are divided into three main categories: baseline performance without node failure, performance under single node failure at various epochs, and performance under multiple node failures at specific epochs.

## Requirements

**Files required:**
- **train2.py**
- **kill.sh**
- **host.sh**
- **expr1.sh**
- **expr2.sh**
- **expr3.sh**

1. Horovod should be installed with Gloo support.

2. Add the following code snippet in the experiment scripts to copy the log directory to clear the BB (Burst Buffer):
    ```sh
    #! EMPTY THE BB !#
    ```
3. Ensure that the time is synchronized across all nodes ('time.time()' and 'gettimeofday()' are used for logging and timing).


## Quick Guide

1. Run `expr1.sh`
2. Run `expr2.sh`
3. Run `expr3.sh`

## Detailed Explanation about Experiment Scripts

### Experiment 1: Baseline Performance Without Node Failure

**Objective:** Measure the baseline performance of the HVAC system (both ver1 and ver2) without any node failures over a fixed number of epochs.

**Setup:**
- **Nodes:** 1024
- **Tasks:** 1024
- **Epochs:** 20
- **HVAC Versions:** ver0 (without HVAC), ver1, and ver2

**Procedure:**

1. Generate a hostfile to be used with horovodrun and srun.

#### Without HVAC

1. Set `HVAC_LOG_DIR` and create it within the BB of each node.
2. Run the training script (`train2.py`) with 1024 tasks for 20 epochs using Horovod with Elastic Run and Gloo backend, and log the output.
3. Copy the log directory out of BB.
4. Empty the BB.

#### Ver1 & Ver2

1. Set and create the `HVAC_DATA_DIR` in BB of each node.
2. Launch HVAC server (ver1) on 1024 nodes.
3. Run the training script (`train2.py`) with 1024 tasks for 20 epochs using Horovod with Elastic Run and Gloo backend, and log the output.
4. Kill the HVAC SERVER and remaining processes.
5. Copy the log directory out of BB.
6. Empty the BB.
7. Repeat steps 1-6 for ver2.

### Experiment 2: Single Node Failure at Various Epochs

**Objective:** Evaluate the performance and recovery of the HVAC system (both ver1 and ver2) under a single node failure at different epochs.

**Setup:**
- **Nodes:** 1024
- **Tasks:** 1024
- **Epochs:** 20
- **HVAC Versions:** ver1 and ver2
- **Kill Times:** 1

**Epochs to Kill:**
- Epoch 3
- Epoch 8
- Epoch 13
- Epoch 18

**Procedure:**

1. Generate a hostfile to be used with horovodrun and srun.

2. For each epoch to kill, repeat the following steps:
    - Set `MY_JOBID`.
    - Set `HVAC_LOG_DIR` and create it within the BB of each node.
    - Run the HVAC Server.
    - Run the training script with HVAC Client.
    - Kill the processes.
    - Copy the log directory out of BB.
    - Empty the BB.

3. Repeat step 2 with ver2.

### Experiment 3: Multiple Node Failures at Specific Epochs

**Objective:** Evaluate the performance and recovery of the HVAC system (both ver1 and ver2) under multiple node failures at specific epochs.

**Setup:**
- **Nodes:** 1024 and 64
- **Tasks:** 1024 and 64
- **Epochs:** 20
- **HVAC Versions:** ver1 and ver2

**Kill Times and Epochs:**
- 1 Kill at Epoch 8
- 2 Kills at Epochs 8 and 10
- 3 Kills at Epochs 8, 10, and 12
- 4 Kills at Epochs 8, 10, 12, and 14
- 5 Kills at Epochs 8, 10, 12, 14, and 16

**Procedure:**

1. Generate a hostfile to be used with horovodrun and srun.

2. For each set of kill times and epochs, repeat the following steps:
    - Set the `config_count` as 1.
    - Set `MY_JOBID`.
    - Set `HVAC_LOG_DIR` and create it within the BB of each node.
    - Run the HVAC Server.
    - Run the training script with HVAC Client.
    - Kill the processes.
    - Copy the log directory out of BB.
    - Empty the BB.

3. Repeat step 2 with ver2.

4. Repeat steps 1-3 for 64 nodes.

