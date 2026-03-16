---
description: Monitor token usage from Claude Code JSONL logs
---

# /tokens

**Purpose:** View token usage statistics from your Claude Code session logs.

**Scope:** `daily`

Run the token monitoring script:

```bash
python3 .claude/scripts/tokens.py "$@"
```

## Usage

```text
/tokens                 # All time
/tokens --days 7        # Last 7 days
/tokens --days 1        # Last 24 hours
/tokens --project NAME  # Filter by project name
```

## Output

- Total tokens (input, output, cache read, cache create)
- Breakdown by model
- Call counts and averages per model
