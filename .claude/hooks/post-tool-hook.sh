#!/bin/bash
# Post-Tool Hook - Unified dispatcher for Edit, Read, and error tracking
# Consolidates: auto-format.sh, output-validation.sh, error-tracker.sh

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_RESULT=$(echo "$INPUT" | jq -r '.tool_result // empty')
TIMESTAMP=$(date -Iseconds)

# ============================================
# Error Tracking (all tools)
# ============================================
if echo "$TOOL_RESULT" | jq -e 'has("error") or has("is_error")' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$TOOL_RESULT" | jq -r '.error // .text // "Unknown error"')

    LOG_DIR="$CLAUDE_PROJECT_DIR/logs/errors"
    mkdir -p "$LOG_DIR"

    ERROR_LOG="$LOG_DIR/errors_$(date +%Y%m%d).md"

    if [[ ! -f "$ERROR_LOG" ]]; then
        cat > "$ERROR_LOG" << EOF
# Error Log - $(date +%Y-%m-%d)

| Timestamp | Tool | Error |
|-----------|------|-------|
EOF
    fi

    ERROR_PREVIEW=$(echo "$ERROR_MSG" | head -c 200 | tr '\n' ' ')
    echo "| $TIMESTAMP | $TOOL_NAME | $ERROR_PREVIEW |" >> "$ERROR_LOG"

    DETAIL_FILE="$LOG_DIR/errors_$(date +%Y%m%d)_$(date +%H%M%S)_${TOOL_NAME}.json"
    echo "$INPUT" | jq '.' > "$DETAIL_FILE" 2>/dev/null

    echo ""
    echo "## Error Detected"
    echo "**Tool:** $TOOL_NAME"
    echo "**Error:** $ERROR_PREVIEW..."
    echo "Error logged to: \`logs/errors/\`"
    echo ""
fi

# Skip further processing if there's no successful result
if echo "$TOOL_RESULT" | jq -e 'has("error")' > /dev/null 2>&1; then
    exit 0
fi

# ============================================
# Auto-Format (Edit|Write tools)
# ============================================
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]]; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

    if [[ -n "$FILE_PATH" && -f "$FILE_PATH" ]]; then
        FILE_SIZE=$(stat -f%z "$FILE_PATH" 2>/dev/null || stat -c%s "$FILE_PATH" 2>/dev/null || echo 0)

        if (( FILE_SIZE <= 512000 )); then
            case "$FILE_PATH" in
                *.ts|*.tsx|*.js|*.jsx|*.json)
                    command -v prettier &> /dev/null && npx prettier --write "$FILE_PATH" 2>/dev/null || true
                    ;;
                *.py)
                    command -v black &> /dev/null && black "$FILE_PATH" 2>/dev/null || true
                    ;;
                *.go)
                    command -v gofmt &> /dev/null && gofmt -w "$FILE_PATH" 2>/dev/null || true
                    ;;
                *.rs)
                    command -v rustfmt &> /dev/null && rustfmt "$FILE_PATH" 2>/dev/null || true
                    ;;
            esac
        fi
    fi
fi

# ============================================
# Output Validation (Read|Grep|Glob tools)
# ============================================
if [[ "$TOOL_NAME" == "Read" || "$TOOL_NAME" == "Grep" || "$TOOL_NAME" == "Glob" ]]; then
    TOOL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // empty' 2>/dev/null || echo "")

    if [[ -n "$TOOL_OUTPUT" ]]; then
        OUTPUT_SIZE=${#TOOL_OUTPUT}

        # Block threshold: 500KB
        if (( OUTPUT_SIZE > 512000 )); then
            echo "Warning: Output is $(( OUTPUT_SIZE / 1024 ))KB. Consider pagination or filtering." >&2
        fi

        # Warn threshold: 50KB
        if (( OUTPUT_SIZE > 51200 )); then
            echo "Warning: Output is $(( OUTPUT_SIZE / 1024 ))KB. Consider filtering." >&2
        fi

        # Binary content check for Read
        if [[ "$TOOL_NAME" == "Read" ]]; then
            if echo "$TOOL_OUTPUT" | head -c 1000 | LC_ALL=C grep -q '[^[:print:][:space:]]'; then
                echo "Warning: File may contain binary or non-UTF8 content." >&2
            fi

            MAX_LINE_LENGTH=$(echo "$TOOL_OUTPUT" | awk '{ if (length > max) max = length } END { print max+0 }')
            if (( MAX_LINE_LENGTH > 1000 )); then
                echo "Warning: Very long lines (max: $MAX_LINE_LENGTH). May be minified." >&2
            fi
        fi

        # JSON structure check for MCP
        if [[ "$TOOL_NAME" =~ mcp__ ]]; then
            if ! echo "$TOOL_OUTPUT" | jq empty 2>/dev/null; then
                echo "Warning: MCP output is not valid JSON." >&2
            fi
        fi
    fi
fi

# ============================================
# Context Ingestion Logging (Read|Grep|Glob tools)
# BMAD: Log ONLY context files, not all LLM reads (noise reduction)
# ============================================
if [[ "$TOOL_NAME" == "Read" || "$TOOL_NAME" == "Grep" || "$TOOL_NAME" == "Glob" ]]; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
    if [[ -n "$FILE_PATH" ]]; then
        case "$FILE_PATH" in
            */.claude/hooks/*.sh|*/.agents/hooks/*.sh|*/hooks/*.sh)
                # Skip logging hook scripts - they cause feedback loops
                ;;
            */vault/*.md|*/vault/*.md.bak)
                # Log vault context files (active_context.md, todo.md, lessons.md, etc.)
                if [[ -n "$CLAUDE_PROJECT_DIR" ]]; then
                    cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || cd "$(pwd)"
                else
                    cd "$(pwd)" 2>/dev/null
                fi
                "$CLAUDE_PROJECT_DIR/.claude/hooks/context-logger.sh" ingest "$FILE_PATH" 2>/dev/null || true
                ;;
            */docs/*.md)
                # Log docs markdown files (PRDs, specs, architecture docs)
                if [[ -n "$CLAUDE_PROJECT_DIR" ]]; then
                    cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || cd "$(pwd)"
                else
                    cd "$(pwd)" 2>/dev/null
                fi
                "$CLAUDE_PROJECT_DIR/.claude/hooks/context-logger.sh" ingest "$FILE_PATH" 2>/dev/null || true
                ;;
            */.claude/roles/*.md|*/.claude/skills/*.md)
                # Log role and skill definitions
                if [[ -n "$CLAUDE_PROJECT_DIR" ]]; then
                    cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || cd "$(pwd)"
                else
                    cd "$(pwd)" 2>/dev/null
                fi
                "$CLAUDE_PROJECT_DIR/.claude/hooks/context-logger.sh" ingest "$FILE_PATH" 2>/dev/null || true
                ;;
            */.claude/agents/*.md|*/.gemini/agents/*.md)
                # Log agent definitions from sync_subagents.py
                if [[ -n "$CLAUDE_PROJECT_DIR" ]]; then
                    cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || cd "$(pwd)"
                else
                    cd "$(pwd)" 2>/dev/null
                fi
                "$CLAUDE_PROJECT_DIR/.claude/hooks/context-logger.sh" ingest "$FILE_PATH" 2>/dev/null || true
                ;;
            *)
                # Skip all other files (prevents noise from internal LLM reads)
                ;;
        esac
    fi
fi

exit 0
