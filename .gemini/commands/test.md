---
description: Write tests first, then implement. Red → Green → Refactor.
---

# /test

**Purpose: Enforce system reliability through disciplined Test-Driven Development (TDD). Red → Green → Refactor.**

**Scope:** `daily`
**Phase:** Phase 4 — Implementation
**Deep Mode:** `.claude/phases/phase-4-implementation/07-qa-testing/workflow.md`

## Modes

- **`--unit`** (default): Atomic TDD for functions and classes.
- **`--integration`**: Verify service boundaries and data integrity between modules.
- **`--e2e`**: Validate critical user journeys via browser/CLI simulation.

## When to Use

- When implementing new code (test-first).
- When reproducing a bug (failure-first).
- During refactors to ensure zero regressions in a large codebase.
- Before final sign-off for critical features.

## Execution Path
>
> **Disciplined QA Cycle & Regression Audit**

1. **Environment Setup**: Load test configuration; confirm correct runner (pytest/vitest/etc.).
2. **Rigorous RED**: Define the public interface; write comprehensive failing tests for success and edge cases using Gherkin ACs.
3. **Execution**: Implement and verify until GREEN.
4. **Coverage Gate**: Run coverage reports. Target ≥80% for new logic in complex modules.
5. **Anti-pattern Check**: Ensure no execution-order dependencies or shared mutable state.
6. **Regression Audit**: Verify that new tests don't break existing cross-module invariants.

## Output

- New/updated test suites and fixtures.
- Validated coverage reports.
- `docs/qa/report.md` for major feature releases.

## Key Principles

- **Test Behavior, Not Internals**: Focus on public APIs/Contracts; avoid testing private state.
- **RED is Mandatory**: Never write implementation before a failing test exists.
- **Complete Context**: Ensure the agent has the full data model and interface specs before writing integration tests.
