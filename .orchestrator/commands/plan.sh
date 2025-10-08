#!/usr/bin/env bash
# orchestrate plan - Create multi-agent plan from task description
# Version: 2.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/github.sh"
source "$SCRIPT_DIR/../lib/state.sh"

main() {
    local task_description="$*"

    if [[ -z "$task_description" ]]; then
        error "Usage: orchestrate plan <task description>"
    fi

    log "Creating multi-agent orchestration plan..."
    echo
    info "Task: $task_description"
    echo

    # Acquire lock
    state_acquire_lock

    # Generate orchestration ID
    local orch_id="orch-$(generate_id)"

    # Analyze task and create decomposition
    info "Analyzing task for decomposition..."
    echo
    cat <<EOF
${CYAN}────────────────────────────────────────────────────────────────${NC}
${YELLOW}📋 PROPOSED MULTI-AGENT DECOMPOSITION${NC}
${CYAN}────────────────────────────────────────────────────────────────${NC}

${PURPLE}This is where the main Claude Code instance would analyze the task
and propose a decomposition into parallel subtasks.${NC}

For now, this is a manual step. The system will:
1. Create GitHub issues for each subtask
2. Save the plan to state
3. Wait for your approval to execute

${YELLOW}Example decomposition for: "$task_description"${NC}

Task 1: [code-implementation] Core functionality
  - Implement main business logic
  - Create necessary data models
  - Set up basic infrastructure

Task 2: [documentation-specialist] Documentation
  - Write API documentation
  - Create usage examples
  - Document architecture decisions

Task 3: [testing-specialist] Testing
  - Write unit tests
  - Create integration tests
  - Ensure code coverage

${CYAN}────────────────────────────────────────────────────────────────${NC}
EOF

    echo
    if ! confirm "Create this orchestration plan?" "y"; then
        state_release_lock
        warn "Plan cancelled"
        exit 0
    fi

    # Create GitHub issues for subtasks
    info "Creating GitHub issues for subtasks..."

    local task1_issue=$(gh_create_issue \
        "[Subagent] Core Implementation" \
        "$(cat <<'EOFBODY'
## 🤖 Subagent Task

**Agent Role**: code-implementation
**Parent Orchestration**: ${orch_id}

### Objective
Implement core functionality for the requested feature.

### Success Criteria
- [ ] Core business logic implemented
- [ ] Data models created
- [ ] Basic infrastructure set up
- [ ] Code passes linting

### Dependencies
None

### Working Directory
\`./src\`

---
*Created by Claude Code Orchestrator*
EOFBODY
)" \
        "subagent-task,status:pending")

    local task2_issue=$(gh_create_issue \
        "[Subagent] Documentation" \
        "$(cat <<'EOFBODY'
## 🤖 Subagent Task

**Agent Role**: documentation-specialist
**Parent Orchestration**: ${orch_id}

### Objective
Create comprehensive documentation for the feature.

### Success Criteria
- [ ] API documentation written
- [ ] Usage examples created
- [ ] Architecture decisions documented

### Dependencies
- Blocks on: core implementation

### Working Directory
\`./docs\`

---
*Created by Claude Code Orchestrator*
EOFBODY
)" \
        "subagent-task,status:pending")

    local task3_issue=$(gh_create_issue \
        "[Subagent] Testing" \
        "$(cat <<'EOFBODY'
## 🤖 Subagent Task

**Agent Role**: testing-specialist
**Parent Orchestration**: ${orch_id}

### Objective
Create comprehensive test suite.

### Success Criteria
- [ ] Unit tests written
- [ ] Integration tests created
- [ ] Code coverage >= 80%

### Dependencies
- Blocks on: core implementation

### Working Directory
\`./tests\`

---
*Created by Claude Code Orchestrator*
EOFBODY
)" \
        "subagent-task,status:pending")

    success "Created GitHub issues: #$task1_issue, #$task2_issue, #$task3_issue"

    # Save orchestration state
    local state_data=$(cat <<EOF
{
  "orchestration_id": "$orch_id",
  "created_at": "$(timestamp)",
  "task_description": "$task_description",
  "status": "planned",
  "tasks": [
    {
      "issue_number": $task1_issue,
      "agent_role": "code-implementation",
      "status": "pending",
      "title": "Core Implementation"
    },
    {
      "issue_number": $task2_issue,
      "agent_role": "documentation-specialist",
      "status": "pending",
      "title": "Documentation"
    },
    {
      "issue_number": $task3_issue,
      "agent_role": "testing-specialist",
      "status": "pending",
      "title": "Testing"
    }
  ]
}
EOF
)

    state_save "$orch_id" "$state_data"
    state_set_current_id "$orch_id"

    # Release lock
    state_release_lock

    echo
    success "Orchestration plan created: $orch_id"
    echo
    info "GitHub Issues:"
    echo "  • Issue #$task1_issue: Core Implementation"
    echo "  • Issue #$task2_issue: Documentation"
    echo "  • Issue #$task3_issue: Testing"
    echo
    info "Next steps:"
    echo "  1. Review the issues on GitHub"
    echo "  2. Run: orchestrate execute"
    echo
}

main "$@"
