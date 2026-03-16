---
name: mcp-management
description: Manage Model Context Protocol (MCP) servers - discover, analyze, and execute tools/prompts/resources from configured MCP servers. Use when working with MCP integrations, need to discover available MCP capabilities, filter MCP tools for specific tasks, execute MCP tools programmatically, access MCP prompts/resources, or implement MCP client functionality. Supports intelligent tool selection, multi-server management, and context-efficient capability discovery.
---

# MCP Management

Skill for managing and interacting with Model Context Protocol (MCP) servers.

## Overview

MCP is an open protocol enabling AI agents to connect to external tools and data sources. This skill provides scripts and utilities to discover, analyze, and execute MCP capabilities from configured servers without polluting the main context window.

**Key Benefits**:

- Progressive disclosure of MCP capabilities (load only what's needed)
- Intelligent tool/prompt/resource selection based on task requirements
- Multi-server management from single config file
- Context-efficient: subagents handle MCP discovery and execution
- Persistent tool catalog: automatically saves discovered tools to JSON for fast reference

## When to Use This Skill

Use this skill when:

1. **Discovering MCP Capabilities**: Need to list available tools/prompts/resources from configured servers
2. **Task-Based Tool Selection**: Analyzing which MCP tools are relevant for a specific task
3. **Executing MCP Tools**: Calling MCP tools programmatically with proper parameter handling
4. **MCP Integration**: Building or debugging MCP client implementations
5. **Context Management**: Avoiding context pollution by delegating MCP operations to subagents

## Core Capabilities

### 1. Configuration Management

MCP servers configured in `.agents/.mcp.json`.

See [references/configuration.md](references/configuration.md).

### 2. Capability Discovery

```bash
npx tsx scripts/cli.ts list-tools # Saves to assets/tools.json
npx tsx scripts/cli.ts list-prompts
npx tsx scripts/cli.ts list-resources
```

Aggregates capabilities from multiple servers with server identification.

### 3. Intelligent Tool Analysis

LLM analyzes `assets/tools.json` directly - better than keyword matching algorithms.

### 4. Tool Execution

**Primary: Direct Scripts**

```bash
npx tsx scripts/cli.ts list-tools
npx tsx scripts/cli.ts call-tool <server> <tool> <json>
```

**Fallback: mcp-manager Sub-agent**

See [references/mcp-protocol.md](references/mcp-protocol.md) for complete technical details.

## Implementation Patterns

### Pattern 1: Direct Script Execution (Primary)

Use `scripts/cli.ts` for manual discovery and execution.

**Quick Example**:

```bash
npx tsx scripts/cli.ts call-tool <server> <tool> <args>
```

**Benefits**: Full control over parameters, no external dependencies (only Node.js/tsx).

### Pattern 2: Sub-agent Based Execution (Fallback)

Use a dedicated sub-agent for MCP tasks. The sub-agent discovers tools, selects relevant ones, and executes them in an isolated context.

**Benefit**: Main context stays clean, and complex tool multi-step logic is offloaded.

### Pattern 3: LLM-Driven Tool Selection

LLM reads `assets/tools.json`, intelligently selects relevant tools using context understanding, synonyms, and intent recognition.

### Pattern 4: Multi-Server Orchestration

Coordinate tools across multiple servers. Each tool knows its source server for proper routing.

## Scripts Reference

### scripts/mcp-client.ts

Core MCP client manager class. Handles:

- Config loading from `.agents/.mcp.json`
- Connecting to multiple MCP servers
- Listing tools/prompts/resources across all servers
- Executing tools with proper error handling
- Connection lifecycle management

### scripts/cli.ts

Command-line interface for MCP operations. Commands:

- `list-tools` - Display all tools and save to `assets/tools.json`
- `list-prompts` - Display all prompts
- `list-resources` - Display all resources
- `call-tool <server> <tool> <json>` - Execute a tool

**Note**: `list-tools` persists complete tool catalog to `assets/tools.json` with full schemas for fast reference, offline browsing, and version control.

## Quick Start

**Method 1: Direct Scripts**

```bash
cd .agents/skills/mcp-management/scripts && npm install
npx tsx cli.ts list-tools # Saves to assets/tools.json
npx tsx cli.ts call-tool memory create_entities '{"entities":[...]}'
```

**Method 2: Sub-agent Delegation**

Delegate the MCP task to a dedicated sub-agent for maximum context efficiency.

**Method 3: Orchestration Workflow**

Use the project's orchestration workflow (e.g., `sub-agent-orchestrate`) to manage complex MCP interactions across multiple agents.

## Technical Details

See [references/mcp-protocol.md](references/mcp-protocol.md) for:

- JSON-RPC protocol details
- Message types and formats
- Error codes and handling
- Transport mechanisms (stdio, HTTP+SSE)
- Best practices

## Integration Strategy

### Execution Priority

1. **Direct CLI Scripts** (Primary): Manual tool specification

- Use when: Need specific tool/server control
- Execute: `npx tsx scripts/cli.ts call-tool <server> <tool> <args>`

1. **Sub-agent Delegation** (Secondary): Isolated execution

- Use when: Task is complex or requires multi-step logic
- Offloads context discovery to a child session.

### Integration with Agents

The `mcp-manager` agent uses this skill to:

- Discover MCP capabilities without loading into main context
- Execute tools via scripts
- Report results back to main agent

This keeps main agent context clean and enables efficient MCP integration.
