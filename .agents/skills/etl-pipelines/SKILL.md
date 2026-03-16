---
name: etl-pipelines
description: Build and operate ETL/ELT pipelines (ingest → stage → transform → load) with orchestration, idempotency, backfills, and operational playbooks. Use for Airflow/Dagster jobs, CDC/batch loads, and pipeline reviews.
---

# ETL Pipelines

## When to Use
- Designing/implementing Airflow/Dagster jobs, CDC/batch loads, or file ingests
- Adding idempotency/retries/checkpointing or backfilling missing ranges
- Reviewing pipeline robustness (ordering, dependencies, SLAs, data-quality gates)

## Quick Start Blueprint
1) Clarify source/target, expected volume, latency, and SLAs.
2) Choose mode: batch (scheduled), micro-batch, or CDC; decide watermark/bookmark columns.
3) Make it idempotent: deterministic file naming, upserts/merge, or partition overwrite; avoid duplicate side effects.
4) Add observability: row counts, hash checks, freshness, DQ tests (see data-quality skill), alerts.
5) Plan backfill: parameterize date range, guard against double-processing, cap concurrency.
6) Handoff: document schedule, owners, runbook for reruns and incident handling.

## Orchestration Patterns (Airflow/Dagster)
- DAG hygiene: small tasks, explicit dependencies, avoid giant XCom payloads; prefer TaskFlow/Operators for IO.
- Scheduling: `catchup=False` for forward-only; enable `max_active_runs` to cap overlap; set sensible retries/backoff.
- Idempotency: upstream tasks write to temp paths, downstream promotes to final once checks pass; use DAG run logical date for partitioning.
- Backfills: run with bounded date ranges; disable heavy alerts or use maintenance window; verify checkpoints before re-enabling schedule.
- Sensors: prefer external task sensors/events over tight poke loops; set timeouts.

### Write-Audit-Publish (WAP) Pattern
- For Iceberg/Delta Lake: write to staging branch/snapshot, run DQ checks against snapshot, atomic commit if pass (else rollback).
- Prevents dirty reads during long processing; audit failures don't pollute production tables.

### Event-Driven Orchestration
- Trigger DAGs on file arrival (S3KeySensor waiting for `_SUCCESS` flag) instead of polling on schedule.
- Reduces latency and eliminates empty runs; use Airflow sensors or Dagster asset sensors for real-time triggers.

## Data Movement Recipes
- Batch files (S3/GCS → warehouse): land to `raw/`, validate schema/row count, move to `staging/processed/` only after success; include manifest.
- CDC/Log-based: use stable ordering column (LSN/offset/timestamp); upsert into staging then merge to target; keep `last_processed` bookmark.
- Incremental tables: filter by `updated_at`/`ingested_at`; store high-watermark; handle late data with overlap window.
- API pagination: respect rate limits; retry with jitter; persist checkpoints per page/token.
- Streaming bridge: if streaming exists but batch is required, consume from compacted topic with offset tracking.

## Reliability and Quality Gates
- Pre-flight checks: schema drift detection, column count, required fields present; validate against registered JSON Schema/Protobuf contracts before processing.
- Post-load checks: row count vs source, sum/agg reconciliation on key measures, distinct keys counts.
- Freshness/SLA: alert when partitions missing or late; include data-quality block in DAG.
- Dead-letter queue (DLQ): route bad records to separate table/bucket with error metadata (timestamp, reason, source file); create playbook for DLQ replay without re-running successful batch.
- Schema evolution: define rules for new columns (ignore, error, or auto-evolve via ALTER TABLE).

## Operations and Runbooks
- Rerun strategy: rerun by partition/date; clean partial outputs before retrying; ensure idempotent merge.
- Backfill strategy: chunk by day/week; disable downstream consumers or mark data as reprocessing; verify counts after each chunk.
- Incident basics: capture failing task logs, input manifest, run-id; roll back target tables if partial loads escaped.

## Delivery Checklist
- Parameters for date ranges and environments
- Logging: structured, with correlation ids per run
- Metrics: processed rows, duration, bytes moved, late records, DQ failures
- Alerts: route to channel/on-call with run-id and remediation link

## Related Skills
- data-quality (tests/freshness), data-modeling (grains/fact types), dbt (transform layer), sql-optimization (performance), python-data-stack (dataframe transforms).
