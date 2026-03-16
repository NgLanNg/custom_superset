---
name: 'step-02-architecture'
description: 'Architecture Extraction'

# Output / Next Step
nextStepFile: '{project-root}/.claude/phases/phase-1-analysis/02-codebase-documentation/steps/step-03-finalize.md'
outputFile: '{project-root}/docs/architecture.md'
templateFile: '{project-root}/.agents/template/architecture.template.md'
---

# Step 02: Architecture Extraction

## STEP GOAL

Identify existing architectural patterns to document the system skeleton.

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
- 🚫 NEVER guess patterns. Search for key terms (JWT, OAuth, gRPC, REST).

### Step-Specific Boundaries & Limits

- 🎯 Focus only on identifying context-sensitive architectural decisions and patterns.
- 🚫 FORBIDDEN to guess assumptions or skip steps.
- 🔄 Available context: Codebase root files and detected source directories.

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

### 2. Extract Details

- **Auth mechanisms**: Search for "login", "auth", "token", "session", "passport", "auth0" using `grep_search`.
- **Communication Patterns**: Search for "fetch", "axios", "api", "graphql", "rpc", "pubsub".
- **Data Model**: Identify the 5 most important tables or entities by scanning models or schema files.
- **Backend/Frontend Interface**: Determine how components interact (e.g., REST API, Server-Side Rendering, Client-Side routing).

### 2. Menu / Post-Action

- 🛑 STOP: Do not proceed further on your own.
- Present Menu Options:
"I have identified the following architectural components:
**Auth:** {{Auth Details}}
**Communication:** {{Comm Patterns}}
**Data Model:** {{Top Entities}}

Does this accurately describe the system skeleton?

[C] Continue to Final Serialization (Step 03)
[A] Adjust architecture details
[P] Pause and wait for instructions"

- ONLY WHEN user selects 'C', update frontmatter `stepsCompleted: [2]` in `{outputFile}` and load `{nextStepFile}`.

---

## 🚨 SYSTEM SUCCESS/FAILURE METRICS

### ✅ SUCCESS

- Existing architecture appropriately classified according to code realities.
- Authentication, communication, and data patterns documented in `{outputFile}`.
- A/P/C menu presented with clear options.

### ❌ SYSTEM FAILURE

- Generating content or assumptions without clear user instructions.
- Proceeding to the next step without explicit user confirmation ('C').
- Assuming patterns without searching actual codebase details.
- Using relative paths for file operations.
