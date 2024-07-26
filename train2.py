# 'Regression of 3D Sky Map to Cosmological Parameters (CosmoFlow)'
# Copyright (c) 2018, The Regents of the University of California,
# through Lawrence Berkeley National Laboratory (subject to receipt of any
# required approvals from the U.S. Dept. of Energy).  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# If you have questions about your rights to use or distribute this software,
# please contact Berkeley Lab's Innovation & Partnerships Office at IPO@lbl.gov.
#
# NOTICE.  This Software was developed under funding from the U.S. Department of
# Energy and the U.S. Government consequently retains certain rights. As such,
# the U.S. Government has been granted for itself and others acting on its
# behalf a paid-up, nonexclusive, irrevocable, worldwide license in the Software
# to reproduce, distribute copies to the public, prepare derivative works, and
# perform publicly and display publicly, and to permit other to do so.

"""
Main training script for the CosmoFlow Keras benchmark
"""

# System imports
import os
import argparse
import logging
import pickle
from types import SimpleNamespace
import time
import psutil
import threading
import json
import ctypes
import socket

# External imports
import yaml
import pandas as pd
import tensorflow as tf
# Suppress TF warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
tf.compat.v1.logging.set_verbosity(logging.ERROR)
import horovod.tensorflow.keras as hvd
import wandb
#sy add
import subprocess
import random

# MLPerf logging
try:
    from mlperf_logging import mllog
    have_mlperf_logging = True
except ImportError:
    have_mlperf_logging = False

# Local imports
from data import get_datasets
from models import get_model
# Fix for loading Lambda layer checkpoints
from models.layers import *
from utils.optimizers import get_optimizer, get_lr_schedule
from utils.callbacks import (TimingCallback, MLPerfLoggingCallback,
                             StopAtTargetCallback)
from utils.device import configure_session
from utils.argparse import ReadYaml
from utils.checkpoints import reload_last_checkpoint
from utils.mlperf_logging import configure_mllogger, log_submission_info

from tensorflow.core.protobuf import rewriter_config_pb2


# sy: add - code to kill the processes
class KillProcessesCallback(tf.keras.callbacks.Callback):
    def __init__(self, epochs_to_kill, kill_times, nodes, initial_epochs):
        super(KillProcessesCallback, self).__init__()
        self.epochs_to_kill = set(epochs_to_kill)  # Store as a set for fast membership testing
        self.kill_times = kill_times
        self.kills_done = 0
        self.nodes = nodes
        self.epoch_to_kill = None
        self.batch_to_kill = None
        self.killed_epochs = set()  # To keep track of epochs already killed
        self.initial_epochs = initial_epochs
		
    def on_epoch_begin(self, epoch, logs=None):
        if hvd.rank() == 0:
            if epoch in self.epochs_to_kill and epoch not in self.killed_epochs:  # Ensure only rank 0 executes this
                steps_per_epoch = self.params['steps']
                self.batch_to_kill = steps_per_epoch // 2  # Kill at the middle of the epoch
                self.epoch_to_kill = epoch
#                print(f"Epoch {epoch} started. Will kill processes at batch {self.batch_to_kill}.")
#            else:
#                print(f"Epoch {epoch} started. No killing scheduled for this epoch.")

    def on_batch_begin(self, batch, logs=None):
        if hvd.rank() == 0:
            if self.kills_done < self.kill_times and self.epoch_to_kill in self.epochs_to_kill and batch == self.batch_to_kill:
                node_to_kill = random.choice(self.nodes)
                kill_time = time.time()
                self.nodes.remove(node_to_kill)  # Remove the node from the list after selecting it
                print(f"[{node_to_kill}][None][None][None][None][Kill][{self.epoch_to_kill}][{batch}][{kill_time}]")
#                print(f"Killing processes on node {node_to_kill} at epoch {self.epoch_to_kill}, batch {batch}")
                subprocess.run(["./kill.sh", node_to_kill], check=True)
                self.kills_done += 1
                self.killed_epochs.add(self.epoch_to_kill)  # Ensure we don't kill again in this epoch
                self.epochs_to_kill.remove(self.epoch_to_kill)  # Ensure we don't kill again in this epoch
                self.epoch_to_kill = None  # Reset the epoch to kill
#            elif batch == self.batch_to_kill:
#                print(f"Batch {batch} reached in epoch {self.epoch_to_kill}, but no killing is needed.")

    def on_epoch_end(self, epoch, logs=None):
        self.initial_epochs[0] = epoch
#        if hvd.rank() == 0:
#            print(f"Epoch {epoch} ended. Kills done: {self.kills_done}/{self.kill_times}.")
#            print(f"Killed epochs so far: {self.killed_epochs}")
#            print(f"Remaining epochs to kill: {self.epochs_to_kill}")

class TimeLogCallback(tf.keras.callbacks.Callback):
    def __init__(self):
        super(TimeLogCallback, self).__init__()
        self.epoch_number = 0
        self.epoch_start = 0
        self.epoch_end = 0
        self.batch_start = 0
        self.batch_end = 0

    def on_epoch_begin(self, epoch, logs=None):
        self.epoch_number = epoch
        self.epoch_start = time.time()
        print(f"[None][None][None][None][None][EpochStart][{epoch}][None][{self.epoch_start}]") 
    def on_epoch_end(self, epoch, logs=None):
        self.epoch_end = time.time()
        #[string:filepath][string: request][int: flag][int: client rank][int: server rank][string: expn][int: epoch #][int: batch #][gettimeofday: Clocktime]
        print(f"[None][None][None][None][None][EpochEnd][{epoch}][None][{self.epoch_end}]") 
    
    def on_batch_begin(self, batch, logs=None):
        self.batch_start = time.time()
        print(f"[None][None][None][None][None][EpochStart][{self.epoch_number}][{batch}][{self.batch_start}]") 

    def on_batch_end(self, batch, logs=None):
        self.batch_end = time.time()
        print(f"[None][None][None][None][None][BatchDuration][{self.epoch_number}][{batch}][{self.batch_end}]")


def append_to_json_file(data, filename='/scratch/s5104a21/cosmoflow/hpc/cosmoflow/training_configurations.json'):
    if not os.path.exists(filename):
        with open(filename, 'w') as file:
            json.dump([], file)  # Create a new JSON file if it does not exist

    with open(filename, 'r+') as file:
        file_data = json.load(file)  # Load existing data
        file_data.append(data)       # Append new data
        file.seek(0)                 # Reset file pointer to the top
        json.dump(file_data, file, indent=4)  # Write updated data back to file


def get_slurm_job_id():
    return os.getenv('SLURM_JOB_ID')

def get_job_memory_usage(job_id):
    total_memory = 0
    for proc in psutil.process_iter(attrs=['memory_info']):
        try:
            total_memory += proc.info['memory_info'].rss
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    return total_memory / (1024 * 1024)  # Convert from bytes to MB


def monitor_memory_usage(job_id, interval=2, filename="memory_usage.json"):
    memory_usages = []
    while not training_completed:
        current_usage = get_job_memory_usage(job_id)
        memory_usages.append(current_usage)
        time.sleep(interval)
    # Calculate average, min, and max memory usage
    memory_data = {}
    if memory_usages:
        memory_data['average_memory_usage'] = sum(memory_usages) / len(memory_usages)
        memory_data['min_memory_usage'] = min(memory_usages)
        memory_data['max_memory_usage'] = max(memory_usages)
    else:
        memory_data['message'] = "No memory usage data collected."

    # Append the results to a JSON file
    with open(filename, "a") as file:
        json.dump({job_id: memory_data}, file)
        file.write("\n")  # Add a newline for separation between entries


def parse_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser('train.py')
    add_arg = parser.add_argument
    add_arg('config', nargs='?', default='/scratch/s5104a21/cosmoflow/hpc/cosmoflow/configs/cosmo.yaml')
    add_arg('--output-dir', help='Override output directory')
    add_arg('--run-tag', help='Unique run tag for logging')

    # Override data settings
    add_arg('--data-dir', help='Override the path to input files')
    add_arg('--n-train', type=int, help='Override number of training samples')
    add_arg('--n-valid', type=int, help='Override number of validation samples')
    add_arg('--batch-size', type=int, help='Override the batch size')
    add_arg('--n-epochs', type=int, help='Override number of epochs')
    add_arg('--apply-log', type=int, choices=[0, 1], help='Apply log transform to data')
    add_arg('--stage-dir', help='Local directory to stage data to before training')
    add_arg('--n-parallel-reads', type=int, help='Override num parallel read calls')
    add_arg('--prefetch', type=int, help='Override data prefetch number')

    # Hyperparameter settings
    add_arg('--conv-size', type=int, help='CNN size parameter')
    add_arg('--fc1-size', type=int, help='Fully-connected size parameter 1')
    add_arg('--fc2-size', type=int, help='Fully-connected size parameter 2')
    add_arg('--hidden-activation', help='Override hidden activation function')
    add_arg('--dropout', type=float, help='Override dropout')
    add_arg('--optimizer', help='Override optimizer type')
    add_arg('--lr', type=float, help='Override learning rate')

    # Runtime / device settings
    add_arg('-d', '--distributed', action='store_true')
    add_arg('--gpu', type=int, help='Specify a specific GPU number to use')
    add_arg('--rank-gpu', action='store_true',
            help='Use GPU based on local rank')
    add_arg('--resume', action='store_true',
            help='Resume from last checkpoint')
    add_arg('--intra-threads', type=int, default=32, #32
            help='TF intra-parallel threads')
    add_arg('--inter-threads', type=int, default=2,
            help='TF inter-parallel threads')
    add_arg('--kmp-blocktime', help='Set KMP_BLOCKTIME')
    add_arg('--kmp-affinity', help='Set KMP_AFFINITY')
    add_arg('--omp-num-threads', help='Set OMP_NUM_THREADS')
    add_arg('--amp', action='store_true', help='Enable automatic mixed precision')

    # Other settings
    add_arg('--seed', type=int, default=0, help='Specify the random seed')
    add_arg('--deterministic-ops', action='store_true',
            help='Enable TF deterministic ops (may not be 100% deterministic)')
    add_arg('--mlperf', action='store_true', help='Enable MLPerf logging')
    add_arg('--wandb', action='store_true', help='Enable W&B logging')
    add_arg('--tensorboard', action='store_true', help='Enable TB logger')
    add_arg('--print-fom', action='store_true', help='Print parsable figure of merit')
    add_arg('-v', '--verbose', action='store_true')
    add_arg('--kill-times', type=int, default=1, help='Number of times to kill the processes')
    add_arg('--epochs-to-kill', type=int, nargs='+', help='Specific epochs at which to kill processes')
    return parser.parse_args()

def init_workers(distributed=False):
    if distributed:
        hvd.init()
        rank = hvd.rank()
        local_rank = hvd.local_rank()
        os.environ['CUDA_VISIBLE_DEVICES'] = str(local_rank)
        return SimpleNamespace(rank=hvd.rank(), size=hvd.size(),
                               local_rank=hvd.local_rank(),
                               local_size=hvd.local_size())
    else:
        return SimpleNamespace(rank=0, size=1, local_rank=0, local_size=1)


def config_logging(verbose):
    log_format = '%(asctime)s %(levelname)s %(message)s'
    log_level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(level=log_level, format=log_format)


def load_config(args):
    """Reads the YAML config file and returns a config dictionary"""
    with open(args.config) as f:
        config = yaml.load(f, Loader=yaml.FullLoader)

    # Expand paths
    output_dir = config['output_dir'] if args.output_dir is None else args.output_dir
    config['output_dir'] = os.path.expandvars(output_dir)

    # Override data config from command line
    if args.data_dir is not None:
        config['data']['data_dir'] = args.data_dir
    if args.n_train is not None:
        config['data']['n_train'] = args.n_train
    if args.n_valid is not None:
        config['data']['n_valid'] = args.n_valid
    if args.batch_size is not None:
        config['data']['batch_size'] = args.batch_size
    if args.n_epochs is not None:
        config['data']['n_epochs'] = args.n_epochs
    if args.apply_log is not None:
        config['data']['apply_log'] = bool(args.apply_log)
    if args.stage_dir is not None:
        config['data']['stage_dir'] = args.stage_dir
    if args.n_parallel_reads is not None:
        config['data']['n_parallel_reads'] = args.n_parallel_reads
    if args.prefetch is not None:
        config['data']['prefetch'] = args.prefetch

    # Hyperparameters
    if args.conv_size is not None:
        config['model']['conv_size'] = args.conv_size
    if args.fc1_size is not None:
        config['model']['fc1_size'] = args.fc1_size
    if args.fc2_size is not None:
        config['model']['fc2_size'] = args.fc2_size
    if args.hidden_activation is not None:
        config['model']['hidden_activation'] = args.hidden_activation
    if args.dropout is not None:
        config['model']['dropout'] = args.dropout
    if args.optimizer is not None:
        config['optimizer']['name'] = args.optimizer
    if args.lr is not None:
        config['optimizer']['lr'] = args.lr

    return config


def save_config(config):
    output_dir = config['output_dir']
    config_file = os.path.join(output_dir, 'config.pkl')
    logging.info('Writing config via pickle to %s', config_file)
    with open(config_file, 'wb') as f:
        pickle.dump(config, f)


def load_history(output_dir):
    return pd.read_csv(os.path.join(output_dir, 'history.csv'))


def print_training_summary(output_dir, print_fom):
    history = load_history(output_dir)
    if 'val_loss' in history.keys():
        best = history.val_loss.idxmin()
        logging.info('Best result:')
        for key in history.keys():
            logging.info('  %s: %g', key, history[key].loc[best])
        # Figure of merit printing for HPO parsing
        if print_fom:
            print('FoM:', history['val_loss'].loc[best])
    logging.info('Total epoch time: %.3f', history.time.sum())
    logging.info('Mean epoch time: %.3f', history.time.mean())


    with open("./time.json", "a") as file:
        data = {
            'Total epoch time': history['time'].sum(),
            'Mean epoch time': history['time'].mean()
        }
        json.dump(data, file)
        file.write("\n")


def check_gpus(gpus):
#    gpus = tf.config.experimental.list_physical_devices('GPU')
    if not gpus:
        print("No GPUs detected. Exiting.")
        exit(1)
    print("Available GPUs:", gpus)


def main():
    """Main function"""
    print("init")
    # Initialization

	# sy: add
    global training_completed
    training_completed = False
#    job_id = get_slurm_job_id()
#    config = tf.compat.v1.ConfigProto()
#    off = rewriter_config_pb2.RewriterConfig.OFF
#    config.graph_options.rewrite_options.arithmetic_optimization = off
#    session = tf.compat.v1.Session(config=config)


    args = parse_args()
#    ctypes.CDLL('/scratch/s5104a21/hvactest/build/src/lib/libhvac_client.so')
    dist = init_workers(args.distributed)
    config = load_config(args)
    gpus = tf.config.experimental.list_physical_devices('GPU')
    if gpus:
        try:
            for gpu in gpus:
                tf.config.experimental.set_memory_growth(gpu, True)
        except RuntimeError as e:
            print(e)
	
    check_gpus(gpus)
    os.environ['HOROVOD_RANK'] = str(hvd.rank())
    hostname = socket.gethostname()
    print(f"[{hostname}][{hvd.rank()}][None][None][None][None][None][None][None]")

    global_batch_size = args.batch_size * hvd.size() # sy add
    os.makedirs(config['output_dir'], exist_ok=True)
    config_logging(verbose=args.verbose)
    logging.info('Initialized rank %i size %i local_rank %i local_size %i',
                 dist.rank, dist.size, dist.local_rank, dist.local_size)
    if dist.rank == 0:
        logging.info('Configuration: %s', config)

    # Random seeding
    tf.keras.utils.set_random_seed(args.seed)

    # Enable deterministic ops - should ensure single-gpu determinism but
    # doesn't seem to guarantee determinism with Horovod distributed training
    if args.deterministic_ops:
        tf.config.experimental.enable_op_determinism()

    # Setup MLPerf logging
    if args.mlperf:
        mllogger = configure_mllogger(config['output_dir'])
    if dist.rank == 0 and args.mlperf:
        mllogger.event(key=mllog.constants.CACHE_CLEAR)
        mllogger.start(key=mllog.constants.INIT_START)
        mllogger.start(key=mllog.constants.SEED, value=args.seed)
        # Scale logging for mlperf hpc metrics
        mllogger.event(key='number_of_ranks', value=dist.size)
        mllogger.event(key='number_of_nodes', value=(dist.size//dist.local_size))
        mllogger.event(key='accelerators_per_node', value=dist.local_size)

    # Initialize Weights & Biases logging
    if args.wandb and dist.rank == 0:
        import wandb
        wandb.init(project='cosmoflow', name=args.run_tag, id=args.run_tag,
                   config=config, resume=args.run_tag)

    # Device and session configuration
    gpu = dist.local_rank if args.rank_gpu else args.gpu
    if gpu is not None:
        logging.info('Taking gpu %i', gpu)
    configure_session(gpu=gpu,
                      intra_threads=args.intra_threads,
                      inter_threads=args.inter_threads,
                      kmp_blocktime=args.kmp_blocktime,
                      kmp_affinity=args.kmp_affinity,
                      omp_num_threads=args.omp_num_threads)

    # Mixed precision
    if args.amp:
        logging.info('Enabling mixed float16 precision')
        tf.keras.mixed_precision.set_global_policy('mixed_float16')

    # Start MLPerf logging
    if dist.rank == 0 and args.mlperf:
        log_submission_info(**config.get('mlperf', {}))
        mllogger.end(key=mllog.constants.INIT_STOP)
        mllogger.start(key=mllog.constants.RUN_START)

    # Load the data
    data_config = config['data']
    if dist.rank == 0:
        logging.info('Loading data')
    datasets = get_datasets(dist=dist, **data_config)
    logging.debug('Datasets: %s', datasets)

    # Construct or reload the model
    if dist.rank == 0:
        logging.info('Building the model')
    train_config = config['train']
#    initial_epoch = 0
    initial_epochs = [0]
    checkpoint_format = os.path.join(config['output_dir'], 'checkpoint-{epoch:03d}.h5')
    if args.resume and os.path.exists(checkpoint_format.format(epoch=1)):
        # Reload model from last checkpoint
        initial_epochs[0], model = reload_last_checkpoint(
            checkpoint_format, data_config['n_epochs'],
            distributed=args.distributed)
    else:
        # Build a new model
        model = get_model(**config['model'])
        # Configure the optimizer
        opt = get_optimizer(distributed=args.distributed,
                            **config['optimizer'])
        # Compile the model
        model.compile(optimizer=opt, loss=train_config['loss'],
                      metrics=train_config['metrics'])
#        model.compile(optimizer=opt, loss=train_config['loss'],
#                      metrics=[tf.keras.metrics.MeanAbsoluteError()])


    ####################### Modified codes for Elastic Keras
    def on_state_reset(): 
        tf.keras.backend.set_value(model.optimizer.lr, model.optimizer.lr * hvd.size())

    state = hvd.elastic.KerasState(model, batch=global_batch_size, epoch=initial_epochs[0])
    state.register_reset_callbacks([on_state_reset])


    if dist.rank == 0:
        model.summary()

    # Save configuration to output directory
    if dist.rank == 0:
        config['n_ranks'] = dist.size
        save_config(config)

    # Prepare the callbacks
    if dist.rank == 0:
        logging.info('Preparing callbacks')
    
	# sy: add - List of nodes
    nodes = ["gpu33", "gpu38"]
    ####################### Modified codes for Elastic Keras
    # callbacks = []
    callbacks = [
        hvd.callbacks.BroadcastGlobalVariablesCallback(0),
        hvd.callbacks.MetricAverageCallback(),
        hvd.elastic.CommitStateCallback(state),
        hvd.elastic.UpdateBatchStateCallback(state),
        hvd.elastic.UpdateEpochStateCallback(state),
		KillProcessesCallback(epochs_to_kill=args.epochs_to_kill, kill_times=args.kill_times, nodes=nodes, initial_epochs=initial_epochs), # sy: add
        TimeLogCallback() # yc: add
    ]

#    if args.distributed:
        # Broadcast initial variable states from rank 0 to all processes.
#        callbacks.append(hvd.callbacks.BroadcastGlobalVariablesCallback(0))
        # Average metrics across workers
#        callbacks.append(hvd.callbacks.MetricAverageCallback())

    # Learning rate decay schedule
    if 'lr_schedule' in config:
        global_batch_size = data_config['batch_size'] * dist.size
        callbacks.append(tf.keras.callbacks.LearningRateScheduler(
            get_lr_schedule(global_batch_size=global_batch_size,
                            **config['lr_schedule'])))

    # Timing
    timing_callback = TimingCallback()
    callbacks.append(timing_callback)

    # Checkpointing and logging from rank 0 only
    if dist.rank == 0:
#        callbacks.append(tf.keras.callbacks.ModelCheckpoint(checkpoint_format))
        callbacks.append(tf.keras.callbacks.CSVLogger(
            os.path.join(config['output_dir'], 'history.csv'), append=args.resume))
        if args.tensorboard:
            callbacks.append(tf.keras.callbacks.TensorBoard(
                os.path.join(config['output_dir'], 'tensorboard')))
        if args.mlperf:
            callbacks.append(MLPerfLoggingCallback())
        if args.wandb:
            callbacks.append(wandb.keras.WandbCallback())

    # Early stopping
    patience = train_config.get('early_stopping_patience', None)
    if patience is not None:
        callbacks.append(tf.keras.callbacks.EarlyStopping(
            monitor='val_loss', min_delta=1e-5, patience=patience, verbose=1))

    # Stopping at specified target
    target_mae = train_config.get('target_mae', None)
    callbacks.append(StopAtTargetCallback(target_max=target_mae))

    if dist.rank == 0:
        logging.debug('Callbacks: %s', callbacks)
    # Train the model
    if dist.rank == 0:
        logging.info('Beginning training')
    fit_verbose = 1 if (args.verbose and dist.rank==0) else 2

	# sy: add
#    if dist.rank == 0:
#        monitor_thread = threading.Thread(target=monitor_memory_usage, args=(job_id, 2))
#        monitor_thread.start()

    ###################### Modified code for Elastic Keras
    train_start_time = time.time()
    @hvd.elastic.run 
    def train(state): 
        model.fit(datasets['train_dataset'],
            steps_per_epoch=datasets['n_train_steps'],
            epochs=data_config['n_epochs'],
            validation_data=datasets['valid_dataset'],
            validation_steps=datasets['n_valid_steps'],
            callbacks=callbacks,
            initial_epoch=initial_epochs[0],
            verbose=fit_verbose)
    train(state)
    train_end_time = time.time()

    # model.fit(datasets['train_dataset'],
    #           steps_per_epoch=datasets['n_train_steps'],
    #           epochs=data_config['n_epochs'],
    #           validation_data=datasets['valid_dataset'],
    #           validation_steps=datasets['n_valid_steps'],
    #           callbacks=callbacks,
    #           initial_epoch=initial_epoch,
    #           verbose=fit_verbose)

    state.sync()

    if dist.rank == 0:
        training_completed = True
        print(f"[None][None][None][None][None][TrainStart][None][None][{train_start_time}")
        print(f"[None][None][None][None][None][TrainEnd][None][None][{train_end_time}")

        #[string:filepath][string: request][int: flag][int: client rank][int: server rank][string: expn][int: epoch #][int: batch #][gettimeofday: Clocktime]
        # print(f"[None][None][None][None][None][E2E][None][None][{train_end_time - train_start_time}")
#        monitor_thread.join()
    # Stop MLPerf timer
    if dist.rank == 0 and args.mlperf:
        mllogger.end(key=mllog.constants.RUN_STOP, metadata={'status': 'success'})

    # Print training summary
    if dist.rank == 0:
        print_training_summary(config['output_dir'], args.print_fom)

    # Print GPU memory
    #if gpu is not None:
    #    gpu_mem_info = tf.config.experimental.get_memory_info(f'GPU:{gpu}')
    #    logging.info('Peak GPU memory: %.2f GB', gpu_mem_info['peak'] / 1024 / 1024 / 1024)

    # Finalize
    if dist.rank == 0:
        logging.info('All done!')


if __name__ == '__main__':
	print("main")
	main()
