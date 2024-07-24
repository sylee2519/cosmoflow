import os
import re
import sys
import difflib

def highlight_differences(remote_buffer, real_buffer):
    diff = difflib.ndiff(remote_buffer, real_buffer)
    result = []
    for char in diff:
        if char.startswith(' '):  # No difference
            result.append(char[2])
        elif char.startswith('-'):  # Character in remote_buffer but not in real_buffer
            result.append(f"\033[91m{char[2]}\033[0m")  # Red color for deletion
        elif char.startswith('+'):  # Character in real_buffer but not in remote_buffer
            result.append(f"\033[92m{char[2]}\033[0m")  # Green color for addition
    return ''.join(result)

def parse_log_file(file_path):
    discrepancies = []
    with open(file_path, 'r') as file:
        lines = file.readlines()
        remote_buffer = None
        real_buffer = None
        remote_line_num = None
        for i, line in enumerate(lines):
            if "Buffer content after remote read:" in line:
                remote_buffer = re.search(r'Buffer content after remote read: ([0-9A-F]+)', line).group(1)
                remote_line_num = i + 1  # Store the line number
            elif "Buffer content after real read:" in line:
                real_buffer = re.search(r'Buffer content after real read: ([0-9A-F]+)', line).group(1)
                if remote_buffer and real_buffer and remote_buffer != real_buffer:
                    diff_result = highlight_differences(remote_buffer, real_buffer)
                    discrepancies.append((file_path, remote_line_num, i + 1, diff_result))
                remote_buffer = None
                real_buffer = None
    return discrepancies

def process_log_files(directory, pattern):
    discrepancy_count = 0
    discrepancy_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if pattern in file:
                file_path = os.path.join(root, file)
                discrepancies = parse_log_file(file_path)
                if discrepancies:
                    discrepancy_count += 1
                    discrepancy_files.extend(discrepancies)
    return discrepancy_count, discrepancy_files

def main(directory, pattern):
    discrepancy_count, discrepancy_files = process_log_files(directory, pattern)
    print(f"Total discrepancies found: {discrepancy_count}")
    if discrepancy_count > 0:
        print("Files with discrepancies and their line numbers:")
        for file, remote_line_num, real_line_num, diff_result in discrepancy_files:
            print(f"File: {file}, Remote read line: {remote_line_num}, Real read line: {real_line_num}")
            print("Differences:")
            print(diff_result)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python compare_buffers.py <directory> <pattern>")
        sys.exit(1)

    directory = sys.argv[1]
    pattern = sys.argv[2]
    main(directory, pattern)

