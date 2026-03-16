---
description: 'Plan the upcoming sprint by reviewing the backlog and estimating effort.'
---

# /sprint

> Plan the upcoming sprint by reviewing the backlog and estimating effort.

**Scope:** `sprint`
**Phase:** Phase 4 - Implementation
**Deep Mode:** (Sprint planning - no separate workflow file)

## When to Use

- At the start of a new development cycle or sprint.
- When the Product Manager (PM) needs to allocate Stories from the backlog to Developers.
- When you need to generate a clear `sprint_status.md` or update Jira sprint boards.

## Fast Mode
>
> Local markdown sprint allocation.

1. **Read Epics**: Read all Epics and Stories listed in `docs/epics.md`.
2. **Prioritize**: Identify pending `backlog` stories.
3. **Estimate**: Provide rough T-shirt size estimates (S, M, L) for the next 3-5 logical stories.
4. **Output**: Write these selected stories to `docs/sprint_status.yaml` or `.md`, marking them as `ready-for-dev`.

## Deep Mode
>
> Full Jira-integrated execution using MCP tooling.

1. **Fetch Truth (Jira)**: Use the `mcp-management` skill (or local Atlassian tools) to fetch the current Jira backlog.
2. **Analyze Capacity**: Review the current sprint capacity and priority tags on the Jira Epics.
3. **Allocate**:
   - Select the highest value Stories that fit within the sprint bounds.
   - Use the Jira MCP to transition these tickets from `Backlog` to `Selected for Development` (or `ready-for-dev`).
   - Assign the tickets to the Developer role.
4. **Local Sync**: Update a local `docs/sprint_status.yaml` tracking file so local agents know what is actively in transition.

*Status Reference*: Epic (`backlog` → `in-progress` → `done`), Story (`backlog` → `ready-for-dev` → `in-progress` → `review` → `done`).

## Output

- Jira Sprint Board Updated (in Deep Mode).
- `docs/sprint_status.yaml` tracking file.

## Key Principles

- **Dependencies First**: Always sequence backend/design-architecture stories before frontend/dashboard stories.
- **No Scope Creep**: Only pull stories that have been explicitly defined in the PRD and Epics list.
- **Atomic Commits**: Ensure selected stories can reasonably be completed independently.
