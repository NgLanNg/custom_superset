---
name: 'step-01-discover'
description: 'Context Discovery & Initialization'

# Output / Next Step
nextStepFile: '{project-root}/.claude/phases/phase-1-analysis/01-project-context/steps/step-02-patterns.md'
outputFile: '{project-root}/docs/project-context.md'
templateFile: '{project-root}/.agents/template/project-context.template.md'
---

# Step 01: Context Discovery & Initialization

## STEP GOAL

Discover the project's existing technology stack and initialize the context document.

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
- 🧠 ANTI-HALLUCINATION: If a file or version is not found, state "NOT FOUND" instead of guessing.

### Step-Specific Boundaries & Limits

- 🎯 Focus only on discovering existing project context and technology stack.
- 🚫 FORBIDDEN to guess assumptions or skip steps.
- 🔄 Available context: Codebase root files (`package.json`, `requirements.txt`, etc.).

## EXECUTION PROTOCOLS

- Execute tasks chronologically.
- Wait for user feedback before proceeding to the next logical group of actions.

## CONTEXT BOUNDARIES

- Context is restricted to the current step and any provided inputs.

## SEQUENCE OF INSTRUCTIONS (Do not deviate, skip, or optimize)

### 1. Check for Existing Project Context

- Check if file `{outputFile}` exists using `view_file`.
- If it exists:
  - Read to understand existing rules.
  - Ask: "Found existing project context at `{outputFile}`. Update it or start fresh?"
- If it doesn't exist:
  - Proceed to setup and copy/write the template from `{templateFile}` to `{outputFile}`.
  - Initialize the state-tracking frontmatter in `{outputFile}`.

### 2. Discover Technology Stack

- Scan for: `package.json`, `requirements.txt`, `dbt_project.yml`, `tsconfig.json`, `go.mod`, `Cargo.toml`.
- Extract exact versions of core dependencies (e.g., React, Python, Node, dbt).
- Identify primary data engines (Snowflake, BigQuery, Postgres, etc.) from configs.

### 3. Identify Code Patterns

- Identify naming conventions for files (PascalCase, snake_case).
- Identify naming conventions for variables/functions.
- Map directory structure patterns (e.g., `src/`, `models/`, `tests/`).
- Identify linting/formatting configs (`.eslintrc`, `.prettierrc`, `pyproject.toml`).

### 4. Menu / Post-Action

- 🛑 STOP: Do not proceed further on your own.
- Present Menu Options:
"I've analyzed the project.
**Tech Stack:** {{Versions}}
**Patterns:** {{Naming/Structure}}
**Ready to extract specific implementation rules?**

[C] Continue to Pattern Extraction (Step 02)
[A] Adjust discoveries
[P] Pause and wait for instructions"

- ONLY WHEN user selects 'C', update frontmatter `stepsCompleted: [1]` in `{outputFile}` and load `{nextStepFile}`.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS

- Technology stack accurately identified with exact versions (or "NOT FOUND").
- Critical implementation patterns discovered and confirmed.
- `{outputFile}` initialized with correct frontmatter.
- A/P/C menu presented with clear options.

### ❌ SYSTEM FAILURE

- Generating content or assumptions without clear user instructions.
- Proceeding to the next step without explicit user confirmation ('C').
- Missing critical technology versions or configurations available in the root.
- Using relative paths for file operations.
