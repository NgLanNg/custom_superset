---
name: 'step-03-rules'
description: 'Rule Extraction'

# Output / Next Step
nextStepFile: '{project-root}/.claude/phases/phase-1-analysis/01-project-context/steps/step-04-finalize.md'
outputFile: '{project-root}/docs/project-context.md'
---

# Step 03: Rule Extraction

## STEP GOAL

Identify critical, unobvious rules for AI agents.

## MANDATORY EXECUTION RULES (READ FIRST)

### Universal Guardrails

- 🛑 NEVER generate content without user input.
- 📖 CRITICAL: Read the complete step file before taking any action.
- 📋 YOU ARE A FACILITATOR, not a content generator.
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style with the config `{communication_language}`.
- 📂 ALWAYS Use ABSOLUTE PATHS for all file operations.

### Role Reinforcement

- ✅ ROLE: You are a Product Owner (PO) and Developer (dev).
- ✅ Maintain a collaborative tone throughout.
- 🚫 NEVER assume rules. Search for // ALWAYS / // NEVER in code.

### Step-Specific Boundaries & Limits

- 🎯 Focus only on extraction of explicit coding rules and specific behaviors expected.
- 🚫 FORBIDDEN to guess assumptions or skip steps.
- 🔄 Available context: Codebase root files and identified sub-directories.

## EXECUTION PROTOCOLS

- Execute tasks chronologically.
- Wait for user feedback before proceeding to the next logical group of actions.

## CONTEXT BOUNDARIES

- Context is restricted to the current step and any provided inputs.

## SEQUENCE OF INSTRUCTIONS (Do not deviate, skip, or optimize)

### 1. Rule Discovery

- Search comments in code files for "Always/Never" or other explicit strict behavior hints using `grep_search`.
- Check testing framework requirement constraints (e.g., "Must have 80% coverage") in `.github/workflows` or documentation.
- Identify archiving rules (e.g., "Move old SQL to `_archive/`").
- Look for Dev Workflow conventions (Branch/Commit naming convention).

### 2. Menu / Post-Action

- 🛑 STOP: Do not proceed further on your own.
- Present Menu Options:
*"I extracted these rules for future agents. Any additions?"*
{{Extracted Rules}}

[C] Continue to Final Serialization (Step 04)
[A] Adjust extracted rules
[P] Pause and wait for instructions"

- ONLY WHEN user selects 'C', update frontmatter `stepsCompleted: [3]` in `{outputFile}` and load `{nextStepFile}`.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS

- Existing rules and test requirements correctly isolated and documented in `{outputFile}`.
- A/P/C menu presented with clear options.

### ❌ SYSTEM FAILURE

- Generating content or assumptions without clear user instructions.
- Proceeding to the next step without explicit user confirmation ('C').
- Assuming rules without actually finding them inside the codebase.
- Using relative paths for file operations.
