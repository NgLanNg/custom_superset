#!/usr/bin/env python3
"""
Simple token usage monitor - parses Claude Code JSONL logs.
"""

import json
import sys
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path


def find_sessions(project_filter=None):
    """Find all session JSONL files."""
    base = Path.home() / ".claude" / "projects"
    if not base.exists():
        return []

    sessions = []
    for session_dir in base.iterdir():
        if not session_dir.is_dir():
            continue
        if project_filter and project_filter.lower() not in session_dir.name.lower():
            continue
        for jsonl in session_dir.glob("*.jsonl"):
            sessions.append(jsonl)
    return sorted(sessions, reverse=True)


def parse_session(jsonl_path, days=None):
    """Parse a single session file for token usage."""
    entries = []
    cutoff = datetime.now() - timedelta(days=days) if days else None

    try:
        with open(jsonl_path, "r") as f:
            for line in f:
                try:
                    data = json.loads(line)
                    if data.get("type") != "assistant":
                        continue

                    msg = data.get("message", {})
                    if msg.get("type") != "message":
                        continue

                    usage = msg.get("usage", {})
                    if not usage:
                        continue

                    timestamp = data.get("timestamp", "")
                    if cutoff and timestamp:
                        try:
                            ts = datetime.fromisoformat(
                                timestamp.replace("Z", "+00:00")
                            )
                            if ts < cutoff:
                                continue
                        except:
                            pass

                    entries.append(
                        {
                            "model": msg.get("model", "unknown"),
                            "input_tokens": usage.get("input_tokens", 0),
                            "output_tokens": usage.get("output_tokens", 0),
                            "cache_read": usage.get("cache_read_input_tokens", 0),
                            "cache_create": usage.get("cache_creation_input_tokens", 0),
                            "timestamp": timestamp,
                            "session": jsonl_path.parent.name,
                        }
                    )
                except (json.JSONDecodeError, KeyError):
                    continue
    except IOError:
        pass

    return entries


def main():
    days = None
    project_filter = None

    if "--days" in sys.argv:
        idx = sys.argv.index("--days")
        if idx + 1 < len(sys.argv):
            days = int(sys.argv[idx + 1])

    if "--project" in sys.argv:
        idx = sys.argv.index("--project")
        if idx + 1 < len(sys.argv):
            project_filter = sys.argv[idx + 1]

    sessions = find_sessions(project_filter)
    print(f"Scanning {len(sessions)} session files...")

    all_entries = []
    for session_file in sessions[:50]:  # Limit to 50 most recent
        entries = parse_session(session_file, days=days)
        all_entries.extend(entries)

    if not all_entries:
        print("No token usage found.")
        return

    # Aggregate
    total_input = sum(e["input_tokens"] for e in all_entries)
    total_output = sum(e["output_tokens"] for e in all_entries)
    total_cache_read = sum(e["cache_read"] for e in all_entries)
    total_cache_create = sum(e["cache_create"] for e in all_entries)
    grand_total = total_input + total_output + total_cache_read + total_cache_create

    # By model
    by_model = defaultdict(
        lambda: {
            "input": 0,
            "output": 0,
            "cache_read": 0,
            "cache_create": 0,
            "calls": 0,
        }
    )
    for e in all_entries:
        by_model[e["model"]]["input"] += e["input_tokens"]
        by_model[e["model"]]["output"] += e["output_tokens"]
        by_model[e["model"]]["cache_read"] += e["cache_read"]
        by_model[e["model"]]["cache_create"] += e["cache_create"]
        by_model[e["model"]]["calls"] += 1

    # Print report
    print("\n" + "=" * 60)
    print("TOKEN USAGE REPORT")
    if days:
        print(f"Period: Last {days} days")
    if project_filter:
        print(f"Project: {project_filter}")
    print("=" * 60)
    print(f"\nTotal Tokens: {grand_total:,}")
    print(f"  Input:        {total_input:,}")
    print(f"  Output:       {total_output:,}")
    print(f"  Cache Read:   {total_cache_read:,}")
    print(f"  Cache Create: {total_cache_create:,}")
    print(f"\nTotal API Calls: {len(all_entries):,}")

    # Cost calculation per model (USD per 1M tokens - approximate rates as of 2026-03)
    pricing = {
        "claude-opus-4-6": {
            "input": 3.00,
            "output": 15.00,
            "cache_read": 0.25,
            "cache_create": 3.75,
        },
        "claude-sonnet-4-6": {
            "input": 0.30,
            "output": 1.25,
            "cache_read": 0.03,
            "cache_create": 0.375,
        },
        "claude-haiku-4-5-20251001": {
            "input": 0.25,
            "output": 1.25,
            "cache_read": 0.02,
            "cache_create": 0.30,
        },
        "qwen3-coder-next": {
            "input": 0.55,
            "output": 1.65,
            "cache_read": 0.05,
            "cache_create": 0.55,
        },
        "qwen3.5-plus": {
            "input": 0.60,
            "output": 1.80,
            "cache_read": 0.06,
            "cache_create": 0.60,
        },
        "kimi-k2.5": {
            "input": 0.49,
            "output": 1.96,
            "cache_read": 0.05,
            "cache_create": 0.49,
        },
        "glm-5": {
            "input": 0.50,
            "output": 2.00,
            "cache_read": 0.05,
            "cache_create": 0.50,
        },
        "qwen3-coder-plus": {
            "input": 1.00,
            "output": 3.00,
            "cache_read": 0.10,
            "cache_create": 1.00,
        },
        "bytedance-seed-code": {
            "input": 0.65,
            "output": 1.95,
            "cache_read": 0.07,
            "cache_create": 0.65,
        },
        "gpt-5.1-codex-max": {
            "input": 1.00,
            "output": 4.00,
            "cache_read": 0.25,
            "cache_create": 1.25,
        },
        "auto": {
            "input": 0.30,
            "output": 1.20,
            "cache_read": 0.03,
            "cache_create": 0.375,
        },
    }

    # Calculate costs by model
    print("\n--- BY MODEL ---")
    for model, stats in sorted(
        by_model.items(), key=lambda x: x[1]["input"] + x[1]["output"], reverse=True
    ):
        total_tokens = (
            stats["input"]
            + stats["output"]
            + stats["cache_read"]
            + stats["cache_create"]
        )

        # Calculate cost if pricing available
        cost = 0.0
        if model in pricing:
            p = pricing[model]
            cost = (
                stats["input"] * p["input"] / 1_000_000
                + stats["output"] * p["output"] / 1_000_000
                + stats["cache_read"] * p["cache_read"] / 1_000_000
                + stats["cache_create"] * p["cache_create"] / 1_000_000
            )
        elif stats["input"] > 0:
            # Fallback: estimate $0.50 input + $1.50 output
            cost = (
                stats["input"] * 0.50 / 1_000_000 + stats["output"] * 1.50 / 1_000_000
            )

        print(f"\n{model}:")
        print(f"  Calls:  {stats['calls']:,}")
        print(f"  Total:  {total_tokens:,} tokens")
        print(f"  Avg:    {total_tokens // max(stats['calls'], 1):,} tokens/call")
        if cost > 0:
            print(f"  Est. Cost: ${cost:.2f}")

    # Total cost
    total_cost = 0.0
    for model, stats in by_model.items():
        if model in pricing:
            p = pricing[model]
            total_cost += (
                stats["input"] * p["input"] / 1_000_000
                + stats["output"] * p["output"] / 1_000_000
                + stats["cache_read"] * p["cache_read"] / 1_000_000
                + stats["cache_create"] * p["cache_create"] / 1_000_000
            )
    print(f"\n--- TOTAL ESTIMATED COST: ${total_cost:.2f} ---")


if __name__ == "__main__":
    main()
