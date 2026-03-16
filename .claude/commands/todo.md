---
description: Generate a scoped task breakdown for a developer to implement.
---

# /todo

> Generate a scoped task breakdown for a developer to implement.

**Scope:** `daily`
**Phase:** Phase 2 — Planning
**Deep Mode:** `.claude/phases/phase-2-planning/02-task-breakdown/workflow.md`

## When to Use

- After `/brainstorm` or `/spec` produces a design
- Before starting any implementation sprint
- When a large feature needs to be broken into atomic tasks

## Fast Mode
>
> Quick task list for well-understood features.

1. Read the spec or design doc
2. Identify all files that will change — list them explicitly
3. Break into ordered, atomic tasks (each task = one focused change)
4. Add acceptance criteria for each task
5. Output: a checklist in `vault/tasks/todo_{brief}_{date}.md`

## Deep Mode
>
> Structured breakdown with dependency ordering and risk scoring.

Load: `.claude/phases/phase-2-planning/02-task-breakdown/workflow.md`

1. **Ingest** — Read design doc, spec, and existing codebase context
2. **Decompose** — Break epic into stories; stories into tasks (lowest-level first)
3. **Order** — Sequence by dependency (no task depends on a later one)
4. **Risk Score** — Rate impact/risk for each task (High/Medium/Low)
5. **Output** — `vault/tasks/todo_{brief}_{date}.md` with checkable items and estimates

## Output

- `vault/tasks/todo_{brief}_{date}.md` (e.g., `todo_login-flow_2026-03-15.md`)

## Key Principles

- **Atomic tasks**: One file, one concern per task
- **Dependency order**: Lower-level changes before higher-level ones
- **Testable items**: Every task has a clear done condition
- **Date-stamped**: Each todo is date-specific for session tracking
- **Session ID tracking**: Include `SESSION_ID` at the top of the file for traceability
