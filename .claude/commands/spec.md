---
description: Create an implementation-ready technical spec through conversational discovery.
---

# /spec

> Create a high-fidelity, implementation-ready technical spec through disciplined conversational discovery and deep source investigation.
> **Also absorbs `/design-architect`** - data models, API contracts, and system structure.

**Scope:** `daily`
**Phase:** Phase 2 — Planning
**Deep Mode:** `.claude/phases/phase-2-planning/01-scope/workflow.md`

## When to Use

- Before implementing any non-trivial feature or complex refactor.
- When surfacing architectural unknowns or cross-module dependencies.
- To produce a "self-contained" spec that ensures any specialized agent can implement the change with zero context bleed.
- **Design architecture** for new services, APIs, or data models (absorbs `/design-architect`)

## Execution Path
>
> **Comprehensive Technical Discovery & Architectural Gate**

1. **Understand**: Clarify business requirements, success metrics, and technical constraints.
2. **Investigate**: Perform a "deep dive" into the source code. Read all relevant interfaces, data models, and callers. **No placeholders.**
3. **Design**: Define data models, API contracts, and system structure.
4. **Draft Spec**: Write the implementation roadmap in `docs/specs/`. Include file paths, logic changes, and test requirements.
5. **Scaffold Gate**: Validate against the "Power Spec" standard:
   - **Actionable**: Every task has a specific file path and a clear operation.
   - **Dependency-Ordered**: Logic changes are sequenced to prevent broken builds.
   - **Self-Contained**: The spec contains ALL necessary context (snippets, schemas) so the implementer doesn't have to re-discover it.

## Output

- A high-fidelity technical spec in `docs/specs/YYYY-MM-DD-{feature}.md`.
- Data models and API contracts (when appropriate).

## Key Principles

- **Complete or Nothing**: A partial spec leads to implementation drift. Investigation must be finished before implementation starts.
- **Investigate First**: Always read the "Ground Truth" of the current code before proposing changes.
- **Context Integrity**: Use comprehensive `repomix` packs to ensure the spec is grounded in the full project reality.
- **Design Integration**: Data models, schemas, and API contracts are part of the spec - not a separate step.
