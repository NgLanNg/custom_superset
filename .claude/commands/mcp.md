---
description: Use Model Context Protocol (MCP) server tools to accomplish tasks without writing custom scripts.
---

# /mcp

> Use Model Context Protocol (MCP) server tools to accomplish tasks without writing custom scripts.

**Scope:** `situational`
**Phase:** Phase 1 — Analysis
**Deep Mode:** `.claude/phases/phase-1-analysis/00-mcp/workflow.md`

## When to Use

- Accessing external APIs or services via MCP tools
- When a task requires a tool that is already configured as an MCP server
- Prefer over custom bash scripts whenever a suitable MCP tool exists

## Fast Mode
>
> Quick tool lookup and execution.

1. Check `.agents/rules/INDEX.md` or `mcp-management` skill for available servers
2. Identify the matching tool and its parameters
3. Execute via the MCP skill — do not write a new script
4. Report result or escalate if no tool found

## Deep Mode
>
> Full discovery, troubleshooting, and execution.

Load: `.claude/phases/phase-1-analysis/00-mcp/steps/step-01-mcp.md`

1. **Discover** — Use `mcp-management` skill to list and filter available MCP servers
2. **Select** — Match tool capabilities to the task
3. **Execute** — Delegate to `mcp-manager` subagent; never write ad-hoc scripts
4. **Troubleshoot** — If tool fails, use `mcp-builder` skill to diagnose; report back if unresolvable

## Output

- Task completed via MCP tool
- Updated knowledge of tool capabilities (if new tools discovered)

## Key Principles

- **No new scripts**: Only use existing MCP tools — if none fit, report back
- **Subagent only**: Delegate to `mcp-manager`; keep main context clean
- **Prefer skills over reimplementation**: `mcp-management` and `mcp-builder` are the entry points
