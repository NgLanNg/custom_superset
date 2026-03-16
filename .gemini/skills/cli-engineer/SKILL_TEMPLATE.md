---
name: cli-engineer
description: Convert documentation, patterns, runbooks, and knowledge into robust, self-contained CLI tools.
---

# CLI Engineer – Knowledge to Action

This skill is designed to take static knowledge (documentation, patterns, scripts, manual workflows) and engineer robust, maintainable Command Line Interface (CLI) tools.

## When to Use

- You have a repeatable task described in a markdown file or knowledge base.
- You find yourself copying/pasting shell commands or code snippets frequently.
- You want to standardize a process (deployment, data migration, scaffolding).
- You need to distribute a tool or script to a team.

## Capability

This skill can:

1. **Analyze** the source material (docs, patterns, scripts).
2. **Design** a CLI structure (commands, subcommands, arguments, flags).
3. **Generate** production-ready Python code using `typer` (recommended) or `argparse`.
4. **Implement** robust error handling, logging, and help text (`--help`).
5. **Package** the tool as a single executable script or installable package.

## Workflow

### 1. Analysis

- Read the source document.
- Identify the key actions (verbs) and parameters (nouns).
- Determine required inputs (files, credentials, flags).
- Identify dependencies (external CLIs, libraries).

### 2. Design

- Propose a command structure: `tool <verb> <noun> [options]`
- Define arguments:
  - Positional: Essential inputs (e.g., input file)
  - Options: Configuration (e.g., `--verbose`, `--dry-run`)
  - Environment Variables: Secrets/Config (e.g., `API_KEY`)

### 3. Implementation (Python/Typer)

- Use `typer` for clean, type-hinted Python CLIs.
- Use `rich` for beautiful terminal output (tables, progress bars).
- Include standard flags: `--version`, `--verbose`, `--json` (for machine readability).
- Add shebang: `#!/usr/bin/env python3`
- Make executable: `chmod +x`

### 4. Output

- Save the tool to a standard location (e.g., `./scripts/`, `~/.local/bin/`).
- Generate a README section or `--help` documentation.

## Example Prompts

- "Convert this deployment guide into a `deploy.py` CLI tool."
- "Turn this SQL migration pattern into a repeatable script."
- "Make a CLI for searching my notes based on this grep command pattern."

## Best Practices

- **Idempotency:** Tools should be safe to run multiple times.
- **Dry Run:** Always implement a `--dry-run` flag for destructive actions.
- **Logging:** Use structured logging or clear stderr/stdout separation.
- **Dependencies:** Keep dependencies minimal or vendor them if possible; otherwise, use `pipx` or generate a `requirements.txt`.

## Reference Implementation

See `gog` (Google Workspace CLI) for a reference implementation of a complex CLI structure:

```bash
gog <service> <action> [options]
# e.g., gog gmail send --to ...
```

This pattern of `noun -> verb` (Service -> Action) is highly recommended for multi-purpose tools.
