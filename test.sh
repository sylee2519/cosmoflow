#!/bin/bash

while true; do
    sleep 1  # Check every 1 sec
    ps -u $USER -o pid,rss,command | awk '{print $0; total+=$2} END {print "Total memory usage: " total " KB"}'
done &
