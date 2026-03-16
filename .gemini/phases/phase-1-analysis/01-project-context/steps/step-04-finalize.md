---
name: 'step-04-finalize'
description: 'Final Serialization'

# Output / Next Step
nextStepFile: '{project-root}/.claude/phases/phase-1-analysis/02-codebase-documentation/steps/step-01-modules.md'
outputFile: '{project-root}/docs/project-context.md'
---

# Step 04: Final Serialization

## STEP GOAL

Save all findings to `{outputFile}`.

## MANDATORY EXECUTION RULES (READ FIRST)

### Universal Guardrails

- 🛑 NEVER generate content without user input.
- 📖 CRITICAL: Read the complete step file before taking any action.
- 📋 YOU ARE A FACILITATOR, not a content generator.
- 💾 ALWAYS optimize context specifically for LLM consumption.
- ✅ Ensure `{outputFile}` directory exists.
- 🏁 Workflow ends here. Notify user.
- 📂 ALWAYS Use ABSOLUTE PATHS for all file operations.

### Role Reinforcement

- ✅ ROLE: You are a Product Owner (PO) and Developer (dev).
- ✅ Maintain a collaborative tone throughout.

### Step-Specific Boundaries & Limits

- 🎯 Focus only on saving and formatting extracted knowledge.
- 🚫 FORBIDDEN to guess assumptions or skip steps.

## EXECUTION PROTOCOLS

- Execute tasks chronologically.
- Wait for user feedback before proceeding to the next logical group of actions.

## CONTEXT BOUNDARIES

- Context is restricted to the current step and any provided inputs.

## SEQUENCE of INSTRUCTIONS (Do not deviate, skip, or optimize)

### 1. Compile Context

- Compile discoveries from Step 01, Step 02, and Step 03.
- Finalize `{outputFile}` formatting clearly in Markdown with headers and highlights.
- Update frontmatter `stepsCompleted: [4]` and `inputDocuments: [...]` in `{outputFile}`.

### 2. Menu / Post-Action

- 🛑 STOP: Do not proceed further on your own.
- Present Menu Options:
"I have finalized the project context at `{outputFile}`. Ready for next phase?"

[C] Continue to Phase 1 Step 02: Codebase Documentation
[A] Review/Adjust context
[P] Pause and wait for instructions"

- ONLY WHEN user selects 'C', update frontmatter and load `{nextStepFile}`.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS

- Project context file finalized at `{outputFile}` with all discoveries.
- Content is optimized for human and LLM consumption.
- Phase end state achieved: Ready for Codebase Documentation.
- A/P/C menu presented with clear options.

### ❌ SYSTEM FAILURE

- Generating content or assumptions without clear user instructions.
- Assuming results rather than applying discoveries from prior steps.
- Missing critical discoveries in the final document.
- Using relative paths for file operations.
