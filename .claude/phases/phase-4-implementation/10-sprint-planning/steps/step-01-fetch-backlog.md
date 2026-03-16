# Step 01: Fetch Backlog

**Purpose:** Gather all backlog items from Jira or local epics.

## Instructions

1. Read `docs/epics.md` to identify all Epics and their Stories
2. If Jira MCP is available, use it to fetch the current sprint backlog
3. Document all items with their current status and priority

## Output

- `backlog_items`: Array of story objects with id, title, status, priority
- `epic_mapping`: Mapping of stories to their parent epics
- `priority_tags`: List of priority levels used (must-have, nice-to-have, etc.)

## Ready to Continue?

When you have completed this step, ask the user to select:
- [C] Continue to Step 02: Analyze Dependencies
- [A] Adjust: Refetch backlog with different parameters
- [P] Pause: Wait for user instruction
