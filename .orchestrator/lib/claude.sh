#!/usr/bin/env bash
# Claude Code process management
# Version: 2.0

# Spawn Claude Code subagent process
claude_spawn_subagent() {
    local issue_number="$1"
    local agent_role="$2"
    local task_description="$3"
    local working_dir="${4:-.}"

    debug "Spawning Claude Code subagent for issue #$issue_number"

    # Create prompt for subagent
    local prompt=$(cat <<EOF
You are a specialized subagent: ${agent_role}

Your task is tracked in GitHub Issue #${issue_number}.

TASK DESCRIPTION:
${task_description}

INSTRUCTIONS:
1. Read the complete issue description: gh issue view ${issue_number}
2. Update status when you start: gh issue edit ${issue_number} --remove-label "status:pending" --add-label "status:in-progress"
3. Work on your assigned task
4. Document all decisions: gh issue comment ${issue_number} --body "## Decision: ... Reasoning: ..."
5. Post progress updates regularly
6. When complete: gh issue edit ${issue_number} --remove-label "status:in-progress" --add-label "status:completed"
7. Add completion report: gh issue comment ${issue_number} --body "## Completed ..."

WORKING DIRECTORY: ${working_dir}

START WORK:
Begin by reading the issue and updating its status, then proceed with the task.
EOF
)

    # Log the spawn
    log "Spawning subagent for issue #$issue_number (role: $agent_role)"

    # In a real implementation, this would spawn actual Claude Code process
    # For now, we'll create a marker file and log it
    local state_file=".orchestrator/state/subagent-${issue_number}.state"
    cat > "$state_file" <<EOF
{
  "issue_number": ${issue_number},
  "agent_role": "${agent_role}",
  "status": "spawned",
  "spawned_at": "$(timestamp)",
  "pid": $$,
  "working_dir": "${working_dir}"
}
EOF

    info "Subagent spawned for issue #$issue_number"
    info "In a real implementation, this would launch: claude code --prompt '...'"

    # Return state file path
    echo "$state_file"
}

# Check if Claude Code is available
claude_check_available() {
    if ! command -v claude &>/dev/null; then
        warn "Claude Code CLI not found in PATH"
        return 1
    fi
    return 0
}

# Monitor subagent health
claude_check_health() {
    local state_file="$1"

    if [[ ! -f "$state_file" ]]; then
        echo "not_found"
        return 1
    fi

    local pid=$(jq -r '.pid' "$state_file")

    if kill -0 "$pid" 2>/dev/null; then
        echo "running"
        return 0
    else
        echo "stopped"
        return 1
    fi
}

# Get subagent status
claude_get_status() {
    local state_file="$1"

    if [[ ! -f "$state_file" ]]; then
        echo "{}"
        return
    fi

    cat "$state_file"
}

# Stop subagent
claude_stop_subagent() {
    local state_file="$1"

    if [[ ! -f "$state_file" ]]; then
        warn "State file not found: $state_file"
        return 1
    fi

    local pid=$(jq -r '.pid' "$state_file")

    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null || true
        success "Stopped subagent (PID: $pid)"
    fi

    rm -f "$state_file"
}

# List all active subagents
claude_list_subagents() {
    local state_dir=".orchestrator/state"

    if [[ ! -d "$state_dir" ]]; then
        echo "[]"
        return
    fi

    local agents="[]"
    for state_file in "$state_dir"/subagent-*.state; do
        if [[ -f "$state_file" ]]; then
            local status=$(cat "$state_file")
            agents=$(echo "$agents" | jq ". += [$status]")
        fi
    done

    echo "$agents"
}
