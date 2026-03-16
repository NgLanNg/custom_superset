# Workflow: Task Breakdown

**Phase:** 2 — Planning
**Config:** `config.yaml`

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `context_read`.

| Node Type | Behavior |
|---|---|
| `action` | Perform the described action. If `file:` is set, load and follow that step file. |
| `decision` | Evaluate condition. Follow the matching `branches` edge. |
| `checkpoint` | Present `options` as a labeled menu. STOP — wait for user selection. Follow chosen edge. |
| `terminal` | Workflow complete. If `next_phase` is defined, offer to transition. |

## Rules

- At every `checkpoint` with `human_in_loop: true` — STOP and wait before proceeding.
- On `[P] Pause` — halt and wait for user to resume.
- On resume — confirm which checkpoint to restart from.
- Never skip a checkpoint without explicit user confirmation.
- After each confirmed step, update `stepsCompleted` in the output document frontmatter.

## End State

- `docs/tasks.md` populated with a flat, prioritized list of independent developer tasks.
- Ready to transition to `phase-3-solutioning/05-technical-design`.
