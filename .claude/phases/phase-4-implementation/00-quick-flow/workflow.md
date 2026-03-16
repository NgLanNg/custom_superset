# Workflow: Quick Development Flow

**Phase:** 4 — Implementation
**Config:** `config.yaml`
**Primary Role:** Dev

## Purpose

enable subagents to execute rapid development cycles with automatic mode detection and escalation paths.

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `mode_detection`.

The flow automatically detects the appropriate execution mode:
- **Mode A (Tech-Spec):** Routes to `quick-spec` sub-workflow for detailed specs
- **Mode B (Direct):** Executes fast TDD loop for simple changes
- **Escalation:** Can redirect to full BMAD flow if scope grows

## Mode Detection

The flow evaluates:
1. **Existing spec?** → Mode A (Tech-Spec)
2. **Simple change (under scope threshold)?** → Mode B (Direct)
3. **Complex/uncertain scope?** → Escalate to full BMAD flow

## Sub-Workflows

| Sub-Workflow | Purpose |
| :--- | :--- |
| `quick-spec/` | High-fidelity technical specs |
| `quick-dev/` | Direct implementation with TDD |
| `quick-dev-new-preview/` | Preview mode for new features |

## Rules

- At every `checkpoint` with `human_in_loop: true` — STOP and wait before proceeding.
- On escalation paths, delegate to the appropriate sub-workflow.
- Never skip testing even in fast mode.
- On 3 consecutive implementation failures — STOP and escalate to user.

## End State

- Code changes committed with tests passing
- Story status updated to `done`
- Ready to transition to `phase-4-implementation/07-qa-testing`
