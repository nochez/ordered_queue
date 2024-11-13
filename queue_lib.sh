QUEUE_FILE="/tmp/exec_queue"
QUEUE_LOCK="/tmp/exec_queue.lock"
EXEC_LOCK="/tmp/exec_lock"

register() {
  local priority="$1"
  local timestamp=$(date +%s%N)
  local pid="$$"

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

  # Sort queue and see if we are first
  while true; do
    (
      flock -s 200
      local first_entry=$(sort -k1,1n -k2,2n "$QUEUE_FILE" | head -n1)
    ) 200>"$QUEUE_LOCK"

    if [[ "$first_entry" == "$priority $timestamp $pid" ]]; then
      break
    else
      sleep 5
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

