#!/bin/bash
# Session Ledger Writer
# Appends events to .claude/session-ledger.jsonl (append-only)
# Usage: echo "EVENT_JSON" | ./session-ledger.sh

INPUT=$(cat)
LEDGER_FILE="vault/session-ledger.jsonl"

# Ensure directory exists
mkdir -p vault

# Add timestamp and append (compact JSON format for JSONL)
TIMESTAMP=$(date -Iseconds)
echo "$INPUT" | jq -c --arg ts "$TIMESTAMP" '. + {timestamp: $ts}' >> "$LEDGER_FILE"

# Set restrictive permissions
chmod 600 "$LEDGER_FILE" 2>/dev/null || true

exit 0
