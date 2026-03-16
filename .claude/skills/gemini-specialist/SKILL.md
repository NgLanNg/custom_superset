---
name: gemini-specialist
description: Spawns a dedicated Gemini subagent by dynamically loading a specific YAML role file. Use this when you need massive context windows (entire codebases), multi-modal capabilities, or fast bulk analysis from one of the roles in .gemini/agents/.
---

# Gemini Specialist Skill

This skill allows Supervisor agents to delegate tasks to specific specialist personas using **Gemini** as the underlying engine. Gemini (specifically `gemini-2.5-pro`) excels at processing massive context windows, entire codebases, and multi-modal inputs.

## When to Use

Use `gemini-specialist` for tasks that require:

- Reading dozens of files or the entire repository at once.
- Fast, broad screening of patterns.
- Multi-modal analysis (e.g., UI Designer reviewing an image).
- Bulk codebase modifications (Code Reviewer).

Look up available roles in `.gemini/agents/*.yaml`.
*(Note: For highly nuanced reasoning or strict architecture adherence, consider using `claude-specialist`).*

## Execution

Invoke the specialist using the bundled `gemini-runner.sh` script.

### Syntax

```bash
.agents/skills/gemini-specialist/scripts/gemini-runner.sh <path_to_yaml_role> "<task_description>"
```

### Examples

#### Example 1: Data Engineer (Large Context)

```bash
.agents/skills/gemini-specialist/scripts/gemini-runner.sh .gemini/agents/data_engineer.yaml "Review all python files in the src/pipeline directory and map the data lineage."
```

#### Example 2: UX Designer

```bash
.agents/skills/gemini-specialist/scripts/gemini-runner.sh .gemini/agents/ux_designer.yaml "Analyze the user flow described in docs/onboarding.md and suggest friction reductions."
```

## How It Works

1. The runner reads the provided YAML definition.
2. It constructs a system prompt commanding Gemini to adopt the identity, principles, and communication style of that role.
3. The prompt is passed to `gemini -y -m gemini-2.5-pro -p`.
4. The script cleans the output (stripping CLI logging noise) and returns only Gemini's final response, keeping your main context clean.
