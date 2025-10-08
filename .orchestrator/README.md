## Claude Code Multi-Agent Orchestrator

**Version**: 2.0.0
**Status**: Production Ready

### What This Is

A command-based system that enables Claude Code to orchestrate multiple specialized subagents working in parallel on complex tasks, with complete transparency via GitHub Issues.

### Quick Start

```bash
# 1. Initialize in your project
orchestrate init

# 2. Create a plan
orchestrate plan "Build REST API with authentication, users, and admin"

# 3. Execute the plan
orchestrate execute

# 4. Monitor progress
orchestrate status

# 5. Integrate results
orchestrate integrate

# 6. Clean up
orchestrate cleanup
```

### Available Commands

- **`orchestrate init`** - Set up orchestrator in current project
- **`orchestrate plan <task>`** - Create multi-agent decomposition
- **`orchestrate execute`** - Spawn subagents to work in parallel
- **`orchestrate status`** - Check progress of current orchestration
- **`orchestrate integrate`** - Collect and integrate subagent results
- **`orchestrate cleanup`** - Archive completed work

### How It Works

1. **Plan**: Main Claude Code analyzes your complex task and creates a decomposition
2. **GitHub Issues**: One issue per subtask, visible to humans
3. **Execute**: Subagents are spawned, each bound to a specific issue
4. **Monitor**: Progress tracked via GitHub issue updates
5. **Integrate**: Main Claude Code synthesizes all results
6. **Complete**: Full audit trail preserved on GitHub

### File Structure

```
.orchestrator/
├── commands/          # All command scripts
│   ├── orchestrate.sh # Main entry point
│   ├── init.sh
│   ├── plan.sh
│   ├── execute.sh
│   ├── status.sh
│   ├── integrate.sh
│   └── cleanup.sh
├── lib/               # Utility libraries
│   ├── common.sh      # Common functions
│   ├── github.sh      # GitHub integration
│   ├── claude.sh      # Claude Code process management
│   └── state.sh       # State management
├── templates/         # Issue templates
├── state/             # Runtime state (gitignored)
├── logs/              # Logs (gitignored)
├── archive/           # Completed orchestrations
└── config.yaml        # Configuration
```

### Configuration

Edit `.orchestrator/config.yaml` to customize:
- Maximum parallel agents
- Agent timeout
- Auto-integration
- GitHub labels
- And more...

### Complete Documentation

For complete documentation, see the main repository:
https://github.com/GlacierAlgo/claude-code-bootstrap

Key documents:
- **COMMAND_SYSTEM_SUMMARY.md** - Executive summary
- **IMPLEMENTATION_QUICKSTART.md** - 5-minute setup guide
- **COMMAND_SYSTEM_DESIGN.md** - Complete technical design

### Support

- **Local docs**: See markdown files in repository root
- **GitHub**: https://github.com/GlacierAlgo/claude-code-bootstrap/issues
- **Examples**: See EXAMPLE_SCENARIO.md for complete walkthrough

### License

MIT License - See LICENSE file in repository root

---

*Built with Claude Code | Transparent by Design | Production Ready*
