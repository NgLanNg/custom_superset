---
description: Simulate a roundtable of expert personas to debate and solve problems. You are the Boss; they are your squad.
---

# /likeaboss

> Use subagent to simulate a roundtable of expert personas to debate and solve problems. You are the Boss; they are your squad.

**Scope:** `situational`
**Phase:** Phase 1 — Analysis
**Deep Mode:** `.claude/phases/phase-1-analysis/00-roundtable/workflow.md`

## When to Use

- Architectural decisions with real trade-offs
- Auditing systems, workflows, or strategies
- When you want adversarial perspectives before committing
- Complex problems where a single AI view is insufficient

## Fast Mode
>
> Quick 3-persona debate for clear decisions.

1. State the problem in one paragraph
2. Pick 3 relevant roles from `.agents/roles/sub/INDEX.md`
3. Each persona gives a 100-word verdict
4. You (Boss) synthesize the consensus
5. Output: a bullet-point decision summary

## Deep Mode
>
> Full structured roundtable with decision record.

Load: `.claude/phases/phase-1-analysis/00-roundtable/steps/step-01-roundtable.md`

1. **Briefing** — Analyze request, select 3-5 personas via `claude-specialist` or `gemini-specialist`
2. **Casting** — Present squad to user for approval
3. **Roundtable** — Each specialist returns an independent response
4. **Synthesis** — Facilitator summarizes trade-offs and consensus
5. **Decision Record** — Write `docs/decisions/YYYY-MM-DD-{topic}.md`

## Output

- `docs/decisions/YYYY-MM-DD-{topic}.md`

## Key Principles

- **Always use real roles**: Spawn from `.agents/roles/sub/` via `claude-specialist`; never simulate all voices in one context
- **Independent voices**: Each specialist must run in isolation — no context bleed
- **Boss decides**: The squad advises; you make the call
