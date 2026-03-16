# Proof of Work — Scenario Planning Dashboard Fixes

**Date:** 2026-03-15  
**Dashboard URL:** `http://localhost:9000/superset/dashboard/scenario-planning/`  
**Scope:** Unblocking UI dev environment + fixing backend API 500 errors

---

## Before vs After

| State | Screenshot |
|-------|-----------|
| Before: TS6307 blocked entire frontend | ![error](login_page_error_1773527456345.png) |
| After Fix 1: UI loads, but backend 500 toasts | ![partial](scenario_planning_dashboard_waiting_sqlite_1773527820262.png) |
| After Fix 2: Fully working, no errors | ![working](final_dashboard_verify_1773528239161.webp) |

---

## Problem 1 — Webpack Dev Server Blocked by TS6307

### Symptom
The entire Superset frontend was blocked by a full-screen React Error Overlay:
```
TS6307: File '.../plugin-chart-scenario/esm/ChangeTracker.js' is not listed
within the file list of project '.../tsconfig.json'. Projects must list all
files or use an 'include' pattern.
```
No dashboard or login page was reachable.

### Root Cause
A previous standalone `npm run build` inside `plugin-chart-scenario/` had emitted compiled output to three directories:
- `esm/` — 17 files (`.js` + `.js.map`)
- `lib/` — compiled declarations
- `dist/` — bundle

The Webpack dev server's `fork-ts-checker-webpack-plugin` picked up these `.js` files, but they weren't included in the root `tsconfig.json` project references, causing TS6307.

Additionally, `plugin-chart-scenario` was **missing from the root `tsconfig.json` references list**, unlike every other plugin.

### Fix

**1. Deleted stale build artifacts:**
```bash
rm -rf esm/ lib/ dist/
# run from: superset-frontend/plugins/plugin-chart-scenario/
```

**2. Added plugin to root `tsconfig.json` references:**
```diff
     { "path": "./plugins/plugin-chart-echarts" },
+    { "path": "./plugins/plugin-chart-scenario" },
     { "path": "./plugins/plugin-chart-handlebars" },
```

The plugin already had its own `tsconfig.json` (correctly configured with `superset-ui-writeback` and `plugin-chart-echarts` references).

---

## Problem 2 — Backend 500 Errors on Config APIs

### Symptom
After the UI was unblocked, the dashboard showed two error toasts:
- `Failed to load growth configuration`
- `Failed to load OPU configuration`

Network inspection confirmed:
- `GET /api/v1/scenario/opu-config?scenario_name=existing_assets` → 500
- `GET /api/v1/scenario/growth-config?scenario_name=existing_assets` → 500

### Root Cause Investigation

| Check | Result |
|-------|--------|
| Tables exist in PostgreSQL? | Yes — `silver_scenario_opu_config`, `silver_scenario_growth_config` exist |
| Data seeded? | Yes — 6 rows each |
| Correct `scenario_name`? | Yes — `existing_assets` matches |
| Views registered in `initialization/__init__.py`? | Yes — both `OPUConfigView`, `GrowthConfigView` registered |

**Actual cause:** PostgreSQL's `UUID` column type maps to a Python `uuid.UUID` object in SQLAlchemy results. Flask's `jsonify` cannot serialize `uuid.UUID` — it raises a `TypeError`, which the `except Exception` block catches and silently returns as a 500.

### Fix

Added `str(row['id'])` cast in both GET handlers before JSON serialization:

```diff
# opu_config_view.py and growth_config_view.py — GET handler
  for row in rows:
+     # UUID -> str (PostgreSQL UUID type is not JSON-serializable)
+     if row.get('id') is not None:
+         row['id'] = str(row['id'])
      if row.get('updated_at'):
          row['updated_at'] = row['updated_at'].isoformat()
```

Restarted Superset Flask backend to pick up the Python changes.

---

## Verification

### Health endpoint (no auth required)
```
GET http://localhost:8088/api/v1/scenario/health
→ {"status": "ok", "view": "scenario", "db": "postgresql"}
```

### API endpoints (authenticated, via browser)

| Endpoint | Status | Data |
|----------|--------|------|
| `/api/v1/scenario/opu-config?scenario_name=existing_assets` | **200 OK** | 17 OPU assets |
| `/api/v1/scenario/growth-config?scenario_name=existing_assets` | **200 OK** | 6 growth projects |

### Dashboard UI
- No Webpack overlay — page loads normally
- No "Failed to load" toasts
- Tabs visible: Equity Share, Growth Project, Operational Data, OPU Registry
- Growth Project and OPU Registry grids render and display data

---

## Question Answered — "why scenario_sqlite?"

The string `scenario_sqlite` **does not exist anywhere in the codebase** (confirmed via `grep -r`).

The confusion came from a legacy docstring in `scenario_writeback.py`:
```python
"""
Custom View for Scenario Write-back (SQLite MVP version).
"""
```
These are cosmetic-only comments. The actual implementation always used `db.session` → PostgreSQL (`postgresql://superset:superset@localhost:5432/superset`).

The health endpoint confirms: `"db": "postgresql"`.

---

## Files Changed

| File | Change |
|------|--------|
| `superset-frontend/tsconfig.json` | Added `plugin-chart-scenario` to `references` |
| `superset-frontend/plugins/plugin-chart-scenario/esm/` | Deleted (34 stale files) |
| `superset-frontend/plugins/plugin-chart-scenario/lib/` | Deleted |
| `superset-frontend/plugins/plugin-chart-scenario/dist/` | Deleted |
| `superset/views/opu_config_view.py` | Cast UUID `id` to `str()` in GET handler |
| `superset/views/growth_config_view.py` | Cast UUID `id` to `str()` in GET handler |
