# Workflow: QA & Testing

**Phase:** 4 — Implementation
**Config:** `config.yaml`

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `step_01_load_context`.

The graph drives a structured QA cycle:
- Load context → build test plan → execute unit/integration/e2e tests
- `review_checkpoint` → human checkpoint: adversarial review sign-off
- `fix_decision` → human checkpoint: triage fix severity (critical / medium / skip)
- Final validation → `terminal_01_complete` or `terminal_02_incomplete`

| Node Type | Behavior |
|---|---|
| `action` | Perform the described action. If `file:` is set, load and follow that step file. |
| `decision` | Evaluate condition. Follow the matching `branches` edge. |
| `checkpoint` | Present `options` as a labeled menu. STOP — wait for user selection. Follow chosen edge. |
| `terminal` | Workflow complete. If `next_phase` is defined, offer to transition. |

## Rules

- At every `checkpoint` with `human_in_loop: true` — STOP and wait before proceeding.
- Target coverage ≥ 80% for all new code.
- On `[P] Pause` — halt and wait for user to resume.
- On resume — confirm which checkpoint to restart from.
- Never mark QA complete with open critical issues.

## End State

- Test suite passing. Coverage ≥ 80% for new code.
- QA sign-off recorded in `docs/qa/report.md`.
- Ready to transition to `phase-4-implementation/08-deployment`.
