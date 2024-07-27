#!/bin/bash

NODE=$1

# Remember the current working directory
initial_pwd=$(pwd)

#echo "Finding and killing processes matching hvac_server, python, or horovodrun..."

if [ -n "$NODE" ]; then
  echo "Connecting to node $NODE..."
  ssh $NODE << 'EOF'
    cd $initial_pwd # Modify this to your scratch dir
    PATTERNS=("hvac_server" "python" "horovodrun")

    for PATTERN in "${PATTERNS[@]}"; do
      PIDS=$(pgrep -f $PATTERN)
      if [ -n "$PIDS" ]; then
#        echo "Killing processes matching pattern '$PATTERN' with PIDs: $PIDS"
        kill -9 $PIDS
#      else
#        echo "No processes found matching pattern '$PATTERN'"
      fi
    done
EOF
#  echo "Process killing complete on node $NODE."
else
#  echo "No node provided, performing process killing on the local machine..."
  PATTERNS=("hvac_server" "python" "horovodrun" "srun")

  for PATTERN in "${PATTERNS[@]}"; do
    PIDS=$(pgrep -f $PATTERN)
    if [ -n "$PIDS" ]; then
#      echo "Killing processes matching pattern '$PATTERN' with PIDs: $PIDS"
      kill -9 $PIDS
#    else
#      echo "No processes found matching pattern '$PATTERN'"
    fi
  done
#  echo "Process killing complete on the local machine."
fi

