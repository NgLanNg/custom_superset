# Workflow: Course Correction

**Phase:** 4 — Implementation
**Config:** `config.yaml`

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `step_01_diagnose`.

The graph drives an emergency pivot process:
- `step_01_diagnose` → identify root cause of the failure/shift
- `step_02_impact` → determine scope of required changes
- `step_03_proposal` → draft `docs/change_proposal.md`
- Human checkpoint → approve, modify, or reject the proposal
- On approval → update sprint plan and resume implementation

| Node Type | Behavior |
|---|---|
| `action` | Perform the described action. If `file:` is set, load and follow that step file. |
| `decision` | Evaluate condition. Follow the matching `branches` edge. |
| `checkpoint` | Present `options` as a labeled menu. STOP — wait for user selection. Follow chosen edge. |
| `terminal` | Workflow complete. If `next_phase` is defined, offer to transition. |

## Rules

- At every `checkpoint` with `human_in_loop: true` — STOP and wait before proceeding.
- Document WHY the course correction is happening — no silent scope changes.
- On `[P] Pause` — halt and wait for user to resume.
- On resume — confirm which checkpoint to restart from.

## End State

- `docs/change_proposal.md` created with delta, approvals, and updated sprint plan.
- Sprint plan updated. Ready to resume `phase-4-implementation/06-implementation`.
