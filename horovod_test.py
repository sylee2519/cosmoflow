import os
import horovod.tensorflow.keras as hvd
import tensorflow as tf

def check_gpus():
    gpus = tf.config.experimental.list_physical_devices('GPU')
    if not gpus:
        print("No GPUs detected. Exiting.")
        exit(1)
    print("Available GPUs:", gpus)

def main():
    hvd.init()
    check_gpus()
    print("Horovod rank:", hvd.rank())
    print("CUDA_VISIBLE_DEVICES:", os.getenv("CUDA_VISIBLE_DEVICES"))

if __name__ == "__main__":
    main()

