# Workflow: Technical Design

**Phase:** 3 — Solutioning
**Config:** `config.yaml`

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `detect_existing_workflow`.

The initial `decision` node checks whether a prior design session exists (`architecture.md` with `stepsCompleted`). It branches to:
- `resume` → `checkpoint_01_resume` (ask user: Resume / Continue / Overview / Start Over)
- `fresh` → `step_01_init` (initialize new design)

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
- After each confirmed step, update `stepsCompleted` in `docs/architecture.md` frontmatter.

## End State

- `docs/architecture.md` generated with ADRs, data models, and implementation patterns.
- Ready to transition to `phase-4-implementation/06-implementation`.
