---
description: Security and tech debt health check. Warning only — no auto-fixes.
---

# /audit

> Security and tech debt health check. Warning only — no auto-fixes.

**Scope:** `situational`
**Phase:** Phase 1 — Analysis
**Deep Mode:** `.claude/phases/phase-1-analysis/04-audit/workflow.md`

## When to Use

- Before a release or merge to main
- After adding new dependencies
- Periodic health check (weekly or monthly)
- After a course correction or major refactor

## Fast Mode
>
> Quick scan for experienced users. Run, read, triage.

1. Run dependency vulnerability scan on the project root
2. Identify code complexity hotspots (files >300 lines, duplication)
3. Note critical findings only — skip low/info severity
4. Output: comment inline in your context or open a `docs/warnings/` file

## Deep Mode
>
> Full structured audit with documented outputs.

Load: `.claude/phases/phase-1-analysis/04-audit/workflow.md`

1. **Scan** — CVE/dependency vulnerabilities, secret exposure risk
2. **Assess** — Tech debt: complexity, duplication, coverage gaps
3. **Report** — Generate `docs/warnings/security-issues.md` + `docs/warnings/tech-debt-report.md`
4. Feed critical findings into next sprint planning

## Output

- `docs/warnings/security-issues.md`
- `docs/warnings/tech-debt-report.md`

## Key Principles

- **Warning only**: Never auto-fix — surface findings for deliberate action
- **Evidence-based**: Link specific files and line numbers
- **Triage by severity**: Critical > High > Medium > Low
