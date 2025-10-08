#!/usr/bin/env bash
# orchestrate execute - Execute approved plan with subagents
# Version: 2.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/github.sh"
source "$SCRIPT_DIR/../lib/claude.sh"
source "$SCRIPT_DIR/../lib/state.sh"

main() {
    local orch_id=$(state_get_current_id)
    local state=$(state_load "$orch_id")

    log "Executing orchestration: $orch_id"
    echo

    # Check if already executed
    local status=$(echo "$state" | jq -r '.status')
    if [[ "$status" == "executing" ]]; then
        warn "Orchestration already executing"
        exit 0
    fi

    # Update status
    state=$(echo "$state" | jq '.status = "executing"')
    state_save "$orch_id" "$state"

    # Get pending tasks
    local pending_tasks=$(echo "$state" | jq -c '.tasks[] | select(.status == "pending")')
    local task_count=$(echo "$pending_tasks" | wc -l | tr -d ' ')

    if [[ "$task_count" -eq 0 ]]; then
        warn "No pending tasks to execute"
        exit 0
    fi

    info "Spawning $task_count subagent(s)..."
    echo

    # Spawn subagent for each pending task
    while IFS= read -r task; do
        local issue=$(echo "$task" | jq -r '.issue_number')
        local role=$(echo "$task" | jq -r '.agent_role')
        local title=$(echo "$task" | jq -r '.title')

        log "Spawning subagent for issue #$issue ($role)..."

        # Get full task description from GitHub
        local task_desc=$(gh issue view "$issue" --json body -q .body)

        # Spawn subagent
        local state_file=$(claude_spawn_subagent "$issue" "$role" "$task_desc")

        success "Spawned subagent for issue #$issue"
        echo "  State file: $state_file"
        echo "  Role: $role"
        echo "  Title: $title"
        echo

        # Update task status in state
        state=$(echo "$state" | jq \
            ".tasks = [.tasks[] | if .issue_number == $issue then .status = \"spawned\" else . end]")

    done <<< "$pending_tasks"

    # Save updated state
    state_save "$orch_id" "$state"

    echo
    success "All subagents spawned!"
    echo
    cat <<EOF
${CYAN}════════════════════════════════════════════════════════════════${NC}
${YELLOW}📝 IMPORTANT NOTE${NC}

This is a demonstration implementation. In a production version:

1. ${PURPLE}Real Claude Code processes would be spawned${NC}
   - Each would run: claude code --prompt "..."
   - Each bound to specific GitHub issue
   - Each working in isolated directory

2. ${PURPLE}Processes would run truly in parallel${NC}
   - Independent Claude Code instances
   - Coordinated via GitHub Issues
   - State synced via files + GitHub API

3. ${PURPLE}Main orchestrator would monitor progress${NC}
   - Poll GitHub issues for updates
   - Check subagent health
   - Handle failures and retry

${YELLOW}Current Implementation:${NC}
- Created state files for each subagent
- Logged spawn attempts
- Ready for manual subagent work

${YELLOW}Next Steps (Manual for now):${NC}
1. Manually work on each GitHub issue
2. Update issue status/comments as you go
3. Run: orchestrate status (to check progress)
4. Run: orchestrate integrate (when all complete)

${CYAN}════════════════════════════════════════════════════════════════${NC}
EOF

    echo
    info "Monitor progress:"
    echo "  orchestrate status"
    echo "  gh issue list --label \"subagent-task\""
    echo
}

main "$@"
