# Workflow: Sprint Planning

**Phase:** 4 — Implementation
**Config:** `config.yaml`
**Primary Role:** PM

## Purpose

Manage Jira sprint planning with dependency-aware story allocation and capacity assessment.

## Execution

Load `config.yaml` from this directory. Execute the state graph starting at `fetch_backlog`.

### Flow Steps

1. **Fetch Backlog** - Gather items from Jira or local epics
2. **Analyze Dependencies** - Map story dependencies, identify blocks
3. **Assess Capacity** - Calculate team capacity, allocate stories
4. **Update Jira** - Sync sprint board and ticket statuses
5. **Create Local Sync** - Generate local tracking file for agents

### Checkpoints (Human-in-Loop)

- After backlog fetch - validate contents
- After dependency analysis - validate order
- After capacity assessment - validate allocation
- After Jira sync - validate state
- Final confirmation - complete sprint plan

## Rules

- **Dependencies First** - backend/design-architecture before frontend
- **No Scope Creep** - only pull from defined PRD and Epics
- **Atomic Commits** - stories should be independently shippable
- **Capacity Aware** - respect sprint bounds and team availability
- At every checkpoint - STOP and wait for user confirmation

## Output

- `docs/sprint_status.md` - Sprint plan with allocated stories
- `docs/sprint-backlog.yaml` - Backlog tracker with priorities
- Jira sprint board updated
- Local sync file for agent context

## End State

- Sprint stories allocated to team
- Jira board synchronized
- Local tracking file created
- Ready for `phase-4-implementation/06-implementation`
