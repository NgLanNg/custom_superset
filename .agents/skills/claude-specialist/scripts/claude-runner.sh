#!/bin/bash
# .agents/skills/claude-specialist/scripts/claude-runner.sh

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <role_yaml_path> <task_description>"
    exit 1
fi

ROLE_PATH="$1"
TASK="$2"

if [ ! -f "$ROLE_PATH" ]; then
    echo "Error: Role file not found at $ROLE_PATH"
    exit 1
fi

ROLE_CONTEXT=$(cat "$ROLE_PATH")

PROMPT="You are acting as a dynamic specialist bridge subagent.
Below is your persona definition in YAML. You must internalize the identity, principles, and communication style before answering. 
You MUST adopt this persona completely.

=== PERSONA JSON/YAML ===
$ROLE_CONTEXT
=========================

Your tasked objective is:
$TASK

Execute this task using any tools available to you. Return ONLY your findings, analysis, or results strictly in your persona's voice."

echo "[INFO] Spawning Claude specialist using $ROLE_PATH..." >&2

# Pipe prompt into claude --print for execution
echo "$PROMPT" | claude --print 2>&1
