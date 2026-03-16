# Batch Orchestration & Lineage Patterns (v0.1.8)

## 1. Parent Lineage (`--parent-id`)

Group related sub-agent tasks using a common Parent ID. This allows for aggregate reporting and synchronization.

```bash
BATCH_ID="refactor-$(date +%s)"
subgemi task delegate "Refactor module A" --parent-id "$BATCH_ID" --lane code
subgemi task delegate "Refactor module B" --parent-id "$BATCH_ID" --lane code
subgemi task delegate "Update docs"       --parent-id "$BATCH_ID" --lane docs
```

> ℹ️ **Concurrency Note (v0.1.8):** With `DEFAULT_MAX_CONCURRENT = 8`, batch loops will naturally
> throttle — tasks beyond the limit queue automatically inside `run_sub_agent`.

## 2. Synchronization (`task await`)

Block the caller until all children of a parent ID (or specific session IDs) complete.

```bash
# Wait for the whole batch, then print combined JSON results
subgemi task await --parent-id "$BATCH_ID"

# Wait for specific sessions only
subgemi task await sub_abc123 sub_def456 --poll 5 --timeout 1800
```

## 3. Aggregate Reporting (`task summary`)

Use `task summary` to get a human-readable table of the entire batch's status, cost, and impact.

```bash
subgemi task summary "$BATCH_ID"
```

Output columns: `session_id`, `status`, `heal_attempts`, `lines_added`, `lines_removed`, `cost_usd`.

## 4. Result Extraction (`task get`)

Final results are stored in a structured JSON payload. `ResultParser` (v0.1.8+) handles primary
(`fsm_payload_out.json`) and fallback (`stdout.log`) extraction transparently.

```bash
# Extract modified files from a completed agent
subgemi task get sub_123_abc

# Pipe into jq for scripting
FILES=$(subgemi task get sub_123_abc | jq -r '.files_modified[]')
```

## 5. Cascaded Pipelines (Sequential Chaining)

For cross-stage dependencies, `await` the first batch before dispatching the next.

```bash
BATCH_A="stage1-$(date +%s)"
subgemi task delegate "Generate migration SQL" --parent-id "$BATCH_A"
subgemi task delegate "Generate rollback SQL"  --parent-id "$BATCH_A"

# Block until stage 1 is done
subgemi task await --parent-id "$BATCH_A"

# Stage 2: run integration tests against the new schema
subgemi task delegate "Run integration tests" --verify-cmd "pytest tests/integration/"
```
