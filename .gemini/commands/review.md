---
description: Systematic pre-commit quality and security audit.
---

# /review

> Systematic pre-commit quality and security audit.

**Scope:** `daily`
**Phase:** Phase 4 — Implementation
**Deep Mode:** `.claude/phases/phase-4-implementation/06-implementation/review/workflow.md`

## When to Use

- Before every commit or PR
- After completing a task in `/build`
- When reviewing another agent's output or a diff

## Fast Mode
>
> Quick diff review focused on critical issues only.

1. Identify intent and scope of the change (what was supposed to happen?)
2. Scan for Critical issues only: SQL injection, hardcoded secrets, broken auth
3. Run project linter and tests
4. Output: a brief pass/fail with any critical blockers noted

## Deep Mode
>
> Full severity-tiered review with documented report.

Load: `.claude/phases/phase-4-implementation/06-implementation/review/workflow.md`

1. **Ingest** — Understand intent, scope, and risk level of the change
2. **Review** — Apply severity-tiered checklist:
   - **Critical**: Security, data loss, broken contracts
   - **High**: Logic errors, missing validation, broken tests
   - **Medium**: Performance, maintainability, test coverage gaps
   - **Low**: Style, naming, documentation
3. **Verify** — Run lints and full test suite
4. **Report** — Summarize findings; block on Critical/High

## Output

- Inline review comments or a review report
- Pass/fail verdict per severity tier

## Key Principles

- **Separate concerns**: Review is not implementation — don't fix while reviewing
- **Block on critical**: Never approve with unresolved Critical or High issues
- **Evidence-based**: Link specific lines; no vague comments
