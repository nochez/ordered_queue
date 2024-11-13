#!/bin/bash
source "queue_lib.sh"

# Ensure priority and task name are provided as arguments
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <priority> <task_name>"
  exit 1
fi

# Get priority and task name from command-line arguments
PRIORITY="$1"
TASK_NAME="$2"
TIMESTAMP=$(date +%s%N)
PID="$$"

register "$PRIORITY" "$TIMESTAMP" "$PID"
echo "Task '$TASK_NAME' : $PRIORITY @ registered."

wait_turn "$PRIORITY" "$TIMESTAMP" "$PID"
echo "Task '$TASK_NAME' : $PRIORITY @ now executing."



start_exe "$PRIORITY" "$TIMESTAMP" "$PID"
echo "Task '$TASK_NAME' : $PRIORITY @ critical section."

sleep 3  # work work work

finish_exe "$PRIORITY" "$TIMESTAMP" "$PID"
echo "Task '$TASK_NAME' : $PRIORITY @ finished execution."


