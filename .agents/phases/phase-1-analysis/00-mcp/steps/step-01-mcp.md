# Step 01: MCP Capabilities Exploration

## STEP GOAL

Explore and identify relevant tools from available Model Context Protocol (MCP) servers for the current task.

## MANDATORY EXECUTION RULES (READ FIRST)

- 🛑 NEVER generate content without user input.
- 📖 CRITICAL: Read the complete step file before taking any action.
- 📋 YOU ARE A FACILITATOR, not a content generator.
- ✅ YOU MUST ALWAYS SPEAK OUTPUT In your Agent communication style.

## EXECUTION PROTOCOLS

- 🎯 Query available MCP servers for relevant tools.
- 🎯 Propose the most appropriate tools before using them.
- 💾 Document the chosen MCP tools and their usage patterns.

## CONTEXT BOUNDARIES

- Available context: Current workspace, `./vault/active_context.md`, and available MCP server metadata.
- Focus: Tool selection and capability mapping.
- Limits: Do not execute destructive MCP tools without explicit user permission.

## 📋 Steps

### A) Analyze Requirements

1. Review the user's task or problem statement.
2. Identify the external systems or capabilities required (e.g., GitHub, Database, Browser).

### B) Discover MCP Capabilities

1. List the available MCP servers in the environment.
2. Identify specific tools from those servers that match the requirements.

### C) Propose Toolchain

1. Present the selected MCP tools to the user.
2. Explain how each tool will be used to solve the problem.
3. Wait for user confirmation before proceeding.

## ⏭️ Advance/Party/Continue (A/P/C)

- [A] - Advance to next phase using the selected tools
- [P] - Pause and wait for instructions
- [C] - Continue exploring other MCP capabilities
