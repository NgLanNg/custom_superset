---
name: 'step-02-patterns'
description: 'Implementation Patterns'

# Output / Next Step
nextStepFile: '{project-root}/.claude/phases/phase-1-analysis/01-project-context/steps/step-03-rules.md'
outputFile: '{project-root}/docs/project-context.md'
---

# Step 02: Implementation Patterns

## STEP GOAL

Identify exactly "how we build things" in this codebase.

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
- 🚫 NO GUESSSING - use codebase search tools to verify findings.

### Step-Specific Boundaries & Limits

- 🎯 Focus only on identifying file and directory patterns.
- 🚫 FORBIDDEN to guess assumptions or skip steps.
- 🔄 Available context: Codebase root files and detected `src/`, `models/`, `tests/` directories.

## EXECUTION PROTOCOLS

- Execute tasks chronologically.
- Wait for user feedback before proceeding to the next logical group of actions.

## CONTEXT BOUNDARIES

- Context is restricted to the current step and any provided inputs.

## SEQUENCE OF INSTRUCTIONS (Do not deviate, skip, or optimize)

### 1. Pattern Discovery

- Inspect 3-5 existing source files across different modules identified in Step 01.
- Map core directory functions (where models/sources/tests live).
- Confirm File Naming: PascalCase vs snake_case based on discovery.
- Confirm Function/Variable formatting: camelCase vs snake_case.
- Confirm Directory Mapping: `{project-root}/src/`, `{project-root}/models/`, `{project-root}/tests/` etc.

### 2. Menu / Post-Action

- 🛑 STOP: Do not proceed further on your own.
- Present Menu Options:
*"Naming convention is {{Pattern}} and directories are {{Structure}}. Alignment confirmed?"*

[C] Continue to Rule Extraction (Step 03)
[A] Adjust patterns
[P] Pause and wait for instructions"

- ONLY WHEN user selects 'C', update frontmatter `stepsCompleted: [2]` in `{outputFile}` and load `{nextStepFile}`.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS

- Existing pattern properly detected and documented in `{outputFile}`.
- Directory mappings are verified using `list_dir`.
- A/P/C menu presented with clear options.

### ❌ SYSTEM FAILURE

- Generating content or assumptions without clear user instructions.
- Proceeding to the next step without explicit user confirmation ('C').
- Assuming patterns without searching actual files.
- Using relative paths for file operations.
