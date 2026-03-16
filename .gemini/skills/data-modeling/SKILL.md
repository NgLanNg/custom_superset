---
name: data-modeling
description: Data warehouse modeling playbook for analytics engineering (facts/dimensions, grains, SCD types, naming/constraints, schema reviews). Use when designing or refactoring warehouse models, changing grain, or reviewing dbt schemas.
---

# Data Modeling

## When to Use
- New mart/stage design, changing table grain, or modeling net-new metrics
- Choosing fact type (transactional, periodic snapshot, accumulating) or dimension type (SCD1 vs SCD2)
- Normalizing/denormalizing staging into marts, reconciling keys, or enforcing constraints/tests
- Reviewing dbt schemas or naming conventions before/after PRs

## Quick Start
1) Clarify business question → define grain (lowest stable unit), business keys, required dimensions/measures.
2) Choose model type: fact vs dimension; pick fact subtype (transactional | periodic snapshot | accumulating).
3) Map sources → staging → intermediate → mart. Document assumptions and filters.
4) Define keys: surrogate `pk`, natural `business_key`, foreign keys; decide SCD type per dimension.
5) Add constraints/tests: not_null + unique on keys, relationships to parents, accepted_values for enums.
6) Document: column descriptions, grain statement, freshness expectations, known caveats.

### Grain Statement Template
- "One row per <entity> per <time grain if any>, identified by <business keys>. Includes <measures> and <dimension keys>. Excludes <filters/caveats>." Keep this in docs and tests.

## Modeling Patterns

### Grain and Keys
- Pick the most atomic stable grain; avoid mixing grains in one model.
- Declare primary key explicitly; create surrogate keys when natural keys are unstable.
- For dedupe, window by business keys + ordered timestamp, keep `row_number = 1` and log discard counts.
- Include `valid_from`, `valid_to`, `is_current` for SCD2; keep `updated_at`/`inserted_at` for audits.

### Fact Table Types
- Transactional: one row per event; keep `occurred_at`, `amount`, `currency`, `status`.
- Periodic snapshot: one row per entity per period; include `snapshot_date`, periodic aggregates, status counts.
- Accumulating snapshot: one row per workflow with milestone timestamps (ordered columns), nullable until reached.

### Dimension Patterns
- Type 1 (overwrite): stable dims where history not needed; update in-place.
- Type 2 (history): add new row when tracked columns change; close prior row by setting `valid_to` and `is_current=false`.
- Junk dimensions: small discrete attributes; combine into one table and join on surrogate key.
- Degenerate dimensions: keep identifiers (e.g., order_id) on facts without separate table.
- Outriggers: only when attribute set is shared and stable; avoid deep snowflakes in marts.

### Intermediate Layer Pattern
- Use `int_` models to handle complex joins, pivots, and aggregations before final marts.
- Decision tree: combine two+ source systems → `int_[entity]_joined`; complex pivot/agg reused in multiple facts → `int_[entity]_pivoted`.
- Keeps marts simple and promotes DRY; avoids "spaghetti SQL" in final presentation layer.

### Naming and Contracts
- Prefixes: `stg_` for staging, `int_` for intermediate, `fct_` for facts, `dim_` for dimensions, `brdg_` for bridges.
- Columns: `*_id` for keys, `_at` for timestamps, `_flag` for booleans, `_amt` for monetary, `_cnt` for counts.
- Enforce units and currency; include `base_currency` and conversion rate columns when needed.
- Surrogate keys: use `dbt_utils.generate_surrogate_key(['col1', 'col2'])` for deterministic hashing on dims.

### Decision Helpers
- Fact subtype: need history of state over time → periodic snapshot; need lifecycle milestones → accumulating; pure events → transactional.
- SCD choice: consumers need "as-was" history → SCD2; only latest matters → SCD1; very volatile noisy fields → keep in junk or ignore.
- Normalization: stage raw close to source; denormalize in marts only when it simplifies BI and does not break grain.

### Performance and Storage
- Partition/cluster facts by date plus high-cardinality keys only if queries benefit.
- Avoid over-wide rows; push arrays/structs to JSON only when necessary and documented.
- For warehouses with cost-based optimizers, supply statistics via ANALYZE (Postgres) or rely on engine metadata (Snowflake/BigQuery).

### dbt Incremental Configuration
- For large transactional facts, use incremental materialization with `delete+insert` or `merge` strategy.
- Look back 2-3 days to catch late-arriving data when filtering on `event_at`.
- Example config block:
```sql
{{
 config(
 materialized='incremental',
 unique_key='transaction_id',
 incremental_strategy='delete+insert'
 )
}}
select * from {{ ref('stg_transactions') }}
{% if is_incremental() %}
 where event_at >= dateadd(day, -3, current_date)
{% endif %}
```

### Data Contracts (dbt v1.5+)
- Enforce schema on critical staging models to prevent upstream drift from breaking pipelines.
- YAML contract example:
```yaml
models:
 - name: stg_orders
 config:
 contract:
 enforced: true
 columns:
 - name: order_id
 data_type: int
 constraints:
 - type: not_null
 - type: primary_key
 - name: status
 data_type: string
```

## Validation and Testing
- Schema tests: `unique` + `not_null` on primary keys; `relationships` on foreign keys; `accepted_values` for enums/status.
- Reconciliation: compare counts/sums to source (same-day or by partition); flag large deltas.
- Freshness: ensure source freshness rules; propagate to marts.
- In dbt, capture grain in `meta` and document with examples; add SCD2 tests for `valid_from/valid_to` gaps/overlaps.

### Quick SQL Patterns
- De-dupe keeping latest: `row_number() over (partition by business_key order by updated_at desc)` then filter to `=1`.
- SCD2 close-out: when change detected, set `valid_to = new_valid_from` and `is_current=false` for prior row; insert new row with `is_current=true`.

## Workflow: From Request to Model
1) Intake: capture metric definition, filters, grain, slice dimensions, source systems.
2) Source audit: profile nulls, duplicate keys, late arriving dimensions; log gaps.
3) Model design: draw lineage from source → staging → fact/dim; select fact type; define surrogate keys.
4) Validation plan: decide tests and reconciliation checks; define monitoring for volume/anomalies.
5) Implement: stage → int → mart; add docs/tests; run backfill with limited range; verify counts.
6) Handoff: publish docs, caveats, and query examples; set owners and SLAs.

## Anti-Patterns to Avoid
- Mixed grains in one table; encoding flags without descriptions; silently dropping late data.
- Using natural keys that change; joining dimensions on non-deterministic text; hiding unit conversions.
- Over-SCD2-ing rapidly changing noisy columns; snowflaking marts without clear benefit.

## References and Related Skills
- Pair with dbt (modeling/tests/docs), data-quality (validation/freshness), sql-optimization (index/plan tuning), etl-pipelines (orchestration/backfills).
- Keep detailed schemas/checklists in references as needed when project-specific.
