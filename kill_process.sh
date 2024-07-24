#!/bin/bash

NODE=$1

# Check if node is provided
if [ -z "$NODE" ]; then
  echo "Usage: $0 <node>"
  exit 1
fi

echo "Connecting to node $NODE and killing processes matching hvac_server, python, or horovodrun..."

pkill -f hvac_server; pkill -f python; pkill -f horovodrun

echo "Processes killed on node $NODE."

