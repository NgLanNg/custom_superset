---
description: Execute implementation work from a spec or task list.
---

# /code

**Purpose: Execute implementation work in large/complex codebases with strict dependency management and verified correctness.**

**Scope:** `daily`
**Phase:** Phase 4 — Implementation
**Deep Mode:** `.agents/phases/phase-4-implementation/00-quick-flow/quick-dev/workflow.md`

## When to Use

- After `/write-spec` or `/task-list` has provided a verified implementation plan.
- For coding tasks requiring rigorous dependency isolation and testing.
- When working on large modules where "context bleed" could lead to regressions.

## Execution Path
>
> **Disciplined Implementation & Verification**

1. **Prerequisite Check**: Ensure an implementation-ready spec exists in `docs/specs/`.
2. **Context Investigation**: Load the full context of the target module and its immediate dependencies using `repomix`.
3. **Dependency Scanning**: Identify the leaf-node files (those with the fewest local dependencies) and sequence implementation accordingly.
4. **TDD Loop**: For every Story/Task:
   - Write/Update tests first.
   - Implement minimal code to pass.
   - Refactor for elegance.
5. **Nyquist Gate**: Verify cross-module impacts. Run the full integration suite.
6. **Task Closure**: Mark `[x]` in `todo.md` ONLY after tests are confirmed GREEN.
7. **Cleanup**: Proactively archive any temporary files to `_archive/`.

## Output

- High-quality, tested code changes.
- Updated `todo.md` with proof of verification.

## Key Principles

- **Tests gate progress**: A task is NOT complete until its specific tests pass.
- **Isolation Rigor**: Ensure context is "enough and correct" for the current module; avoid irrelevant bleed.
