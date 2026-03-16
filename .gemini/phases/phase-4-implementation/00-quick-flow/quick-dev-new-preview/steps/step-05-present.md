---
name: 'step-05-present'
description: 'Present findings, get approval, create PR'
---

# Step 5: Present

## STEP GOAL

Understand and execute this step according to its primary objective.



## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER generate content without user input
- 📖 CRITICAL: Read the complete step file before taking any action


## EXECUTION PROTOCOLS

- Execute tasks chronologically.
- Wait for user feedback before proceeding to the next logical group of actions.


## CONTEXT BOUNDARIES

- Context is restricted to the current step and any provided inputs.
## RULES

- YOU MUST ALWAYS SPEAK OUTPUT in your Agent communication style with the config `{communication_language}`
- NEVER auto-push.

## INSTRUCTIONS

1. If version control is available and the tree is dirty, create a local commit with a conventional message derived from the spec title.
2. Change `{spec_file}` status to `done` in the frontmatter.
3. Display summary of your work to the user, including the commit hash if one was created. Advise on how to review the changes. Offer to push and/or create a pull request.

Workflow complete.
