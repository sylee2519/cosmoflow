import json
import os

def extract_data(input_filename, output_filename):
    with open(input_filename, 'r') as file:
        data = file.readlines()

    configurations = {}
    results = []

    for line in data:
        try:
            json_data = json.loads(line.strip())
        except json.JSONDecodeError:
            continue

        if 'nodes' in json_data:
            # This line is a configuration
            config_key = (json_data['nodes'], json_data['gpus'], json_data['ntasks'], json_data['batch_size'], json_data['prefetch'])
            if config_key not in configurations:
                configurations[config_key] = True  # Mark this configuration as seen
        elif any(key.isdigit() for key in json_data.keys()):
            # This line is a result and follows a configuration
            max_memory_usage = json_data[next(iter(json_data))]['max_memory_usage']
            last_config = list(configurations)[-1] if configurations else None
            if last_config:
                results.append(last_config + (max_memory_usage,))
    
    file_exists = os.path.isfile(output_filename) and os.path.getsize(output_filename) > 0
    mode = 'a' if file_exists else 'w'
    # Save results to CSV
    with open(output_filename, mode) as out_file:
#        out_file.write('nodes,gpus,ntasks,batch_size,prefetch,max_memory_usage\n')
        for result in results:
            out_file.write(','.join(map(str, result)) + '\n')

# Usage
extract_data('memory_prev.json', 'memory_data.csv')

