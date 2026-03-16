# Workflow: Developer Implementation

**Phase:** 4 — Implementation
**Config:** `config.yaml`

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `find_task`.

The graph drives the full TDD cycle:
- `find_task` → find first `ready` task in `docs/tasks.md`
- `detect_review` → check if a prior review session exists (review_continuation)
- `implement_red` → `implement_green` → `implement_refactor` (TDD loop)
- `run_validations` → loop back to RED if tests fail
- `story_completion` → human checkpoint: DoD validation before sign-off

| Node Type | Behavior |
|---|---|
| `action` | Perform the described action. If `file:` is set, load that step reference. |
| `decision` | Evaluate condition. Follow the matching `branches` edge. |
| `checkpoint` | Present `options` as a labeled menu. STOP — wait for user selection. Follow chosen edge. |
| `terminal` | Workflow complete. If `next_phase` is defined, offer to transition. |

## Rules

- At every `checkpoint` with `human_in_loop: true` — STOP and wait before proceeding.
- NEVER mark a task complete unless ALL validation gates pass (tests green, ACs met, regression suite clean).
- NEVER implement anything not mapped to a task in `docs/tasks.md`.
- On `[P] Pause` — halt and wait for user to resume.
- On 3 consecutive implementation failures — STOP and escalate to user.
- After each confirmed task, mark `[x]` in `docs/tasks.md`.

## End State

- All tasks in `docs/tasks.md` marked `[x]`.
- Full test suite passing with no regressions.
- Story status updated to `review`.
- Ready to transition to `phase-4-implementation/07-qa-testing`.
