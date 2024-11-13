QUEUE_FILE="/tmp/exec_queue"
QUEUE_LOCK="/tmp/exec_queue.lock"
EXEC_LOCK="/tmp/exec_lock"

# Debug messages only if DEBUG_MODE is on
debug_echo() {
  if [[ "$DEBUG_MODE" == "true" ]]; then
    echo "$@"
  fi
}

register() {
  local priority="$1"
  local timestamp="$2"
  local pid="$3"

  # Atomic write into queue
  (
    flock -x 200
    echo "$priority $timestamp $pid" >> "$QUEUE_FILE"
  ) 200>"$QUEUE_LOCK"
}

wait_turn() {
  local priority="$1"
  local timestamp="$2"
  local pid="$3"

  while true; do
    local first_entry=$(
      (
        flock -s 200
        sort -k1,1n -k2,2n "$QUEUE_FILE" | head -n1
      ) 200>"$QUEUE_LOCK"
    )

    # Debug output
    debug_echo "Checking if current task is first in queue..."
    debug_echo "Expected entry: '$priority $timestamp $pid'"
    debug_echo "First entry in queue: '$first_entry'"

    if [[ "$first_entry" == "$priority $timestamp $pid" ]]; then
      debug_echo "This task is first in the queue. Proceeding..."
      break
    else
      debug_echo "."
      sleep 3
    fi
  done
}

start_exe() {
  # extra lock for critical path
  exec 300>"$EXEC_LOCK"
  flock -x 300
}

finish_exe() {
  # Finished and remove itself from queue
  (
    flock -x 200
    sed -i "/^$1 $2 $3$/d" "$QUEUE_FILE"
  ) 200>"$QUEUE_LOCK"

  flock -u 300
  exec 300>&-
}

