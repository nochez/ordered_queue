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
    # Find dirs
    local directories=$(find "$QUEUE_DIR" -mindepth 1 -maxdepth 1 -type d)
    debug_echo "Directories: $directories"

    # Read task_info files
    local task_infos=""
    for dir in $directories; do
      if [[ -f "$dir/task_info" ]]; then
        local info=$(cat "$dir/task_info")
        task_infos+="$info"$'\n'
      else
        debug_echo "No task_info found in directory: $dir"
      fi
    done
    debug_echo "Collected task_infos before sorting:\n$task_infos"

    # Remove empty lines (this fixes a bug)
    local filtered_task_infos=$(echo -e "$task_infos" | grep -v '^$')
    debug_echo "Filtered (no empty lines) task_infos:\n$filtered_task_infos"

    # Sort
    local sorted_task_infos=$(echo -e "$filtered_task_infos" | sort -k1,1n -k2,2n)
    debug_echo "Sorted task_infos:\n$sorted_task_infos"

    # High priority task
    local first_task=$(echo "$sorted_task_infos" | head -n 1)
    debug_echo "First task info: $first_task"

    debug_echo "Checking if current task is first in queue..."
    debug_echo "Expected entry: '$priority $timestamp $pid'"
    debug_echo "First entry in queue: '$first_task'"

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
  rm -rf "$QUEUE_DIR/$3"

  flock -u 300
  exec 300>&-
}
