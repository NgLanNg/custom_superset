# Claude Hooks Documentation

## Overview

This directory contains hook scripts that extend Claude Code's behavior. Hooks are shell scripts triggered by specific events (tool calls, session start/stop, etc.).

## Configuration

Hooks are registered in `.claude/settings.json` under the `hooks` key.

---

## Hook Registry

### SessionStart Hooks

| Hook | Purpose | Configuration |
|------|---------|---------------|
| `reinject-rules.sh` | Injects `RULES.md` and `active_context.md` into context at session start | Always runs |
| `usage-alert.sh` | Warns when approaching token/cost thresholds | Threshold: **$5.00** / 200K tokens |

### SessionStart (matcher: compact)

| Hook | Purpose |
|------|---------|
| `smart-context.sh` | Re-injects comprehensive session state after context compaction |

### UserPromptSubmit Hooks

| Hook | Purpose | Blocks? |
|------|---------|---------|
| `input-validation.sh` | Validates user input for destructive commands, PII, secrets | Yes (ask/deny) |

### PreToolUse Hooks

| Trigger | Hook | Purpose | Blocks? |
|---------|------|---------|---------|
| **Bash** | `bash-safety.sh` | Blocks dangerous commands (`rm -rf`, `> /dev/null`, etc.) | Yes (exit 2) |
| **Bash** | `shadow-git-checkpoint.sh` | Creates git stash before modifying commands | No (checkpoint) |
| **Edit/Write** | `edit-guard.sh` | Secret scanning + doom loop detection | Yes |
| **Edit/Write** | `shadow-git-checkpoint.sh` | Creates git stash before file edits | No (checkpoint) |
| **mcp__** | `production-safety.sh` | Blocks production environment MCP calls | Yes |
| **Read** | `token-reduce.sh` | Blocks verbose file reads (node_modules, .git, large files) | Yes (ask/deny) |

### PostToolUse Hooks

| Hook | Purpose |
|------|---------|
| `post-tool-hook.sh` | Auto-formats code, logs errors, warns on large output |

### PreCompact Hooks

| Hook | Purpose |
|------|---------|
| `context-compaction.sh` | Preserves context before compaction, generates session summary |

### Stop Hooks

| Hook | Purpose |
|------|---------|
| `session-summary.sh` | Archives session ledger and summary to `logs/session-logs/` |

### PermissionRequest Hooks

| Hook | Purpose |
|------|---------|
| `permission-intelligence.sh` | Auto-approves safe read operations |

---

## Hook Specifications

### `usage-alert.sh`

**Trigger:** SessionStart
**Purpose:** Warn when approaching cost/token thresholds

**Configuration:**
```bash
THRESHOLD_COST_USD=5.00      # Changed from $2.00 for long sessions
THRESHOLD_TOKENS=200000      # Changed from 100K for long sessions
WARNING_INTERVAL=50000       # Warn every 50K tokens
```

**Output Example:**
```
## Usage Alerts

**Current Usage:** 150000 tokens (~$3.50)

- **USAGE_MILESTONE: Session at 150000 tokens (crossed 150000 marker)**
```

---

### `smart-context.sh`

**Trigger:** SessionStart (matcher: compact)
**Purpose:** Re-inject comprehensive context after compaction to prevent context loss

**Context Priority Order:**
1. **Session State** - `session-summary.md`, `session-ledger.jsonl` (preserved across compaction)
2. **Active Context** - Full `vault/active_context.md`
3. **Current Tasks** - Full `vault/tasks/todo-{brief of task}-{date}.md`
4. **Recent Commits** - Last 5 commits
5. **Lessons Learned** - Last 30 lines
6. **Project Docs** - `project-context.md`, `ARCHITECTURE.md`, `PRD.md` (first 50 lines each)

**Note:** This hook reads FULL files (not head) for active_context and todo to ensure complete context.

---

### `edit-guard.sh`

**Trigger:** PreToolUse (Edit|Write)
**Purpose:** Secret scanning and doom loop detection

**Secret Scanning:**
- Skips: `.md`, `.example`, `.template`, `.sample`, `.stub`, `.env.example` files
- High-confidence patterns only: AWS keys, GitHub tokens, private keys
- Skips content with: `EXAMPLE`, `TEST`, `YOUR_`, `${}`, `process.env.`

**Doom Loop Detection:**
```bash
WINDOW=100 seconds      # Changed from 60s
THRESHOLD=5 edits       # Changed from 3
PROGRESS_DETECTION=true # Allows if 3+ unique content versions
```

---

### `bash-safety.sh`

**Trigger:** PreToolUse (Bash)
**Purpose:** Block dangerous shell commands

**Blocked Patterns:**
- `rm -rf /`, `rm -rf ~`
- `drop database`, `truncate table`
- `> /dev/null` (redirection)
- `chmod 777`, `chown -R /`
- `mkfs`, `dd if=/`

---

### `token-reduce.sh`

**Trigger:** PreToolUse (Read)
**Purpose:** Block verbose/low-value file reads

**Blocked Patterns:**
- `node_modules/`, `.git/`, `dist/`, `build/`
- `.venv/`, `venv/`, `__pycache__/`
- `.claude/session-logs/`, `*.log`, `*.lock`
- `*.min.js`, `*.map`, `package-lock.json`

**Large File Warning:** Files >100KB trigger permission ask

---

### `shadow-git-checkpoint.sh`

**Trigger:** PreToolUse (Bash/Edit/Write)
**Purpose:** Create git stash checkpoint before modifying operations

**Behavior:**
- Only runs if there are uncommitted changes
- Creates stash with message: `claude-checkpoint-YYYYMMDD-HHMMSS`
- Stores checkpoint name in `/tmp/claude-last-checkpoint.txt`
- Logs to `/tmp/claude-checkpoint-log.txt`

**Rollback:**
```bash
git stash pop  # Restore last checkpoint
git stash list # View all checkpoints
```

---

### `session-ledger.sh`

**Trigger:** Manual (pipe event to hook)
**Purpose:** Append-only session event writer

**Usage:**
```bash
echo '{"turn": 1, "type": "goal", "content": "My goal"}' | .claude/hooks/session-ledger.sh
```

**Output:** `.claude/session-ledger.jsonl` (compact JSONL format, 600 permissions)

---

### `context-compaction.sh`

**Trigger:** PreCompact
**Purpose:** Preserve context before compaction, generate session summary

**Generates:** `.claude/session-summary.md` with:
- Current goal (from active_context.md)
- Current tasks (from todo-{brief of task}-{date}.md)
- Ledger event count

---

### `session-summary.sh`

**Trigger:** Stop
**Purpose:** Archive session data on session end

**Archives to `logs/session-logs/`:**
- `ledger_YYYYMMDD_HHMMSS.jsonl`
- `summary_YYYYMMDD_HHMMSS.md`

---

## Hook Data Formats

### Input (stdin, JSON)
```json
{
  "session_id": "uuid",
  "cwd": "/path/to/project",
  "tool_name": "Bash|Edit|Write|Read",
  "tool_input": { "file_path": "...", "command": "..." },
  "tool_result": { ... }
}
```

### Output (stdout, for blocking hooks)
```json
{"block": true, "reason": "..."}
{"hookSpecificOutput": {"permissionDecision": "deny|ask|allow", "permissionDecisionReason": "..."}}
```

---

## Troubleshooting

### Hook is being reverted

Some hooks (like `edit-guard.sh`) have linter functionality that may revert changes. To modify protected hooks:

1. Temporarily disable in `settings.json`:
```json
"PreToolUse": [
  {"matcher": "Edit|Write", "hooks": []}
]
```

2. Make your changes

3. Re-enable hooks in `settings.json`

### Hook is blocking legitimate work

Check the hook's log output:
- Security blocks: `logs/security/`
- Error logs: `logs/errors/`
- Usage logs: `logs/usage/`

### Context loss after compaction

The `smart-context.sh` hook should re-inject context. If context is still lost:

1. Check `.claude/session-summary.md` exists
2. Check `.claude/session-ledger.jsonl` has events
3. Verify hook is registered in `settings.json`

---

## Adding New Hooks

1. Create script in `.claude/hooks/your-hook.sh`
2. Make executable: `chmod +x .claude/hooks/your-hook.sh`
3. Register in `.claude/settings.json` under appropriate trigger
4. Test with the relevant tool/event

### Hook Template
```bash
#!/bin/bash
# Your Hook Name
# Trigger: EventName

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Your logic here

# Allow (empty response) or block (JSON response)
echo '{}'
exit 0
```

---

## Changelog

### 2026-03-14 - Smart Context Compaction

- Added `session-ledger.sh` - append-only event writer
- Enhanced `smart-context.sh` - comprehensive context re-injection
- Enhanced `context-compaction.sh` - generates session summary
- Enhanced `session-summary.sh` - archives to `logs/session-logs/`

### 2026-03-14 - Hook Improvements

- `usage-alert.sh`: Threshold increased to $5.00 / 200K tokens for long sessions
- `smart-context.sh`: Now reads full `active_context.md` and `todo-{brief of task}-{date}.md` (not truncated)
- `edit-guard.sh`: Improved secret scanning (skips docs), progress-aware doom loop detection
