---
description: Turn ideas into concrete designs through collaborative dialogue. Use before building anything non-trivial.
---

# /brainstorm

> Turn ideas into concrete designs through collaborative dialogue. Use before building anything non-trivial.

**Scope:** `daily`
**Phase:** Phase 1 — Analysis
**Deep Mode:** `.claude/phases/phase-1-analysis/00-brainstorm/workflow.md`

## When to Use

- Before creating a new feature, component, or service
- When modifying existing behavior and multiple approaches exist
- When you're stuck or need a second opinion on trade-offs
- Before writing a spec or architecture document

## Fast Mode
>
> Quick alignment on approach. Good for small features or incremental changes.

1. State the problem in one sentence
2. Propose 2-3 approaches with key trade-off each
3. Pick the winner based on simplicity + fit with current stack
4. Output: a short bullet list of design decisions to carry into `/quick-spec`

## Deep Mode
>
> Full collaborative discovery with structured steps.

Load: `.claude/phases/phase-1-analysis/00-brainstorm/steps/step-01-connect.md`

1. **Connect** — Understand the core problem, constraints, and non-goals (`step-01-connect.md`)
2. **Ideate** — Explore approaches using structured frameworks (`step-02-ideate.md`)
3. **Synthesize** — Score approaches and form a concrete design (`step-03-synthesize.md`)

## Output

- `docs/plans/YYYY-MM-DD-{topic}-design.md`

## Key Principles

- **One question at a time**: Don't overwhelm — progressive refinement
- **Diverge then converge**: Explore options before committing
- **Concrete over abstract**: Prefer specific file/function decisions over general patterns
