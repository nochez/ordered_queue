#!/bin/bash
source “queue_lib.sh"

PRIORITY=10
TIMESTAMP=$(date +%s%N)
PID="$$"

register "$PRIORITY"
wait_turn "$PRIORITY" "$TIMESTAMP" "$PID"
start_exe "$PRIORITY" "$TIMESTAMP" "$PID"

sleep 10  # Here should do some work

finish_exe

