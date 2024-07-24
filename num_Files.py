import os
import sys

def count_sentences_in_file(file_path, search_string):
    with open(file_path, 'r') as file:
        content = file.read()
    
    # Split content into sentences (naive approach)
    sentences = content.split('.')
    
    # Count sentences containing the search string
    count = sum(1 for sentence in sentences if search_string in sentence)
    return count

def find_files_in_directory(directory, file_string):
    matching_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file_string in file:
                matching_files.append(os.path.join(root, file))
    return matching_files

def main(directory, file_string, search_string):
    matching_files = find_files_in_directory(directory, file_string)
    if not matching_files:
        print(f"No files found containing '{file_string}' in the directory '{directory}'")
        return
    
    for file_path in matching_files:
        count = count_sentences_in_file(file_path, search_string)
        print(f"File: {file_path} -> Sentences containing '{search_string}': {count}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <directory> <file_string> <search_string>")
        sys.exit(1)
    
    directory = sys.argv[1]
    file_string = sys.argv[2]
    search_string = sys.argv[3]

    main(directory, file_string, search_string)

