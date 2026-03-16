---
type: delegate-brief
date: 2026-03-12
author: Antigravity
project: Slide 1 — OPU GHG Summary Sheet (Superset)
assigned_to: subagent
---

# Delegation Brief: Build Slide 1 Superset Dashboard

## Mission

Build a read-only Superset dashboard called **"OPU GHG Summary Sheet"** that replicates Slide 1
of the GHG Executive Dashboard. Use native Superset charts (no custom plugins) connected to
dbt Gold tables in the `peth_dev` schema.

---

## Context of Truth

| Artifact | Path |
| --- | --- |
| Technical Spec | `.cla/specs/2026-03-12-slide-1-superset-dashboard.md` |
| Task Tracker | `vault/tasks/ghg_dashboard_todo.md` |
| Sprint Plan | `docs/sprint_status.md` |
| Epics + ACs | `docs/epics.md` |
| Slide Reference | `docs/slides/slide_01.md` |
| Active Context | `vault/active_context.md` |

---

## Environment

### Superset
- URL: `http://localhost:8088`
- Auth: `admin` / `admin`
- Existing DB connection: id=`1`, name=`PostgreSQL` — already points to the correct Postgres instance

### PostgreSQL (local Docker)
- Host: `localhost:5432`
- User/Pass: `superset` / `superset`
- Database: `superset`
- Target schema: `peth_dev`

### Verify with:
```bash
PGPASSWORD=superset psql -h localhost -p 5432 -U superset -d superset -c "\dt peth_dev.*"
```

---

## Verified State (pre-confirmed — do NOT re-check)

| Item | Status | Detail |
| --- | --- | --- |
| T1: Gold tables exist | DONE | `gold_summary_sheet`=1,472 rows; `gold_decarb_capex`=384 rows |
| T2: dbt scaffold | SKIPPED | Tables already materialized |
| T3: Superset DB connection | DONE | DB id=1 "PostgreSQL" connects to the correct instance |
| T4: Dataset DS1 | PENDING | `gold_summary_sheet` not yet registered in Superset |
| T5: Dataset DS2 | PENDING | `gold_decarb_capex` not yet registered in Superset |
| T6–T14 | PENDING | All charts, dashboard, filters, and verification |

---

## Critical Schema Facts

### `peth_dev.gold_summary_sheet`
| Column | Type | Sample Values |
| --- | --- | --- |
| category | text | 'GHG Intensity', 'GHG Emission', 'Production' |
| metric | text | OPU names or 'Total GHG Emission', 'Upon Reduction' |
| type | text | 'operational control', 'equity share' |
| uom | text | 'tCO2e', 'tCO2e/tonne', 'tCO2e/ tonne', etc. |
| year | text | '2019' … '2050' |
| value | numeric | raw tCO2e — NOT divided by 1M |
| scenario_id | text | 'base' (only value present) |
| user_email | text | 'base' (only value present) |

### `peth_dev.gold_decarb_capex`
| Column | Type | Sample Values |
| --- | --- | --- |
| kpi | text | 'OC', 'ES', 'CAPEX' |
| type | text | 'CCS', 'Electrification', 'Energy efficiency', 'Zero Routine Flaring & Venting' |
| year | text | '2019' … '2050' |
| uom | text | 'million tCO2e' (OC/ES), blank (CAPEX) |
| value | numeric | RM Million for CAPEX; million tCO2e for OC/ES |

> IMPORTANT: The `lever` column mentioned in slide_01.md is stored as `type` in `gold_decarb_capex`.
> Do not use a column named `lever` — it does not exist. Use `type`.

---

## Task Execution Plan

Execute in strict order. Mark `[x]` in `vault/tasks/ghg_dashboard_todo.md` after each task.

### T4 — Create Dataset DS1: GHG Summary Sheet

Use the Superset REST API (preferred) or UI.

**API:**
```bash
TOKEN=$(curl -s -X POST http://localhost:8088/api/v1/security/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin","provider":"db","refresh":true}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

curl -X POST http://localhost:8088/api/v1/dataset/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "database": 1,
    "schema": "peth_dev",
    "table_name": "gold_summary_sheet"
  }'
```

**Done when:** Response returns dataset id; `GET /api/v1/dataset/` shows `gold_summary_sheet`.

---

### T5 — Create Dataset DS2: Decarb CAPEX

```bash
curl -X POST http://localhost:8088/api/v1/dataset/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "database": 1,
    "schema": "peth_dev",
    "table_name": "gold_decarb_capex"
  }'
```

**Done when:** Response returns dataset id; `GET /api/v1/dataset/` shows `gold_decarb_capex`.

---

### T6 — Create Top Band Charts (C1 + C2)

Get DS2 id from T5 result. Use Superset Explore UI or API.

**C1 — GHG Reduction OC/ES (Grouped Bar Chart):**
- Dataset: DS2 (`gold_decarb_capex`)
- Chart type: `dist_bar` (Bar Chart with series)
- Metrics: `SUM(value)`
- Group by: `type` (this is the lever column)
- Series: `kpi`
- Filter: `kpi IN ('OC', 'ES')`
- X-axis: `year`

**C2 — Green CAPEX (Bar Chart):**
- Dataset: DS2
- Chart type: `dist_bar`
- Metrics: `SUM(value)`
- Group by: `type` (lever column)
- Filter: `kpi = 'CAPEX'`
- X-axis: `year`
- Y-axis label: `RM Million`

**Done when:** Both charts render with correct data and no SQL errors.

---

### T7 — Create Left Panel Charts (C3–C6) — Operational Control

All use DS1 (`gold_summary_sheet`). All filter `type = 'operational control'`.

**C3 — OC GHG Intensity (Stacked Area Chart):**
- Chart type: `area`
- Metrics: `SUM(value)`
- Group by: `metric` (series = individual OPUs)
- Filter: `category = 'GHG Intensity' AND type = 'operational control'`
- X-axis: `year`

**C4 — OC Total GHG Emission (Line Chart):**
- Chart type: `line`
- Metrics: `SUM(value)`
- Filter: `metric = 'Total GHG Emission' AND type = 'operational control'`
- X-axis: `year`

**C5 — OC Upon Reduction (Line Chart):**
- Chart type: `line`
- Metrics: `SUM(value)`
- Filter: `metric = 'Upon Reduction' AND type = 'operational control'`
- X-axis: `year`

**C6 — OC Production (Table):**
- Chart type: `table`
- Columns: `metric`, `year`, `uom`, `SUM(value)`
- Filter: `category = 'Production' AND type = 'operational control'`

**Done when:** All 4 charts show OC data only; no ES rows visible.

---

### T8 — Create Right Panel Charts (C7–C10) — Equity Share

Same config as T7, swap every `type = 'operational control'` filter to `type = 'equity share'`.

- C7: ES GHG Intensity (Stacked Area)
- C8: ES Total GHG Emission (Line)
- C9: ES Upon Reduction (Line)
- C10: ES Production (Table)

**Done when:** All 4 charts show ES data only; no OC rows visible.

---

### T9 — Create Dashboard Shell

```bash
curl -X POST http://localhost:8088/api/v1/dashboard/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "dashboard_title": "OPU GHG Summary Sheet",
    "slug": "opu-ghg-summary",
    "published": true,
    "owners": [1]
  }'
```

**Done when:** Dashboard accessible at `http://localhost:8088/superset/dashboard/opu-ghg-summary/`

---

### T10 — Layout: 3-Section Grid

Add all 10 charts to the dashboard and arrange using the Superset drag-and-drop editor:

| Section | Charts | Position |
| --- | --- | --- |
| Top Band (full width, ~25% height) | C1, C2 | Row 0, columns 0–11 |
| Left Panel (left half, ~75% height) | C3, C4, C5, C6 | Rows 1–4, columns 0–5 |
| Right Panel (right half, ~75% height) | C7, C8, C9, C10 | Rows 1–4, columns 6–11 |

**Done when:** Layout visually matches the 3-section reference in `docs/slides/slide_01.md`.

---

### T11 — Add Dashboard Filters

Add native Superset filter bar with:
- Filter 1: `year` — Range or Multi-select — applies to DS1 and DS2
- Filter 2: `type` on DS1 — hidden (used by chart-level filters, not user-facing)

**Done when:** Changing year filter updates all 10 charts simultaneously.

---

### T12 — Visual Verification

Side-by-side comparison vs `docs/slides/slide_01.md` reference:
- [ ] Top band shows OC + ES reduction by lever (CCS, Electrification, Energy efficiency, ZRF&V)
- [ ] Top band shows CAPEX in RM Million by lever
- [ ] Left panel shows OC basis only
- [ ] Right panel shows ES basis only
- [ ] All section labels correct and legible

---

### T13 — Data Accuracy Spot-Check

Run directly against Postgres and compare to chart values:
```sql
-- Check OC Total GHG Emission for year 2024
SELECT year, SUM(value)
FROM peth_dev.gold_summary_sheet
WHERE metric = 'Total GHG Emission'
  AND type = 'operational control'
  AND year = '2024'
GROUP BY year;
```

**Done when:** Chart value matches SQL for 2–3 sampled year/metric combinations.

---

### T14 — Performance Check

Load the dashboard with no filters. Measure time in browser DevTools Network tab.

**Target:** All charts render within 5 seconds.

---

## Reporting Requirements

After completing all tasks:

1. Mark each completed task `[x]` in `vault/tasks/ghg_dashboard_todo.md`
2. Add a `## Review` row per task with proof (response ID, row count, screenshot path)
3. Update `vault/active_context.md`:
   - Set Current Phase to: `Sprint 1 — COMPLETE`
   - Set Active Blockers to: `None`
   - List Completed items with evidence

---

## NYQUIST Gate Compliance

- State order before executing: "I will execute T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14 in this order."
- Run verification after each task before proceeding.
- Never mark `[x]` without proof (API response, row count, or screenshot).
- If any task fails 3 times, STOP and report the blocker — do not attempt workarounds.
- Do not create new files at the project root; write all artifacts under `vault/` or `.cla/`.

---

## Acceptance Criteria (from epics.md)

| AC | Pass Condition |
| --- | --- |
| AC1 | Dashboard loads at `/superset/dashboard/opu-ghg-summary/` without errors |
| AC2 | Top band shows OC/ES + CAPEX by lever (4 distinct lever types visible) |
| AC3 | Left panel shows ONLY `type = 'operational control'` data |
| AC4 | Right panel shows ONLY `type = 'equity share'` data |
| AC5 | Dashboard layout matches Slide 1 reference (3 sections) |
| AC6 | Chart values match direct SQL spot-check on gold tables |
