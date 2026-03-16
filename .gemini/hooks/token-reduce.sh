#!/bin/bash
# Token reduction hook - blocks reads of verbose/low-value files
# Runs on PreToolUse to prevent token bloat from large files

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only intercept Read operations
if [[ "$TOOL_NAME" != "Read" ]]; then
    exit 0
fi

# Block patterns that commonly cause token bloat
# Using fnmatch-style patterns that work with [[ == ]]

# Direct literal substring patterns (work with *"$pattern"*)
BLOCKED_SUBSTRINGS=(
    "node_modules/"
    ".git/"
    "dist/"
    "build/"
    ".venv/"
    "venv/"
    "__pycache__/"
    ".claude/session-logs/"
    "package-lock.json"
    "yarn.lock"
    "pnpm-lock.yaml"
)

# Glob patterns (need to test differently)
BLOCKED_GLOBS=(
    "*.log"
    "*.lock"
    "*.min.js"
    "*.map"
)

for pattern in "${BLOCKED_SUBSTRINGS[@]}"; do
    if [[ "$FILE_PATH" == *"$pattern"* ]]; then
        echo "{\"hookSpecificOutput\": {\"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"Blocked: $FILE_PATH matches blocked pattern '$pattern'. Use Grep or Read specific lines instead.\"}}"
        exit 0
    fi
done

# Test glob patterns using bash pattern matching with extglob
shopt -s extglob nullglob
for pattern in "${BLOCKED_GLOBS[@]}"; do
    # Convert glob to bash pattern and test
    case "$FILE_PATH" in
        $pattern)
            echo "{\"hookSpecificOutput\": {\"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"Blocked: $FILE_PATH matches glob pattern '$pattern'.\"}}"
            exit 0
            ;;
    esac
done
shopt -u extglob nullglob

# Allow large files only if explicitly small (< 100KB)
if [[ -f "$FILE_PATH" ]]; then
    FILE_SIZE=$(stat -f%z "$FILE_PATH" 2>/dev/null || stat -c%s "$FILE_PATH" 2>/dev/null || echo 0)
    if (( FILE_SIZE > 102400 )); then
        echo "{\"hookSpecificOutput\": {\"permissionDecision\": \"ask\", \"permissionDecisionReason\": \"File is $(( FILE_SIZE / 1024 ))KB. Consider reading specific sections.\"}}"
        exit 0
    fi
fi

# Log successful context ingestion attempts for Read operations.
if [[ -n "$FILE_PATH" ]] && [[ -x "$CLAUDE_PROJECT_DIR/.claude/hooks/context-logger.sh" ]]; then
    "$CLAUDE_PROJECT_DIR/.claude/hooks/context-logger.sh" ingest "$FILE_PATH" >/dev/null 2>&1 || true
fi

exit 0
