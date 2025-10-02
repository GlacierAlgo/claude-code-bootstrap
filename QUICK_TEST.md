# 🚀 快速测试：使用本地 gh CLI 的多智能体协同

## ✅ 你的环境已就绪

- **gh CLI**: v2.73.0 ✅
- **认证状态**: 已登录 (GlacierAlgo) ✅
- **Token权限**: `repo` (足够) ✅
- **协议**: SSH ✅

## 🎯 快速测试流程

### 1. 创建测试Labels（一次性设置）

```bash
# 创建多智能体协同所需的labels
gh label create "subagent-task" --color "0E8A16" --description "Issue assigned to a subagent" --force
gh label create "status:pending" --color "FBCA04" --description "Task created but not started" --force
gh label create "status:in-progress" --color "1D76DB" --description "Subagent actively working" --force
gh label create "status:completed" --color "0E8A16" --description "Task finished" --force
gh label create "status:blocked" --color "D93F0B" --description "Task blocked, needs attention" --force
gh label create "needs-review" --color "D93F0B" --description "Requires main agent review" --force
gh label create "integration" --color "5319E7" --description "Main agent integration work" --force
```

### 2. 模拟创建一个子智能体任务

```bash
# 创建一个测试issue（模拟子智能体任务）
gh issue create \
  --title "[Subagent] Test Task: Implement User Authentication" \
  --body "## 🤖 Subagent Task

**Assigned Agent**: code-implementation
**Parent Context**: Building REST API

### Objective
Implement JWT-based user authentication endpoints

### Success Criteria
- [ ] POST /auth/login endpoint
- [ ] POST /auth/register endpoint
- [ ] JWT token generation
- [ ] Password hashing with bcrypt

### Dependencies
- Database schema must be ready
- User model must exist

### Working Directory
\`src/auth/\`

---
*Created by Main Claude Code*
*Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")*" \
  --label "subagent-task" \
  --label "status:pending"
```

### 3. 更新任务状态（模拟子智能体开始工作）

```bash
# 获取刚创建的issue编号
ISSUE_NUMBER=$(gh issue list --label "subagent-task" --limit 1 --json number -q '.[0].number')

# 更新状态为进行中
gh issue edit $ISSUE_NUMBER \
  --remove-label "status:pending" \
  --add-label "status:in-progress"

# 添加进度评论
gh issue comment $ISSUE_NUMBER \
  --body "## 🔄 Progress Update

**Status**: Started implementation

### Work Done
- ✅ Created auth module structure
- ✅ Implemented JWT token generation
- 🔄 Working on password hashing

### Next Steps
- Complete bcrypt integration
- Write unit tests
- Update API documentation

---
*Subagent: code-implementation*
*Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")*"
```

### 4. 记录决策（模拟子智能体决策）

```bash
# 记录架构决策
gh issue comment $ISSUE_NUMBER \
  --body "## 💡 Decision Made

**Decision**: Use PyJWT library for JWT token handling

**Reasoning**:
- Industry standard, widely adopted
- Excellent documentation
- Active maintenance
- Built-in support for multiple algorithms

**Alternatives Considered**:
- python-jose: Less active development
- authlib: More complex, overkill for our needs

**Implementation**:
\`\`\`python
import jwt
from datetime import datetime, timedelta

def create_token(user_id: int) -> str:
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(hours=24)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm='HS256')
\`\`\`

---
*Subagent: code-implementation*
*Decision ID: AUTH-001*"
```

### 5. 完成任务（模拟子智能体完成）

```bash
# 标记为完成
gh issue edit $ISSUE_NUMBER \
  --remove-label "status:in-progress" \
  --add-label "status:completed"

# 添加完成报告
gh issue comment $ISSUE_NUMBER \
  --body "## ✅ Task Completed

### Deliverables
- \`src/auth/jwt_handler.py\` - JWT token generation/validation
- \`src/auth/routes.py\` - Authentication endpoints
- \`tests/test_auth.py\` - Unit tests (95% coverage)
- \`docs/auth_api.md\` - API documentation

### Success Criteria
- ✅ POST /auth/login endpoint (implemented)
- ✅ POST /auth/register endpoint (implemented)
- ✅ JWT token generation (PyJWT)
- ✅ Password hashing with bcrypt

### Integration Notes
All endpoints follow the existing API pattern. No breaking changes.

### Ready for Integration
This task is complete and ready for main agent to integrate.

---
*Subagent: code-implementation*
*Completion Time: $(date -u +"%Y-%m-%dT%H:%M:%SZ")*"

# 关闭issue
gh issue close $ISSUE_NUMBER --comment "Integration complete by main agent"
```

## 🎯 实际使用示例

### 场景：主Claude Code收到复杂任务

**用户请求**: "构建一个完整的用户管理系统，包括认证、权限、个人资料"

**主Claude Code的工作流**:

```bash
# 1. 创建3个子智能体任务
gh issue create --title "[Subagent] Authentication Module" --body "..." \
  --label "subagent-task" --label "status:pending"

gh issue create --title "[Subagent] Authorization & Permissions" --body "..." \
  --label "subagent-task" --label "status:pending"

gh issue create --title "[Subagent] User Profile Management" --body "..." \
  --label "subagent-task" --label "status:pending"

# 2. 生成3个子智能体（使用Task tool）
# 主Claude Code会使用: Task tool with prompt containing issue number

# 3. 监控进度
gh issue list --label "subagent-task" --label "status:in-progress" --json number,title,labels

# 4. 检查完成情况
gh issue list --label "subagent-task" --label "status:completed" --json number,title

# 5. 收集所有子智能体的输出
for issue in $(gh issue list --label "subagent-task" --state closed --json number -q '.[].number'); do
  echo "=== Issue #$issue ==="
  gh issue view $issue --comments
done

# 6. 集成所有结果
gh issue create --title "[Integration] User Management System" \
  --body "Integrated results from 3 subagents..." \
  --label "integration"
```

## 📊 透明性体现

### GitHub上的可见性

1. **所有任务可见**
   ```bash
   gh issue list --label "subagent-task"
   ```

2. **进度追踪**
   ```bash
   gh issue list --label "status:in-progress"
   ```

3. **决策历史**
   ```bash
   gh issue view 123 --comments
   ```

4. **完整审计轨迹**
   ```bash
   gh issue list --label "subagent-task" --state all --json number,title,state,labels,createdAt,closedAt
   ```

## 🔄 与AGENTS.md集成

主Claude Code在生成子智能体时，会：

1. **读取 AGENTS.md** - 了解可用的agent角色
2. **创建GitHub Issue** - 使用 `gh issue create`
3. **生成子智能体** - 使用 Task tool，prompt中包含issue编号
4. **子智能体指令**:
   ```
   You are a specialized code-implementation subagent.
   Your task is tracked in GitHub Issue #123.

   Instructions:
   1. Read the issue description for your objectives
   2. Update issue status when you start: gh issue edit 123 --add-label "status:in-progress"
   3. Comment your decisions: gh issue comment 123 --body "Decision: ..."
   4. Update progress regularly
   5. Mark complete when done: gh issue edit 123 --add-label "status:completed"

   [Full task details from AGENTS.md]
   ```

## 🎓 关键优势

### 1. **无需额外工具**
- ✅ 使用本地 `gh` CLI
- ✅ 不依赖GitHub App
- ✅ 不需要webhook
- ✅ 不需要服务器

### 2. **完全透明**
- ✅ 所有工作在GitHub Issues可见
- ✅ 人类可随时查看进度
- ✅ 可以通过评论介入
- ✅ 完整审计轨迹

### 3. **简单直接**
- ✅ 标准的GitHub workflow
- ✅ 熟悉的issue界面
- ✅ 可以用GitHub搜索/过滤
- ✅ 可以关联PR、Commits

## 🚀 开始使用

```bash
# 1. 确认gh已配置（你已经完成✅）
gh auth status

# 2. 创建labels
cd /Users/yanghh/Documents/code/quant/cc_bootstrap
bash -c 'gh label create "subagent-task" --color "0E8A16" --description "Issue assigned to a subagent" --force'

# 3. 复制AGENTS.md到你的项目
cp AGENTS.md /path/to/your/project/

# 4. 给Claude Code一个复杂任务，观察它如何：
#    - 创建GitHub Issues
#    - 生成子智能体
#    - 通过issues追踪进度
#    - 集成最终结果
```

## 📝 提示

当你给Claude Code一个复杂任务时，如果它遵循了MULTI_AGENT_ORCHESTRATION.md的指令，它会：

1. **评估任务复杂度**
2. **提出分解方案** - 询问你是否批准
3. **创建GitHub Issues** - 每个子任务一个
4. **生成子智能体** - 使用Task tool
5. **监控进度** - 通过GitHub Issues
6. **集成结果** - 综合所有子智能体的输出

你会在GitHub上看到整个过程！

---

**现在就试试**：给Claude Code一个复杂任务，看它如何使用本地 `gh` 命令协调多个子智能体！
