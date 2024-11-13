#!/bin/bash
source “queue_lib.sh"

PRIORITY=10
TIMESTAMP=$(date +%s%N)
PID="$$"

register "$PRIORITY"
wait_turn "$PRIORITY" "$TIMESTAMP" "$PID"
start_exe "$PRIORITY" "$TIMESTAMP" "$PID"

echo "task A"
sleep 2  # Here we do some work

finish_exe

