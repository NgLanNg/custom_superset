---
description: Create or update documentation. Covers project analysis, drafting, discovery, and micro-docs.
---

# /docs

> Create or update documentation. Covers project analysis, drafting, discovery, and micro-docs.

**Scope:** `daily`
**Phase:** Phase 1 — Analysis (documentation steps)
**Mode:** `.claude/phases/phase-1-analysis/02-codebase-documentation/workflow.md` (for `--project`)

## Modes

- **`--discover`**: Plan documentation for a new feature or codebase
- **`--draft`**: Write content from an approved plan
- **`--micro`**: Document a specific component or feature inline
- **`--project`**: Analyze and document the full project *(absorbs `/document-project`)*

> If no mode is given, ask the user to choose.

## When to Use

- After completing a feature (document what changed)
- Before planning a feature (discover the existing landscape)
- To generate an API reference, system overview, or feature doc
- To produce project-level documentation from a full codebase scan

---

## Fast Mode

> Quick documentation for a single component or change.

1. Identify: what changed and why
2. Write inline: Intent, Key Invariants, Usage example
3. Save to `docs/features/{name}.md` or update the relevant doc file
4. Update any index or table of contents files

---

## Deep Mode (`--discover`)
>
> Plan docs for a new feature or codebase.

1. Inventory: scan codebase with `find_by_name`, `grep`, or `repomix`
2. Map: entry points, data models, key logic
3. Output: `docs/plans/documentation-plan-{topic}.md`
   - Proposed doc structure
   - List of files to cover
   - Identified gaps

---

## Deep Mode (`--draft`)
>
> Write documentation from an approved discovery plan.

1. Read approved plan from `docs/plans/`
2. Select template:
   - General: `docs/{category}/YYYY-MM-DD-{slug}.md`
   - API: `docs/api/api-reference.md`
   - System: `docs/system/{name}.md`
3. Write content following the agreed structure
4. Verify: code examples match actual implementation

---

## Deep Mode (`--micro`)
>
> Document a specific component in detail.

1. Locate source files for the feature
2. Analyze: Intent, Invariants, Usage, Dependencies
3. Draft using FEATURE_DOC structure:
   - **Intent**: The "Why"
   - **Critical Invariants**: Must-haves (security, performance)
   - **Usage**: Real code examples
   - **Dependencies**: What it relies on
4. Save to `docs/features/{feature-name}.md`

---

## Deep Mode (`--project`)
>
> Full codebase analysis and project documentation.

Load: `.claude/phases/phase-1-analysis/02-codebase-documentation/workflow.md`

1. Bootstrap: load `docs/project-context.md` if it exists
2. Scan: full codebase with `repomix` or phase analysis tools
3. Output: structured docs covering architecture, data flow, key decisions
4. Save: update `docs/project-context.md` or create `docs/system/project-overview.md`

---

## Output

- `docs/plans/documentation-plan-{topic}.md` (`--discover`)
- `docs/{category}/{slug}.md` (`--draft`)
- `docs/features/{name}.md` (`--micro`)
- `docs/project-context.md` or `docs/system/project-overview.md` (`--project`)

## Key Principles

- **Evidence-based**: Document what exists, not what you wish existed
- **Consumer-focused**: Write for the reader of the doc, not the writer
- **Invariants over prose**: Hard constraints in bullet points beat long paragraphs
