#!/bin/bash
# Token Usage Logger - parses Claude JSONL and outputs token/cost data
# Filters by session ID to get only current session stats

SESSION_ID="${2:-}"
LOG_DIR="$HOME/.claude/projects"
OUTPUT_FILE="${1:-logs/token-usage.json}"

mkdir -p "$(dirname "$OUTPUT_FILE")"

# Find session JSONL files (last 2 hours)
LATEST_SESSION=$(find "$LOG_DIR" -name "*.jsonl" -mmin -120 2>/dev/null | head -1)

if [[ -z "$LATEST_SESSION" ]]; then
    echo '{"totals":{"input":0,"output":0,"cache_read":0,"cache_create":0,"calls":0,"cost_usd":0},"models":{}}' > "$OUTPUT_FILE"
    exit 0
fi

python3 - "$LATEST_SESSION" "$OUTPUT_FILE" "$SESSION_ID" << 'PYTHON'
import json
import sys
from collections import defaultdict

PRICING = {
    "claude-opus-4-6": {"input": 15.0, "output": 75.0},
    "claude-opus-4-5-20251001": {"input": 15.0, "output": 75.0},
    "claude-3-opus": {"input": 15.0, "output": 75.0},
    "claude-sonnet-4-6": {"input": 3.0, "output": 15.0},
    "claude-3-5-sonnet": {"input": 3.0, "output": 15.0},
    "claude-3-7-sonnet": {"input": 3.0, "output": 15.0},
    "claude-3-haiku": {"input": 0.25, "output": 1.25},
    "claude-haiku-4-5": {"input": 1.0, "output": 5.0},
    "gpt-4o": {"input": 2.5, "output": 10.0},
    "gpt-4-turbo": {"input": 10.0, "output": 30.0},
    "gpt-5.1-codex-max": {"input": 2.5, "output": 10.0},
    "gpt-5.2-codex": {"input": 2.5, "output": 10.0},
    "o1": {"input": 15.0, "output": 60.0},
    "o3-mini": {"input": 1.1, "output": 4.4},
    "qwen3.5-plus": {"input": 0.5, "output": 2.0},
    "qwen-plus": {"input": 0.5, "output": 2.0},
    "gemini-3-pro-high": {"input": 1.25, "output": 5.0},
    "gemini-3.1-pro-high": {"input": 1.25, "output": 5.0},
    "glm-5": {"input": 0.5, "output": 2.0},
    "kimi-k2.5": {"input": 0.5, "output": 2.0},
    "auto": {"input": 3.0, "output": 15.0},
}

def get_pricing(model):
    if model in PRICING:
        return PRICING[model]
    for key, value in PRICING.items():
        if key in model:
            return value
    return {"input": 3.0, "output": 15.0}

def calc_cost(input_tokens, output_tokens, pricing):
    return round((input_tokens / 1_000_000) * pricing["input"] + (output_tokens / 1_000_000) * pricing["output"], 4)

jsonl_path = sys.argv[1]
output_path = sys.argv[2]
session_id = sys.argv[3] if len(sys.argv) > 3 else None

totals = defaultdict(lambda: {"input": 0, "output": 0, "cache_read": 0, "cache_create": 0, "calls": 0})

try:
    with open(jsonl_path, "r") as f:
        for line in f:
            try:
                data = json.loads(line)
                if data.get("type") != "assistant":
                    continue
                # Filter by session ID if provided
                if session_id and data.get("sessionId") != session_id:
                    continue
                msg = data.get("message", {})
                if msg.get("type") != "message":
                    continue
                usage = msg.get("usage", {})
                if not usage:
                    continue
                model = msg.get("model", "unknown")
                totals[model]["input"] += usage.get("input_tokens", 0)
                totals[model]["output"] += usage.get("output_tokens", 0)
                totals[model]["cache_read"] += usage.get("cache_read_input_tokens", 0)
                totals[model]["cache_create"] += usage.get("cache_creation_input_tokens", 0)
                totals[model]["calls"] += 1
            except:
                continue
except:
    pass

models_with_cost = {}
for model, stats in totals.items():
    pricing = get_pricing(model)
    cost = calc_cost(stats["input"], stats["output"], pricing)
    models_with_cost[model] = {**stats, "cost_usd": cost}

result = {
    "totals": {
        "input": sum(v["input"] for v in totals.values()),
        "output": sum(v["output"] for v in totals.values()),
        "cache_read": sum(v["cache_read"] for v in totals.values()),
        "cache_create": sum(v["cache_create"] for v in totals.values()),
        "calls": sum(v["calls"] for v in totals.values()),
        "cost_usd": sum(m["cost_usd"] for m in models_with_cost.values()),
    },
    "models": models_with_cost,
}

with open(output_path, "w") as f:
    json.dump(result, f, indent=2)
PYTHON
