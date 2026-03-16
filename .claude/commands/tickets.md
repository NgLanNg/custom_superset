---
description: 'Break requirements into epics and user stories. Use when the user says "create the epics and stories list"'
---

# /tickets

> Break requirements into epics and user stories.

**Scope:** `project`
**Phase:** Phase 3 - Solutioning
**Deep Mode:** `.claude/phases/phase-3-solutioning/05-technical-design/workflow.md`

## When to Use

- After the Product Owner (PO) has finalized the PRD in Confluence.
- When you need to translate business requirements into actionable Jira Epics and Stories for the development team.
- At the start of a new major project feature kickoff.

## Execution Path
>
> **High-Fidelity Project Decomposition**

1. **Information Ingest**: Read `docs/prd.md` or fetch it from Confluence via MCP. For large codebases, perform a comprehensive context load of all architectural documentation.
2. **Requirements Inventory**: Enumerate all Functional and Non-Functional Requirements. Trace every story back to these requirements.
3. **Decompose**:
   - Break requirements into structured Epics.
   - Break Epics into Stories following the `As a <user>, I want to <goal> so that <benefit>` format.
   - For every Story, write strict Acceptance Criteria using the Gherkin `Given/When/Then` standard.
4. **Handoff & Sync**:
   - Write results to `docs/epics.md`.
   - If MCP Jira tools are available, sync Epics and Stories directly to the Jira workspace.
5. **Verify Constraints**: Validate that no tech stacks or architectural decisions were hallucinated if they were not present in the PRD.

## Output

- `docs/epics.md` containing full requirements mapping and Gherkin ACs.
- Created Epics and Stories in Jira (when in Deep Mode with Atlassian MCP).

## Key Principles

- **No Hallucination**: If the PRD is missing a detail, DO NOT guess. Write `{TBD}` and assign an action item to the PO.
- **Traceability**: Every story must trace back to a specific requirement in the PRD.
- **Actionable Scope**: Stories must be small enough for a single developer to complete in one sprint.
