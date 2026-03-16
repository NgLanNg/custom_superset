#!/bin/bash
# Rules Re-injection Hook
# Reads project rules and outputs them to context at session start

RULES_FILE="$CLAUDE_PROJECT_DIR/.claude/hooks/RULES.md"
ACTIVE_CONTEXT="$CLAUDE_PROJECT_DIR/vault/active_context.md"

echo "=== PROJECT RULES & CONTEXT ==="

# Re-inject rules if exists
if [[ -f "$RULES_FILE" ]]; then
    echo ""
    echo "--- RULES ---"
    cat "$RULES_FILE"
    echo ""
fi

# Re-inject active context if exists
if [[ -f "$ACTIVE_CONTEXT" ]]; then
    echo ""
    echo "--- ACTIVE CONTEXT ---"
    cat "$ACTIVE_CONTEXT"
    echo ""
fi

echo "=== END RULES & CONTEXT ==="

# Set SESSION_ID for tracking across hooks
SESSION_ID="${SESSION_ID:-$(date +%Y%m%d_%H%M%S)_$$}"
export SESSION_ID

# Send meaningful start notification (macOS only)
if [[ "$OSTYPE" == "darwin"* ]] && command -v osascript &>/dev/null; then
    osascript -e "display notification \"Ready for session tasks.\" with title \"Claude Code Session Started ($SESSION_ID)\" sound name \"default\""
fi

exit 0
