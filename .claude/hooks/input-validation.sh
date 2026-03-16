#!/bin/bash
# Input Validation Hook
# Validates user input before processing
# Detects destructive commands and PII

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

# Skip if no prompt
if [[ -z "$PROMPT" ]]; then
    exit 0
fi

# ============================================
# Check for destructive commands
# ============================================
DESTRUCTIVE_PATTERNS=(
    "delete all"
    "drop table"
    "truncate table"
    "rm -rf /"
    "rm -rf ~"
    "rm -rf \\*"
    "wipe all"
    "destroy all"
    "format disk"
    ":(){ :|:& };:"  # Fork bomb
)

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
    if echo "$PROMPT" | grep -qi "$pattern"; then
        echo "{\"hookSpecificOutput\": {\"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"Input contains potentially destructive pattern: '$pattern'. Please be more specific about what you want to delete or modify.\"}}"
        exit 0
    fi
done

# ============================================
# Check for PII patterns
# ============================================

# Credit card numbers (13-19 digits)
if echo "$PROMPT" | grep -qE '\b[0-9]{13,19}\b'; then
    echo "{\"hookSpecificOutput\": {\"permissionDecision\": \"ask\", \"permissionDecisionReason\": \"Input may contain a credit card number. Confirm this is safe to process.\"}}"
    exit 0
fi

# SSN (XXX-XX-XXXX or XXXXXXXXX)
if echo "$PROMPT" | grep -qE '\b[0-9]{3}-[0-9]{2}-[0-9]{4}\b|\b[0-9]{9}\b'; then
    echo "{\"hookSpecificOutput\": {\"permissionDecision\": \"ask\", \"permissionDecisionReason\": \"Input may contain a Social Security Number. Confirm this is safe to process.\"}}"
    exit 0
fi

# API keys (common patterns)
if echo "$PROMPT" | grep -qE '(sk-[a-zA-Z0-9]{20,}|api[_-]?key[_-]?[a-zA-Z0-9]{10,}|Bearer [a-zA-Z0-9._-]+)'; then
    echo "{\"hookSpecificOutput\": {\"permissionDecision\": \"ask\", \"permissionDecisionReason\": \"Input may contain an API key or token. Confirm this is safe to process.\"}}"
    exit 0
fi

# Email addresses (for privacy consideration)
if echo "$PROMPT" | grep -qE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'; then
    # Don't block, just note
    :
fi

# ============================================
# Check for secrets/passwords
# ============================================
SECRET_PATTERNS=(
    "password[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]"
    "secret[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]"
    "api_key[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]"
    "token[[:space:]]*=[[:space:]]*['\"][^'\"]+['\"]"
)

for pattern in "${SECRET_PATTERNS[@]}"; do
    if echo "$PROMPT" | grep -qiE "$pattern"; then
        echo "{\"hookSpecificOutput\": {\"permissionDecision\": \"ask\", \"permissionDecisionReason\": \"Input may contain hardcoded secrets. Consider using environment variables instead.\"}}"
        exit 0
    fi
done

# Allow the action
exit 0