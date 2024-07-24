import horovod.tensorflow as hvd
import tensorflow as tf

hvd.init()

# Print Horovod size (number of processes)
print("Horovod size:", hvd.size())

# Print TensorFlow version
print("TensorFlow version:", tf.__version__)

