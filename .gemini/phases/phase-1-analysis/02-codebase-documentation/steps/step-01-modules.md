---
name: 'step-01-modules'
description: 'Mapping Core Modules'

# Output / Next Step
nextStepFile: '{project-root}/.claude/phases/phase-1-analysis/02-codebase-documentation/steps/step-02-architecture.md'
outputFile: '{project-root}/docs/readme.md'
templateFile: '{project-root}/.agents/template/readme.template.md'
---

# Step 01: Mapping Core Modules

## STEP GOAL

Summarize project directories and their specific purposes to build the foundational readme.

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
- 🚫 NO GUESSSING - use `list_dir` to verify directory structure.

### Step-Specific Boundaries & Limits

- 🎯 Focus only on identifying top-level modules and their primary roles.
- 🚫 FORBIDDEN to guess assumptions or skip steps.
- 🔄 Available context: Codebase root and first level sub-directories.

## EXECUTION PROTOCOLS

- Execute tasks chronologically.
- Wait for user feedback before proceeding to the next logical group of actions.

## CONTEXT BOUNDARIES

- Context is restricted to the current step and any provided inputs.

## SEQUENCE OF INSTRUCTIONS (Do not deviate, skip, or optimize)

### 1. Initialize Document

- Check if file `{outputFile}` exists using `view_file`.
- If it doesn't exist: Proceed to setup and copy/write the template from `{templateFile}` to `{outputFile}`.
- Initialize the state-tracking frontmatter in `{outputFile}`.

### 2. Identify Core Folders

- Perform a directory scan (depth=2) of the codebase root using `list_dir`.
- For each folder, determine its primary function (e.g., source code, models, tests, configuration, documentation).
- Identify entry points: Look for files like `index.js`, `main.py`, `app.py`, etc.
- Identify testing patterns: Confirm where unit and integration tests live.

### 2. Menu / Post-Action

- 🛑 STOP: Do not proceed further on your own.
- Present Menu Options:
"I have mapped these core modules:
{{Module List and Description}}

Are these descriptions accurate?

[C] Continue to Architecture Extraction (Step 02)
[A] Adjust modules
[P] Pause and wait for instructions"

- ONLY WHEN user selects 'C', update frontmatter `stepsCompleted: [1]` in `{outputFile}` and load `{nextStepFile}`.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS

- Top directories structure properly recognized and documented in `{outputFile}`.
- Entry points and test locations correctly identified.
- `{outputFile}` initialized with correct frontmatter.
- A/P/C menu presented with clear options.

### ❌ SYSTEM FAILURE

- Generating content or assumptions without clear user instructions.
- Proceeding to the next step without explicit user confirmation ('C').
- Assuming structure without searching actual codebase directories.
- Using relative paths for file operations.
