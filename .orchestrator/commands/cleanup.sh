#!/usr/bin/env bash
# orchestrate cleanup - Archive completed orchestration
# Version: 2.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/github.sh"
source "$SCRIPT_DIR/../lib/state.sh"

main() {
    local orch_id=$(state_get_current_id)
    local state=$(state_load "$orch_id")

    log "Cleaning up orchestration: $orch_id"
    echo

    local status=$(echo "$state" | jq -r '.status')

    if [[ "$status" != "integrated" ]]; then
        warn "Orchestration status: $status (not integrated)"
        if ! confirm "Cleanup anyway?"; then
            exit 0
        fi
    fi

    # Show summary
    local task_desc=$(echo "$state" | jq -r '.task_description')
    local created_at=$(echo "$state" | jq -r '.created_at')
    local summary=$(state_get_status "$orch_id")
    local total=$(echo "$summary" | jq -r '.total_tasks')
    local completed=$(echo "$summary" | jq -r '.completed')

    echo -e "${YELLOW}Orchestration Summary:${NC}"
    echo "  ID: $orch_id"
    echo "  Task: $task_desc"
    echo "  Created: $created_at"
    echo "  Tasks: $completed/$total completed"
    echo ""

    if ! confirm "Archive this orchestration?" "y"; then
        warn "Cleanup cancelled"
        exit 0
    fi

    # Close all related GitHub issues
    info "Closing GitHub issues..."

    local tasks=$(echo "$state" | jq -c '.tasks[]')
    while IFS= read -r task; do
        local issue=$(echo "$task" | jq -r '.issue_number')
        local title=$(echo "$task" | jq -r '.title')

        gh_close_issue "$issue" "Orchestration complete. Archived: $orch_id"
        success "Closed issue #$issue: $title"
    done <<< "$tasks"

    # Close integration issue if exists
    local integration_issue=$(echo "$state" | jq -r '.integration_issue // empty')
    if [[ -n "$integration_issue" ]]; then
        gh_close_issue "$integration_issue" "Orchestration archived: $orch_id"
        success "Closed integration issue #$integration_issue"
    fi

    # Stop any running subagents
    info "Stopping subagents..."
    for state_file in .orchestrator/state/subagent-*.state; do
        if [[ -f "$state_file" ]]; then
            claude_stop_subagent "$state_file" || true
        fi
    done

    # Archive state
    state_archive "$orch_id"

    # Clear current orchestration
    state_clear_current

    # Release lock if held
    state_release_lock || true

    echo
    success "Orchestration archived successfully!"
    echo
    info "Archive location: .orchestrator/archive/$(date +%Y-%m)/$orch_id.json"
    info "You can start a new orchestration with: orchestrate plan \"...\""
    echo
}

main "$@"
