# 🤖 MULTI-AGENT ORCHESTRATION SYSTEM

## Claude Code Native Multi-Agent Architecture

This system leverages Claude Code's built-in capabilities for transparent, GitHub-integrated multi-agent workflows.

---

# 🎯 CORE ORCHESTRATION PRINCIPLES

## Architecture Overview

**Key Insight**: We're NOT building a Python orchestrator. We're using Claude Code's native features:
- **CLAUDE.md**: Global orchestration instructions
- **AGENTS.md**: Project-specific agent definitions
- **Task tool**: Spawn specialized subagents
- **TodoWrite**: Built-in task tracking
- **GitHub CLI (`gh`)**: Transparency and human oversight

## Orchestration Philosophy

### When to Use Multi-Agent Approach
- **Complex decomposable tasks**: Can be split into 3+ independent subtasks
- **Parallel execution potential**: Subtasks don't depend on each other
- **Specialized expertise needed**: Different subtasks require different approaches
- **Human oversight required**: Decisions need visibility and approval

### When NOT to Use Multi-Agent
- **Simple linear tasks**: Can be completed in 2-3 steps sequentially
- **Tightly coupled operations**: Each step depends on previous results
- **Real-time interactive work**: Requires immediate user feedback
- **Trivial operations**: Overhead exceeds value

---

# 🔧 ORCHESTRATION INSTRUCTIONS FOR CLAUDE.md

## Multi-Agent Decomposition Protocol

### Step 1: Task Analysis (Main Claude Code)

When receiving a complex request:

1. **Assess Decomposability**:
   ```
   - Can this be split into 3+ independent subtasks?
   - Are subtasks truly parallel (no sequential dependencies)?
   - Does each subtask have clear success criteria?
   - Is the overhead of coordination worth it?
   ```

2. **Create Decomposition Plan**:
   ```
   Task: [User's original request]

   Decomposition:
   1. [Subtask 1] - [Why it's independent] - [Success criteria]
   2. [Subtask 2] - [Why it's independent] - [Success criteria]
   3. [Subtask 3] - [Why it's independent] - [Success criteria]

   Integration: [How results will be combined]
   ```

3. **Ask User for Approval**:
   ```
   "I can decompose this into [N] parallel tasks:
   - [Brief description of each]

   Each will be tracked via GitHub Issues for transparency.
   Proceed with multi-agent approach? (yes/no)"
   ```

### Step 2: GitHub Issue Creation (Before Spawning Subagents)

For each approved subtask:

```bash
# Create issue with specific template
gh issue create \
  --title "🤖 [Subagent]: [Subtask Title]" \
  --body "$(cat <<'EOF'
## Subagent Task

**Parent Request**: [Original user request]
**Assigned To**: [Subagent type - e.g., general-purpose]
**Status**: 🟡 Pending

## Objective
[Clear, specific goal for this subtask]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Context
[Relevant information the subagent needs]

## Constraints
- [Any limitations or requirements]

## Expected Output
[What the subagent should produce]

---
*Orchestrated by Main Claude Code*
*Created: $(date)*
EOF
)" \
  --label "subagent-task" \
  --label "status:pending"
```

### Step 3: Subagent Spawning with Issue Binding

```python
# Use Task tool to spawn subagent with GitHub issue context
task_result = use_task_tool(
    instructions=f"""
    You are a specialized subagent working on: [Subtask Title]

    **GitHub Issue**: #{issue_number}

    **Your Responsibilities**:
    1. Work on the specific objective defined in the issue
    2. Document all decisions as comments on issue #{issue_number}
    3. Update issue labels as you progress
    4. Post final results as a comment when complete

    **Objective**: [Clear goal]

    **Success Criteria**: [From issue]

    **GitHub Update Protocol**:
    - Start: Update label to "status:in-progress"
    - Decisions: Add comments with "🔍 Decision:" prefix
    - Blockers: Add comment with "⚠️ Blocker:" prefix and label "needs-review"
    - Complete: Update label to "status:completed", post results

    **Commands**:
    - Progress: `gh issue comment {issue_number} --body "🔍 Decision: [decision]"`
    - Blocker: `gh issue edit {issue_number} --add-label "needs-review" && gh issue comment {issue_number} --body "⚠️ Blocker: [description]"`
    - Complete: `gh issue edit {issue_number} --add-label "status:completed" && gh issue comment {issue_number} --body "✅ Results: [summary]"`
    """,
    agent_type="general-purpose"
)
```

### Step 4: Monitoring and Coordination

Main Claude Code monitors via GitHub:

```bash
# Check subagent progress
gh issue list --label "subagent-task" --json number,title,labels,comments

# Check for blockers needing review
gh issue list --label "needs-review" --label "subagent-task"

# Get specific subagent status
gh issue view {issue_number} --comments
```

### Step 5: Result Collection and Synthesis

When all subagents complete:

```bash
# Collect all results
for issue in $(gh issue list --label "subagent-task" --label "status:completed" --json number --jq '.[].number'); do
  echo "=== Subagent #$issue Results ==="
  gh issue view $issue --json body,comments --jq '.comments[] | select(.body | startswith("✅ Results:")) | .body'
done

# Synthesize final output
# Close all subagent issues
gh issue close {issue_numbers} --comment "Integrated into final solution"
```

---

# 📋 DECISION DOCUMENTATION PATTERNS

## Subagent Decision Logging

Every significant decision must be documented:

```bash
# Architecture decisions
gh issue comment {issue_number} --body "🔍 Decision: [Architecture Choice]

**Context**: [Why this decision was needed]
**Options Considered**:
1. [Option 1] - [Pros/Cons]
2. [Option 2] - [Pros/Cons]

**Selected**: [Chosen option]
**Rationale**: [Why this is best]
**Impact**: [What this affects]"

# Implementation decisions
gh issue comment {issue_number} --body "🔍 Decision: [Implementation Detail]

**Approach**: [What was implemented]
**Alternatives**: [What was NOT chosen and why]
**Trade-offs**: [What we gained/lost]"

# Blocker encountered
gh issue comment {issue_number} --body "⚠️ Blocker: [Issue Description]

**Attempted Solutions**:
- [What was tried]

**Need Human Input**:
- [Specific question or decision needed]

**Impact**: [What's blocked by this]"
```

---

# 🔄 SUBAGENT-TO-MAIN COMMUNICATION PROTOCOL

## Status Updates

Subagents update their issue at key points:

1. **Start**:
   ```bash
   gh issue edit {issue_number} --add-label "status:in-progress"
   gh issue comment {issue_number} --body "🚀 Started working on: [brief plan]"
   ```

2. **Progress Milestones** (every significant step):
   ```bash
   gh issue comment {issue_number} --body "📊 Progress: [milestone achieved]

   Completed:
   - [x] [Task 1]
   - [x] [Task 2]

   Next:
   - [ ] [Task 3]"
   ```

3. **Decisions Made**:
   ```bash
   gh issue comment {issue_number} --body "🔍 Decision: [topic]

   [Decision details using template above]"
   ```

4. **Blockers Hit**:
   ```bash
   gh issue edit {issue_number} --add-label "needs-review"
   gh issue comment {issue_number} --body "⚠️ Blocker: [description]

   [Blocker details using template above]"
   ```

5. **Completion**:
   ```bash
   gh issue edit {issue_number} --add-label "status:completed"
   gh issue comment {issue_number} --body "✅ Results: [Summary]

   ## Deliverables
   - [File 1]: [Description]
   - [File 2]: [Description]

   ## Key Decisions
   - [Decision 1]
   - [Decision 2]

   ## Success Criteria Met
   - [x] [Criterion 1]
   - [x] [Criterion 2]

   ## Integration Notes
   [How main agent should use these results]"
   ```

---

# 🎯 MAIN CLAUDE CODE COORDINATION RULES

## Orchestrator Responsibilities

### Before Spawning Subagents

1. **Verify decomposition is valid**:
   - Tasks are truly independent
   - Clear success criteria exist
   - Integration path is clear

2. **Create GitHub issues first**:
   - One issue per subtask
   - Include all context needed
   - Set up proper labels

3. **Get user approval**:
   - Show decomposition plan
   - Explain GitHub tracking
   - Confirm before proceeding

### During Subagent Execution

1. **Monitor progress**:
   ```bash
   # Check status every N minutes (if needed)
   gh issue list --label "subagent-task" --json number,title,labels
   ```

2. **Handle blockers**:
   ```bash
   # Check for review requests
   gh issue list --label "needs-review" --label "subagent-task"

   # Review and respond
   gh issue comment {issue_number} --body "🔧 Resolution: [guidance]"
   gh issue edit {issue_number} --remove-label "needs-review"
   ```

3. **Don't interfere unnecessarily**:
   - Let subagents work independently
   - Only intervene for blockers or integration conflicts

### After Subagent Completion

1. **Collect all results**:
   ```bash
   # Get completion comments
   for issue in $(gh issue list --label "status:completed" --label "subagent-task" --json number --jq '.[].number'); do
     gh issue view $issue --comments
   done
   ```

2. **Synthesize final output**:
   - Integrate subagent results
   - Resolve any conflicts
   - Create unified solution

3. **Document integration**:
   ```bash
   # Create integration summary issue
   gh issue create \
     --title "🎯 Multi-Agent Integration: [Task Name]" \
     --body "[Integration summary]

     ## Subagent Contributions
     - Issue #X: [Contribution]
     - Issue #Y: [Contribution]

     ## Final Solution
     [Integrated result]

     ## Related Issues
     Closes #X, #Y, #Z"
   ```

4. **Clean up**:
   ```bash
   # Close subagent issues
   for issue in {issue_numbers}; do
     gh issue close $issue --comment "Integrated in #{integration_issue_number}"
   done
   ```

---

# 🚫 ANTI-PATTERNS TO AVOID

## Don't Do This

1. **Over-Decomposition**:
   ```
   ❌ Breaking a 3-step linear task into 3 subagents
   ✅ Keep linear tasks in main agent
   ```

2. **Hidden Work**:
   ```
   ❌ Subagent makes decisions without documenting in issue
   ✅ Every decision is a GitHub comment
   ```

3. **Synchronous Dependencies**:
   ```
   ❌ Subagent A must finish before B can start
   ✅ Only truly parallel tasks get subagents
   ```

4. **Micro-Management**:
   ```
   ❌ Main agent checking subagent status every minute
   ✅ Subagents report at milestones, main agent trusts them
   ```

5. **Opaque Integration**:
   ```
   ❌ Combining results without explanation
   ✅ Document integration decisions in final issue
   ```

---

# 📊 WORKFLOW STATE TRACKING

## GitHub Labels for Orchestration

Standard labels for all multi-agent tasks:

- `subagent-task`: Identifies issue as subagent work
- `status:pending`: Created but not started
- `status:in-progress`: Subagent actively working
- `status:completed`: Work finished
- `status:blocked`: Waiting on external input
- `needs-review`: Requires main agent attention
- `agent-type:general`: General-purpose subagent
- `agent-type:specialized`: Specialized subagent
- `integration-ready`: Results ready for synthesis

## TodoWrite Integration

Main Claude Code maintains TodoWrite in sync with GitHub:

```python
# When creating subagent tasks
TodoWrite([
    {
        "content": "Coordinate subagent #{issue_number}: {task_name}",
        "activeForm": "Coordinating subagent #{issue_number}: {task_name}",
        "status": "in_progress"
    }
])

# When subagent completes
TodoWrite([
    {
        "content": "Coordinate subagent #{issue_number}: {task_name}",
        "activeForm": "Coordinating subagent #{issue_number}: {task_name}",
        "status": "completed"
    }
])
```

---

# 🔍 HUMAN OVERSIGHT MECHANISMS

## How Humans Can Intervene

### Via GitHub Issue Comments

1. **Review decisions**:
   ```
   Human adds comment: "@claude I disagree with this approach because..."
   Subagent sees it, responds, adjusts course
   ```

2. **Provide missing context**:
   ```
   Human adds comment: "Additional context: [information]"
   Subagent incorporates and updates plan
   ```

3. **Change direction**:
   ```
   Human adds comment: "Stop current approach, instead try..."
   Subagent acknowledges, pivots strategy
   ```

### Via Labels

1. **Request attention**:
   ```
   Human adds label: "needs-human-review"
   Main Claude Code sees it, escalates to user
   ```

2. **Block progress**:
   ```
   Human adds label: "do-not-proceed"
   Subagent halts work until label removed
   ```

3. **Approve continuation**:
   ```
   Human removes label: "needs-review"
   Subagent proceeds with cleared blocker
   ```

---

# ✅ SUCCESS CRITERIA FOR MULTI-AGENT TASKS

## Required Outcomes

Every multi-agent orchestration must achieve:

1. **Complete Transparency**:
   - [ ] Every subtask has a GitHub issue
   - [ ] All decisions documented in issues
   - [ ] Progress visible through labels/comments
   - [ ] Final integration explained

2. **Proper Decomposition**:
   - [ ] Tasks are truly independent
   - [ ] No hidden dependencies discovered
   - [ ] Integration path was clear from start
   - [ ] Parallel execution saved time

3. **Quality Results**:
   - [ ] All subagent success criteria met
   - [ ] Integration is coherent
   - [ ] No conflicts or inconsistencies
   - [ ] Final output meets user needs

4. **Human Oversight Enabled**:
   - [ ] Humans could review all decisions
   - [ ] Intervention points were clear
   - [ ] Issues remain as documentation
   - [ ] Audit trail is complete

## Quality Metrics

Good multi-agent execution:
- Faster than sequential approach would be
- More thorough (parallel specialized attention)
- Transparent (all work visible on GitHub)
- Reviewable (humans can audit decisions)

Bad multi-agent execution:
- Coordination overhead exceeds value
- Subagents blocked waiting on each other
- Decisions hidden or poorly documented
- Integration conflicts not foreseen

---

# 🎓 EXAMPLE WORKFLOW PATTERNS

## Pattern 1: Parallel Feature Implementation

**Scenario**: Build 3 independent API endpoints

```bash
# Main Claude Code creates issues
gh issue create --title "🤖 [Subagent]: Implement /users endpoint" ...
gh issue create --title "🤖 [Subagent]: Implement /products endpoint" ...
gh issue create --title "🤖 [Subagent]: Implement /orders endpoint" ...

# Spawn subagents, each bound to their issue
# Subagents work in parallel
# Main agent collects results, creates integration tests
```

## Pattern 2: Multi-Source Data Analysis

**Scenario**: Analyze data from 3 different sources

```bash
# Main Claude Code creates issues
gh issue create --title "🤖 [Subagent]: Analyze database logs" ...
gh issue create --title "🤖 [Subagent]: Analyze API metrics" ...
gh issue create --title "🤖 [Subagent]: Analyze user feedback" ...

# Subagents analyze independently
# Main agent synthesizes cross-source insights
```

## Pattern 3: Documentation Generation

**Scenario**: Create docs for different modules

```bash
# Main Claude Code creates issues
gh issue create --title "🤖 [Subagent]: Document auth module" ...
gh issue create --title "🤖 [Subagent]: Document data module" ...
gh issue create --title "🤖 [Subagent]: Document API module" ...

# Subagents create specialized docs
# Main agent ensures consistency, creates overview
```

---

# 🔗 INTEGRATION WITH EXISTING CLAUDE.md

This multi-agent orchestration system follows all existing principles:

- **SIMPLEX**: Start simple (main agent), add complexity (subagents) only when needed
- **YAGNI**: Don't use multi-agent unless truly beneficial
- **Trust-Based**: Subagents trusted to do their work independently
- **Fail Fast**: Blockers immediately visible via GitHub labels
- **Complete Implementation**: No half-done subagent tasks
- **Direct Naming**: Issue titles clearly describe subtasks
- **Transparent Communication**: All decisions visible to humans

The orchestration is an extension, not a replacement, of core development philosophy.
