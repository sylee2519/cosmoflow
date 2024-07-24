import binascii
import difflib
import sys

def read_file_as_hex(file_path):
    with open(file_path, 'rb') as f:
        content = f.read()
        return binascii.hexlify(content).decode('utf-8')

def highlight_differences(hex1, hex2):
    diff = difflib.ndiff(hex1, hex2)
    result = []
    for char in diff:
        if char.startswith(' '):  # No difference
            result.append(char[2])
        elif char.startswith('-'):  # Character in hex1 but not in hex2
            result.append(f"\033[91m{char[2]}\033[0m")  # Red color for deletion
        elif char.startswith('+'):  # Character in hex2 but not in hex1
            result.append(f"\033[92m{char[2]}\033[0m")  # Green color for addition
    return ''.join(result)

def compare_files(file1, file2):
    hex1 = read_file_as_hex(file1)
    hex2 = read_file_as_hex(file2)
    
    print("Differences (Red: in file1 but not in file2, Green: in file2 but not in file1):")
    print(highlight_differences(hex1, hex2))

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python compare_hex_files.py <file1> <file2>")
        sys.exit(1)

    file1 = sys.argv[1]
    file2 = sys.argv[2]

    compare_files(file1, file2)

