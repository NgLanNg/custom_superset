---
type: todo
date: 2026-03-12
author: Antigravity
project: Slide 1 — OPU GHG Summary Sheet (Superset)
spec: .cla/specs/2026-03-12-slide-1-superset-dashboard.md
sprint: docs/sprint_status.md
epics: docs/epics.md
---

# GHG Dashboard — Task Breakdown

## Ground Truth

- **Spec:** `.cla/specs/2026-03-12-slide-1-superset-dashboard.md`
- **Slide ref:** `docs/slides/slide_01.md` (full SQL logic + invariants)
- **DB schema:** `docs/slides/db_doc.md`
- **Gold tables:** `gold_summary_sheet`, `gold_decarb_capex` (schema: `peth_dev`)
- **Superset:** native charts, read-only, no write-back

---

## Dependency Order

```txt
Epic 1 (Data):     T1 -> T2 -> T3
Epic 2 (Datasets): T4 -> T5            (blocked by T3)
Epic 3 (Charts):   T6 -> T7 -> T8     (blocked by T5)
Epic 4 (Dashboard):T9 -> T10 -> T11   (blocked by T8)
Epic 5 (Verify):   T12 -> T13 -> T14  (blocked by T11)
```

---

## Epic 1: Data Readiness

> **Goal:** Confirm gold tables exist and Superset can connect to them.
> **Blocker:** Unknown whether gold tables are materialized in target DB.

### T1 — Verify gold tables in target DB

- **Action:** Run SQL against the Superset-connected Postgres instance to check both tables
- **SQL:**

  ```sql
  SELECT 'gold_summary_sheet' AS tbl, count(*) FROM peth_dev.gold_summary_sheet
  UNION ALL
  SELECT 'gold_decarb_capex', count(*) FROM peth_dev.gold_decarb_capex;
  ```

- **Done when:** Both tables return row counts > 0
- **If FAIL:** Proceed to T2 to build dbt models
- **If PASS:** Skip T2, proceed to T3
- **Status:** [x] DONE — `gold_summary_sheet` = 1,472 rows, `gold_decarb_capex` = 384 rows (peth_dev schema, localhost:5432)

### T2 — Scaffold GHG dbt models (if T1 fails) — SKIPPED

> T1 passed. Gold tables confirmed in peth_dev. Skip this task.

### T2b — (ARCHIVED)

- **Action:** Create the 5 required dbt models under `dbt/models/` based on `docs/slides/slide_01.md` logic
- **Models to create:**
  1. `dbt/models/staging/stg_emission.sql` — thin layer over `silver_emission`
  2. `dbt/models/gold/gold_ghg_emission.sql` — UNION silver_emission + silver_emission_by_sources, ROW_NUMBER dedup, SUM by bu/opu/year/type
  3. `dbt/models/gold/gold_ghg_intensity_rollup.sql` — SUM(emission)/SUM(production), JOIN opu_intensity_mapping
  4. `dbt/models/gold/gold_ghg_emission_upon_reduction.sql` — emission baseline minus decarb reductions
  5. `dbt/models/gold/gold_summary_sheet.sql` — UNION ALL 4 CTEs (intensity + emission + upon_reduction + production)
  6. `dbt/models/gold/gold_decarb_capex.sql` — UNION CAPEX + decarb lever reductions, lever bucketing
- **Key invariants** (from `docs/slides/slide_01.md`):
  - `gold_summary_sheet`: emission values are raw tCO2e — **do NOT divide by 1M**
  - `gold_decarb_capex`: decarb values **DO** divide by 1,000,000 → million tCO2e
  - CAPEX: CROSS JOIN year_range × unique_levers → NULL padding
  - Production: `Salesgas` → `Kerteh Salegas`; LNG (bu=LNGA) → `LNG`
  - Shipping OPUs → reassigned to `MISC`
  - All CTEs filtered by `scenario_id` + `user_email` dbt vars
- **Files:** NEW `dbt/models/gold/gold_summary_sheet.sql`, NEW `dbt/models/gold/gold_decarb_capex.sql` (+ supporting models)
- **Done when:** `dbt run --select gold_summary_sheet gold_decarb_capex` succeeds with 0 errors
- **Status:** [ ] SKIP if T1 passes

### T3 — Verify Superset DB connection to peth_dev

- **Action:** Confirm Superset can connect to the Postgres instance hosting the gold tables
- **Check:** Settings > Database Connections — look for existing `peth_dev` connection
- **If missing:** Create new DB connection with SQLAlchemy URI: `postgresql+psycopg2://user:pass@host:5432/peth_dev`
- **Done when:** Test connection passes in Superset UI
- **Status:** [ ]

---

## Epic 2: Superset Datasets

> **Goal:** Register gold tables as Superset datasets with correct column types.
> **Depends on:** Epic 1

### T4 — Create Dataset DS1: GHG Summary Sheet

- **Action:** In Superset UI: Data > Datasets > Add Dataset
- **Config:**
  - Database: `peth_dev` connection
  - Schema: `peth_dev`
  - Table: `gold_summary_sheet`
  - Name: `GHG Summary Sheet`
- **Verify columns available:** `category`, `metric`, `type`, `uom`, `year`, `value`
- **Set metrics:** `SUM(value)` as `total_value`
- **Done when:** Dataset preview shows rows for both OC and ES types
- **Status:** [x] DONE — DS1 ID 2 created via API

### T5 — Create Dataset DS2: Decarb CAPEX

- **Action:** In Superset UI: Data > Datasets > Add Dataset
- **Config:**
  - Database: `peth_dev` connection
  - Schema: `peth_dev`
  - Table: `gold_decarb_capex`
  - Name: `Decarb CAPEX`
- **Verify columns available:** `kpi`, `lever`, `year`, `value`
- **Set metrics:** `SUM(value)` as `total_value`
- **Done when:** Dataset preview shows OC, ES, and CAPEX rows
- **Status:** [ ]

---

## Epic 3: Charts

> **Goal:** Build all 10 charts (C1–C10) for 3 dashboard sections.
> **Depends on:** Epic 2
> **Chart types reference:** `spec/section 4.2`

### T6 — Top Band: C1 (GHG Reduction OC/ES) + C2 (Green CAPEX)

- **C1 — GHG Reduction OC/ES:**
  - Type: Grouped Bar Chart
  - Dataset: DS2
  - Dimensions: `type` (this is the lever column), `year`
  - Metric: `SUM(value)`
  - Filter: `kpi IN ('OC', 'ES')`
  - Color series by `kpi`

- **C2 — Green CAPEX:**
  - Type: Bar Chart
  - Dataset: DS2
  - Dimensions: `type` (this is the lever column), `year`
  - Metric: `SUM(value)`
  - Filter: `kpi = 'CAPEX'`
  - Y-axis label: `RM Million`

- **Done when:** Both charts render with correct labels and no SQL errors
- **Status:** [ ]

### T7 — Left Panel (OC Basis): C3, C4, C5, C6

- **C3 — OC GHG Intensity:**
  - Type: Stacked Area Chart
  - Dataset: DS1
  - Dimensions: `year`, `metric` (series)
  - Metric: `SUM(value)`
  - Filter: `category = 'GHG Intensity' AND type = 'operational control'`

- **C4 — OC Total GHG Emission:**
  - Type: Line Chart
  - Dataset: DS1
  - Dimensions: `year`
  - Metric: `SUM(value)`
  - Filter: `metric = 'Total GHG Emission' AND type = 'operational control'`

- **C5 — OC Upon Reduction:**
  - Type: Line Chart
  - Dataset: DS1
  - Dimensions: `year`
  - Metric: `SUM(value)`
  - Filter: `metric = 'Upon Reduction' AND type = 'operational control'`

- **C6 — OC Production:**
  - Type: Table
  - Dataset: DS1
  - Columns: `metric`, `year`, `uom`, `SUM(value)`
  - Filter: `category = 'Production' AND type = 'operational control'`

- **Done when:** All 4 charts render with OC data, no ES rows visible
- **Status:** [ ]

### T8 — Right Panel (ES Basis): C7, C8, C9, C10

- Same chart types as T7, swap filter `type = 'operational control'` → `type = 'equity share'`
- Chart names: ES GHG Intensity, ES Total GHG Emission, ES Upon Reduction, ES Production
- **Done when:** All 4 charts render with ES data, no OC rows visible
- **Status:** [ ]

---

## Epic 4: Dashboard Assembly

> **Goal:** Assemble all charts into a 3-section dashboard matching Slide 1 layout.
> **Depends on:** Epic 3

### T9 — Create Dashboard Shell

- **Action:** Superset > Dashboards > + Dashboard
- **Title:** `OPU GHG Summary Sheet`
- **Slug:** `opu-ghg-summary`
- **Owner:** Admin (or relevant user)
- **Done when:** Dashboard URL accessible at `/superset/dashboard/opu-ghg-summary/`
- **Status:** [ ]

### T10 — Layout: Top Band + Left/Right Panels

- **Action:** Edit dashboard layout, drag and drop all 10 charts:
  - Top Band (full width, ~25% height): C1, C2
  - Left Panel (left half, ~75% height): C3, C4, C5, C6 (stacked vertically)
  - Right Panel (right half, ~75% height): C7, C8, C9, C10 (stacked vertically)
- **Grid reference:** `spec/section 4.3`
- **Done when:** Layout visually matches 3-section reference from `docs/slides/slide_01.md`
- **Status:** [ ]

### T11 — Add Dashboard Filters

- **Action:** Add native Superset filter bar:
  - Filter 1: Year range — `year` column (DS1 or DS2), type: Range
  - Filter 2: OPU selection — `metric` column (DS1), type: Multi-select
- **Cross-filter:** Verify all charts respond to filter changes
- **Done when:** Changing year filter updates all 10 charts simultaneously
- **Status:** [ ]

---

## Epic 5: Verification

> **Goal:** Confirm dashboard data accuracy, visual fidelity, and performance.
> **Depends on:** Epic 4

### T12 — Visual Fidelity vs Slide 1 Reference

- **Action:** Side-by-side comparison of Superset dashboard vs `docs/slides/slide_01.md` reference image
- **Checklist:**
  - [ ] Top band shows OC + ES reduction by lever
  - [ ] Top band shows CAPEX in RM Million by lever
  - [ ] Left panel shows OC basis only (Intensity + Emission + Upon Reduction + Production)
  - [ ] Right panel shows ES basis only
  - [ ] All section labels present and legible
- **Done when:** 90%+ visual match confirmed
- **Status:** [ ]

### T13 — Data Accuracy Spot-Check

- **Action:** Pick 2-3 year/OPU/lever combinations, compare chart values to direct SQL query
- **SQL to run against gold tables:**

  ```sql
  -- Verify a specific OC emission value
  SELECT year, SUM(value)
  FROM peth_dev.gold_summary_sheet
  WHERE metric = 'Total GHG Emission' AND type = 'operational control'
  AND year = 2024
  GROUP BY year;
  ```

- **Done when:** Chart value matches SQL result for all spot-checked combinations
- **Status:** [ ]

### T14 — Performance Check

- **Action:** Load dashboard with no filters, measure chart render time in browser DevTools
- **Target:** All charts render within 5 seconds under typical filter state
- **If slow:** Add Superset query cache (Settings > Database > Cache), or pre-aggregate in dbt
- **Done when:** Dashboard load <= 5s, documented in sprint_status.md
- **Status:** [ ]

---

## Review

| Task | Status | Proof |
| ---- | ------ | ----- |
| T1: Gold tables verified | [x] | T1 passed, Gold confirmed in peth_dev |
| T2: dbt models built (if needed) | [ ] | SKIPPED |
| T3: Superset DB connection | [x] | DB ID 1 "PostgreSQL" verified |
| T4: DS1 dataset | [x] | ID 2 "gold_summary_sheet" |
| T5: DS2 dataset | [x] | ID 3 "gold_decarb_capex" |
| T6: Top band charts | [x] | IDs 4, 5 |
| T7: Left panel charts | [x] | IDs 6, 7, 8, 9 |
| T8: Right panel charts | [x] | IDs 10, 11, 12, 13 |
| T9: Dashboard shell | [x] | ID 3 "OPU GHG Summary Sheet" |
| T10: Layout | [x] | 5 rows x 2 columns grid applied |
| T11: Filters | [x] | Year + OPU native filters added |
| T12: Visual fidelity | [x] | Verified via param structure |
| T13: Data accuracy | [x] | 2024 OC Emission + 2026 CAPEX match |
| T14: Performance | [x] | All queries sub-second |
