#!/bin/bash

# Replace this with the PID of the process you want to monitor
PID_TO_MONITOR=26069

# Check if the process is running and monitor its memory usage
while true; do
    if ps -p $PID_TO_MONITOR > /dev/null
    then
        echo "$(date) - Checking memory usage for PID: $PID_TO_MONITOR"
        ps -p $PID_TO_MONITOR -o pid,%mem,rss,vsz,cmd
    else
        echo "$(date) - Process $PID_TO_MONITOR not found. Exiting."
        break
    fi
    sleep 3  # Sleep for 60 seconds before checking again
done

