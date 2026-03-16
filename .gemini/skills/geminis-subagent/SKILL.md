---
name: geminis-subagent
description: "Comprehensive orchestration and delegation of parallel AI tasks using the subgemi CLI. Use when you need to: (1) Delegate complex coding or research tasks to background sub-agents, (2) Run multiple tasks in parallel with automated self-healing, (3) Enforce quality gates via verification commands, (4) Process results as structured JSON."
---

# SUBGEMI – Parallel Orchestration & Auto-Healing (v0.1.8)

**SUBGEMI** is an orchestration protocol designed for high-velocity development through mass-parallelization and autonomous quality assurance.

## 🚀 Quick Start: Delegation

The primary command is `task delegate`. It dispatches a background sub-agent into an isolated Git workspace.

```bash
# Standard delegation with verification
subgemi task delegate "Refactor the authentication module" \
  --verify-cmd "pytest tests/test_auth.py" \
  --lane code

# Slim mode (50%+ token reduction)
subgemi task delegate "Fix typos in docstrings" --slim

# Targeted context (only pack relevant files)
subgemi task delegate "Optimize DB queries" \
  --include "src/db/**" \
  --exclude "*.log,*.pdf"
```

## 🛠️ Core Commands

| Command | Action |
| :--- | :--- |
| `task delegate` | Dispatch a sub-agent. Use `--verify-cmd` for auto-healing. |
| `task delegate --slim` | Skip context files (GEMINI.md, plans) to save 50%+ tokens. |
| `task delegate --include` | Explicitly whitelist files for Repomix packing. |
| `task delegate --exclude` | Blacklist files/dirs from context (e.g. `node_modules,*.log`). |
| `task await` | Block until a specific session or a `--parent-id` batch completes. |
| `task summary` | View a visual dashboard of success/failure/cost for a batch. |
| `task get <id>` | Retrieve structured JSON payload from a completed session. |
| `session board` | Attach to the live TUI monitor for a real-time view of all tasks. |
| `session kill` | Stop a specific sub-agent and clean up its isolation container. |

## � Concurrency Control (v0.1.8+)

Subgemi enforces a global concurrency limit to prevent resource exhaustion and API throttling:

- **Global Limit**: Default is **8 concurrent sub-agents** (`DEFAULT_MAX_CONCURRENT` in `config.py`).
- **Queuing**: If the limit is reached, new `task delegate` commands automatically wait until a slot becomes available, logging a warning each polling interval.
- **Tuning**: Override `DEFAULT_MAX_CONCURRENT` in `config.py` for your environment.

## �📉 Context Optimization (v0.1.6+)

To reduce rate limit pressure and cost, use the context reduction flags:

- **`--slim`**: Skips internal rules (`GEMINI.md`), planning docs (`vault/`), and role personas.
- **`--include "src/**,tests/**"`**: Forces Repomix to only pack matching paths.
- **`--exclude "*.log,docs/*.pdf"`**: Prevents large or irrelevant files from entering context.

## � API Resilience (v0.1.6+)

The FSM automatically detects `429 Rate Limit` errors and applies exponential backoff with jitter. See [references/fsm_architecture.md](references/fsm_architecture.md).

## 📐 Architecture (v0.1.8+)

### Key Modules

| Module | Responsibility |
| :--- | :--- |
| `core/engine.py` | `SubAgentFSM` – state machine for task lifecycle |
| `core/delegator.py` | `run_sub_agent()` – global orchestrator + concurrency gate |
| `core/parser.py` | `ResultParser` – standardized fallback JSON extraction from `stdout.log` |
| `cli/options.py` | Shared `Annotated` Typer options (lane, timeout, background, etc.) |
| `infrastructure/session.py` | `SessionManager` – atomic JSON registry with filelock |
| `infrastructure/executor.py` | `ProcessExecutor` – sandboxed subprocess runner |
| `infrastructure/workspace.py` | `GitWorkspace` – worktree management and diff stats |

### Advanced Guidance

- **Auto-Healing & FSM**: See [references/fsm_architecture.md](references/fsm_architecture.md).
- **Safety & Isolation**: See [references/security_isolation.md](references/security_isolation.md).
- **Batch Orchestration Patterns**: See [references/orchestration_patterns.md](references/orchestration_patterns.md).

## 🧠 Principles

1. **Delegate, Don't Code**: Your token window is for orchestration. Use `subgemi` to execute the actual logic.
2. **Always Verify**: Providing a `--verify-cmd` is the most effective way to ensure sub-agent quality.
3. **Structured Handoff**: Use `subgemi task get <id>` to pass precise state between sequential sub-agents.
4. **Tune Concurrency**: For large batch jobs, set `DEFAULT_MAX_CONCURRENT` to match your API rate tier.
