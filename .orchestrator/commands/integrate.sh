#!/usr/bin/env bash
# orchestrate integrate - Integrate subagent results
# Version: 2.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/github.sh"
source "$SCRIPT_DIR/../lib/state.sh"

main() {
    local orch_id=$(state_get_current_id)
    local state=$(state_load "$orch_id")

    log "Integrating results for orchestration: $orch_id"
    echo

    # Check all tasks are complete
    local incomplete=$(echo "$state" | jq '[.tasks[] | select(.status != "completed")] | length')

    if [[ "$incomplete" -gt 0 ]]; then
        warn "Not all tasks are completed ($incomplete remaining)"
        if ! confirm "Continue with integration anyway?"; then
            exit 0
        fi
    fi

    # Collect results from each GitHub issue
    info "Collecting results from GitHub issues..."
    echo

    local tasks=$(echo "$state" | jq -c '.tasks[]')
    local results=""

    while IFS= read -r task; do
        local issue=$(echo "$task" | jq -r '.issue_number')
        local title=$(echo "$task" | jq -r '.title')
        local role=$(echo "$task" | jq -r '.agent_role')

        info "Collecting from issue #$issue ($title)..."

        # Get issue details and comments
        local issue_data=$(gh_get_issue "$issue")
        local comments=$(echo "$issue_data" | jq -c '.comments[]')

        # Extract completion report if exists
        local completion_report=""
        while IFS= read -r comment; do
            local body=$(echo "$comment" | jq -r '.body')
            if echo "$body" | grep -q "## ✅.*Completed"; then
                completion_report="$body"
                break
            fi
        done <<< "$comments"

        if [[ -n "$completion_report" ]]; then
            success "Found completion report for issue #$issue"
            results+="

Issue #$issue: $title ($role)
$completion_report

---
"
        else
            warn "No completion report found for issue #$issue"
        fi

    done <<< "$tasks"

    # Create integration issue
    info "Creating integration summary issue..."

    local integration_issue=$(gh_create_issue \
        "[Integration] Orchestration Complete: $orch_id" \
        "$(cat <<EOFBODY
## 🎯 Integration Summary

**Orchestration ID**: $orch_id
**Completed**: $(timestamp)

### Results Collected

$results

### Integration Notes

All subagent tasks have been completed. This is the final integration point.

#### Main Agent Tasks:
- [ ] Review all subagent outputs
- [ ] Test integrated system
- [ ] Resolve any conflicts
- [ ] Finalize documentation
- [ ] Close all related issues

---
*Created by Claude Code Orchestrator*
EOFBODY
)" \
        "integration,status:in-progress")

    success "Created integration issue: #$integration_issue"

    # Update orchestration state
    state=$(echo "$state" | jq '.status = "integrated" | .integration_issue = '"$integration_issue")
    state_save "$orch_id" "$state"

    echo
    success "Integration complete!"
    echo
    info "Integration issue: #$integration_issue"
    info "View on GitHub: gh issue view $integration_issue"
    echo
    info "Next steps:"
    echo "  1. Review integration issue #$integration_issue"
    echo "  2. Test the integrated system"
    echo "  3. Run: orchestrate cleanup (when satisfied)"
    echo
}

main "$@"
