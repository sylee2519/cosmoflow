import re
import csv

# Initialize lists to store times and counters for storage and NVMe operations
storage_pread_times = []
storage_open_times = []
storage_close_times = []
storage_open_count = 0
storage_pread_count = 0

nvme_pread_times = []
nvme_open_times = []
nvme_close_times = []
nvme_open_count = 0
nvme_pread_count = 0

# Flags to identify the current operation mode
is_nvme = False

# Regular expression to match operation lines
operation_pattern = re.compile(r'(pread|read|open|close) (\d+)ns')

# Read the log file and process the lines
with open('operation_times_0.log', 'r') as file:
    for line in file:
        if 'redirect' in line:
            is_nvme = True
        else:
            match = operation_pattern.match(line)
            if match:
                operation, time_ns = match.groups()
                time_ns = int(time_ns)
                if is_nvme:
                    if operation in ('pread', 'read'):
                        nvme_pread_times.append(time_ns)
                        nvme_pread_count += 1
                    elif operation == 'open':
                        nvme_open_times.append(time_ns)
                        nvme_open_count += 1
                    elif operation == 'close':
                        nvme_close_times.append(time_ns)
                else:
                    if operation in ('pread', 'read'):
                        storage_pread_times.append(time_ns)
                        storage_pread_count += 1
                    elif operation == 'open':
                        storage_open_times.append(time_ns)
                        storage_open_count += 1
                    elif operation == 'close':
                        storage_close_times.append(time_ns)

# Function to calculate average
def calculate_average(times):
    return sum(times) / len(times) if times else 0

# Calculate averages and totals for storage operations
storage_avg_pread = calculate_average(storage_pread_times)
storage_avg_open = calculate_average(storage_open_times)
storage_avg_close = calculate_average(storage_close_times)
storage_total = sum(storage_pread_times) + sum(storage_open_times) + sum(storage_close_times)

# Calculate averages and totals for NVMe operations
nvme_avg_pread = calculate_average(nvme_pread_times)
nvme_avg_open = calculate_average(nvme_open_times)
nvme_avg_close = calculate_average(nvme_close_times)
nvme_total = sum(nvme_pread_times) + sum(nvme_open_times) + sum(nvme_close_times)

# Write results to a CSV file
with open('operation_times_summary.csv', 'w', newline='') as csvfile:
    fieldnames = ['Type', 'Average Pread/Read (ns)', 'Average Open (ns)', 'Average Close (ns)', 'Total (ns)', 'Files Opened', 'Read/Pread Count']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    writer.writerow({'Type': 'Storage',
                     'Average Pread/Read (ns)': storage_avg_pread,
                     'Average Open (ns)': storage_avg_open,
                     'Average Close (ns)': storage_avg_close,
                     'Total (ns)': storage_total,
                     'Files Opened': storage_open_count,
                     'Read/Pread Count': storage_pread_count})
    writer.writerow({'Type': 'NVMe',
                     'Average Pread/Read (ns)': nvme_avg_pread,
                     'Average Open (ns)': nvme_avg_open,
                     'Average Close (ns)': nvme_avg_close,
                     'Total (ns)': nvme_total,
                     'Files Opened': nvme_open_count,
                     'Read/Pread Count': nvme_pread_count})

print("Summary CSV file has been created.")

