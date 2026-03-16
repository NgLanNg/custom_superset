#!/bin/bash
# Health System Hook - Integrates health-system.sh with Claude Code
# Usage: Called from post-tool-hook.sh on PostToolUse

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
SESSION_ID="${SESSION_ID:-$(echo "$INPUT" | jq -r '.session_id // "unknown"')}"

# Set up environment
HEALTH_DIR="${CLAUDE_PROJECT_DIR}/.claude/health-system"
DIAGNOSTIC_LOG="${CLAUDE_PROJECT_DIR}/logs/diagnostics/diagnostic_${SESSION_ID}.jsonl"

# Ensure directories exist
mkdir -p "$(dirname "$DIAGNOSTIC_LOG")"

# Log successful tool execution
log_event() {
    local event="$1"
    local category="$2"
    local severity="$3"
    local description="$4"
    local context="${5:-{}}"
    local recommendation="${6:-}"

    cat >> "$DIAGNOSTIC_LOG" <<EOF
{"timestamp":"$(date -Iseconds)","event":"$event","category":"$category","severity":"$severity","description":"$description","context":$context,"recommendation":"$recommendation","agent_learnable":true}
EOF
}

# Track tool usage patterns
case "$TOOL_NAME" in
    "Read")
        # Track file reads - potential signal for context compaction
        FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
        if [[ -n "$FILE_PATH" ]]; then
            # Check if this is a context file
            case "$FILE_PATH" in
                *"active_context.md"*|*"todo.md"*|*"project-context.md"*)
                    log_event "context_read" "context" "low" "Read context file" "{\"file\":\"$FILE_PATH\"}"
                    ;;
            esac
        fi
        ;;
    "Edit"|"Write")
        # Track file modifications
        FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
        if [[ -n "$FILE_PATH" ]]; then
            log_event "file_modified" "tool" "low" "Modified file" "{\"file\":\"$FILE_PATH\",\"tool\":\"$TOOL_NAME\"}"
        fi
        ;;
    "Bash")
        # Track bash commands
        COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
        case "$COMMAND" in
            *".claude/"*|*".agents/"*)
                log_event "hook_execution" "tool" "low" "Executed hook script" "{\"command\":\"$COMMAND\"}"
                ;;
        esac
        ;;
    "MCP"*)
        log_event "mcp_call" "tool" "low" "MCP tool called" "{\"tool\":\"$TOOL_NAME\"}"
        ;;
esac

# Keep the diagnostic file permissions secure
chmod 600 "$DIAGNOSTIC_LOG" 2>/dev/null || true

exit 0
