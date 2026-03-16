# Workflow: Research

**Phase:** 1 — Analysis
**Config:** `config.yaml`

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `select_research_type`.

The initial `decision` node asks the user which research type to conduct and branches to:
- `market` → load `workflow-market-research.md` and follow `market-steps/`
- `domain` → load `workflow-domain-research.md` and follow `domain-steps/`
- `technical` → load `workflow-technical-research.md` and follow `technical-steps/`

Each sub-workflow has its own step files that serve as action implementations for their nodes.

| Node Type | Behavior |
|---|---|
| `action` | Perform the described action. If `file:` is set, load and follow that step file. |
| `decision` | Evaluate condition. Follow the matching `branches` edge. |
| `checkpoint` | Present `options` as a labeled menu. STOP — wait for user selection. Follow chosen edge. |
| `terminal` | Workflow complete. If `next_phase` is defined, offer to transition. |

## Rules

- At every `checkpoint` with `human_in_loop: true` — STOP and wait before proceeding.
- Web search is required. If unavailable, abort immediately.
- All findings must cite verified sources — no hallucinated references.
- On `[P] Pause` — halt and wait for user to resume.
- Never skip a checkpoint without explicit user confirmation.

## End State

- Research document generated in `docs/research/` with findings, citations, and narrative.
- Ready to transition to `phase-1-analysis/00-brainstorm` or `phase-2-planning/01-scope`.
