#!/bin/sh
#SBATCH -J testvac
#SBATCH -p cas_v100_4
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err
#SBATCH --time=48:00:00
#SBATCH --gres=gpu:1 # using 2 gpus per node
#SBATCH --comment etc

module purge
module load gcc/10.2.0 mpi/openmpi-4.1.1

conda activate my_tensorflow

env | grep SLURM_JOB
set -x
srun -l -u python train.py -d --rank-gpu $@
