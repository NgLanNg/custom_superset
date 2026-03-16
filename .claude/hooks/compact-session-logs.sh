#!/bin/bash
# Compact per-session logs into day-level summaries.
# Keeps only a few recent raw session files while preserving daily aggregates.

set -euo pipefail

LOG_DIR="logs/session-logs"
KEEP_RECENT_RAW="${KEEP_RECENT_RAW:-3}"
KEEP_DAILY_DAYS="${KEEP_DAILY_DAYS:-90}"

mkdir -p "$LOG_DIR"

python3 - "$LOG_DIR" <<'PYTHON'
import datetime
import glob
import json
import os
import re
import sys
from collections import defaultdict

log_dir = sys.argv[1]
pattern = os.path.join(log_dir, "session_*.json")
session_files = sorted(glob.glob(pattern))

day_groups = defaultdict(list)
for path in session_files:
    name = os.path.basename(path)
    m = re.match(r"session_(\d{8})_\d{6}\.json$", name)
    if not m:
        continue
    day_groups[m.group(1)].append(path)

for day, paths in day_groups.items():
    sessions = []
    usage = {
        "input": 0,
        "output": 0,
        "cache_read": 0,
        "cache_create": 0,
        "calls": 0,
        "cost_usd": 0.0,
    }
    models = defaultdict(lambda: {
        "input": 0,
        "output": 0,
        "cache_read": 0,
        "cache_create": 0,
        "calls": 0,
        "cost_usd": 0.0,
    })
    end_reasons = defaultdict(int)

    for path in sorted(paths):
        name = os.path.basename(path)
        sessions.append(name)
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception:
            continue

        u = data.get("usage") or {}
        usage["input"] += int(u.get("input", 0) or 0)
        usage["output"] += int(u.get("output", 0) or 0)
        usage["cache_read"] += int(u.get("cache_read", 0) or 0)
        usage["cache_create"] += int(u.get("cache_create", 0) or 0)
        usage["calls"] += int(u.get("calls", 0) or 0)
        usage["cost_usd"] += float(u.get("cost_usd", 0) or 0)

        reason = data.get("end_reason", "unknown")
        end_reasons[reason] += 1

        for model, stats in (data.get("models") or {}).items():
            models[model]["input"] += int(stats.get("input", 0) or 0)
            models[model]["output"] += int(stats.get("output", 0) or 0)
            models[model]["cache_read"] += int(stats.get("cache_read", 0) or 0)
            models[model]["cache_create"] += int(stats.get("cache_create", 0) or 0)
            models[model]["calls"] += int(stats.get("calls", 0) or 0)
            models[model]["cost_usd"] += float(stats.get("cost_usd", 0) or 0)

    usage["cost_usd"] = round(usage["cost_usd"], 4)
    models_out = {}
    for model, stats in models.items():
        stats["cost_usd"] = round(stats["cost_usd"], 4)
        models_out[model] = stats

    out_path = os.path.join(log_dir, f"daily_{day}.json")
    payload = {
        "date": day,
        "session_count": len(sessions),
        "sessions": sessions,
        "usage": usage,
        "models": models_out,
        "end_reasons": dict(sorted(end_reasons.items())),
        "generated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)
        f.write("\n")
PYTHON

# Keep only a few most recent raw session logs.
ls -t "$LOG_DIR"/session_*.json 2>/dev/null | tail -n +$((KEEP_RECENT_RAW + 1)) | xargs rm -f 2>/dev/null || true

# Keep daily summaries for a longer retention window.
find "$LOG_DIR" -name 'daily_*.json' -mtime +"$KEEP_DAILY_DAYS" -delete 2>/dev/null || true

exit 0