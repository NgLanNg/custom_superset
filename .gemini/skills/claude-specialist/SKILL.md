---
name: claude-specialist
description: Spawns a dedicated Claude subagent by dynamically loading a specific YAML role file. Use this when you need nuanced reasoning, strict instruction following, or complex formatting (e.g., deep architecture reviews, security audits) from one of the roles in .agents/roles/sub/.
---

# Claude Specialist Skill

This skill allows Supervisor agents to delegate tasks to specific specialist personas using **Claude** as the underlying reasoning engine. Claude excels at complex logic, deep architecture reviews, and strict instruction following.

## When to Use

Use `claude-specialist` for tasks that require:

- High-level reasoning and nuanced analysis.
- Strict adherence to complex constraints or formatting.
- Deep security audits (AppSec Engineer).
- Enterprise architecture decisions (Solutions Architect).

Look up available roles in `.agents/roles/sub/INDEX.md`.
*(Note: For massive codebase context or fast screening, use `gemini-specialist` instead).*

## Execution

Invoke the specialist using the bundled `claude-runner.sh` script.

### Syntax

```bash
.agents/skills/claude-specialist/scripts/claude-runner.sh <path_to_yaml_role> "<task_description>"
```

### Examples

#### Example 1: Solutions Architect

```bash
.agents/skills/claude-specialist/scripts/claude-runner.sh .agents/roles/sub/analysis/solutions_architect.yaml "Review the proposed microservices architecture in docs/architecture.md and list potential single points of failure."
```

#### Example 2: AppSec Engineer

```bash
.agents/skills/claude-specialist/scripts/claude-runner.sh .agents/roles/sub/security/appsec_engineer.yaml "Audit the authentication flow in src/auth.ts for OWASP Top 10 vulnerabilities."
```

## How It Works

1. The runner reads the provided YAML definition.
2. It constructs a system prompt commanding Claude to adopt the identity, principles, and communication style of that role.
3. The prompt is piped into `claude --print` in an isolated sub-process.
4. The script returns only Claude's final response, keeping your main context clean.
