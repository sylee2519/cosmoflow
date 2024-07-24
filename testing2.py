import os
import hashlib
import horovod.tensorflow as hvd

def hash_file_path(file_path):
    """Hash the file path to a number."""
    hasher = hashlib.sha256()
    hasher.update(file_path.encode('utf-8'))
    return int(hasher.hexdigest(), 16)

def read_file(file_path):
    """Read file content."""
    try:
        with open(file_path, 'rb') as f:
            while True:
                data = f.read(4096)  # Read in chunks of 4096 bytes
                if not data:
                    break
                # Process data here if necessary
    except IOError as e:
        print(f"Error reading file {file_path}: {e}")

def process_files(directory, rank, size):
    """Process files in the directory."""
    for root, _, files in os.walk(directory):
        for file_name in files:
            file_path = os.path.join(root, file_name)
            file_hash = hash_file_path(file_path)
            if file_hash % size == rank:
                read_file(file_path)

def main():
    # Initialize Horovod
    hvd.init()

    # Get the rank and size
    rank = hvd.rank()
    size = hvd.size()

    # Directory to read files from
    directory = '/scratch/s5104a21/cosmoflow/cosmo/cosmoUniverse_2019_05_4parE_tf_v2'


    # Process files
    process_files(directory, rank, size)

if __name__ == "__main__":
    main()

