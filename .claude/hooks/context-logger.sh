#!/bin/bash
# Context Ingestion Logger
# Logs all files ingested into context for auditing
# Usage: ./context-logger.sh ingest <file_path> [file_size]
#        ./context-logger.sh summary

ACTION="$1"

# Use CLAUDE_PROJECT_DIR if set (from hook), otherwise use current directory
if [[ -n "$CLAUDE_PROJECT_DIR" && -d "$CLAUDE_PROJECT_DIR" ]]; then
    PROJECT_DIR="$CLAUDE_PROJECT_DIR"
else
    PROJECT_DIR="$(pwd)"
fi

LOG_FILE="$PROJECT_DIR/logs/context-ingest.log"
SUMMARY_FILE="$PROJECT_DIR/logs/context-ingest-summary.json"

# Ensure log directory exists
mkdir -p "$PROJECT_DIR/logs"

log_entry() {
    local file_path="$1"
    local file_size="${2:-0}"
    local timestamp=$(date -Iseconds)
    local cwd=$(pwd)

    # Skip log files themselves (feedback loop prevention)
    case "$file_path" in
        *.jsonl|*/logs/*.log|*/logs/*/*.json)
            return 0
            ;;
    esac

    echo "{\"type\":\"ingest\",\"file\":\"$file_path\",\"size\":$file_size,\"timestamp\":\"$timestamp\",\"cwd\":\"$cwd\"}" >> "$LOG_FILE"
}

print_summary() {
    if [[ -f "$LOG_FILE" ]]; then
        echo "=== CONTEXT INGESTION SUMMARY ==="
        echo "Log file: $LOG_FILE"
        echo "Total ingested files: $(wc -l < "$LOG_FILE")"
        echo ""

        # Top 10 largest files
        echo "Top 10 Largest Files:"
        if command -v jq &> /dev/null; then
            jq -r '.size' "$LOG_FILE" 2>/dev/null | sort -rn | head -10 | while read size; do
                if [[ -n "$size" ]]; then
                    local file=$(jq -r --argjson s "$size" '.file' "$LOG_FILE" 2>/dev/null | head -1)
                    echo "  $size bytes - $file"
                fi
            done
        fi

        echo ""
        echo "By file extension:"
        if command -v jq &> /dev/null; then
            jq -r '.file' "$LOG_FILE" 2>/dev/null | sed -n 's/.*\.//p' | sort | uniq -c | sort -rn | head -10
        fi
    else
        echo "No context ingestion log found."
    fi
}

case "$ACTION" in
    ingest)
        if [[ -n "$2" ]]; then
            # Get file size if it exists
            if [[ -f "$2" ]]; then
                file_size=$(stat -f%z "$2" 2>/dev/null || stat -c%s "$2" 2>/dev/null || echo "0")
            else
                file_size="0"
            fi
            log_entry "$2" "$file_size"
            echo "Logged context ingest: $2 ($file_size bytes)"
        fi
        ;;
    summary)
        print_summary
        ;;
    *)
        echo "Usage: $0 {ingest <file> | summary}"
        exit 1
        ;;
esac

exit 0
