# 🔧 GITHUB CLI PATTERNS FOR MULTI-AGENT ORCHESTRATION

Complete reference for all GitHub CLI commands used in Claude Code multi-agent workflows.

---

# 🎯 CORE WORKFLOW COMMANDS

## 1. Issue Creation for Subagent Tasks

### Basic Subagent Issue

```bash
gh issue create \
  --title "🤖 [Subagent]: Implement user authentication module" \
  --body "$(cat <<'EOF'
## Subagent Task

**Parent Request**: Build user management system
**Assigned To**: Code Implementation Subagent
**Status**: 🟡 Pending
**GitHub Issue**: Will be updated by subagent

## Objective
Implement complete user authentication module with password hashing, JWT tokens, and session management.

## Success Criteria
- [ ] Password hashing using bcrypt
- [ ] JWT token generation and validation
- [ ] Session storage in Redis
- [ ] All functions have type hints
- [ ] No external dependencies beyond specified libraries

## Context
This is part of a larger user management system. Other subagents are working on:
- User profile management (#123)
- Permission system (#124)

Your authentication module will be imported by both.

## Constraints
- Must use `bcrypt` for password hashing
- Must use `PyJWT` for token management
- Must use `redis-py` for session storage
- Must follow project structure: `src/auth/`
- Must not modify existing user database schema

## Expected Output
1. `src/auth/password.py` - Password hashing functions
2. `src/auth/tokens.py` - JWT token functions
3. `src/auth/sessions.py` - Session management functions
4. Integration instructions in issue comment
5. Decision log for any architecture choices

## Resources
- Existing user model: `src/models/user.py`
- Project coding standards: See CLAUDE.md
- Related issues: #123, #124

## Reporting Protocol
1. **Start**: Update label to "status:in-progress", post initial plan
2. **Progress**: Comment on key milestones
3. **Decisions**: Comment with "🔍 Decision:" prefix
4. **Blockers**: Add "needs-review" label, comment with "⚠️ Blocker:" prefix
5. **Complete**: Update to "status:completed", post results summary

---
*Orchestrated by Main Claude Code*
*Created: $(date)*
EOF
)" \
  --label "subagent-task" \
  --label "status:pending" \
  --label "agent-type:code-implementation"
```

### Research/Analysis Issue

```bash
gh issue create \
  --title "🤖 [Subagent]: Analyze performance bottlenecks in data pipeline" \
  --body "$(cat <<'EOF'
## Research/Analysis Task

**Parent Request**: Investigate system slowdowns
**Assigned To**: Research Subagent
**Status**: 🟡 Pending

## Objective
Analyze the data processing pipeline to identify performance bottlenecks and recommend optimizations.

## Research Questions
1. What are the slowest operations in the pipeline?
2. Where is memory usage highest?
3. Are there any blocking I/O operations?
4. What is the current throughput vs. theoretical maximum?

## Success Criteria
- [ ] Complete performance profile of pipeline
- [ ] Top 5 bottlenecks identified with metrics
- [ ] Root cause analysis for each bottleneck
- [ ] Optimization recommendations with expected impact
- [ ] Trade-offs documented for each recommendation

## Data Sources
- Application logs: `/var/log/app/`
- Metrics database: QuestDB on port 9000
- Profiling data: Run `python -m cProfile` on main pipeline
- System metrics: `htop`, `iostat` output

## Scope
**In Scope**:
- Data ingestion pipeline
- Processing transforms
- Database writes

**Out of Scope**:
- Web API performance (separate analysis)
- Frontend rendering
- External API latency (not under our control)

## Output Format
Structured markdown report with:
1. Executive summary
2. Methodology
3. Findings (with metrics)
4. Recommendations (prioritized)
5. Implementation estimates

---
*Created: $(date)*
EOF
)" \
  --label "subagent-task" \
  --label "status:pending" \
  --label "agent-type:research"
```

### Documentation Issue

```bash
gh issue create \
  --title "🤖 [Subagent]: Document authentication API endpoints" \
  --body "$(cat <<'EOF'
## Documentation Task

**Parent Request**: Complete API documentation
**Assigned To**: Documentation Subagent
**Status**: 🟡 Pending

## Objective
Write comprehensive documentation for all authentication-related API endpoints.

## Target Audience
- External API consumers
- Frontend developers integrating with our API
- Technical level: Intermediate (comfortable with REST APIs)

## Scope
**Endpoints to Document**:
- POST /auth/register
- POST /auth/login
- POST /auth/logout
- POST /auth/refresh-token
- GET /auth/verify-email
- POST /auth/reset-password

**For Each Endpoint**:
- HTTP method and path
- Request parameters (query, body, headers)
- Response format (success and error cases)
- Authentication requirements
- Rate limiting rules
- Example requests/responses (curl and Python)

## Success Criteria
- [ ] All endpoints documented
- [ ] Request/response examples provided
- [ ] Error codes explained
- [ ] Authentication flow diagram included
- [ ] Follows documentation template
- [ ] Reviewed for accuracy

## Resources
- API implementation: `src/api/auth.py`
- Existing docs template: `docs/api/template.md`
- OpenAPI spec: `openapi.yaml`

## Output Location
`docs/api/authentication.md`

---
*Created: $(date)*
EOF
)" \
  --label "subagent-task" \
  --label "status:pending" \
  --label "agent-type:documentation"
```

---

# 🔄 PROGRESS TRACKING COMMANDS

## Update Issue Status

### Mark as In Progress

```bash
# Subagent starts work
ISSUE_NUMBER=123
gh issue edit $ISSUE_NUMBER \
  --add-label "status:in-progress" \
  --remove-label "status:pending"

gh issue comment $ISSUE_NUMBER --body "🚀 Started working on this task

## Initial Plan
1. Set up module structure in \`src/auth/\`
2. Implement password hashing with bcrypt
3. Implement JWT token generation
4. Implement session storage
5. Write integration instructions

**Estimated completion**: [timeframe]
**Current focus**: Setting up module structure"
```

### Post Progress Update

```bash
ISSUE_NUMBER=123
gh issue comment $ISSUE_NUMBER --body "📊 Progress Update

## Completed
- [x] Module structure created in \`src/auth/\`
- [x] Password hashing implemented with bcrypt
- [x] Unit tests for password module passing

## In Progress
- [ ] JWT token generation - 60% complete
  - Token creation: Done
  - Token validation: In progress
  - Expiry handling: TODO

## Next Steps
- Complete JWT validation logic
- Implement session storage
- Write integration tests

**Blockers**: None
**ETA for next update**: [timeframe]"
```

### Mark as Completed

```bash
ISSUE_NUMBER=123
gh issue edit $ISSUE_NUMBER \
  --add-label "status:completed" \
  --remove-label "status:in-progress"

gh issue comment $ISSUE_NUMBER --body "✅ Task Completed

## Deliverables
- ✅ \`src/auth/password.py\` - Password hashing and validation
- ✅ \`src/auth/tokens.py\` - JWT token management
- ✅ \`src/auth/sessions.py\` - Redis session storage
- ✅ \`tests/auth/\` - Unit tests (100% coverage)

## Key Decisions Made
1. **Password Hashing**: Used bcrypt with cost factor 12 (see decision #1)
2. **Token Expiry**: Default 24h access token, 30d refresh token (see decision #2)
3. **Session Storage**: Redis with 7-day TTL (see decision #3)

## Success Criteria
- [x] Password hashing using bcrypt ✓
- [x] JWT token generation and validation ✓
- [x] Session storage in Redis ✓
- [x] All functions have type hints ✓
- [x] No external dependencies beyond specified libraries ✓

## Integration Instructions
\`\`\`python
# Import authentication module
from src.auth import hash_password, verify_password, create_token, verify_token

# Hash password during registration
hashed = hash_password(plain_password)

# Verify password during login
is_valid = verify_password(plain_password, hashed)

# Create JWT token
token = create_token(user_id=123, expiry_hours=24)

# Verify token
payload = verify_token(token)  # Returns user_id or raises InvalidTokenError
\`\`\`

## Files Modified
- Created: \`src/auth/__init__.py\`
- Created: \`src/auth/password.py\`
- Created: \`src/auth/tokens.py\`
- Created: \`src/auth/sessions.py\`
- Created: \`tests/auth/test_password.py\`
- Created: \`tests/auth/test_tokens.py\`
- Created: \`tests/auth/test_sessions.py\`

## Dependencies Added
- bcrypt==4.1.2
- PyJWT==2.8.0
- redis==5.0.1

All dependencies already in \`pyproject.toml\`, no changes needed.

---
**Ready for integration**"
```

---

# 📝 DECISION DOCUMENTATION

## Log Architecture Decision

```bash
ISSUE_NUMBER=123
gh issue comment $ISSUE_NUMBER --body "🔍 Decision: Password Hashing Cost Factor

## Context
Need to choose bcrypt cost factor for password hashing. Higher is more secure but slower.

## Options Considered

### Option 1: Cost Factor 10 (bcrypt default)
**Pros**:
- Fast hashing (~50ms per hash)
- Standard default value
- Good security for most use cases

**Cons**:
- May be vulnerable to GPU-based attacks
- Doesn't future-proof against hardware improvements

### Option 2: Cost Factor 12 (recommended 2024)
**Pros**:
- OWASP recommended for 2024
- Balances security and performance (~200ms per hash)
- Resistant to current GPU attacks
- Future-proof for 2-3 years

**Cons**:
- Slightly slower than default
- May need adjustment in future

### Option 3: Cost Factor 14
**Pros**:
- Maximum security
- Very resistant to brute force

**Cons**:
- Slow (~800ms per hash)
- Poor user experience for login
- Overkill for our threat model

## Selected: Cost Factor 12

## Rationale
- Follows current OWASP recommendations
- 200ms hashing time is acceptable for our use case (login/registration)
- Balances security with user experience
- We're not storing highly sensitive data (no financial/health records)

## Impact
- Average login time: +200ms
- Registration time: +200ms
- No impact on other operations (token validation doesn't use bcrypt)

## Implementation
\`\`\`python
bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt(rounds=12))
\`\`\`

## Reversibility
Easy to change - just modify the \`rounds\` parameter. Existing hashed passwords will still work (bcrypt stores the cost factor in the hash).

**Decision made**: $(date)"
```

## Log Implementation Decision

```bash
ISSUE_NUMBER=123
gh issue comment $ISSUE_NUMBER --body "🔍 Decision: JWT Token Storage Location

## Context
Need to decide where clients should store JWT tokens.

## Options Considered

### Option 1: localStorage
**Pros**: Simple, persists across browser sessions
**Cons**: Vulnerable to XSS attacks

### Option 2: httpOnly Cookie
**Pros**: Not accessible to JavaScript (XSS protection)
**Cons**: Requires CORS configuration, CSRF protection needed

### Option 3: In-memory only (no persistence)
**Pros**: Most secure, no persistence risk
**Cons**: User must re-login on page refresh

## Selected: httpOnly Cookie with CSRF protection

## Rationale
- Our API already uses cookies for session management
- XSS is a bigger threat than CSRF in our environment
- We can implement CSRF tokens easily
- Provides good UX (persists across page refreshes)

## Impact
- Backend must set \`httpOnly\`, \`secure\`, \`sameSite\` flags
- Must implement CSRF token mechanism
- Frontend doesn't need to manage token storage
- Must configure CORS properly for cross-domain requests

## Implementation Notes
Token is set as cookie in response:
\`\`\`python
response.set_cookie(
    'access_token',
    value=token,
    httpOnly=True,
    secure=True,  # HTTPS only
    sameSite='Strict',
    max_age=86400  # 24 hours
)
\`\`\`

**Decision made**: $(date)"
```

---

# ⚠️ BLOCKER ESCALATION

## Report Blocker

```bash
ISSUE_NUMBER=123
gh issue edit $ISSUE_NUMBER --add-label "needs-review"

gh issue comment $ISSUE_NUMBER --body "⚠️ BLOCKER: Cannot Access Redis in Test Environment

## What's Blocked
Cannot complete session storage implementation and testing.

## Root Cause
Redis server is not running in test environment. Tests fail when trying to connect to \`localhost:6379\`.

## Attempted Solutions
1. **Used pytest-redis plugin** - Failed: Plugin doesn't support Redis 7.x
   \`\`\`bash
   pip install pytest-redis
   # Error: incompatible with redis-py 5.0
   \`\`\`

2. **Docker Compose for test Redis** - Failed: CI environment doesn't support Docker
   \`\`\`bash
   docker-compose up redis-test
   # Error: Docker not available in CI
   \`\`\`

3. **Mocked Redis with fakeredis** - Partial success but has limitations
   \`\`\`python
   from fakeredis import FakeRedis
   # Works for basic operations but missing some Redis 7 features
   \`\`\`

## Need from Main Agent
- [ ] **Decision**: Is fakeredis acceptable for tests? (Pro: Works in CI. Con: Not 100% Redis compatible)
- [ ] **Or**: Set up real Redis in CI environment
- [ ] **Or**: Adjust testing strategy to skip Redis-dependent tests in CI

## Impact if Not Resolved
- Session storage module cannot be tested
- Integration tests cannot run
- Task cannot be marked complete per success criteria

## Workarounds Considered

### Workaround 1: Use fakeredis for tests
**Pros**: Works immediately, no infrastructure changes
**Cons**: Not 100% Redis compatible, may miss edge cases
**Risk**: Medium - most Redis operations are covered

### Workaround 2: Mock Redis client entirely
**Pros**: Full control over test behavior
**Cons**: Not testing real Redis integration
**Risk**: High - may miss real Redis issues

### Workaround 3: Skip CI tests, run locally only
**Pros**: Can use real Redis locally
**Cons**: CI pipeline broken, no automated testing
**Risk**: Unacceptable - breaks CI/CD

## Recommendation
Use fakeredis for tests with explicit documentation of limitations. Add TODO to replace with real Redis tests once CI infrastructure supports it.

**Blocked since**: $(date)
**Severity**: Medium (can proceed with workaround, but not ideal)"
```

## Resolve Blocker

```bash
ISSUE_NUMBER=123
gh issue edit $ISSUE_NUMBER --remove-label "needs-review"

gh issue comment $ISSUE_NUMBER --body "🔧 Blocker Resolved: Use fakeredis for Now

## Resolution
Proceed with fakeredis for testing. This is an acceptable trade-off given our constraints.

## Approach
1. Use \`fakeredis\` in test environment
2. Document limitations in test comments
3. Create follow-up issue for real Redis in CI
4. Mark tests with \`@pytest.mark.redis\` for future filtering

## Additional Context
fakeredis covers 95% of our Redis usage:
- ✅ String operations (get/set)
- ✅ Expiry (TTL)
- ✅ Hash operations
- ❌ Some advanced features (pub/sub) - but we don't use them

## Implementation
\`\`\`python
# conftest.py
import pytest
from fakeredis import FakeRedis

@pytest.fixture
def redis_client():
    return FakeRedis()

# Mark tests that need real Redis
@pytest.mark.redis
def test_session_with_real_redis():
    # Will skip in CI, run locally
    pass
\`\`\`

## Updated Success Criteria
- [x] Session storage implementation complete
- [x] Tests passing with fakeredis
- [x] Limitations documented
- [x] Follow-up issue created (#125) for real Redis in CI

## Follow-up Issue
Created #125: \"Set up Redis in CI environment for integration tests\"

**You can proceed with implementation. Unblocked as of**: $(date)"
```

---

# 🔍 MONITORING COMMANDS

## Check All Subagent Status

```bash
# Get overview of all subagent tasks
gh issue list \
  --label "subagent-task" \
  --json number,title,labels,createdAt,updatedAt \
  --jq '.[] | {
    number: .number,
    title: .title,
    status: (.labels[] | select(.name | startswith("status:")) | .name),
    age_hours: ((now - (.createdAt | fromdateiso8601)) / 3600 | floor),
    updated_hours_ago: ((now - (.updatedAt | fromdateiso8601)) / 3600 | floor)
  }'
```

## Find Blockers Needing Review

```bash
# Get all blocked subagents
gh issue list \
  --label "subagent-task" \
  --label "needs-review" \
  --json number,title,comments \
  --jq '.[] | {
    issue: .number,
    title: .title,
    blocker: (.comments[] | select(.body | startswith("⚠️ BLOCKER")) | .body)
  }'
```

## Check Subagent Progress

```bash
# Get latest progress update for specific subagent
ISSUE_NUMBER=123
gh issue view $ISSUE_NUMBER \
  --json number,title,body,comments \
  --jq '{
    issue: .number,
    title: .title,
    latest_update: (.comments | last | .body)
  }'
```

## List Completed Subagents Ready for Integration

```bash
# Find all completed subagent tasks
gh issue list \
  --label "subagent-task" \
  --label "status:completed" \
  --json number,title,comments \
  --jq '.[] | {
    issue: .number,
    title: .title,
    results: (.comments[] | select(.body | startswith("✅")) | .body)
  }'
```

---

# 🎯 INTEGRATION COMMANDS

## Collect All Subagent Results

```bash
# Collect results from all completed subagents
COMPLETED_ISSUES=$(gh issue list --label "subagent-task" --label "status:completed" --json number --jq '.[].number')

echo "# Subagent Results Collection"
echo ""

for issue in $COMPLETED_ISSUES; do
  echo "## Issue #$issue"
  gh issue view $issue --json title,comments --jq '
    "### " + .title,
    "",
    "#### Deliverables",
    (.comments[] | select(.body | startswith("✅")) | .body | split("\n") | .[] | select(startswith("- ✅"))),
    "",
    "#### Key Decisions",
    (.comments[] | select(.body | startswith("🔍 Decision:")) | "- " + (.body | split("\n")[0])),
    ""
  '
  echo ""
done
```

## Create Integration Summary Issue

```bash
# After synthesizing subagent results
PARENT_TASK="Implement user management system"
SUBAGENT_ISSUES="123 124 125"

gh issue create \
  --title "🎯 Integration: $PARENT_TASK" \
  --body "$(cat <<EOF
## Multi-Agent Integration Summary

**Parent Task**: $PARENT_TASK
**Completion Date**: $(date)

## Subagent Contributions

### Issue #123: User Authentication Module
**Deliverables**:
- Password hashing and validation
- JWT token management
- Session storage

**Key Decisions**:
- Password cost factor: 12 (OWASP 2024)
- Token storage: httpOnly cookies
- Session TTL: 7 days

### Issue #124: User Profile Management
**Deliverables**:
- Profile CRUD operations
- Avatar upload handling
- Privacy settings

**Key Decisions**:
- Avatar storage: S3 with CloudFront CDN
- Privacy defaults: Private by default
- Profile update rate limiting: 10/hour

### Issue #125: Permission System
**Deliverables**:
- Role-based access control
- Permission checking middleware
- Admin dashboard integration

**Key Decisions**:
- Roles: Admin, Moderator, User (simple 3-tier)
- Permission caching: Redis with 5-min TTL
- Hierarchical permissions: Admin inherits all

## Integration Work Performed

### 1. Module Integration
Combined all subagent outputs into unified \`src/user_management/\` module:
\`\`\`
src/user_management/
├── __init__.py          # Public API exports
├── auth/               # From #123
├── profile/            # From #124
└── permissions/        # From #125
\`\`\`

### 2. Conflict Resolution
**Conflict**: Both auth and permissions needed user lookup
**Resolution**: Created shared \`src/user_management/models.py\` for common user model

### 3. Integration Tests
Created \`tests/integration/test_user_management.py\` covering:
- [ ] Registration → Profile creation → Permission assignment flow
- [ ] Login → Token validation → Permission check flow
- [ ] Profile update with permission verification
- [ ] All integration tests passing

### 4. API Endpoints
Unified API in \`src/api/users.py\`:
- POST /users/register (auth + profile)
- POST /users/login (auth + permissions)
- GET /users/me (profile + permissions)
- PUT /users/me (profile with permission check)

## Final Deliverables

- ✅ Complete user management system
- ✅ All subagent success criteria met
- ✅ Integration tests passing
- ✅ API documentation updated
- ✅ Deployment guide created

## Related Issues
Integrates: #123, #124, #125
Closes: #120 (original request)

## Next Steps
- [ ] Deploy to staging
- [ ] Run load tests
- [ ] Update production docs

---
*Main Claude Code Integration*
*Completed: $(date)*
EOF
)" \
  --label "integration" \
  --label "multi-agent"

# Get the issue number of the integration summary
INTEGRATION_ISSUE=$(gh issue list --label "integration" --limit 1 --json number --jq '.[0].number')

echo "Created integration summary: #$INTEGRATION_ISSUE"
```

## Close Subagent Issues After Integration

```bash
INTEGRATION_ISSUE=126  # The integration summary issue
SUBAGENT_ISSUES=(123 124 125)

for issue in "${SUBAGENT_ISSUES[@]}"; do
  gh issue close $issue --comment "✅ Integrated in #$INTEGRATION_ISSUE

This subagent task has been successfully integrated into the final solution. See integration summary for details on how this work was incorporated.

**Integration Status**: Complete
**Final Location**: See #$INTEGRATION_ISSUE for file locations
**Closed**: $(date)"

  echo "Closed #$issue"
done

echo "All subagent issues closed and linked to integration #$INTEGRATION_ISSUE"
```

---

# 🏷️ LABEL MANAGEMENT

## Create Standard Labels

```bash
# Create all standard labels for multi-agent orchestration
# Run once per repository

# Core labels
gh label create "subagent-task" --color "0E8A16" --description "Issue assigned to a subagent" --force
gh label create "integration" --color "1D76DB" --description "Main agent integration work" --force
gh label create "multi-agent" --color "5319E7" --description "Multi-agent orchestration" --force

# Status labels
gh label create "status:pending" --color "FBCA04" --description "Task created but not started" --force
gh label create "status:in-progress" --color "0E8A16" --description "Subagent actively working" --force
gh label create "status:completed" --color "0E8A16" --description "Task finished successfully" --force
gh label create "status:blocked" --color "D93F0B" --description "Waiting on external input" --force

# Agent type labels
gh label create "agent-type:code-implementation" --color "C2E0C6" --description "Code implementation subagent" --force
gh label create "agent-type:research" --color "BFD4F2" --description "Research/analysis subagent" --force
gh label create "agent-type:documentation" --color "D4C5F9" --description "Documentation subagent" --force
gh label create "agent-type:testing" --color "FEF2C0" --description "Testing/validation subagent" --force
gh label create "agent-type:refactoring" --color "E99695" --description "Refactoring subagent" --force

# Action labels
gh label create "needs-review" --color "D93F0B" --description "Requires main agent attention" --force
gh label create "integration-ready" --color "0E8A16" --description "Results ready for synthesis" --force

echo "All multi-agent orchestration labels created successfully"
```

## Apply Labels to Issues

```bash
# Add status label
gh issue edit 123 --add-label "status:in-progress"

# Change status (remove old, add new)
gh issue edit 123 --remove-label "status:pending" --add-label "status:in-progress"

# Add agent type
gh issue edit 123 --add-label "agent-type:code-implementation"

# Mark as needing review
gh issue edit 123 --add-label "needs-review"

# Mark as ready for integration
gh issue edit 123 --add-label "integration-ready"
```

---

# 📊 REPORTING COMMANDS

## Generate Multi-Agent Report

```bash
# Generate comprehensive report of all multi-agent activity
cat << 'EOF' | bash
#!/bin/bash

echo "# Multi-Agent Orchestration Report"
echo "Generated: $(date)"
echo ""

echo "## Active Subagents"
gh issue list --label "subagent-task" --label "status:in-progress" --json number,title,createdAt | \
  jq -r '.[] | "- #\(.number): \(.title) (started: \(.createdAt | fromdateiso8601 | strftime("%Y-%m-%d %H:%M")))"'
echo ""

echo "## Blocked Subagents"
gh issue list --label "subagent-task" --label "needs-review" --json number,title | \
  jq -r '.[] | "- #\(.number): \(.title) ⚠️ NEEDS REVIEW"'
echo ""

echo "## Completed Subagents"
gh issue list --label "subagent-task" --label "status:completed" --json number,title,closedAt | \
  jq -r '.[] | "- #\(.number): \(.title) ✅"'
echo ""

echo "## Integration Summaries"
gh issue list --label "integration" --json number,title,createdAt | \
  jq -r '.[] | "- #\(.number): \(.title) (completed: \(.createdAt | fromdateiso8601 | strftime("%Y-%m-%d")))"'
echo ""

echo "## Statistics"
TOTAL=$(gh issue list --label "subagent-task" --json number | jq 'length')
IN_PROGRESS=$(gh issue list --label "subagent-task" --label "status:in-progress" --json number | jq 'length')
COMPLETED=$(gh issue list --label "subagent-task" --label "status:completed" --json number | jq 'length')
BLOCKED=$(gh issue list --label "subagent-task" --label "needs-review" --json number | jq 'length')

echo "- Total subagent tasks: $TOTAL"
echo "- In progress: $IN_PROGRESS"
echo "- Completed: $COMPLETED"
echo "- Blocked: $BLOCKED"
EOF
```

---

# 🔧 UTILITY COMMANDS

## Search Subagent Decisions

```bash
# Find all decisions made by subagents
gh issue list --label "subagent-task" --json number,comments | \
  jq -r '.[] | .number as $num | .comments[] | select(.body | startswith("🔍 Decision:")) |
  "Issue #\($num): " + (.body | split("\n")[0])'
```

## Find Stale Subagent Tasks

```bash
# Find subagent tasks not updated in 24+ hours
gh issue list --label "subagent-task" --label "status:in-progress" --json number,title,updatedAt | \
  jq -r 'map(select((now - (.updatedAt | fromdateiso8601)) > 86400)) |
  .[] | "#\(.number): \(.title) - Last update: \(.updatedAt | fromdateiso8601 | strftime("%Y-%m-%d %H:%M")) ⚠️ STALE"'
```

## Export Subagent Work for Audit

```bash
# Export all subagent work to JSON for audit
gh issue list --label "subagent-task" --json number,title,body,comments,labels,createdAt,updatedAt,closedAt > subagent_audit_$(date +%Y%m%d).json

echo "Exported to: subagent_audit_$(date +%Y%m%d).json"
```

---

# 📝 TEMPLATES FOR COMMON SCENARIOS

## Template: Simple 3-Subagent Decomposition

```bash
#!/bin/bash
# Quick script to create 3 parallel subagent tasks

PARENT_TASK="$1"
TASK1_TITLE="$2"
TASK1_OBJECTIVE="$3"
TASK2_TITLE="$4"
TASK2_OBJECTIVE="$5"
TASK3_TITLE="$6"
TASK3_OBJECTIVE="$7"

create_subagent_issue() {
  local title=$1
  local objective=$2

  gh issue create \
    --title "🤖 [Subagent]: $title" \
    --body "## Subagent Task

**Parent Request**: $PARENT_TASK
**Status**: 🟡 Pending

## Objective
$objective

## Success Criteria
- [ ] Objective completed
- [ ] All decisions documented
- [ ] Integration instructions provided

---
*Created: $(date)*" \
    --label "subagent-task" \
    --label "status:pending"
}

echo "Creating subagent tasks for: $PARENT_TASK"

ISSUE1=$(create_subagent_issue "$TASK1_TITLE" "$TASK1_OBJECTIVE")
ISSUE2=$(create_subagent_issue "$TASK2_TITLE" "$TASK2_OBJECTIVE")
ISSUE3=$(create_subagent_issue "$TASK3_TITLE" "$TASK3_OBJECTIVE")

echo "Created issues: $ISSUE1, $ISSUE2, $ISSUE3"
echo "Track with: gh issue list --label subagent-task"
```

Usage:
```bash
./create_3_subagents.sh \
  "Build user dashboard" \
  "Implement user statistics widget" "Create widget showing user activity stats" \
  "Implement notification panel" "Create panel showing recent notifications" \
  "Implement settings page" "Create page for user preferences"
```

---

# 🎯 COMPLETE WORKFLOW EXAMPLE

```bash
#!/bin/bash
# Complete multi-agent workflow from start to finish

set -e

echo "🎯 Multi-Agent Orchestration Workflow"
echo "======================================"
echo ""

# 1. Create subagent tasks
echo "Step 1: Creating subagent tasks..."
ISSUE1=$(gh issue create --title "🤖 [Subagent]: Task 1" --body "..." --label "subagent-task" --label "status:pending" --json number --jq '.number')
ISSUE2=$(gh issue create --title "🤖 [Subagent]: Task 2" --body "..." --label "subagent-task" --label "status:pending" --json number --jq '.number')
ISSUE3=$(gh issue create --title "🤖 [Subagent]: Task 3" --body "..." --label "subagent-task" --label "status:pending" --json number --jq '.number')

echo "Created issues: #$ISSUE1, #$ISSUE2, #$ISSUE3"
echo ""

# 2. Subagents start work (simulated with status update)
echo "Step 2: Subagents starting work..."
for issue in $ISSUE1 $ISSUE2 $ISSUE3; do
  gh issue edit $issue --remove-label "status:pending" --add-label "status:in-progress"
  gh issue comment $issue --body "🚀 Started working on this task"
done
echo ""

# 3. Monitor progress
echo "Step 3: Monitoring progress..."
gh issue list --label "subagent-task" --label "status:in-progress"
echo ""

# 4. Check for blockers
echo "Step 4: Checking for blockers..."
BLOCKED=$(gh issue list --label "subagent-task" --label "needs-review" --json number --jq '. | length')
if [ $BLOCKED -gt 0 ]; then
  echo "⚠️ $BLOCKED subagent(s) blocked - needs review"
  gh issue list --label "needs-review" --label "subagent-task"
else
  echo "✅ No blockers"
fi
echo ""

# 5. Collect completed results
echo "Step 5: Collecting results from completed subagents..."
gh issue list --label "subagent-task" --label "status:completed" --json number,title
echo ""

# 6. Create integration summary
echo "Step 6: Creating integration summary..."
INTEGRATION_ISSUE=$(gh issue create \
  --title "🎯 Integration: Parent Task Name" \
  --body "Integration of #$ISSUE1, #$ISSUE2, #$ISSUE3" \
  --label "integration" \
  --label "multi-agent" \
  --json number --jq '.number')

echo "Created integration summary: #$INTEGRATION_ISSUE"
echo ""

# 7. Close subagent issues
echo "Step 7: Closing subagent issues..."
for issue in $ISSUE1 $ISSUE2 $ISSUE3; do
  gh issue close $issue --comment "Integrated in #$INTEGRATION_ISSUE"
done

echo ""
echo "✅ Multi-agent workflow complete!"
echo "Integration summary: #$INTEGRATION_ISSUE"
```

---

This comprehensive GitHub CLI patterns guide provides all necessary commands for transparent multi-agent orchestration in Claude Code.
