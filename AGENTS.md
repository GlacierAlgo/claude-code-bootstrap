# 🤖 PROJECT-SPECIFIC AGENT CONFIGURATION

## Agent Definitions for Claude Code Multi-Agent Orchestration

This file defines specialized agent roles, task decomposition strategies, and communication protocols for this project.

---

# 🎯 AGENT ROLES AND RESPONSIBILITIES

## Main Orchestrator Agent (You)

**Role**: Coordination, decomposition, integration, human interface

**Responsibilities**:
- Analyze incoming requests for decomposability
- Create GitHub issues for subtasks
- Spawn and monitor subagents
- Collect and synthesize results
- Maintain communication with user
- Handle blockers and conflicts

**Decision Authority**:
- ✅ Whether to use multi-agent approach
- ✅ How to decompose tasks
- ✅ Which subagents to spawn
- ✅ How to integrate results
- ✅ When to escalate to user

**Never Do**:
- ❌ Work on subtasks directly (delegate to subagents)
- ❌ Hide subagent decisions from GitHub
- ❌ Override subagent work without documenting why
- ❌ Use multi-agent for simple tasks

---

# 🔧 SPECIALIZED SUBAGENT TYPES

## 1. Code Implementation Subagent

**Use When**:
- Implementing independent code modules
- Building isolated features
- Creating separate components

**GitHub Issue Template**:
```markdown
## Code Implementation Task

**Module**: [Module name]
**Dependencies**: [What this code depends on]
**Integration Point**: [How it connects to rest of system]

### Success Criteria
- [ ] Module passes type checking
- [ ] Follows project coding standards
- [ ] No external dependencies beyond specified
- [ ] Integration interface is clear

### Constraints
- Must use [specific libraries/patterns]
- Must follow [architectural guidelines]
- Must be compatible with [existing systems]
```

**Expected Outputs**:
- Complete, functional code
- Decision log on architecture choices
- Integration instructions
- Any discovered issues/blockers

## 2. Research/Analysis Subagent

**Use When**:
- Analyzing codebases
- Investigating bugs
- Researching solutions
- Gathering requirements

**GitHub Issue Template**:
```markdown
## Research/Analysis Task

**Topic**: [What to research]
**Scope**: [What to include/exclude]
**Output Format**: [How to present findings]

### Success Criteria
- [ ] All relevant information gathered
- [ ] Sources documented
- [ ] Options/approaches compared
- [ ] Recommendation provided (if applicable)

### Research Questions
1. [Question 1]
2. [Question 2]
3. [Question 3]
```

**Expected Outputs**:
- Comprehensive findings document
- Pros/cons of options discovered
- Recommendations with rationale
- Links/references to sources

## 3. Documentation Subagent

**Use When**:
- Writing API documentation
- Creating user guides
- Documenting architecture
- Writing code comments

**GitHub Issue Template**:
```markdown
## Documentation Task

**Target Audience**: [Who will read this]
**Scope**: [What to document]
**Format**: [Markdown/API docs/Comments/etc]

### Success Criteria
- [ ] Clear and accurate
- [ ] Follows documentation standards
- [ ] Includes examples
- [ ] Reviewed for completeness

### Key Topics
1. [Topic 1]
2. [Topic 2]
3. [Topic 3]
```

**Expected Outputs**:
- Complete documentation files
- Code examples (if applicable)
- Diagrams (if needed)
- Review checklist

## 4. Testing/Validation Subagent

**Use When**:
- Writing test cases
- Validating implementations
- Quality assurance
- Bug reproduction

**GitHub Issue Template**:
```markdown
## Testing/Validation Task

**Subject**: [What to test]
**Test Type**: [Unit/Integration/E2E]
**Coverage Goal**: [What must be covered]

### Success Criteria
- [ ] All scenarios covered
- [ ] Edge cases identified and tested
- [ ] Test passes/fails correctly
- [ ] Documentation of test approach

### Test Scenarios
1. [Scenario 1]
2. [Scenario 2]
3. [Scenario 3]
```

**Expected Outputs**:
- Test code (if applicable)
- Test results
- Bug reports (if found)
- Coverage analysis

## 5. Refactoring Subagent

**Use When**:
- Improving code structure
- Eliminating duplication
- Optimizing performance
- Modernizing code

**GitHub Issue Template**:
```markdown
## Refactoring Task

**Target**: [What code to refactor]
**Goal**: [What to improve]
**Constraints**: [What must not change]

### Success Criteria
- [ ] Functionality unchanged
- [ ] Code quality improved
- [ ] Tests still pass
- [ ] Performance maintained or improved

### Refactoring Objectives
1. [Objective 1]
2. [Objective 2]
3. [Objective 3]
```

**Expected Outputs**:
- Refactored code
- Before/after comparison
- Performance metrics (if relevant)
- Migration guide (if needed)

---

# 📋 TASK DECOMPOSITION STRATEGIES

## When to Decompose

Use multi-agent when task meets ALL criteria:

1. **Independence**: Subtasks can proceed without waiting for others
2. **Complexity**: Each subtask is non-trivial (>30 min work)
3. **Clarity**: Success criteria are clear for each subtask
4. **Value**: Parallel execution provides real benefit

## Decomposition Patterns

### Pattern: Feature Implementation

**Original Task**: "Implement user authentication system"

**Decomposition**:
```
Main Task: User Authentication System

Subtasks:
1. Code Subagent: Implement password hashing and validation
   - Independent: Uses standard crypto library
   - Output: auth/password.py module

2. Code Subagent: Implement JWT token management
   - Independent: Uses JWT library
   - Output: auth/tokens.py module

3. Code Subagent: Implement session storage
   - Independent: Uses Redis library
   - Output: auth/sessions.py module

4. Documentation Subagent: Write authentication API docs
   - Independent: Documents interfaces
   - Output: docs/authentication.md

Integration (Main Agent):
- Combine modules into auth/__init__.py
- Create integration tests
- Write deployment guide
```

### Pattern: Data Analysis

**Original Task**: "Analyze system performance issues"

**Decomposition**:
```
Main Task: Performance Analysis

Subtasks:
1. Research Subagent: Analyze database query logs
   - Independent: Separate data source
   - Output: Database bottleneck report

2. Research Subagent: Analyze application metrics
   - Independent: Separate data source
   - Output: Application performance report

3. Research Subagent: Analyze network latency
   - Independent: Separate data source
   - Output: Network analysis report

Integration (Main Agent):
- Correlate findings across sources
- Identify root causes
- Create prioritized action plan
```

### Pattern: Documentation Sprint

**Original Task**: "Document entire API surface"

**Decomposition**:
```
Main Task: API Documentation

Subtasks:
1. Documentation Subagent: Document user endpoints
   - Independent: Separate module
   - Output: docs/api/users.md

2. Documentation Subagent: Document product endpoints
   - Independent: Separate module
   - Output: docs/api/products.md

3. Documentation Subagent: Document order endpoints
   - Independent: Separate module
   - Output: docs/api/orders.md

4. Documentation Subagent: Document authentication
   - Independent: Separate module
   - Output: docs/api/auth.md

Integration (Main Agent):
- Create unified API index
- Ensure consistent formatting
- Generate OpenAPI spec
```

---

# 🔄 COMMUNICATION PROTOCOLS

## Subagent-to-Main Communication

### Standard Update Format

Every subagent uses this format for progress updates:

```markdown
## Progress Update

**Status**: [In Progress / Blocked / Completed]
**Completion**: [X%]

### Completed
- [x] [Task 1]
- [x] [Task 2]

### In Progress
- [ ] [Task 3] - [current status]

### Blocked
- [ ] [Task 4] - [blocker description]

### Next Steps
- [Next action 1]
- [Next action 2]

### Decisions Made
- [Decision 1]: [rationale]
- [Decision 2]: [rationale]

### Questions/Concerns
- [Question 1]
- [Question 2]
```

### Decision Documentation Format

All significant decisions:

```markdown
## Decision: [Decision Title]

**Context**: [Why this decision was needed]

**Options Considered**:
1. **[Option 1]**
   - Pros: [benefits]
   - Cons: [drawbacks]

2. **[Option 2]**
   - Pros: [benefits]
   - Cons: [drawbacks]

**Selected**: [Chosen option]

**Rationale**: [Why this was best choice]

**Impact**:
- [Impact on other components]
- [Impact on timelines]
- [Impact on users]

**Reversibility**: [Can this be changed later? How difficult?]
```

### Blocker Escalation Format

When blocked:

```markdown
## ⚠️ BLOCKER

**What's Blocked**: [Specific task/work that cannot proceed]

**Root Cause**: [Why are we blocked?]

**Attempted Solutions**:
1. [What was tried] - [Result]
2. [What was tried] - [Result]

**Need from Main Agent**:
- [ ] [Specific help needed]
- [ ] [Alternative approach approval]
- [ ] [Additional context/resources]

**Impact if Not Resolved**:
- [What happens if this isn't fixed]

**Workarounds Considered**:
- [Workaround 1] - [Why not viable]
- [Workaround 2] - [Why not viable]
```

## Main-to-Subagent Communication

### Task Assignment Format

```markdown
## Task Assignment

**Objective**: [Clear, specific goal]

**Context**: [Why this task exists, how it fits in larger picture]

**Success Criteria**:
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Measurable criterion 3]

**Constraints**:
- [Technical constraint 1]
- [Technical constraint 2]
- [Time/resource constraint]

**Resources Available**:
- [Existing code/docs to reference]
- [Tools/libraries to use]
- [People to ask if needed]

**Integration Plan**:
- [How your output will be used]
- [Who/what depends on this]
- [When integration will happen]

**Reporting**:
- Update issue with progress every [timeframe]
- Document all decisions immediately
- Escalate blockers ASAP
```

### Blocker Resolution Format

```markdown
## Blocker Resolution

**Blocker**: [Reference to blocker description]

**Resolution**: [How to proceed]

**Approach**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Additional Context**:
- [New information]
- [Clarifications]

**Updated Success Criteria** (if changed):
- [ ] [Updated criterion 1]
- [ ] [Updated criterion 2]

**Proceed when ready**
```

---

# 🎯 PROJECT-SPECIFIC GUIDELINES

## Code Standards for Subagents

All code subagents must follow:

1. **From CLAUDE.md**:
   - SIMPLEX principles (simple first, no premature abstraction)
   - No fake implementations (complete or explicit NotImplementedError)
   - Trust-based programming (validate at boundaries only)
   - Direct naming (no qualifiers like _new, _clean)

2. **Language-Specific**:
   - Python: Use `uv` for packages, `click` for CLI, type hints required
   - JavaScript: [Add project-specific standards]
   - [Other languages as needed]

3. **Architecture**:
   - Follow project structure in CLAUDE.md
   - Use composition over inheritance
   - Dependency injection where appropriate
   - Single responsibility principle

## Documentation Standards for Subagents

All documentation subagents must:

1. **Format**: Use Markdown unless specified otherwise
2. **Structure**:
   - Clear hierarchy (headings)
   - Code examples where relevant
   - Links to related docs
3. **Audience**: Match technical level to intended readers
4. **Completeness**: Cover all success criteria from issue

## Research Standards for Subagents

All research subagents must:

1. **Sources**: Document all sources of information
2. **Verification**: Cross-check important findings
3. **Bias**: Note any limitations or potential biases
4. **Recommendations**: Provide clear, actionable recommendations

---

# 🚦 ESCALATION PATHS

## When Subagents Should Escalate

Immediately escalate (add "needs-review" label) when:

1. **Fundamental Blocker**:
   - Cannot proceed without external input
   - Technical impossibility discovered
   - Requirement conflict found

2. **Scope Change Needed**:
   - Success criteria cannot be met as stated
   - Significant additional work discovered
   - Different approach needed than assigned

3. **Integration Risk**:
   - Conflict with other subagent's work detected
   - Incompatibility with existing systems found
   - Breaking change required

4. **Quality Concern**:
   - Cannot meet quality standards with current approach
   - Security/performance issue discovered
   - Technical debt would be excessive

## Main Agent Response Protocol

When subagent escalates:

1. **Acknowledge within [timeframe]**: "Reviewing blocker"
2. **Gather context**: Review issue, check related work
3. **Make decision**:
   - Provide resolution
   - Adjust scope
   - Reassign if needed
   - Escalate to user if necessary
4. **Document decision**: Update issue with rationale
5. **Unblock**: Remove "needs-review" label, subagent proceeds

---

# 🔍 QUALITY ASSURANCE

## Pre-Completion Checklist for Subagents

Before marking task complete, verify:

- [ ] All success criteria met
- [ ] All decisions documented
- [ ] Code follows project standards (if applicable)
- [ ] Integration instructions clear
- [ ] No unresolved blockers
- [ ] Output is complete (no TODOs or placeholders)
- [ ] Testing done (if applicable)
- [ ] Documentation updated (if applicable)

## Integration Checklist for Main Agent

Before marking multi-agent task complete:

- [ ] All subagent tasks completed
- [ ] Results collected from all issues
- [ ] Integration conflicts resolved
- [ ] Combined solution tested
- [ ] Final documentation complete
- [ ] All subagent issues closed/linked
- [ ] User requirements fully met
- [ ] Audit trail is complete (all work visible on GitHub)

---

# 📊 METRICS AND LEARNING

## Track for Future Improvement

After each multi-agent task:

1. **Effectiveness**:
   - Did parallel execution save time?
   - Were tasks truly independent?
   - Did integration go smoothly?

2. **Communication**:
   - Were decisions well-documented?
   - Were blockers resolved quickly?
   - Was GitHub tracking effective?

3. **Quality**:
   - Did results meet standards?
   - Were there surprises in integration?
   - Would we decompose the same way again?

## Continuous Improvement

Learn and adapt:
- Update this AGENTS.md based on experience
- Refine decomposition patterns that work well
- Improve templates that are unclear
- Add new agent types as patterns emerge

---

# 🎓 PROJECT-SPECIFIC EXAMPLES

## Example 1: [Project-Specific Scenario]

**Scenario**: [Describe a common task in your project]

**Decomposition**:
```
[Show how this would be decomposed for your project]
```

**Subagents**:
- [Agent 1]: [Responsibility]
- [Agent 2]: [Responsibility]
- [Agent 3]: [Responsibility]

**Integration**:
- [How main agent combines results]

## Example 2: [Another Project-Specific Scenario]

**Scenario**: [Describe another common task]

**Decomposition**:
```
[Show decomposition]
```

**Expected Issues Created**:
1. Issue #X: [Subagent 1 task]
2. Issue #Y: [Subagent 2 task]
3. Issue #Z: [Subagent 3 task]

**GitHub Activity**:
```bash
# Show actual gh commands that would be used
```

---

# 🔗 INTEGRATION WITH GLOBAL CLAUDE.MD

This project-specific agent configuration:

- **Extends** global CLAUDE.md principles
- **Specializes** for this project's needs
- **Follows** all core development philosophies
- **Adds** project-specific decomposition patterns

When in conflict, global CLAUDE.md takes precedence, but this file provides project-specific implementation details.

---

# 📝 CUSTOMIZATION INSTRUCTIONS

To adapt this for your specific project:

1. **Update Agent Types**: Add/remove specialized agents based on your project's needs
2. **Add Examples**: Include real scenarios from your project
3. **Set Standards**: Specify your project's code/doc standards
4. **Define Metrics**: What success looks like for your multi-agent tasks
5. **Create Templates**: GitHub issue templates for common decompositions

This is a living document - update it as you learn what works for your project.
