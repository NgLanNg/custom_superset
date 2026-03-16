---
description: Design the technical blueprint — data models, API contracts, and system structure.
---

# /design-architect

> Design the technical blueprint — data models, API contracts, and system structure.

**Scope:** `situational`
**Phase:** Phase 3 — Solutioning
**Deep Mode:** `.claude/phases/phase-3-solutioning/05-technical-design/workflow.md`

## When to Use

- Before implementing a new service, API, or data layer
- When the feature requires cross-cutting changes (DB + API + frontend)
- After `/brainstorm` aligned on approach but before writing specs

## Fast Mode
>
> Quick architecture sketch for familiar patterns.

1. Define the data model (entities + relationships)
2. Sketch the API contract (endpoints, inputs, outputs)
3. Note integration points with existing code
4. Output: `docs/design-architecture/YYYY-MM-DD-{topic}.md` (draft)

## Deep Mode
>
> Full structured technical design with schema and decision log.

Load: `.claude/phases/phase-3-solutioning/05-technical-design/workflow.md`

1. **Context** — Read project-context, existing models, and constraints
2. **Data Design** — Define schemas, entity relationships, indexes
3. **API Design** — REST/GraphQL contracts, error handling, auth scope
4. **Integration** — Map to existing services and identify touch points
5. **Decisions** — Record key design decisions with trade-offs
6. **Output** — `docs/design-architecture/YYYY-MM-DD-{topic}.md`

## Output

- `docs/design-architecture/YYYY-MM-DD-{topic}.md`

## Key Principles

- **Schema first**: Lock data models before API; API before implementation
- **Decisions log**: Every non-obvious choice gets a "why" entry
- **Minimal surface area**: Design the smallest interface that solves the problem
