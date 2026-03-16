# Workflow: Deployment

**Phase:** 4 — Implementation
**Config:** `config.yaml`

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `pre_deployment_check`.

| Node Type | Behavior |
|---|---|
| `action` | Perform the described action. If `file:` is set, load and follow that step file. |
| `decision` | Evaluate condition. Follow the matching `branches` edge. |
| `checkpoint` | Present `options` as a labeled menu. STOP — wait for user selection. Follow chosen edge. |
| `terminal` | Workflow complete. If `next_phase` is defined, offer to transition. |

## Rules

- At every `checkpoint` with `human_in_loop: true` — STOP and wait before proceeding.
- Never deploy without all pre-deployment checks passing.
- On `[P] Pause` — halt and wait for user to resume.
- On resume — confirm which checkpoint to restart from.
- Never skip a checkpoint without explicit user confirmation.

## End State

- Application deployed and verified in target environment.
- Deployment recorded in `docs/deployment/log.md`.
