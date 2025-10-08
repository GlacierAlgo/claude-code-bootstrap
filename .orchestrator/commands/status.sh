#!/usr/bin/env bash
# orchestrate status - Show current orchestration status
# Version: 2.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/github.sh"
source "$SCRIPT_DIR/../lib/state.sh"

main() {
    local orch_id=$(state_get_current_id)
    local state=$(state_load "$orch_id")

    log "Orchestration Status: $orch_id"
    echo

    # Get status summary
    local status_summary=$(state_get_status "$orch_id")
    local total=$(echo "$status_summary" | jq -r '.total_tasks')
    local completed=$(echo "$status_summary" | jq -r '.completed')
    local in_progress=$(echo "$status_summary" | jq -r '.in_progress')
    local pending=$(echo "$status_summary" | jq -r '.pending')
    local blocked=$(echo "$status_summary" | jq -r '.blocked')
    local progress=$(echo "$status_summary" | jq -r '.progress_percent')

    # Show progress bar
    local bar_width=50
    local filled=$((progress * bar_width / 100))
    local empty=$((bar_width - filled))

    echo -ne "${CYAN}Progress: ${NC}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    echo -e "] ${progress}%"
    echo

    # Show summary
    echo -e "${YELLOW}Summary:${NC}"
    echo "  Total Tasks:    $total"
    echo "  ✅ Completed:   $completed"
    echo "  🔄 In Progress: $in_progress"
    echo "  ⏳ Pending:     $pending"
    echo "  🚫 Blocked:     $blocked"
    echo ""

    # Show each task
    echo -e "${YELLOW}Tasks:${NC}"
    local tasks=$(echo "$state" | jq -c '.tasks[]')
    while IFS= read -r task; do
        local issue=$(echo "$task" | jq -r '.issue_number')
        local title=$(echo "$task" | jq -r '.title')
        local status=$(echo "$task" | jq -r '.status')
        local role=$(echo "$task" | jq -r '.agent_role')

        case "$status" in
            completed)
                local icon="✅"
                local color="$GREEN"
                ;;
            in_progress)
                local icon="🔄"
                local color="$BLUE"
                ;;
            blocked)
                local icon="🚫"
                local color="$RED"
                ;;
            *)
                local icon="⏳"
                local color="$YELLOW"
                ;;
        esac

        echo -e "  ${icon} ${color}#${issue}${NC}: $title (${role})"
    done <<< "$tasks"

    echo
    info "View details: gh issue list --label \"subagent-task\""
    echo
}

main "$@"
