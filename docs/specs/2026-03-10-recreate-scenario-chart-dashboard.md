---
type: spec
date: 2026-03-10
author: Antigravity
feature: Recreate Scenario Chart & Dashboard (Post-PostgreSQL Migration)
status: draft
---

# Spec: Recreate Scenario Chart & Dashboard

## Problem

After migrating from SQLite to PostgreSQL, all Superset UI objects (charts, dashboards) were lost. The plugin code, write-back API, dataset, and seed data are all intact. We need to recreate the chart and dashboard configuration.

## Pre-conditions (Verified)

| Asset | Status | Location |
|-------|--------|----------|
| PostgreSQL container | Running | `superset-postgres:5432` |
| Superset backend | Running | `localhost:8088` |
| Database connection | Registered | id=1, name="PostgreSQL" |
| Dataset | Registered | id=1, table=`silver_scenario_equity_share` |
| Seed data | 32 rows | 4 OPUs x 8 years |
| Admin user | Created | admin/admin, id=1 |
| Plugin code | Unchanged | `plugin-chart-scenario/` |
| VizType | Registered | `scenario_chart` in `MainPreset.ts` |
| Write-back API | Active | `POST /api/v1/scenario/writeback` |

## Tasks

### T1 -- Create Scenario Chart via REST API

**Endpoint:** `POST /api/v1/chart/`
**Auth:** Bearer token from admin login

**Payload:**

```json
{
  "slice_name": "Scenario Creator",
  "datasource_id": 1,
  "datasource_type": "table",
  "viz_type": "scenario_chart",
  "owners": [1],
  "params": "{\"groupby\": [\"bu\", \"opu\", \"year\", \"value\"], \"metrics\": [], \"scenarioName\": \"existing_assets\", \"bu\": \"LNGA\"}"
}
```

**Done when:** `GET /api/v1/chart/` returns count=1 with viz_type=`scenario_chart`.

### T2 -- Create Dashboard via REST API

**Endpoint:** `POST /api/v1/dashboard/`

**Payload:** (uses chart ID from T1)

```json
{
  "dashboard_title": "Scenario Planning",
  "slug": "scenario-planning",
  "published": true,
  "owners": [1],
  "json_metadata": "{\"native_filter_configuration\": [], \"cross_filters_enabled\": false}"
}
```

**Done when:** `GET /api/v1/dashboard/` returns count=1.

### T3 -- Add Chart to Dashboard

**Endpoint:** `PUT /api/v1/chart/{chart_id}`

**Payload:**

```json
{
  "dashboards": [dashboard_id]
}
```

**Done when:** Dashboard shows the Scenario Creator chart at `http://localhost:8088/superset/dashboard/scenario-planning/`.

## Execution Order

```
T1 (create chart) -> T2 (create dashboard) -> T3 (link chart to dashboard)
```

## Risk

Low. All three tasks are idempotent API calls against verified infrastructure.
