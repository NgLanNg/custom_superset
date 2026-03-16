#!/bin/bash
# Session summary hook - logs session details + token usage at end
# Merges token stats with session metadata into single log file

INPUT=$(cat)
REASON=$(echo "$INPUT" | jq -r '.reason // "unknown"')

# Create log directory
LOG_DIR="logs/session-logs"
mkdir -p "$LOG_DIR"

# Generate timestamp and log file
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_FILE="$LOG_DIR/session_$TIMESTAMP.json"

# Get session info from hook payload
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
USER=$(whoami)
HOSTNAME=$(hostname)

# Parse current session tokens from Claude JSONL (filter by session ID)
TEMP_TOKEN_FILE="/tmp/token-usage-$$".json
"$CLAUDE_PROJECT_DIR/.claude/hooks/token-logger.sh" "$TEMP_TOKEN_FILE" "$SESSION_ID"

# Get token stats
if [[ -f "$TEMP_TOKEN_FILE" ]]; then
    MODELS_JSON=$(jq '.models' "$TEMP_TOKEN_FILE" 2>/dev/null || echo '{}')
    TOTALS_JSON=$(jq '.totals' "$TEMP_TOKEN_FILE" 2>/dev/null || echo '{}')
    rm -f "$TEMP_TOKEN_FILE"
else
    MODELS_JSON='{}'
    TOTALS_JSON='{}'
fi

# Create merged session log
cat > "$LOG_FILE" << EOF
{
  "session_id": "$SESSION_ID",
  "timestamp": "$TIMESTAMP",
  "user": "$USER",
  "hostname": "$HOSTNAME",
  "cwd": "$CWD",
  "end_reason": "$REASON",
  "system_info": {
    "os": "$(uname -s)",
    "version": "$(uname -r)",
    "arch": "$(uname -m)"
  },
  "usage": $TOTALS_JSON,
  "models": $MODELS_JSON
}
EOF

# Compact into day-level files and keep only a few recent raw session logs.
"$CLAUDE_PROJECT_DIR/.claude/hooks/compact-session-logs.sh" >/dev/null 2>&1 || true

# Generate meaningful notification message (macOS only)
if [[ "$OSTYPE" == "darwin"* ]] && command -v osascript &>/dev/null; then
    TOTAL_TOKENS=$(jq -r '.usage.input + .usage.output + .usage.cache_read + .usage.cache_create' "$LOG_FILE" 2>/dev/null || echo 0)
    TOTAL_COST=$(jq -r '.usage.cost_usd // 0' "$LOG_FILE" 2>/dev/null || echo 0)
    TOTAL_CALLS=$(jq -r '.usage.calls // 0' "$LOG_FILE" 2>/dev/null || echo 0)

    # Get top model
    TOP_MODEL=$(jq -r '.models | to_entries | sort_by(.value.input + .value.output) | last | .key // "N/A"' "$LOG_FILE" 2>/dev/null || echo "N/A")

    # Build meaningful message
    if [[ "$TOTAL_CALLS" -eq 0 ]]; then
        MSG="Session complete - no API calls"
    elif [[ "$TOTAL_TOKENS" -lt 10000 ]]; then
        MSG="Quick task done - $TOTAL_CALLS calls, $TOTAL_TOKENS tokens"
    elif [[ "$TOTAL_TOKENS" -lt 100000 ]]; then
        MSG="Task done - $TOTAL_CALLS calls, $TOTAL_TOKENS tokens | \$${TOTAL_COST}"
    else
        MSG="Heavy work done - $TOTAL_CALLS calls, $TOTAL_TOKENS tokens | \$${TOTAL_COST}"
    fi

    # Add model info if meaningful
    if [[ "$TOTAL_TOKENS" -gt 50000 ]]; then
        MSG="$MSG ($TOP_MODEL)"
    fi

    osascript -e "display notification \"$MSG\" with title \"Claude Code Session Complete\" sound name \"default\""
fi

exit 0
