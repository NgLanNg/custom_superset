---
name: 'step-03-finalize'
description: 'Final Serialization'

# Output / Next Step
nextStepFile: '{project-root}/.claude/phases/phase-1-analysis/03-product-brief/workflow.md'
outputFile: '{project-root}/docs/readme.md'
---

# Step 03: Final Serialization

## STEP GOAL

Save all findings to `{project-root}/docs/readme.md` and `{project-root}/docs/architecture.md`.

## MANDATORY EXECUTION RULES (READ FIRST)

### Universal Guardrails

- 🛑 NEVER generate content without user input.
- 📖 CRITICAL: Read the complete step file before taking any action.
- 📋 YOU ARE A FACILITATOR, not a content generator.
- 💾 ALWAYS ensure `docs/` folder exists at `{project-root}/docs/`.
- ✅ Generate README and Architecture docs from Step 01 & 02.
- 🏁 Workflow ends here. Notify user.
- 📂 ALWAYS Use ABSOLUTE PATHS for all file operations.

### Role Reinforcement

- ✅ ROLE: You are a Product Owner (PO) and Developer (dev).
- ✅ Maintain a collaborative tone throughout.

### Step-Specific Boundaries & Limits

- 🎯 Focus only on serializing discovered data into finalized documentation.
- 🚫 FORBIDDEN to guess assumptions or skip steps.

## EXECUTION PROTOCOLS

- Execute tasks chronologically.
- Wait for user feedback before proceeding to the next logical group of actions.

## CONTEXT BOUNDARIES

- Context is restricted to the current step and any provided inputs.

## SEQUENCE OF INSTRUCTIONS (Do not deviate, skip, or optimize)

### 1. File Writing

- Compile discoveries from Step 01 and Step 02.
- Finalize `{project-root}/docs/readme.md` with project mapping formatting clearly in Markdown.
- Finalize `{project-root}/docs/architecture.md` with patterns formatting clearly in Markdown.
- Update frontmatter `stepsCompleted: [3]` and `inputDocuments: [...]` in both files.

### 2. Menu / Post-Action

- 🛑 STOP: Do not proceed further on your own.
- Present Menu Options:
"Codebase documentation is complete.
Files generated:
- `{project-root}/docs/readme.md`
- `{project-root}/docs/architecture.md`

Ready for Phase 1 Step 03: Product Brief?

[C] Continue to Product Brief Phase
[A] Review/Adjust docs
[P] Pause and wait for instructions"

- ONLY WHEN user selects 'C', update frontmatter and load `{nextStepFile}`.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS

- Both document files correctly saved with accurate formatting and frontmatter.
- Content is fully optimized for human and LLM consumption.
- A/P/C menu presented with clear options.

### ❌ SYSTEM FAILURE

- Generating content or assumptions without clear user instructions.
- Assuming structure rather than using extracted discoveries.
- Missing critical discoveries in the final documents.
- Using relative paths for file operations.
