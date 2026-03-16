# Implementation Plan: Scenario Plugin Write-back to Data Warehouse

**Date:** 2026-03-09  
**Author:** Antigravity  
**Status:** Approved for Implementation  
**Approach:** Option 1 — Native Superset DB Connection to existing PostgreSQL RDS

---

## 1. Objective & Context

The Scenario UI (custom Superset chart plugin) must allow users to input equity share percentages per asset/year and have those values **persisted into the same PostgreSQL RDS** instance used by all other PETH data (`peth_prod` / `peth_dev` schemas).

This avoids any secondary service or CORS complexity. The Superset backend already holds a live SQLAlchemy connection to PostgreSQL; we reuse it for writes.

---

## 2. Architecture Overview

```
[User edits cell in React Plugin]
         |
         | SupersetClient.post (with CSRF token)
         v
[Flask Blueprint: /api/v1/scenario/writeback]
         |
         | SQLAlchemy UPSERT (ON CONFLICT DO UPDATE)
         v
[PostgreSQL RDS: peth_prod.silver_scenario_equity_share]
         |
         | dbt run (manual trigger or scheduled)
         v
[peth_prod.gold_scenario_equity_share]
         |
         | Tableau reads gold table
         v
[Dashboard renders updated chart]
```

---

## 3. Database: New Table Design

### Table: `silver_scenario_equity_share`

Lives in schema `peth_prod` (and mirrors to `peth_dev` for testing).  
Follows the same column conventions as other silver tables in the PETH schema.

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `uuid` | PK, `gen_random_uuid()` | Surrogate key — matches all other silver tables |
| `scenario_name` | `text` | NOT NULL | E.g. `existing_assets`, `growth_projects` |
| `bu` | `text` | NOT NULL | Business Unit — e.g. `LNGA`, `G&P` |
| `opu` | `text` | NOT NULL | Operating Unit / asset name — e.g. `MLNG`, `LNGC2` |
| `year` | `integer` | NOT NULL | Financial year — e.g. `2025` |
| `value` | `numeric` | NOT NULL | Equity percentage (0–100) |
| `scenario_id` | `text` | NULL | Planning scenario — matches convention in all silver tables |
| `user_email` | `text` | NULL | Superset user email — links to `ab_user.email` |
| `updated_at` | `timestamptz` | `DEFAULT now()` | Timestamp of last edit — used for dbt dedup |
| `file_path` | `text` | NULL | NULL for manually-entered rows (distinguishes from Lambda-ingested rows) |

**Indexes & Constraints:**

```sql
-- Unique constraint: ensures UPSERT merges on cell position, not creates duplicates
ALTER TABLE silver_scenario_equity_share
  ADD CONSTRAINT uq_scenario_opu_year
  UNIQUE (scenario_name, opu, year, scenario_id, user_email);

-- Fast lookups for populating the React grid
CREATE INDEX idx_scenario_equity_lookup
  ON silver_scenario_equity_share (scenario_name, bu, opu);
```

**Migration script (`init_db_script/create_scenario_table.sql`):**

```sql
CREATE TABLE IF NOT EXISTS peth_prod.silver_scenario_equity_share (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_name text        NOT NULL,
  bu            text        NOT NULL,
  opu           text        NOT NULL,
  year          integer     NOT NULL,
  value         numeric     NOT NULL,
  scenario_id   text,
  user_email    text,
  updated_at    timestamptz DEFAULT now(),
  file_path     text,
  CONSTRAINT uq_scenario_opu_year UNIQUE (scenario_name, opu, year, scenario_id, user_email)
);

CREATE INDEX IF NOT EXISTS idx_scenario_equity_lookup
  ON peth_prod.silver_scenario_equity_share (scenario_name, bu, opu);
```

> **Why this matches the existing schema:**  
> All silver tables use `uuid` PKs, `text` for `scenario_id` + `user_email`, `timestamptz` for `updated_at`, and `file_path` for audit trail. This table is consistent and will integrate naturally into dbt dedup patterns.

---

## 4. API: Flask Write-back Endpoint

**File:** `superset/views/scenario_writeback.py`

```python
from flask import Blueprint, request, jsonify
from flask_appbuilder.api import protect
from superset import db
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy import Table, MetaData
from datetime import datetime, timezone

scenario_bp = Blueprint("scenario", __name__, url_prefix="/api/v1/scenario")

@scenario_bp.route("/writeback", methods=["POST"])
@protect()  # Requires valid Superset session; rejects unauthenticated requests
def writeback():
    payload = request.get_json(force=True)

    # --- Validate ---
    required = ["scenario_name", "bu", "opu", "year", "value"]
    for field in required:
        if field not in payload:
            return jsonify({"status": "error", "message": f"Missing field: {field}"}), 400

    value = float(payload["value"])
    if not (0 <= value <= 100):
        return jsonify({"status": "error", "message": "Value must be between 0 and 100."}), 400

    # --- Get current user email from Superset session ---
    from flask_login import current_user
    user_email = current_user.email if current_user.is_authenticated else None

    # --- UPSERT ---
    meta = MetaData(schema="peth_prod")
    table = Table("silver_scenario_equity_share", meta, autoload_with=db.engine)

    stmt = pg_insert(table).values(
        scenario_name=payload["scenario_name"],
        bu=payload["bu"],
        opu=payload["opu"],
        year=int(payload["year"]),
        value=value,
        scenario_id=payload.get("scenario_id"),
        user_email=user_email,
        updated_at=datetime.now(timezone.utc),
        file_path=None,
    ).on_conflict_do_update(
        constraint="uq_scenario_opu_year",
        set_={"value": value, "updated_at": datetime.now(timezone.utc)}
    )

    db.session.execute(stmt)
    db.session.commit()

    return jsonify({
        "status": "success",
        "data": {
            "opu": payload["opu"],
            "year": payload["year"],
            "value": value,
            "updated_at": datetime.now(timezone.utc).isoformat()
        }
    }), 200
```

**Register the blueprint in `superset/app.py`:**

```python
from superset.views.scenario_writeback import scenario_bp
app.register_blueprint(scenario_bp)
```

---

## 5. Frontend: React Plugin Integration

The React plugin (`plugin-chart-scenario`) calls the endpoint using Superset's native HTTP client — **no `fetch()` directly** — so CSRF tokens are managed automatically.

```typescript
import { SupersetClient } from '@superset-ui/core';

// Called from onCellInput event in the AG Grid component
const handleCellEdit = async (params: CellEditEvent) => {
  const payload = {
    scenario_name: currentScenario,    // e.g. "existing_assets"
    bu: params.data.bu,
    opu: params.data.opu,
    year: params.colDef.field,         // The column header is the year
    value: params.newValue,
    scenario_id: activeScenarioId,
  };

  // 1. Optimistic: Update local grid state immediately
  setGridData(prev => updateGridRow(prev, params));
  recalculateChartSeries();

  // 2. Async: Persist to DB
  try {
    await SupersetClient.post({
      endpoint: '/api/v1/scenario/writeback',
      jsonPayload: payload,
    });
  } catch (err) {
    // 3. Revert on failure
    setGridData(prev => revertGridRow(prev, params));
    notification.error({ message: 'Save failed. Please try again.' });
  }
};
```

---

## 6. dbt: Gold Model for Tableau

A thin `dbt` model transforms the silver write-back table so Tableau can read it like any other gold table.

**File:** `dbt_project/models/gold_table/gold_scenario_equity_share.sql`

```sql
-- gold_scenario_equity_share.sql
-- Deduplicates writes by keeping the latest value per (scenario_name, opu, year, scenario_id, user_email).

{{ config(materialized='incremental', unique_key='id') }}

WITH deduped AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY scenario_name, opu, year, scenario_id, user_email
      ORDER BY updated_at DESC
    ) AS rn
  FROM {{ source('base', 'silver_scenario_equity_share') }}
)
SELECT
  id,
  scenario_name,
  bu,
  opu,
  year::text        AS year,     -- cast to text: consistent with all gold tables
  value,
  scenario_id,
  user_email,
  updated_at,
  file_path
FROM deduped
WHERE rn = 1
```

**Add source to `dbt_project/models/sources.yml`:**

```yaml
- name: silver_scenario_equity_share
```

---

## 7. Task List

| # | Task | Layer | Impact | Risk | Status |
|---|---|---|---|---|---|
| T1 | Create `create_scenario_table.sql` and run against `peth_dev` | DB | High | Low | [ ] |
| T2 | Write `scenario_writeback.py` Flask Blueprint | Backend | High | Medium | [ ] |
| T3 | Verify write privilege of Superset's DB connection user on RDS | DB | High | Medium | [ ] |
| T4 | Register blueprint in Superset `app.py` | Backend | High | Low | [ ] |
| T5 | Integrate `handleCellEdit` in React plugin with optimistic rendering | Frontend | High | Low | [ ] |
| T6 | Add `silver_scenario_equity_share` to `sources.yml` | dbt | Low | Low | [ ] |
| T7 | Create `gold_scenario_equity_share.sql` dbt model | dbt | Medium | Low | [ ] |
| T8 | Run `dbt run` in `peth_dev` and verify gold output | dbt | Medium | Low | [ ] |
| T9 | Connect gold table to Tableau as a new data source | BI | Medium | Low | [ ] |

---

## 8. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Superset RDS user is read-only | Medium | High | **T3**: Run `\du` on RDS to confirm privileges. Grant `INSERT, UPDATE` on `peth_prod.silver_scenario_equity_share` only. |
| UPSERT constraint mismatch | Low | Medium | Test with duplicate inserts in `peth_dev` before promoting to `peth_prod`. |
| Optimistic UI desync on network failure | Low | Low | Accepted trade-off. `catch` block reverts local state and shows error toast. |
| dbt incremental model picks up stale rows | Low | Low | `ROW_NUMBER() OVER ... ORDER BY updated_at DESC` is the same dedup pattern used across all existing gold models. |

---

## 9. Decision Log

| Decision | Rationale |
|---|---|
| Store in `peth_prod` schema (not Superset metadata DB) | Keeps all analytical data in one place. dbt can model it. Tableau can consume it. Consistent with the existing Silver/Gold architecture. |
| Match silver table conventions (`uuid` PK, `scenario_id`, `user_email`, `updated_at`) | Zero learning curve for the existing dbt pipeline. The gold dedup pattern (ROW_NUMBER by `updated_at`) applies immediately. |
| Use `file_path = NULL` for manually-entered rows | Provides a clean audit trail: Lambda-ingested rows always have a `file_path`; manual UI entries are `NULL`. |
| `@protect()` on Flask endpoint | Reuses Superset's native auth layer. No custom session management or tokens needed. |
| `integer` for `year` column (not `text`) | The silver tables store `year` as `text` for historical reasons. Here we cast to `integer` at silver level since UI inputs are always numeric, and cast back to `text` in the gold model for consistency with existing Tableau queries. |
