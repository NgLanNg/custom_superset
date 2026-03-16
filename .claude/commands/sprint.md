---
description: Execute sprint implementation with integrated testing and deployment.
---

# /sprint

> Execute implementation work from a spec or task list with integrated TDD, testing, and verification.
> **Absorbs `/code`, `/test`, `/sprint`** - unified implementation workflow.

**Scope:** `sprint`
**Phase:** Phase 4 — Implementation
**Deep Mode:** `.claude/phases/phase-4-implementation/06-implementation/workflow.md`

## When to Use

- After `/spec` or `/todo` has provided a verified implementation plan.
- For coding tasks requiring rigorous dependency isolation and testing.
- When working on large modules where "context bleed" could lead to regressions.
- **Sprint planning and execution** - allocate stories and implement them.

## Modes
>
> **Sprint Mode** (default): Full cycle from backlog allocation to implementation.
> **Test Mode** (`--test`): Focus on writing tests first (RED phase).
> **Code Mode** (`--code`): Focus on implementation only ( GREEN + REFACTOR).

## Fast Mode
>
> Quick implementation for well-understood features.

1. **Read Plan**: Read the spec or task list in `docs/specs/` or `vault/tasks/`
2. **Implement**: Follow TDD cycle - write tests, implement to pass, refactor
3. **Verify**: Run full test suite, verify cross-module impacts
4. **Output**: Code changes with tests passing

## Deep Mode
>
> Full structured implementation with checkpoints.

1. **Sprint Planning** - Review backlog, allocate stories, estimate effort
2. **Context Investigation** - Load full context of target module using `repomix`
3. **Dependency Scanning** - Identify leaf-node files, sequence implementation
4. **TDD Loop** - For every task: Write tests first (RED), Implement (GREEN), Refactor
5. **Nyquist Gate** - Verify cross-module impacts, run full integration suite
6. **Task Closure** - Mark `[x]` in `vault/tasks/todo_{brief}_{date}.md` ONLY after tests GREEN

## Output

- High-quality, tested code changes.
- Updated `vault/tasks/todo_{brief}_{date}.md` with proof of verification.
- Sprint progress tracking in `docs/sprint_status.yaml`.

## Key Principles

- **Tests gate progress**: A task is NOT complete until its specific tests pass.
- **TDD Cycle**: RED → GREEN → REFACTOR for every task
- **Isolation Rigor**: Ensure context is "enough and correct" for the current module
- **Atomic Commits**: Every task is a self-contained, testable change
