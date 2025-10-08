#!/usr/bin/env bash
# orchestrate init - Initialize orchestrator in current project
# Version: 2.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/github.sh"

main() {
    log "Initializing Claude Code Multi-Agent Orchestrator..."

    # Check dependencies
    check_dependencies

    # Check if in git repo
    if ! git rev-parse --git-dir &>/dev/null; then
        if confirm "Not in a git repository. Initialize git?"; then
            git init
            success "Git repository initialized"
        else
            error "Orchestrator requires a git repository"
        fi
    fi

    # Create directory structure
    info "Creating orchestrator directory structure..."
    local orch_root=".orchestrator"
    ensure_dir "$orch_root/commands"
    ensure_dir "$orch_root/templates"
    ensure_dir "$orch_root/state"
    ensure_dir "$orch_root/logs"
    ensure_dir "$orch_root/archive"
    ensure_dir "$orch_root/lib"

    # Copy AGENTS.md if it doesn't exist
    if [[ ! -f "AGENTS.md" ]]; then
        info "Creating AGENTS.md template..."
        cat > "AGENTS.md" <<'EOF'
# Agent Definitions

This file defines the specialized agents available for multi-agent orchestration.

## Available Agent Roles

### code-implementation
**Capabilities**: Implement code, write functions, create modules
**Use For**: Backend API endpoints, business logic, data processing
**Example Tasks**: "Implement user authentication", "Create REST API endpoint"

### documentation-specialist
**Capabilities**: Write docs, create API specifications, user guides
**Use For**: API documentation, README files, architecture docs
**Example Tasks**: "Document API endpoints", "Create user guide"

### testing-specialist
**Capabilities**: Write tests, create test fixtures, ensure coverage
**Use For**: Unit tests, integration tests, test automation
**Example Tasks**: "Write tests for auth module", "Create integration tests"

### research-analyst
**Capabilities**: Research libraries, analyze options, provide recommendations
**Use For**: Technology selection, architecture decisions, best practices
**Example Tasks**: "Research JWT libraries", "Analyze database options"

### refactoring-specialist
**Capabilities**: Refactor code, improve structure, optimize performance
**Use For**: Code cleanup, performance optimization, technical debt
**Example Tasks**: "Refactor user module", "Optimize query performance"

### security-reviewer
**Capabilities**: Security audit, vulnerability analysis, security best practices
**Use For**: Security reviews, penetration testing, compliance
**Example Tasks**: "Review authentication security", "Audit API endpoints"

## Custom Agents

Add your own specialized agents below:

EOF
        success "Created AGENTS.md"
    fi

    # Setup GitHub labels
    if confirm "Set up GitHub labels?"; then
        gh_setup_labels
    fi

    # Add to .gitignore
    if [[ -f ".gitignore" ]] && ! grep -q ".orchestrator/state" ".gitignore" 2>/dev/null; then
        info "Adding orchestrator paths to .gitignore..."
        cat >> .gitignore <<'EOF'

# Claude Code Orchestrator
.orchestrator/state/
.orchestrator/logs/
.orchestrator/archive/
EOF
        success "Updated .gitignore"
    fi

    # Create symlink to orchestrate command
    if [[ -d "/usr/local/bin" ]] && [[ -w "/usr/local/bin" ]]; then
        if confirm "Create global 'orchestrate' command?"; then
            ln -sf "$(pwd)/.orchestrator/commands/orchestrate.sh" /usr/local/bin/orchestrate
            success "Created /usr/local/bin/orchestrate"
        fi
    fi

    echo
    success "Orchestrator initialized successfully!"
    echo
    info "Next steps:"
    echo "  1. Review and customize AGENTS.md"
    echo "  2. Run: orchestrate plan \"<your complex task>\""
    echo "  3. Run: orchestrate execute"
    echo
}

main "$@"
