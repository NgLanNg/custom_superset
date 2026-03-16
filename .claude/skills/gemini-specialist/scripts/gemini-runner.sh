#!/bin/bash
# .agents/skills/gemini-specialist/scripts/gemini-runner.sh

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

MODEL="gemini-2.5-pro"
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

echo "[INFO] Spawning Gemini specialist using $ROLE_PATH..." >&2

# Execute Gemini, filtering noisy CLI logs 
gemini -y -m "$MODEL" -p "$PROMPT" 2>&1 | grep -v "^Loaded\|^Skill\|^Attempt"
