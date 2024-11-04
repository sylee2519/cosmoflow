import csv

def read_times_from_csv(file_path):
    """Read hash times from a CSV file and return a list of integers."""
    times = []
    with open(file_path, mode='r') as file:
        reader = csv.reader(file)
        next(reader)  # Skip the header row
        for row in reader:
            times.append(int(row[0]))
    return times

def calculate_average_and_total(times):
    """Calculate the average and total of a list of times."""
    total_time = sum(times)
    average_time = total_time / len(times)
    return average_time, total_time

def compare_times(times1, times2):
    """Compare the average and total times between two lists."""
    avg1, total1 = calculate_average_and_total(times1)
    avg2, total2 = calculate_average_and_total(times2)
    
    comparison = {
        'File 1': {'Average Time': avg1, 'Total Time': total1},
        'File 2': {'Average Time': avg2, 'Total Time': total2},
        'Difference': {
            'Average Time': abs(avg1 - avg2),
            'Total Time': abs(total1 - total2)
        }
    }
    return comparison

def print_comparison(comparison):
    """Print the comparison of average and total times."""
    print("Comparison of Hash Times:")
    for key, value in comparison.items():
        if key == 'Difference':
            print(f"\n{key}:")
        else:
            print(f"\n{key}:")
        for metric, time in value.items():
            print(f"  {metric}: {time:.2f} ns")

def main():
    file1 = 'hash_times.csv'
    file2 = 'hash_times_d.csv'
    
    times1 = read_times_from_csv(file1)
    times2 = read_times_from_csv(file2)
    
    comparison = compare_times(times1, times2)
    print_comparison(comparison)

if __name__ == '__main__':
    main()

