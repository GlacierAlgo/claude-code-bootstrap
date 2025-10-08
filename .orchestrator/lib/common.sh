#!/usr/bin/env bash
# Common utility functions
# Version: 2.0

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*"
}

info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $*" >&2
}

error() {
    echo -e "${RED}✗${NC} $*" >&2
    exit 1
}

debug() {
    if [[ "${ORCHESTRATE_DEBUG:-}" == "1" ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $*" >&2
    fi
}

# Progress indicator
spinner() {
    local pid=$1
    local message="${2:-Working...}"
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    while kill -0 "$pid" 2>/dev/null; do
        for i in $(seq 0 9); do
            echo -ne "\r${CYAN}${spinstr:$i:1}${NC} $message"
            sleep 0.1
        done
    done
    echo -ne "\r"
}

# Confirmation prompt
confirm() {
    local message="$1"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        local prompt="[Y/n]"
    else
        local prompt="[y/N]"
    fi

    read -p "$(echo -e "${YELLOW}?${NC} $message $prompt ")" -n 1 -r
    echo

    if [[ "$default" == "y" ]]; then
        [[ ! $REPLY =~ ^[Nn]$ ]]
    else
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Check required commands
check_dependencies() {
    local deps=("gh" "git" "jq")
    local missing=()

    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing[*]}\n\nPlease install them and try again."
    fi
}

# Get project root
get_project_root() {
    git rev-parse --show-toplevel 2>/dev/null || echo "."
}

# Get orchestrator root
get_orchestrator_root() {
    local project_root="$(get_project_root)"
    echo "$project_root/.orchestrator"
}

# Generate unique ID
generate_id() {
    date +%s | shasum -a 256 | base64 | head -c 8
}

# Get current timestamp
timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Format duration
format_duration() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))

    if [[ $hours -gt 0 ]]; then
        printf "%dh %dm %ds" $hours $minutes $secs
    elif [[ $minutes -gt 0 ]]; then
        printf "%dm %ds" $minutes $secs
    else
        printf "%ds" $secs
    fi
}

# Create directory if not exists
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        debug "Created directory: $dir"
    fi
}

# Safe file write (atomic)
safe_write() {
    local file="$1"
    local content="$2"
    local temp="${file}.tmp.$$"

    echo "$content" > "$temp"
    mv "$temp" "$file"
}

# Read JSON value
json_get() {
    local json="$1"
    local key="$2"
    echo "$json" | jq -r ".$key // empty"
}

# Pretty print JSON
json_pretty() {
    local json="$1"
    echo "$json" | jq '.'
}
