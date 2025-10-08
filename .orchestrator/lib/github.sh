#!/usr/bin/env bash
# GitHub integration utilities
# Version: 2.0

# Create GitHub issue
gh_create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    debug "Creating GitHub issue: $title"

    local issue_url=$(gh issue create \
        --title "$title" \
        --body "$body" \
        --label "$labels" 2>&1)

    if [[ $? -eq 0 ]]; then
        local issue_number=$(echo "$issue_url" | grep -oE '[0-9]+$')
        echo "$issue_number"
    else
        error "Failed to create GitHub issue: $issue_url"
    fi
}

# Update issue labels
gh_update_labels() {
    local issue_number="$1"
    local add_labels="$2"
    local remove_labels="$3"

    debug "Updating labels for issue #$issue_number"

    if [[ -n "$remove_labels" ]]; then
        gh issue edit "$issue_number" --remove-label "$remove_labels" 2>/dev/null || true
    fi

    if [[ -n "$add_labels" ]]; then
        gh issue edit "$issue_number" --add-label "$add_labels" 2>/dev/null || true
    fi
}

# Add comment to issue
gh_add_comment() {
    local issue_number="$1"
    local comment="$2"

    debug "Adding comment to issue #$issue_number"

    gh issue comment "$issue_number" --body "$comment" >/dev/null
}

# Get issue details
gh_get_issue() {
    local issue_number="$1"

    gh issue view "$issue_number" --json number,title,state,labels,body,comments
}

# List issues with labels
gh_list_issues() {
    local labels="$1"

    gh issue list --label "$labels" --json number,title,state,labels
}

# Close issue
gh_close_issue() {
    local issue_number="$1"
    local comment="${2:-}"

    if [[ -n "$comment" ]]; then
        gh issue close "$issue_number" --comment "$comment"
    else
        gh issue close "$issue_number"
    fi
}

# Get current repository
gh_get_repo() {
    gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo ""
}

# Check if label exists
gh_label_exists() {
    local label="$1"
    gh label list --json name -q ".[] | select(.name == \"$label\") | .name" 2>/dev/null | grep -q "^$label$"
}

# Create label if not exists
gh_ensure_label() {
    local name="$1"
    local color="$2"
    local description="$3"

    if ! gh_label_exists "$name"; then
        gh label create "$name" --color "$color" --description "$description" --force 2>/dev/null
        debug "Created label: $name"
    fi
}

# Setup all required labels
gh_setup_labels() {
    info "Setting up GitHub labels..."

    gh_ensure_label "subagent-task" "0E8A16" "Issue assigned to a subagent"
    gh_ensure_label "status:pending" "FBCA04" "Task not started"
    gh_ensure_label "status:in-progress" "1D76DB" "Task in progress"
    gh_ensure_label "status:completed" "0E8A16" "Task completed"
    gh_ensure_label "status:blocked" "D93F0B" "Task blocked"
    gh_ensure_label "needs-review" "D93F0B" "Needs review"
    gh_ensure_label "integration" "5319E7" "Main agent integration"

    success "GitHub labels ready"
}

# Get issue number from URL
gh_extract_issue_number() {
    local url="$1"
    echo "$url" | grep -oE '[0-9]+$'
}
