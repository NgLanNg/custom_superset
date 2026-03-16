#!/bin/bash
# Health Session Report Hook
# Generates health report at session end
# Called on "Stop" event in settings.json

set -euo pipefail

INPUT=$(cat)
SESSION_ID="${SESSION_ID:-$(echo "$INPUT" | jq -r '.session_id // "unknown"')}"
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Paths - logs at project root, not inside .claude
DIAGNOSTIC_LOG="${CLAUDE_PROJECT_DIR}/logs/diagnostics/diagnostic_${SESSION_ID}.jsonl"
REPORT_DIR="${CLAUDE_PROJECT_DIR}/logs/reports"

mkdir -p "$REPORT_DIR"

# Check if log file exists
if [[ ! -f "$DIAGNOSTIC_LOG" ]]; then
    echo "No diagnostic log found for session $SESSION_ID"
    exit 0
fi

# Count events by severity (handle empty results gracefully)
CRITICAL_COUNT=$(grep '"severity":"critical"' "$DIAGNOSTIC_LOG" 2>/dev/null | wc -l 2>/dev/null || true); CRITICAL_COUNT=${CRITICAL_COUNT:-0}; CRITICAL_COUNT=$(echo "$CRITICAL_COUNT" | tr -d ' ')
HIGH_COUNT=$(grep '"severity":"high"' "$DIAGNOSTIC_LOG" 2>/dev/null | wc -l 2>/dev/null || true); HIGH_COUNT=${HIGH_COUNT:-0}; HIGH_COUNT=$(echo "$HIGH_COUNT" | tr -d ' ')
MEDIUM_COUNT=$(grep '"severity":"medium"' "$DIAGNOSTIC_LOG" 2>/dev/null | wc -l 2>/dev/null || true); MEDIUM_COUNT=${MEDIUM_COUNT:-0}; MEDIUM_COUNT=$(echo "$MEDIUM_COUNT" | tr -d ' ')
LOW_COUNT=$(grep '"severity":"low"' "$DIAGNOSTIC_LOG" 2>/dev/null | wc -l 2>/dev/null || true); LOW_COUNT=${LOW_COUNT:-0}; LOW_COUNT=$(echo "$LOW_COUNT" | tr -d ' ')

# Default to 0 if empty
CRITICAL_COUNT=${CRITICAL_COUNT:-0}
HIGH_COUNT=${HIGH_COUNT:-0}
MEDIUM_COUNT=${MEDIUM_COUNT:-0}
LOW_COUNT=${LOW_COUNT:-0}

# Calculate score (100 base MINUS deductions)
DEDUCT_CRITICAL=15
DEDUCT_HIGH=10
DEDUCT_MEDIUM=5
DEDUCT_LOW=2

TOTAL_DEDUCTION=$((CRITICAL_COUNT * DEDUCT_CRITICAL + HIGH_COUNT * DEDUCT_HIGH + MEDIUM_COUNT * DEDUCT_MEDIUM + LOW_COUNT * DEDUCT_LOW))
SCORE=$((100 - TOTAL_DEDUCTION))
if [[ $SCORE -lt 0 ]]; then SCORE=0; fi

# Determine grade
if [[ $SCORE -ge 90 ]]; then GRADE="Excellent"
elif [[ $SCORE -ge 75 ]]; then GRADE="Great"
elif [[ $SCORE -ge 50 ]]; then GRADE="OK"
else GRADE="Needs Work"; fi

TOTAL_EVENTS=$((CRITICAL_COUNT + HIGH_COUNT + MEDIUM_COUNT + LOW_COUNT))

# Generate Markdown report
REPORT_FILE="${REPORT_DIR}/health_${SESSION_ID}.md"
cat > "$REPORT_FILE" << EOF
# Health Report: Session $SESSION_ID

**Generated:** $(date -Iseconds)
**Health Score:** $SCORE/100 ($GRADE)

## Event Summary

| Severity | Count | Deduction |
| :--- | :--- | :--- |
| Critical | $CRITICAL_COUNT | $((CRITICAL_COUNT * DEDUCT_CRITICAL)) |
| High | $HIGH_COUNT | $((HIGH_COUNT * DEDUCT_HIGH)) |
| Medium | $MEDIUM_COUNT | $((MEDIUM_COUNT * DEDUCT_MEDIUM)) |
| Low | $LOW_COUNT | $((LOW_COUNT * DEDUCT_LOW)) |
| **Total** | **$TOTAL_EVENTS** | **$TOTAL_DEDUCTION** |

## Recommendations

EOF

if [[ $CRITICAL_COUNT -gt 0 ]]; then
    echo "- **CRITICAL**: Review session for safety issues" >> "$REPORT_FILE"
fi

if [[ $HIGH_COUNT -gt 0 ]]; then
    echo "- **HIGH**: Consider dropping unused context domains" >> "$REPORT_FILE"
fi

if [[ $MEDIUM_COUNT -gt 0 ]]; then
    echo "- **MEDIUM**: Review tool usage patterns for optimization" >> "$REPORT_FILE"
fi

if [[ $LOW_COUNT -gt 0 ]]; then
    echo "- **LOW**: Minor tracking events logged" >> "$REPORT_FILE"
fi

if [[ $SCORE -ge 75 ]]; then
    echo "" >> "$REPORT_FILE"
    echo "## Status: PASS" >> "$REPORT_FILE"
else
    echo "" >> "$REPORT_FILE"
    echo "## Status: REVIEW NEEDED" >> "$REPORT_FILE"
fi

# Set permissions
chmod 600 "$REPORT_FILE"

# Output report path for debugging
echo "Health report generated: $REPORT_FILE"

exit 0
