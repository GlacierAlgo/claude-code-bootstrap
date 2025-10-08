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
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Claude Code Multi-Agent Orchestrator v${VERSION}${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}USAGE:${NC}"
    echo "    orchestrate <command> [options]"
    echo ""
    echo -e "${GREEN}COMMANDS:${NC}"
    echo -e "    ${BLUE}init${NC}              Initialize orchestrator in current project"
    echo -e "    ${BLUE}plan${NC} <task>       Create multi-agent plan from task description"
    echo -e "    ${BLUE}execute${NC}           Execute approved plan with subagents"
    echo -e "    ${BLUE}status${NC}            Show current orchestration status"
    echo -e "    ${BLUE}integrate${NC}         Integrate subagent results"
    echo -e "    ${BLUE}cleanup${NC}           Archive completed orchestration"
    echo ""
    echo -e "    ${BLUE}help${NC}              Show this help message"
    echo -e "    ${BLUE}version${NC}           Show version information"
    echo ""
    echo -e "${GREEN}EXAMPLES:${NC}"
    echo -e "    ${PURPLE}# Setup in new project${NC}"
    echo "    orchestrate init"
    echo ""
    echo -e "    ${PURPLE}# Create plan for complex task${NC}"
    echo "    orchestrate plan \"Build REST API with auth, users, and admin endpoints\""
    echo ""
    echo -e "    ${PURPLE}# Execute the plan (spawns subagents)${NC}"
    echo "    orchestrate execute"
    echo ""
    echo -e "    ${PURPLE}# Check progress${NC}"
    echo "    orchestrate status"
    echo ""
    echo -e "    ${PURPLE}# Integrate when complete${NC}"
    echo "    orchestrate integrate"
    echo ""
    echo -e "    ${PURPLE}# Clean up${NC}"
    echo "    orchestrate cleanup"
    echo ""
    echo -e "${GREEN}DOCUMENTATION:${NC}"
    echo "    Local:  See .orchestrator/README.md for complete documentation"
    echo "    Online: https://github.com/GlacierAlgo/claude-code-bootstrap"
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
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
