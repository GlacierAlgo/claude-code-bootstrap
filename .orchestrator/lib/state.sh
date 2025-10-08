#!/usr/bin/env bash
# State management utilities
# Version: 2.0

# State directory
STATE_DIR=".orchestrator/state"
LOCK_FILE=".orchestrator/state/orchestration.lock"

# Create lock file
state_acquire_lock() {
    local timeout="${1:-300}" # 5 minutes default
    local waited=0

    ensure_dir "$STATE_DIR"

    while [[ -f "$LOCK_FILE" ]]; do
        if [[ $waited -ge $timeout ]]; then
            error "Failed to acquire lock after ${timeout}s. Another orchestration may be running.\nRun 'orchestrate cleanup' if you're sure no orchestration is active."
        fi

        warn "Waiting for lock... (${waited}s/${timeout}s)"
        sleep 5
        waited=$((waited + 5))
    done

    # Create lock file
    cat > "$LOCK_FILE" <<EOF
{
  "acquired_at": "$(timestamp)",
  "pid": $$,
  "user": "${USER:-unknown}",
  "hostname": "${HOSTNAME:-unknown}"
}
EOF

    debug "Lock acquired"
}

# Release lock file
state_release_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE"
        debug "Lock released"
    fi
}

# Save orchestration state
state_save() {
    local orchestration_id="$1"
    local state_data="$2"

    ensure_dir "$STATE_DIR"

    local state_file="$STATE_DIR/${orchestration_id}.json"
    safe_write "$state_file" "$state_data"

    debug "State saved: $state_file"
}

# Load orchestration state
state_load() {
    local orchestration_id="$1"
    local state_file="$STATE_DIR/${orchestration_id}.json"

    if [[ ! -f "$state_file" ]]; then
        error "Orchestration state not found: $orchestration_id"
    fi

    cat "$state_file"
}

# Get current orchestration ID
state_get_current_id() {
    local current_file="$STATE_DIR/current.txt"

    if [[ ! -f "$current_file" ]]; then
        error "No active orchestration found. Run 'orchestrate plan' first."
    fi

    cat "$current_file"
}

# Set current orchestration ID
state_set_current_id() {
    local orchestration_id="$1"
    local current_file="$STATE_DIR/current.txt"

    echo "$orchestration_id" > "$current_file"
    debug "Current orchestration: $orchestration_id"
}

# Clear current orchestration
state_clear_current() {
    local current_file="$STATE_DIR/current.txt"
    rm -f "$current_file"
    debug "Cleared current orchestration"
}

# List all orchestrations
state_list_all() {
    ensure_dir "$STATE_DIR"

    local orchestrations="[]"
    for state_file in "$STATE_DIR"/*.json; do
        if [[ -f "$state_file" ]]; then
            local state=$(cat "$state_file")
            orchestrations=$(echo "$orchestrations" | jq ". += [$state]")
        fi
    done

    echo "$orchestrations"
}

# Archive orchestration
state_archive() {
    local orchestration_id="$1"
    local archive_dir=".orchestrator/archive/$(date +%Y-%m)"

    ensure_dir "$archive_dir"

    local state_file="$STATE_DIR/${orchestration_id}.json"
    if [[ -f "$state_file" ]]; then
        mv "$state_file" "$archive_dir/"
        success "Archived: $orchestration_id"
    fi

    # Archive subagent states
    for subagent_state in "$STATE_DIR"/subagent-*.state; do
        if [[ -f "$subagent_state" ]]; then
            mv "$subagent_state" "$archive_dir/"
        fi
    done
}

# Clean up old archives
state_cleanup_old() {
    local days="${1:-30}"
    local archive_dir=".orchestrator/archive"

    if [[ ! -d "$archive_dir" ]]; then
        return
    fi

    find "$archive_dir" -type f -mtime "+$days" -delete
    find "$archive_dir" -type d -empty -delete

    success "Cleaned up archives older than $days days"
}

# Get orchestration status
state_get_status() {
    local orchestration_id="$1"
    local state=$(state_load "$orchestration_id")

    local total_tasks=$(echo "$state" | jq '.tasks | length')
    local completed=$(echo "$state" | jq '[.tasks[] | select(.status == "completed")] | length')
    local in_progress=$(echo "$state" | jq '[.tasks[] | select(.status == "in_progress")] | length')
    local pending=$(echo "$state" | jq '[.tasks[] | select(.status == "pending")] | length')
    local blocked=$(echo "$state" | jq '[.tasks[] | select(.status == "blocked")] | length')

    cat <<EOF
{
  "orchestration_id": "$orchestration_id",
  "total_tasks": $total_tasks,
  "completed": $completed,
  "in_progress": $in_progress,
  "pending": $pending,
  "blocked": $blocked,
  "progress_percent": $((completed * 100 / total_tasks))
}
EOF
}
