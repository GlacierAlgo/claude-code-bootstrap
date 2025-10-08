# 🎯 ORCHESTRATOR TEMPLATE: COPY THIS TO YOUR PROJECT

## Ready-to-Use Template for Adding Multi-Agent Orchestration

---

# 📦 WHAT YOU GET

This template provides everything you need to add command-based multi-agent orchestration to your existing project:

- ✅ Complete `.orchestrator/` directory structure
- ✅ All 6 command scripts (init, plan, execute, status, integrate, cleanup)
- ✅ 4 utility libraries (common, github, claude, state)
- ✅ Configuration file
- ✅ Issue templates
- ✅ AGENTS.md template
- ✅ Documentation

---

# 🚀 INSTALLATION (3 Steps)

## Step 1: Copy Template to Your Project

```bash
# Navigate to your existing project
cd /path/to/your/existing/project

# Copy the orchestrator template
cp -r /path/to/cc_bootstrap/.orchestrator ./.orchestrator

# Copy AGENTS.md template
cp /path/to/cc_bootstrap/AGENTS.md ./AGENTS.md

# Copy GitHub documentation
mkdir -p .github
cp /path/to/cc_bootstrap/.github/ORCHESTRATOR.md ./.github/ORCHESTRATOR.md

# Make scripts executable
chmod +x .orchestrator/commands/*.sh
chmod +x .orchestrator/commands/lib/*.sh
```

## Step 2: Create Command Symlink

```bash
# Add 'orchestrate' command to your PATH
sudo ln -sf "$(pwd)/.orchestrator/commands/orchestrate.sh" /usr/local/bin/orchestrate

# Verify installation
orchestrate --help
```

## Step 3: Initialize GitHub Integration

```bash
# Create GitHub labels and verify prerequisites
orchestrate init
```

**Output**:
```
🚀 Initializing multi-agent orchestration...

✓ Checking prerequisites
✓ Created .orchestrator/ directory
✓ Created GitHub labels
✓ Configured orchestration

✅ Orchestration initialized successfully!
```

Done! You can now use multi-agent orchestration.

---

# 📁 TEMPLATE STRUCTURE

## What Gets Added to Your Project

```
your-project/
├── .orchestrator/              # ← NEW: Orchestration system
│   ├── commands/              # Command scripts
│   │   ├── orchestrate.sh    # Main dispatcher
│   │   ├── init.sh
│   │   ├── plan.sh
│   │   ├── execute.sh
│   │   ├── status.sh
│   │   ├── integrate.sh
│   │   ├── cleanup.sh
│   │   └── lib/              # Utility libraries
│   │       ├── common.sh
│   │       ├── github.sh
│   │       ├── claude.sh
│   │       └── state.sh
│   ├── templates/            # Issue templates
│   │   ├── subagent_task.md
│   │   ├── integration.md
│   │   └── decision.md
│   ├── state/                # Runtime state (gitignored)
│   ├── logs/                 # Logs (gitignored)
│   ├── archive/              # Completed orchestrations
│   └── config.yaml           # Configuration
├── AGENTS.md                  # ← NEW: Agent definitions
├── .github/
│   └── ORCHESTRATOR.md        # ← NEW: GitHub guide
└── .gitignore                 # ← UPDATED: Ignore state/logs

# Your existing files unchanged
```

---

# ⚙️ CONFIGURATION

## .orchestrator/config.yaml

Customize these settings for your project:

```yaml
# Multi-Agent Orchestration Configuration

github:
  # Labels to use
  labels:
    subagent_task: "subagent-task"
    status_pending: "status:pending"
    status_in_progress: "status:in-progress"
    status_completed: "status:completed"
    needs_review: "needs-review"
    integration: "integration"

  # Issue title prefix
  issue_prefix: "🤖 [Subagent]: "

claude:
  # CLI command
  command: "claude"

  # Subagent timeout (minutes)
  timeout: 60

  # Log level
  log_level: "info"

orchestration:
  # Maximum concurrent subagents
  max_concurrent: 5

  # Status check interval (seconds)
  status_check_interval: 60

  # Archive completed orchestrations after (days)
  archive_after_days: 30
```

---

# 📝 CUSTOMIZE AGENTS.MD

## Template Structure

Your `AGENTS.md` should define:

1. **Project-specific agent types**
2. **Common decomposition patterns**
3. **Success criteria templates**
4. **Communication standards**

## Example Customization

```markdown
# 🤖 PROJECT AGENT CONFIGURATION

## For [Your Project Name]

### Agent Type: API Endpoint Agent
Use when: Adding new REST API endpoints

Success Criteria:
- [ ] Endpoint responds correctly
- [ ] Input validation works
- [ ] Tests pass
- [ ] Documentation updated

### Agent Type: Frontend Component Agent
Use when: Building new React components

Success Criteria:
- [ ] Component renders correctly
- [ ] Props validated
- [ ] Tests pass
- [ ] Storybook story added

### Agent Type: Database Migration Agent
Use when: Creating database schema changes

Success Criteria:
- [ ] Migration script works
- [ ] Rollback script works
- [ ] Tests pass
- [ ] No data loss

## Common Decomposition Patterns

### Pattern: Full-Stack Feature
When adding a feature with API + UI + tests:
- Subagent 1: Implement backend API
- Subagent 2: Implement frontend UI
- Subagent 3: Write integration tests

Integration: Combine and verify end-to-end flow

### Pattern: Bug Investigation
When investigating complex bugs:
- Subagent 1: Analyze backend logs
- Subagent 2: Analyze frontend errors
- Subagent 3: Review recent changes

Integration: Identify root cause and fix
```

---

# 🎯 USAGE EXAMPLES

## Example 1: Build 3 API Endpoints

```bash
# 1. Create plan
orchestrate plan "Build REST API with /users, /products, and /orders endpoints"

# 2. Execute (spawns 3 Claude Code processes)
orchestrate execute

# 3. Monitor progress
orchestrate status

# 4. When complete, integrate
orchestrate integrate

# 5. Cleanup
orchestrate cleanup
```

**Time saved**: ~50% vs sequential development

## Example 2: Multi-Source Data Analysis

```bash
# Analyze 3 data sources in parallel
orchestrate plan "Analyze database logs, API metrics, and user feedback to identify performance bottlenecks"

orchestrate execute

orchestrate status --watch  # Monitor continuously

orchestrate integrate  # Synthesize findings

orchestrate cleanup
```

**Benefit**: Comprehensive analysis in parallel

## Example 3: Documentation Sprint

```bash
# Document multiple modules in parallel
orchestrate plan "Create API documentation for authentication, users, and products modules"

orchestrate execute

orchestrate status

orchestrate integrate  # Create unified doc system

orchestrate cleanup
```

**Benefit**: Consistent, comprehensive docs faster

---

# 🔍 MONITORING

## Check Progress

```bash
# Quick status
orchestrate status

# Detailed status
orchestrate status --verbose

# Continuous monitoring
orchestrate status --watch
```

## GitHub Dashboard

View all orchestration work:
```
https://github.com/<user>/<repo>/issues?q=is:issue+label:subagent-task
```

## Logs

```bash
# All logs
tail -f .orchestrator/logs/*.log

# Specific subagent
tail -f .orchestrator/logs/agent_<issue-number>.log

# Main orchestrator
tail -f .orchestrator/logs/main.log
```

---

# 🛠️ MAINTENANCE

## Update Configuration

Edit `.orchestrator/config.yaml` to adjust:
- Maximum concurrent subagents
- Status check interval
- Timeout settings
- Log levels

## Update Agent Patterns

Edit `AGENTS.md` to add:
- New agent types
- New decomposition patterns
- Updated success criteria
- Project-specific guidelines

## Archive Old Orchestrations

Archives are stored in `.orchestrator/archive/`:
```bash
ls -lh .orchestrator/archive/

# View archived orchestration
cat .orchestrator/archive/orch_YYYYMMDD_HHMMSS.json
```

Clean up old archives:
```bash
# Delete archives older than 30 days
find .orchestrator/archive -name "*.json" -mtime +30 -delete
find .orchestrator/archive -name "*.tar.gz" -mtime +30 -delete
```

---

# 🚨 TROUBLESHOOTING

## Issue: "Command not found: orchestrate"

**Fix**:
```bash
# Recreate symlink
sudo ln -sf "$(pwd)/.orchestrator/commands/orchestrate.sh" /usr/local/bin/orchestrate

# Verify
which orchestrate
```

## Issue: "No plan found"

**Fix**:
```bash
# Create a plan first
orchestrate plan "your task description"
```

## Issue: Subagent not updating GitHub

**Fix**:
```bash
# Check GitHub CLI authentication
gh auth status

# If not authenticated
gh auth login
```

## Issue: Process appears stuck

**Check**:
```bash
# View logs
tail -f .orchestrator/logs/agent_<issue-number>.log

# Check GitHub issue
gh issue view <issue-number> --comments
```

---

# 📊 WHEN TO USE

## Good Use Cases ✅

- **Independent features**: Can be built in parallel
- **Module-based work**: Separate, non-overlapping modules
- **Multi-source analysis**: Different data sources to analyze
- **Documentation sprints**: Multiple docs to write
- **Parallel implementation**: Same pattern, different targets

## Bad Use Cases ❌

- **Sequential dependencies**: Steps must happen in order
- **Single responsibility**: One focused task
- **Highly coupled code**: Too many interdependencies
- **Trivial tasks**: Overhead exceeds benefit
- **Real-time interactive**: Need immediate user feedback

---

# 📚 DOCUMENTATION LINKS

## In This Repository

- **COMMAND_SYSTEM_DESIGN.md**: Complete technical design
- **IMPLEMENTATION_QUICKSTART.md**: Quick start guide
- **COMMAND_SYSTEM_INDEX.md**: Documentation navigation
- **MULTI_AGENT_ORCHESTRATION.md**: Orchestration principles
- **AGENTS.md**: Agent definitions template
- **GITHUB_CLI_PATTERNS.md**: GitHub CLI reference
- **EXAMPLE_SCENARIO.md**: Detailed walkthrough

## In Your Project (After Installation)

- **.github/ORCHESTRATOR.md**: GitHub integration guide
- **AGENTS.md**: Your project-specific patterns
- **.orchestrator/config.yaml**: Configuration

---

# ✅ POST-INSTALLATION CHECKLIST

After installing the template:

- [ ] `.orchestrator/` directory created
- [ ] `AGENTS.md` copied and customized
- [ ] `.github/ORCHESTRATOR.md` copied
- [ ] `orchestrate` command available
- [ ] GitHub labels created
- [ ] Config customized for your project
- [ ] .gitignore updated
- [ ] Tested with simple orchestration

**All checked?** You're ready! 🎉

---

# 🔄 UPDATE WORKFLOW

## Getting Updates from Template

When the template is updated:

```bash
# 1. Backup your customizations
cp AGENTS.md AGENTS.md.backup
cp .orchestrator/config.yaml .orchestrator/config.yaml.backup

# 2. Pull latest template
cp -r /path/to/cc_bootstrap/.orchestrator ./.orchestrator

# 3. Restore customizations
# Manually merge your AGENTS.md changes
# Manually merge your config.yaml changes

# 4. Test
orchestrate --help
```

---

# 🎓 LEARNING PATH

## Week 1: Basic Usage
- Install template
- Run first orchestration
- Understand GitHub integration
- Practice with simple tasks

## Week 2: Customization
- Customize AGENTS.md
- Define project patterns
- Adjust configuration
- Create issue templates

## Week 3: Advanced Usage
- Handle blockers
- Optimize decompositions
- Monitor efficiently
- Practice recovery

## Week 4: Team Adoption
- Train team members
- Establish guidelines
- Document patterns
- Share learnings

---

# 🚀 NEXT STEPS

1. **Install**: Follow 3-step installation above
2. **Customize**: Edit AGENTS.md for your project
3. **Test**: Run a simple 3-task orchestration
4. **Learn**: Read COMMAND_SYSTEM_DESIGN.md for details
5. **Use**: Integrate into your workflow

---

**Questions?** See **COMMAND_SYSTEM_INDEX.md** for navigation to all documentation.

**Ready to start?** Run: `orchestrate init`
