# Step 02: Analyze Dependencies

**Purpose:** Map dependencies between stories to determine execution order.

## Instructions

1. Review all backlog items for cross-story dependencies
2. Identify stories that block other stories
3. Classify stories as:
   - `ready_to_dev`: No dependencies, can be started immediately
   - `blocked`: Has unmet dependencies
   - `sequential_chain`: Part of a dependency chain

## Output

- `dependency_graph`: Visual or text representation of dependencies
- `Blocked_stories`: List of stories that cannot start yet
- `ready_stories`: List of stories ready for sprint allocation

## Ready to Continue?

- [C] Continue to Step 03: Assess Capacity
- [A] Adjust: Recategorize dependencies
- [P] Pause: Wait for user instruction
