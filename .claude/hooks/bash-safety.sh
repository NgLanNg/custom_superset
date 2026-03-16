#!/bin/bash
# Bash Safety Hook - Unified protector and doom-loop detector
# Consolidates: protect-files.sh + doom-loop-detection.sh

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty')

# ============================================
# Protection: Block dangerous commands
# ============================================
PROTECTED=(
  "rm -rf /"
  "rm -r /"
  "rm -rf ~"
  "drop database"
  "drop table"
  "truncate table"
  "> /dev/null"
  "chmod 777"
  "chown -R /"
  "mkfs "
  "dd if=/"
)

for pattern in "${PROTECTED[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    echo "Blocked: Command contains dangerous pattern '$pattern'" >&2
    exit 2
  fi
done

# ============================================
# Doom Loop Detection
# ============================================
PATTERN_DIR="/tmp/claude-patterns"
mkdir -p "$PATTERN_DIR"
PATTERN_FILE="${PATTERN_DIR}/${SESSION_ID}.txt"

# Create pattern signature
case "$TOOL_NAME" in
    Bash)
        PATTERN_SIG="${TOOL_NAME}:$(echo "$COMMAND" | head -c 50)"
        ;;
    Read)
        PATTERN_SIG="${TOOL_NAME}:$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')"
        ;;
    Edit|Write)
        PATTERN_SIG="${TOOL_NAME}:$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')"
        ;;
    *)
        PATTERN_SIG="${TOOL_NAME}"
        ;;
esac

# Record timestamp and pattern
TIMESTAMP=$(date +%s)
echo "${TIMESTAMP}:${PATTERN_SIG}" >> "$PATTERN_FILE"

# Check for loops in last 60 seconds
CURRENT_TIME=$(date +%s)
CUTOFF_TIME=$((CURRENT_TIME - 60))

RECENT_COUNT=$(awk -F: -v cutoff="$CUTOFF_TIME" -v pattern="$PATTERN_SIG" '
    $1 >= cutoff {
        reconstructed = $2
        for (i = 3; i <= NF; i++) reconstructed = reconstructed ":" $i
        if (reconstructed == pattern) count++
    }
    END {print count+0}
' "$PATTERN_FILE" 2>/dev/null)

THRESHOLD=3

if (( RECENT_COUNT >= THRESHOLD )); then
    DETECTION_MSG="Doom loop detected: '$TOOL_NAME' executed $RECENT_COUNT times in 60 seconds. Consider: alternative approach, different tool, or ask user for clarification."
    echo "{\"hookSpecificOutput\": {\"permissionDecision\": \"ask\", \"permissionDecisionReason\": \"$DETECTION_MSG\"}}"
    exit 0
fi

# Clean old entries (keep last 5 minutes)
if [[ -f "$PATTERN_FILE" ]]; then
    CLEAN_TIME=$((CURRENT_TIME - 300))
    awk -F: -v cutoff="$CLEAN_TIME" '$1 >= cutoff' "$PATTERN_FILE" > "${PATTERN_FILE}.tmp"
    mv "${PATTERN_FILE}.tmp" "$PATTERN_FILE" 2>/dev/null || true
fi

exit 0
