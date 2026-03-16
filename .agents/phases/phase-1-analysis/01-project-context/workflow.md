# Workflow: Project Context Discovery

**Phase:** 1 — Analysis
**Config:** `config.yaml`

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `step_01_discover`.

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

- `docs/project-context.md` generated with tech stack, naming conventions, and coding rules.
- Ready to transition to `phase-1-analysis/02-codebase-documentation`.
