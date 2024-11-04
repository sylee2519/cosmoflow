#!/bin/bash

# Replace <job_id> with your actual job ID
job_id=303829

# Get the total memory allocated to the job
allocated_memory=$(sacct -j $job_id --format=AllocMem --noheader | tr -d ' ')

# Infinite loop to monitor memory usage
while true; do
    clear
    echo "Total Memory Allocated to Job $job_id: $allocated_memory"
    echo "Current Memory Usage by User $USER's Processes:"
    ps -u $USER -o pid,rss,comm | awk '
    BEGIN { print "PID\tRSS(KB)\tCOMMAND"; total=0; }
    { print $1 "\t" $2 "\t" $3; total += $2 }
    END { print "Total memory usage: " total " KB"; print "-----------------------------------"; }
    '
    sleep 1  # Check every 1 second
done

