#!/usr/bin/env bash
# Claude Code Multi-Agent Orchestrator
# Main entry point for all orchestration commands
# Version: 2.0

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCHESTRATOR_ROOT="$(dirname "$SCRIPT_DIR")"

# Load common utilities
source "$SCRIPT_DIR/../lib/common.sh"

# Version
VERSION="2.0.0"

# Usage information
usage() {
    cat << EOF
${CYAN}════════════════════════════════════════════════════════════════${NC}
${YELLOW}Claude Code Multi-Agent Orchestrator v${VERSION}${NC}
${CYAN}════════════════════════════════════════════════════════════════${NC}

${GREEN}USAGE:${NC}
    orchestrate <command> [options]

${GREEN}COMMANDS:${NC}
    ${BLUE}init${NC}              Initialize orchestrator in current project
    ${BLUE}plan${NC} <task>       Create multi-agent plan from task description
    ${BLUE}execute${NC}           Execute approved plan with subagents
    ${BLUE}status${NC}            Show current orchestration status
    ${BLUE}integrate${NC}         Integrate subagent results
    ${BLUE}cleanup${NC}           Archive completed orchestration

    ${BLUE}help${NC}              Show this help message
    ${BLUE}version${NC}           Show version information

${GREEN}EXAMPLES:${NC}
    ${PURPLE}# Setup in new project${NC}
    orchestrate init

    ${PURPLE}# Create plan for complex task${NC}
    orchestrate plan "Build REST API with auth, users, and admin endpoints"

    ${PURPLE}# Execute the plan (spawns subagents)${NC}
    orchestrate execute

    ${PURPLE}# Check progress${NC}
    orchestrate status

    ${PURPLE}# Integrate when complete${NC}
    orchestrate integrate

    ${PURPLE}# Clean up${NC}
    orchestrate cleanup

${GREEN}DOCUMENTATION:${NC}
    Local:  See .orchestrator/README.md for complete documentation
    Online: https://github.com/GlacierAlgo/claude-code-bootstrap

${CYAN}════════════════════════════════════════════════════════════════${NC}
EOF
}

# Main command dispatcher
main() {
    # Parse command
    case "${1:-help}" in
        init)
            "$SCRIPT_DIR/init.sh" "${@:2}"
            ;;
        plan)
            shift
            "$SCRIPT_DIR/plan.sh" "$@"
            ;;
        execute)
            "$SCRIPT_DIR/execute.sh" "${@:2}"
            ;;
        status)
            "$SCRIPT_DIR/status.sh" "${@:2}"
            ;;
        integrate)
            "$SCRIPT_DIR/integrate.sh" "${@:2}"
            ;;
        cleanup)
            "$SCRIPT_DIR/cleanup.sh" "${@:2}"
            ;;
        help|--help|-h)
            usage
            ;;
        version|--version|-v)
            echo "Claude Code Multi-Agent Orchestrator v${VERSION}"
            ;;
        *)
            error "Unknown command: $1\n\nRun 'orchestrate help' for usage information"
            ;;
    esac
}

# Run main
main "$@"
