---
description: Bootstrap the .agents/ framework for a new or existing project.
---

# /init

> Bootstrap the `.agents/` framework for a new or existing project.

**Scope:** `project-start`
**Phase:** Phase 1 - Analysis
**Deep Mode:** `.claude/phases/phase-1-analysis/01-project-context/workflow.md`

## When to Use

- Starting a brand-new project
- Onboarding an existing codebase into the agent framework
- Resetting or repairing a broken `.agents/` configuration

## Fast Mode
>
> Quick scaffold for familiar project types.

1. Create `.agents/config.yaml` with project name, stack, test command, and language
2. Create `vault/active_context.md` with current state and next steps
3. Run `/scan` to generate `docs/project-context.md`
4. Verify the workflow registry is correct in `active_context.md`

## Deep Mode
>
> Full structured setup with all framework directories.

Load: `.claude/phases/phase-1-analysis/01-project-context/workflow.md`

1. **Scaffold** - Create `.agents/config.yaml`, `vault/`, `docs/`, `.agents/workflows/`
2. **Context** - Run `/scan` to produce `docs/project-context.md`
3. **Roles** - Confirm which roles from `.agents/roles/` are relevant
4. **Validate** - Verify `active_context.md` reflects the current project state

## Output

- `.agents/config.yaml`
- `vault/active_context.md`
- `docs/project-context.md`

## Key Principles

- **Lean config**: Only add what the project actually needs
- **Context first**: Don't write code before `project-context.md` exists
- **Idempotent**: Safe to re-run - existing files are preserved unless explicitly overwritten
