---
description: Emergency pivot when the current plan becomes impossible or invalid.
---

# /rethink

> Emergency pivot when the current plan becomes impossible or invalid.

**Scope:** `situational`
**Phase:** Phase 4 — Implementation
**Deep Mode:** `.agents/phases/phase-4-implementation/09-course-correction/workflow.md`

## When to Use

- Unexpected technical blocker that breaks the current task
- Scope shift from the user mid-sprint
- Infrastructure or dependency failure
- When you realize the current approach is fundamentally wrong

## Fast Mode
>
> Quick recovery for small deviations.

1. State what broke and why in one paragraph
2. Identify the minimal scope change needed (drop task / swap approach)
3. Update `vault/tasks/todo.md` to reflect the new plan
4. Continue from the next valid task

## Deep Mode
>
> Full change proposal with impact analysis and approval gate.

Load: `.agents/phases/phase-4-implementation/09-course-correction/workflow.md`

1. **Root Cause** — Identify the trigger: complexity, shifted requirements, infra failure
2. **Impact Analysis** — Scope down / extend timeline / re-solution
   - Scope down: remove lowest priority stories
   - Extend: timeline approval required
   - Re-solution: return to Phase 3 for affected epics
3. **Proposal** — Write `docs/change_proposal.md`: delta, approvals needed, updated sprint plan
4. **Resume** — Once approved, update `vault/tasks/todo.md` and continue

## Output

- `docs/change_proposal.md`
- Updated `vault/tasks/todo.md`

## Key Principles

- **Stop immediately**: Never push through a known blocker — stop and re-plan
- **Transparency**: Document why the change happened, not just what changed
- **Minimal pivot**: Scope down before requesting timeline extensions
