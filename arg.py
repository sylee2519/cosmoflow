import argparse
import json
import os

import logging

def parse_arguments():
    parser = argparse.ArgumentParser(description='Train a model on specified GPU settings.')
    parser.add_argument('--gpus', type=int, default=1, help='Number of GPUs total.')
    parser.add_argument('--nodes', type=int, default=1, help='Number of nodes.')
    parser.add_argument('--ntasks', type=int, default=1, help='Number of tasks in total.')
    parser.add_argument('--batch_size', type=int, default=4, help='Batch size for training.')
    parser.add_argument('--prefetch', type=int, default=4, help='Batch size for training.')
    args = parser.parse_args()
    return args


def append_to_json_file(data, filename='/scratch/s5104a21/cosmoflow/hpc/cosmoflow/memory_usage.json'):
    try:
        if not os.path.exists(filename):
            os.makedirs(os.path.dirname(filename), exist_ok=True)  # Ensure the directory exists
            with open(filename, 'w') as file:
                json.dump([], file)  # Create a new JSON file if it does not exist

        with open(filename, 'r+') as file:
            file_data = json.load(file)  # Load existing data
            file_data.append(data)       # Append new data
            file.seek(0)                 # Reset file pointer to the top
            file.truncate()              # Truncate the file in case new data is shorter
            json.dump(file_data, file, indent=4)  # Write updated data back to file
    except Exception as e:
        logging.error(f"Failed to append to JSON file: {e}")



def main():
    args = parse_arguments()

    config_data = {
        'nodes': args.nodes,
        'gpus': args.gpus,
        'ntasks': args.ntasks,
        'batch_size': args.batch_size,
        'prefetch': args.prefetch
    }
    with open("memory_usage.json", "a") as file:
        json.dump(config_data, file)
        file.write("\n")  # Add a newline for separation between entries
    with open("time.json", "a") as file:
        json.dump(config_data, file)
        file.write("\n")  # Add a newline for separation between entries

if __name__ == "__main__":
    main()

