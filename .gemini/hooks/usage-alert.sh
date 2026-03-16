#!/bin/bash
# Usage Alert Hook - Warns when approaching token/cost thresholds
# Triggered on SessionStart and periodically during session

THRESHOLD_TOKENS=100000      # Alert at 100K tokens
THRESHOLD_COST_USD=2.00     # Alert at $2.00
WARNING_INTERVAL=50000      # Warn every 50K tokens

# Get current session usage from Claude's JSONL logs
USAGE_FILE=$(ls -t ~/.claude/projects/*/session*.jsonl 2>/dev/null | head -1)

if [[ -z "$USAGE_FILE" ]] || [[ ! -f "$USAGE_FILE" ]]; then
    echo ""
    exit 0
fi

# Export USAGE_FILE for Python to access
export USAGE_FILE

# Calculate running totals using Python (more reliable than jq for this)
read -r TOTAL_TOKENS TOTAL_COST <<< $(python3 << PYEOF
import json
import sys
import os

total_input = 0
total_output = 0
total_cache_read = 0
total_cache_create = 0

USAGE_FILE=os.environ.get("USAGE_FILE", "")
try:
    with open(USAGE_FILE, 'r') as f:
        for line in f:
            msg = json.loads(line.strip())
            usage = msg.get("usage", {})
            total_input += usage.get("input_tokens", 0)
            total_output += usage.get("output_tokens", 0)
            total_cache_read += usage.get("cache_read_input_tokens", 0)
            total_cache_create += usage.get("cache_creation_input_tokens", 0)

    total_tokens = total_input + total_output + total_cache_read + total_cache_create

    # Rough cost estimate (Opus pricing)
    # Input: $2.50/M, Output: $12.50/M, Cache read: $0.30/M
    cost = (
        (total_input - total_cache_read) * 2.50 / 1_000_000 +
        total_output * 12.50 / 1_000_000 +
        total_cache_read * 0.30 / 1_000_000
    )

    print(f"{int(total_tokens)} {cost:.4f}")
except Exception as e:
    print("0 0.00")
PYEOF
)

# Fallback if Python failed
TOTAL_TOKENS=${TOTAL_TOKENS:-0}
TOTAL_COST=${TOTAL_COST:-0.00}

# Check thresholds
ALERTS=()

if (( $(echo "$TOTAL_COST >= $THRESHOLD_COST_USD" | bc -l 2>/dev/null || echo 0) )); then
    ALERTS+=("COST_THRESHOLD: Session cost (\$${TOTAL_COST}) exceeds \$${THRESHOLD_COST_USD}")
fi

if [[ "$TOTAL_TOKENS" -ge "$THRESHOLD_TOKENS" ]]; then
    ALERTS+=("TOKEN_THRESHOLD: Session tokens (${TOTAL_TOKENS}) exceed ${THRESHOLD_TOKENS}")
fi

# Check warning intervals
if [[ "$TOTAL_TOKENS" -gt 0 ]]; then
    WARN_LEVEL=$(( (TOTAL_TOKENS / WARNING_INTERVAL) * WARNING_INTERVAL ))
    if [[ "$WARN_LEVEL" -gt 0 ]]; then
        ALERTS+=("USAGE_MILESTONE: Session at ${TOTAL_TOKENS} tokens (crossed ${WARN_LEVEL} marker)")
    fi
fi

# Output alerts to Claude's context
if [[ ${#ALERTS[@]} -gt 0 ]]; then
    echo ""
    echo "## Usage Alerts"
    echo ""
    echo "**Current Usage:** ${TOTAL_TOKENS} tokens (~\$${TOTAL_COST})"
    echo ""
    for alert in "${ALERTS[@]}"; do
        echo "- **$alert**"
    done
    echo ""
    echo "Consider: Starting a new session, using subagents, or reducing context."
    echo ""
fi

# Log to file for tracking
LOG_DIR="$CLAUDE_PROJECT_DIR/logs/usage"
mkdir -p "$LOG_DIR"
echo "$(date -Iseconds),${TOTAL_TOKENS},${TOTAL_COST}" >> "$LOG_DIR/session-usage.csv"

exit 0
