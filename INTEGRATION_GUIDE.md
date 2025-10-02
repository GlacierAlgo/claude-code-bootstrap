# 🔗 MULTI-AGENT ORCHESTRATION INTEGRATION GUIDE

Step-by-step guide to integrate multi-agent orchestration into your Claude Code workflow.

---

# 🎯 QUICK START

## Prerequisites

1. **Claude Code CLI** installed and configured
2. **GitHub CLI (`gh`)** installed and authenticated
3. **Git repository** with GitHub remote
4. **CLAUDE.md** exists in `~/.claude/` directory

## 5-Minute Setup

```bash
# 1. Create project AGENTS.md
cd /path/to/your/project
cp /Users/yanghh/Documents/code/quant/cc_bootstrap/AGENTS.md ./AGENTS.md

# 2. Create GitHub labels
gh label create "subagent-task" --color "0E8A16" --description "Issue assigned to a subagent"
gh label create "status:pending" --color "FBCA04" --description "Task created but not started"
gh label create "status:in-progress" --color "0E8A16" --description "Subagent actively working"
gh label create "status:completed" --color "0E8A16" --description "Task finished"
gh label create "needs-review" --color "D93F0B" --description "Requires main agent attention"
gh label create "integration" --color "1D76DB" --description "Main agent integration work"

# 3. Add orchestration section to your global CLAUDE.md
# See "CLAUDE.md Enhancement" section below

# 4. Start using multi-agent orchestration!
```

---

# 📝 CLAUDE.MD ENHANCEMENT

## Add to Your Global CLAUDE.md

Add this section to `/Users/yanghh/.claude/CLAUDE.md`:

```markdown
---

# 🤖 MULTI-AGENT ORCHESTRATION

## When to Use Multi-Agent Approach

Use multi-agent orchestration when task meets ALL criteria:

1. **Decomposable**: Can be split into 3+ truly independent subtasks
2. **Parallelizable**: Subtasks don't have sequential dependencies
3. **Complex**: Each subtask is non-trivial (>30 min work)
4. **Clear Criteria**: Success criteria are well-defined for each subtask

**Don't Use** when:
- Task is linear (steps must be sequential)
- Subtasks are trivial (<30 min each)
- Integration complexity exceeds parallelization benefit
- User needs real-time interaction

## Multi-Agent Workflow

### Step 1: Decomposition Analysis

When you receive a complex request:

1. **Assess decomposability**:
   ```
   Questions to ask:
   - Can this be split into independent parts?
   - Are subtasks truly parallel?
   - Is each subtask substantial enough?
   - Are success criteria clear?
   ```

2. **Create decomposition plan**:
   ```markdown
   Task: [User's request]

   Decomposition:
   1. [Subtask 1] - Independent because: [reason]
   2. [Subtask 2] - Independent because: [reason]
   3. [Subtask 3] - Independent because: [reason]

   Integration: [How to combine results]
   ```

3. **Ask user for approval**:
   ```
   "I can decompose this into [N] parallel tasks:
   - [Brief description]

   Each will be tracked via GitHub Issues for transparency.
   Proceed? (yes/no)"
   ```

### Step 2: GitHub Issue Creation

For each approved subtask, create GitHub issue:

```bash
gh issue create \
  --title "🤖 [Subagent]: [Subtask Title]" \
  --body "$(cat <<'EOF'
## Subagent Task

**Parent Request**: [Original user request]
**Status**: 🟡 Pending

## Objective
[Clear, specific goal]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Context
[Relevant information]

## Expected Output
[What subagent should produce]

## Reporting Protocol
1. Start: Update to "status:in-progress"
2. Progress: Comment at milestones
3. Decisions: Comment with "🔍 Decision:" prefix
4. Blockers: Add "needs-review" label
5. Complete: Update to "status:completed", post results

---
*Created: $(date)*
EOF
)" \
  --label "subagent-task" \
  --label "status:pending"
```

### Step 3: Subagent Spawning

Use Task tool to spawn subagent with GitHub binding:

```python
task_result = use_task_tool(
    instructions=f"""
    You are a subagent working on GitHub Issue #{issue_number}.

    **Objective**: [From issue]

    **GitHub Update Protocol**:

    1. Start:
       gh issue edit {issue_number} --add-label "status:in-progress"
       gh issue comment {issue_number} --body "🚀 Started: [plan]"

    2. Progress:
       gh issue comment {issue_number} --body "📊 Progress: [update]"

    3. Decisions:
       gh issue comment {issue_number} --body "🔍 Decision: [details]"

    4. Blockers:
       gh issue edit {issue_number} --add-label "needs-review"
       gh issue comment {issue_number} --body "⚠️ BLOCKER: [description]"

    5. Complete:
       gh issue edit {issue_number} --add-label "status:completed"
       gh issue comment {issue_number} --body "✅ Results: [summary]"

    **Success Criteria**: [From issue]

    Work independently. Begin now.
    """,
    agent_type="general-purpose"
)
```

### Step 4: Monitor Progress

Check subagent status via GitHub:

```bash
# Overview
gh issue list --label "subagent-task"

# Check blockers
gh issue list --label "needs-review" --label "subagent-task"

# Specific subagent
gh issue view {issue_number} --comments
```

### Step 5: Handle Blockers

When subagent hits blocker (adds "needs-review" label):

1. **Review blocker**:
   ```bash
   gh issue view {issue_number} --json comments
   ```

2. **Provide resolution**:
   ```bash
   gh issue comment {issue_number} --body "🔧 Resolution: [guidance]"
   gh issue edit {issue_number} --remove-label "needs-review"
   ```

### Step 6: Collect Results

When all subagents complete:

```bash
# Get all results
for issue in {issue_numbers}; do
  gh issue view $issue --json comments --jq \
    '.comments[] | select(.body | startswith("✅")) | .body'
done
```

### Step 7: Integration

1. **Synthesize results** from all subagents
2. **Resolve conflicts** if any
3. **Create unified solution**
4. **Document integration** in new issue:

```bash
gh issue create \
  --title "🎯 Integration: [Task Name]" \
  --body "[Integration summary]

  ## Subagent Contributions
  - #X: [Contribution]
  - #Y: [Contribution]

  ## Final Solution
  [Integrated result]

  Closes #X, #Y, #Z" \
  --label "integration"
```

5. **Close subagent issues**:
```bash
gh issue close {issue_numbers} --comment "Integrated in #{integration_issue}"
```

## Decision Documentation Standards

Every subagent must document decisions:

```bash
gh issue comment {issue_number} --body "🔍 Decision: [Title]

**Context**: [Why decision needed]

**Options Considered**:
1. [Option 1] - Pros: [...] Cons: [...]
2. [Option 2] - Pros: [...] Cons: [...]

**Selected**: [Choice]

**Rationale**: [Why]

**Impact**: [What this affects]"
```

## Quality Requirements

Every multi-agent orchestration must achieve:

- [ ] All work visible on GitHub (issues + comments)
- [ ] All decisions documented
- [ ] All blockers resolved or escalated
- [ ] Integration is coherent
- [ ] Success criteria met
- [ ] Audit trail complete

## Integration with Existing Principles

Multi-agent orchestration follows all CLAUDE.md principles:

- **SIMPLEX**: Start simple (main agent), add complexity (subagents) only when needed
- **YAGNI**: Don't use multi-agent unless truly beneficial
- **Trust-Based**: Subagents trusted to work independently
- **Fail Fast**: Blockers immediately visible via labels
- **Complete Implementation**: No half-done subagent tasks
- **Transparent**: All work visible to humans

---

**See Also**:
- Project AGENTS.md for agent role definitions
- GITHUB_CLI_PATTERNS.md for command reference
- EXAMPLE_SCENARIO.md for complete walkthrough
```

---

# 🗂️ PROJECT AGENTS.MD SETUP

## Create Project-Specific AGENTS.md

In your project root, create `AGENTS.md`:

```bash
cd /path/to/your/project

cat > AGENTS.md << 'EOF'
# 🤖 PROJECT AGENT CONFIGURATION

## Specialized Agents for This Project

### [Your Agent Type 1]

**Use When**: [When to use this agent type]

**Responsibilities**:
- [Responsibility 1]
- [Responsibility 2]

**Success Criteria Template**:
- [ ] [Criterion 1]
- [ ] [Criterion 2]

**Expected Outputs**:
- [Output 1]
- [Output 2]

### [Your Agent Type 2]

[Similar structure]

## Project-Specific Decomposition Patterns

### Pattern: [Common Task Type]

**Scenario**: [Describe common task in your project]

**Decomposition**:
1. Subagent 1: [Responsibility]
2. Subagent 2: [Responsibility]
3. Subagent 3: [Responsibility]

**Integration**: [How to combine]

## Communication Standards

[Your project-specific communication requirements]

## Quality Checklist

Before marking subagent task complete:
- [ ] [Project-specific requirement 1]
- [ ] [Project-specific requirement 2]
- [ ] [Standard requirements from global CLAUDE.md]

---

See MULTI_AGENT_ORCHESTRATION.md for complete orchestration guide.
EOF
```

## Customize for Your Project

Edit `AGENTS.md` to add:

1. **Your project's agent types** (e.g., "Database Migration Agent", "UI Component Agent")
2. **Your common task patterns** (e.g., "Add new API endpoint", "Create dashboard widget")
3. **Your project-specific standards** (coding style, testing requirements, etc.)
4. **Your success criteria templates**

---

# 🏷️ GITHUB LABELS SETUP

## Create All Required Labels

Run this once per repository:

```bash
#!/bin/bash
# create_labels.sh - Create all multi-agent orchestration labels

# Core labels
gh label create "subagent-task" \
  --color "0E8A16" \
  --description "Issue assigned to a subagent" \
  --force

gh label create "integration" \
  --color "1D76DB" \
  --description "Main agent integration work" \
  --force

gh label create "multi-agent" \
  --color "5319E7" \
  --description "Multi-agent orchestration" \
  --force

# Status labels
gh label create "status:pending" \
  --color "FBCA04" \
  --description "Task created but not started" \
  --force

gh label create "status:in-progress" \
  --color "0E8A16" \
  --description "Subagent actively working" \
  --force

gh label create "status:completed" \
  --color "0E8A16" \
  --description "Task finished successfully" \
  --force

gh label create "status:blocked" \
  --color "D93F0B" \
  --description "Waiting on external input" \
  --force

# Agent type labels (customize for your project)
gh label create "agent-type:code-implementation" \
  --color "C2E0C6" \
  --description "Code implementation subagent" \
  --force

gh label create "agent-type:research" \
  --color "BFD4F2" \
  --description "Research/analysis subagent" \
  --force

gh label create "agent-type:documentation" \
  --color "D4C5F9" \
  --description "Documentation subagent" \
  --force

gh label create "agent-type:testing" \
  --color "FEF2C0" \
  --description "Testing/validation subagent" \
  --force

# Action labels
gh label create "needs-review" \
  --color "D93F0B" \
  --description "Requires main agent attention" \
  --force

gh label create "integration-ready" \
  --color "0E8A16" \
  --description "Results ready for synthesis" \
  --force

echo "✅ All labels created successfully"
```

## Verify Labels

```bash
gh label list | grep -E "subagent|status:|agent-type:|integration|needs-review"
```

---

# 🔄 TODOWRITE INTEGRATION

## Sync TodoWrite with GitHub Issues

Main Claude Code should maintain TodoWrite in sync with subagent issues:

### When Creating Subagent Tasks

```python
# After creating GitHub issues
TodoWrite([
    {
        "content": f"Monitor subagent #{issue_201}: Authentication docs",
        "activeForm": f"Monitoring subagent #{issue_201}: Authentication docs",
        "status": "in_progress"
    },
    {
        "content": f"Monitor subagent #{issue_202}: User management docs",
        "activeForm": f"Monitoring subagent #{issue_202}: User management docs",
        "status": "in_progress"
    },
    {
        "content": f"Monitor subagent #{issue_203}: Product catalog docs",
        "activeForm": f"Monitoring subagent #{issue_203}: Product catalog docs",
        "status": "in_progress"
    }
])
```

### When Subagents Complete

```python
# Update TodoWrite as subagents finish
TodoWrite([
    {
        "content": f"Monitor subagent #{issue_201}: Authentication docs",
        "activeForm": f"Monitoring subagent #{issue_201}: Authentication docs",
        "status": "completed"
    },
    {
        "content": f"Monitor subagent #{issue_202}: User management docs",
        "activeForm": f"Monitoring subagent #{issue_202}: User management docs",
        "status": "in_progress"
    },
    {
        "content": f"Monitor subagent #{issue_203}: Product catalog docs",
        "activeForm": f"Monitoring subagent #{issue_203}: Product catalog docs",
        "status": "in_progress"
    }
])
```

### Integration Phase

```python
# When doing integration
TodoWrite([
    {
        "content": "Collect subagent results",
        "activeForm": "Collecting subagent results",
        "status": "completed"
    },
    {
        "content": "Synthesize final documentation system",
        "activeForm": "Synthesizing final documentation system",
        "status": "in_progress"
    },
    {
        "content": "Create integration summary issue",
        "activeForm": "Creating integration summary issue",
        "status": "pending"
    },
    {
        "content": "Close subagent issues",
        "activeForm": "Closing subagent issues",
        "status": "pending"
    }
])
```

---

# 🎯 USAGE PATTERNS

## Pattern 1: Simple 3-Subagent Decomposition

**Use Case**: 3 independent components to build

```bash
# 1. Ask user approval
echo "Decompose into 3 parallel tasks? (yes/no)"

# 2. Create issues quickly
for task in "Task 1" "Task 2" "Task 3"; do
  gh issue create \
    --title "🤖 [Subagent]: $task" \
    --body "[Standard template]" \
    --label "subagent-task" \
    --label "status:pending"
done

# 3. Spawn subagents (use Task tool for each)

# 4. Monitor and integrate
```

## Pattern 2: Research-Heavy Task

**Use Case**: Analyze multiple data sources

```bash
# 1. Create research issues
gh issue create --title "🤖 [Subagent]: Analyze logs" --label "agent-type:research" ...
gh issue create --title "🤖 [Subagent]: Analyze metrics" --label "agent-type:research" ...
gh issue create --title "🤖 [Subagent]: Analyze feedback" --label "agent-type:research" ...

# 2. Spawn research subagents

# 3. Collect findings

# 4. Synthesize cross-source insights
```

## Pattern 3: Documentation Sprint

**Use Case**: Document multiple modules

```bash
# 1. Create doc issues (one per module)
for module in auth users products; do
  gh issue create \
    --title "🤖 [Subagent]: Document $module API" \
    --label "agent-type:documentation" \
    ...
done

# 2. Spawn doc subagents

# 3. Create unified doc system
```

---

# 🔍 MONITORING AND DEBUGGING

## Check Orchestration Health

```bash
# Overview of all subagent tasks
gh issue list --label "subagent-task" \
  --json number,title,labels,updatedAt \
  | jq -r '.[] | "\(.number): \(.title) - \(.labels | map(.name) | join(", "))"'

# Find stale tasks (not updated in 24h)
gh issue list --label "subagent-task" --label "status:in-progress" \
  --json number,title,updatedAt \
  | jq -r 'map(select((now - (.updatedAt | fromdateiso8601)) > 86400)) |
    .[] | "#\(.number): \(.title) - STALE"'

# Check for blockers
gh issue list --label "needs-review" --label "subagent-task"
```

## Debug Subagent Issues

### Issue: Subagent Not Updating GitHub

**Diagnosis**:
```bash
# Check if subagent has GitHub CLI access
gh auth status

# Check if issue exists
gh issue view {issue_number}
```

**Resolution**:
Ensure subagent instructions include explicit `gh` commands with correct issue number.

### Issue: Subagent Stuck

**Diagnosis**:
```bash
# Check last update time
gh issue view {issue_number} --json updatedAt

# Check last comment
gh issue view {issue_number} --json comments | jq '.comments | last'
```

**Resolution**:
1. Check for "needs-review" label
2. Review last activity to understand blocker
3. Provide resolution via comment
4. Remove "needs-review" label

### Issue: Integration Conflicts

**Diagnosis**:
```bash
# Compare subagent outputs
for issue in {issue_numbers}; do
  gh issue view $issue --json body,comments
done
```

**Resolution**:
1. Document conflicts in integration issue
2. Decide resolution strategy
3. Make necessary adjustments
4. Document in integration summary

---

# 📊 REPORTING AND ANALYTICS

## Generate Multi-Agent Report

```bash
#!/bin/bash
# generate_multiagent_report.sh

cat << 'EOF'
# Multi-Agent Orchestration Report
Generated: $(date)

## Active Subagents
EOF

gh issue list --label "subagent-task" --label "status:in-progress" \
  --json number,title,createdAt \
  | jq -r '.[] | "- #\(.number): \(.title)"'

cat << 'EOF'

## Completed Subagents
EOF

gh issue list --label "subagent-task" --label "status:completed" \
  --json number,title \
  | jq -r '.[] | "- #\(.number): \(.title) ✅"'

cat << 'EOF'

## Statistics
EOF

TOTAL=$(gh issue list --label "subagent-task" --json number | jq 'length')
IN_PROGRESS=$(gh issue list --label "subagent-task" --label "status:in-progress" --json number | jq 'length')
COMPLETED=$(gh issue list --label "subagent-task" --label "status:completed" --json number | jq 'length')

echo "- Total subagent tasks: $TOTAL"
echo "- In progress: $IN_PROGRESS"
echo "- Completed: $COMPLETED"
```

## Export Audit Trail

```bash
# Export all subagent work for audit
gh issue list --label "subagent-task" \
  --json number,title,body,comments,labels,createdAt,updatedAt,closedAt \
  > multiagent_audit_$(date +%Y%m%d).json

echo "Exported to: multiagent_audit_$(date +%Y%m%d).json"
```

---

# ✅ VERIFICATION CHECKLIST

After integration, verify:

## CLAUDE.md
- [ ] Multi-agent orchestration section added
- [ ] Workflow steps documented
- [ ] Decision documentation standards included
- [ ] Integration with existing principles noted

## Project AGENTS.md
- [ ] Project-specific agent types defined
- [ ] Common task decomposition patterns documented
- [ ] Communication standards specified
- [ ] Quality checklists included

## GitHub Setup
- [ ] All required labels created
- [ ] Labels are correct colors
- [ ] Label descriptions are clear

## Testing
- [ ] Create a test subagent issue manually
- [ ] Verify `gh` commands work
- [ ] Test TodoWrite integration
- [ ] Verify issue comments render correctly

## Documentation
- [ ] MULTI_AGENT_ORCHESTRATION.md accessible
- [ ] GITHUB_CLI_PATTERNS.md accessible
- [ ] EXAMPLE_SCENARIO.md accessible
- [ ] Team knows where to find docs

---

# 🚀 NEXT STEPS

## Start Small

1. **First Multi-Agent Task**: Choose a simple 3-part decomposition
2. **Document Everything**: Use this as learning experience
3. **Review Results**: What worked? What didn't?
4. **Refine Process**: Update AGENTS.md based on learnings

## Scale Up

1. **Identify Common Patterns**: What tasks decompose well in your project?
2. **Create Templates**: Make GitHub issue templates for common patterns
3. **Automate**: Create scripts for frequent decomposition patterns
4. **Train Team**: Share knowledge about when/how to use multi-agent

## Optimize

1. **Measure Efficiency**: Track time saved vs coordination overhead
2. **Improve Templates**: Refine based on what works
3. **Better Monitoring**: Create dashboards for subagent status
4. **Process Refinement**: Continuously improve based on results

---

# 🆘 TROUBLESHOOTING

## Common Issues

### "Subagent not updating GitHub"

**Cause**: Subagent instructions missing `gh` commands

**Fix**: Ensure spawning instructions include explicit GitHub update commands

### "Can't find subagent results"

**Cause**: Inconsistent completion comment format

**Fix**: Standardize on "✅ Results:" prefix for all completion comments

### "Integration conflicts"

**Cause**: Subagents made incompatible decisions

**Fix**: Add more context in initial issues, monitor decisions via GitHub

### "Coordination overhead too high"

**Cause**: Task decomposed too granularly

**Fix**: Only decompose into 3-5 substantial subtasks, not 10+ trivial ones

## Getting Help

1. **Review Examples**: See EXAMPLE_SCENARIO.md for complete walkthrough
2. **Check Patterns**: See GITHUB_CLI_PATTERNS.md for command reference
3. **Consult Orchestration Guide**: See MULTI_AGENT_ORCHESTRATION.md for principles
4. **Review AGENTS.md**: Check project-specific patterns

---

# 📚 REFERENCE

## Key Files

- **Global**: `/Users/yanghh/.claude/CLAUDE.md` (global orchestration rules)
- **Project**: `./AGENTS.md` (project-specific agent config)
- **Documentation**:
  - `MULTI_AGENT_ORCHESTRATION.md` - Complete orchestration guide
  - `GITHUB_CLI_PATTERNS.md` - All GitHub CLI commands
  - `EXAMPLE_SCENARIO.md` - End-to-end walkthrough
  - `INTEGRATION_GUIDE.md` - This file

## Quick Commands

```bash
# Create subagent issue
gh issue create --title "🤖 [Subagent]: [Task]" --label "subagent-task" ...

# Check status
gh issue list --label "subagent-task"

# Check blockers
gh issue list --label "needs-review" --label "subagent-task"

# View subagent work
gh issue view {issue_number} --comments

# Close after integration
gh issue close {issue_number} --comment "Integrated in #{integration_issue}"
```

## Label Reference

- `subagent-task` - Identifies subagent work
- `status:pending` - Created, not started
- `status:in-progress` - Actively working
- `status:completed` - Finished
- `needs-review` - Blocked, needs main agent
- `integration` - Main agent integration work
- `agent-type:*` - Subagent specialization

---

You're now ready to use Claude Code's native multi-agent orchestration with full GitHub integration!
