---
description: Scan an existing codebase and generate a lean, LLM-optimized project context file.
---

# /scan

> Scan an existing codebase and generate a lean, LLM-optimized project context file.

**Scope:** `project-start`
**Phase:** Phase 1 — Analysis
**Deep Mode:** `.claude/phases/phase-1-analysis/01-project-context/workflow.md`

## When to Use

- First time an agent is loaded into a new or existing project
- After a major refactor or technology migration
- When the existing `docs/project-context.md` is outdated

## Fast Mode
>
> Quick context bootstrap for well-understood codebases.

1. Read `README.md`, `package.json` / `pyproject.toml`, and top-level directory structure
2. Identify: stack, entry points, key modules, test runner, deployment target
3. Write a compact `docs/project-context.md` (tech stack + 5-10 key decisions)
4. Output: `docs/project-context.md`

## Deep Mode
>
> Full structured discovery with user confirmation checkpoints.

Load: `.claude/phases/phase-1-analysis/01-project-context/steps/step-01-discover.md`

1. **Discover** — Inventory files, detect stack, map entry points
2. **Document** — Tech stack, patterns, conventions, key files
3. **Verify** — User confirms scope accuracy at each checkpoint (A, B, C, D)
4. **Output** — `docs/project-context.md` ready for Phase 2 planning

## Output

- `docs/project-context.md`

## Key Principles

- **LLM-first format**: Write for AI consumption, not humans
- **Lean over exhaustive**: Cover what changes agent behavior; skip obvious boilerplate
- **Confirm at boundaries**: Never infer stack decisions without verification
