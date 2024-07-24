#!/bin/bash

NODE=$1

# Check if node is provided
if [ -z "$NODE" ]; then
  echo "Usage: $0 <node>"
  exit 1
fi

echo "Connecting to node $NODE to find and kill processes matching hvac_server, python, or horovodrun..."

ssh $NODE << 'EOF'
cd /scratch/s5104a21
PATTERNS=("python" "horovodrun")

for PATTERN in "${PATTERNS[@]}"; do
  PIDS=$(pgrep -f $PATTERN)
  if [ -n "$PIDS" ]; then
    echo "Killing processes matching pattern '$PATTERN' with PIDs: $PIDS"
    kill -9 $PIDS
  else
    echo "No processes found matching pattern '$PATTERN'"
  fi
done
EOF

echo "Process killing complete on node $NODE."

