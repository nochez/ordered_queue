QUEUE_DIR="/tmp/exec_queue"
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


  mkdir -p $QUEUE_DIR/$pid
  echo "$priority $timestamp $pid" > "$QUEUE_DIR/$pid/task_info"
}

wait_turn() {
  local priority="$1"
  local timestamp="$2"
  local pid="$3"

  while true; do
    local first_task=$(find "$QUEUE_DIR" -type d -exec bash -c 'cat "$0/task_info"' {} \; | sort -k1,1n -k2,2n | head -n 1)

    debug_echo "Checking if current task is first in queue..."
    debug_echo "Expected entry: '$priority $timestamp $pid'"
    debug_echo "First entry in queue: '$first_task'"

    # Check if the current task matches the first sorted task entry
    if [[ "$first_task" == "$priority $timestamp $pid" ]]; then
      debug_echo "This task is first in the queue. Proceeding..."
      break
    else
      debug_echo "."
      sleep 3
    fi
  done
}

start_exe() {
  # Critical path
  exec 300>"$EXEC_LOCK"
  flock -x 300
}

finish_exe() {
  rm -rf "$QUEUE_DIR/$1"

  flock -u 300
  exec 300>&-
}
