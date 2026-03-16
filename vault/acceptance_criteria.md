# Acceptance Criteria — Scenario Planning Dashboard

## Overview

The Scenario Creation Page is implemented as a **native Superset dashboard** at
`/superset/dashboard/scenario-planning/`. All interactive UI lives inside the
`plugin-chart-scenario` chart plugin embedded in that dashboard. There is no
standalone React route.

---

## A. Backend Acceptance Criteria

### A.1 API Endpoints

| ID | Method | Endpoint | Purpose |
|----|--------|----------|---------|
| BE-001 | GET | `/api/v1/scenario/emission-sources` | Fetch emission rows (filters: bu, opu, scope, source, scenario_id) |
| BE-002 | POST | `/api/v1/scenario/emission-sources` | Upsert a single emission cell (writeback) |
| BE-003 | GET | `/api/v1/scenario/writeback` | Fetch equity share rows |
| BE-004 | POST | `/api/v1/scenario/writeback` | Upsert equity share cell |
| BE-005 | GET | `/api/v1/scenario/growth-config` | Fetch growth project rows (filter: scenario_name) |
| BE-006 | POST | `/api/v1/scenario/growth-config` | Upsert a growth config field |
| BE-007 | GET | `/api/v1/scenario/opu-config` | Fetch OPU rows (filter: scenario_name) |
| BE-008 | POST | `/api/v1/scenario/opu-config` | Upsert an OPU config field |
| BE-009 | GET | `/api/v1/scenario/metadata/` | List scenario metadata records |
| BE-010 | POST | `/api/v1/scenario/metadata/` | Create scenario metadata (status=draft) |
| BE-011 | PUT | `/api/v1/scenario/metadata/<id>` | Update scenario name/description |
| BE-012 | POST | `/api/v1/scenario/metadata/<id>/submit` | Transition status → pending_approval |

### A.2 Data Tables

| Table | Rows (seed) | Key Columns |
|-------|------------|-------------|
| `silver_scenario_equity_share` | 35 | scenario_name, bu, opu, year, value |
| `silver_scenario_growth_config` | 5 | scenario_name, bu, project, fid_year, capacity_mtpa, capex_billion, status |
| `silver_scenario_opu_config` | 14 | scenario_name, opu, bu, type, base_equity_pct, region, active |
| `silver_emission_by_sources` | 72 | scenario_id, bu, opu, scope, source, year, value |

Default `scenario_id` for unseeded/pre-save state: `'base'`

### A.3 Backend Test Scenarios

#### A.3.1 Emission Sources API

| ID | Given | When | Then |
|----|-------|------|------|
| BE-T001 | 72 seed rows exist | GET without filters | Returns 72 rows, status=success |
| BE-T002 | Rows exist | GET with bu=LNGA | Returns only LNGA rows |
| BE-T003 | Rows exist | GET with opu=MLNG | Returns only MLNG rows |
| BE-T004 | Rows exist | GET with scenario_id=base | Returns all 72 seed rows |
| BE-T005 | Row exists | POST upsert with valid payload | Returns 200, value persisted in DB |
| BE-T006 | No session | POST upsert | Returns 401 unauthorized |

#### A.3.2 Equity Writeback

| ID | Given | When | Then |
|----|-------|------|------|
| BE-T100 | Equity row exists (BU=LNGA, GPU=ALNG) | POST new value | Returns 200, status=success, DB updated |
| BE-T101 | Authenticated | POST invalid value (>100) | Returns 400 validation error |
| BE-T102 | Unauthenticated | POST writeback | Returns 401 |

#### A.3.3 Growth Configuration

| ID | Given | When | Then |
|----|-------|------|------|
| BE-T200 | 5 growth rows exist | GET growth-config?scenario_name=existing_assets | Returns 5 rows with fid_year, capacity_mtpa, capex_billion, status |
| BE-T201 | Row exists | POST upsert fid_year for LNGC2 | Returns 200, new value in DB |
| BE-T202 | Row exists | POST invalid fid_year (<2020) | Returns 400 |

#### A.3.4 OPU Configuration

| ID | Given | When | Then |
|----|-------|------|------|
| BE-T300 | 14 OPU rows exist | GET opu-config?scenario_name=existing_assets | Returns 14 rows with opu, bu, base_equity_pct, region |
| BE-T301 | Row exists | POST upsert base_equity_pct | Returns 200, DB updated |

#### A.3.5 Scenario Metadata & Workflow

| ID | Given | When | Then |
|----|-------|------|------|
| BE-T400 | No scenario exists | POST metadata with name | Returns 201 with id, status=draft |
| BE-T401 | Scenario in draft | PUT metadata name update | Returns 200, name updated |
| BE-T402 | Scenario in draft with id | POST /<id>/submit | Returns 200, status=pending_approval |
| BE-T403 | Scenario in pending_approval | POST /<id>/submit again | Returns 400 (invalid transition) |
| BE-T404 | Unauthenticated | POST metadata | Returns 401 |

---

## B. Frontend Acceptance Criteria

### B.1 Plugin Component Map

All components live in `superset-frontend/plugins/plugin-chart-scenario/src/`

| Component | Responsibility |
|-----------|---------------|
| `ScenarioChart.tsx` | Root container: metadata inputs, Save Draft / Submit buttons, top-level Tabs |
| `EmissionSourcesTab.tsx` | Orchestrates FilterPanel + ComparativeChart + EditableDataTable; **owns `editedValues` state** |
| `ComparativeChart.tsx` | **Two-series** ECharts line chart (Baseline vs Scenario), dynamic title |
| `FilterPanel.tsx` | BU / OPU / Scope / Sources dropdowns; populates options from API |
| `EditableDataTable.tsx` | **In-memory edits**, orange cell highlight, Baseline Amount column |
| `useScenarioData.ts` | Equity share state + chart options + handleSave |
| `useGrowthConfig.ts` | Growth config fetch + saveCell |
| `useOPUConfig.ts` | OPU config fetch + saveCell |
| `types.ts` | **`EditKey` type** for tracking in-memory edits |

### B.2 Functional Requirements

#### B.2.1 Metadata Area

| ID | Criteria |
|----|----------|
| FE-001 | Scenario Name input visible, accepts text, max 256 chars |
| FE-002 | Description textarea visible, accepts text, max 2000 chars |
| FE-003 | Save Draft button visible and enabled when name is non-empty and status=draft |
| FE-004 | Submit for Approval button visible, disabled until scenario has been saved (has id) |
| FE-005 | After Save Draft, scenario id is stored; subsequent save calls PUT not POST |
| FE-006 | After Submit, status transitions to pending_approval; both buttons disabled |

#### B.2.2 Tab Navigation

| ID | Criteria |
|----|----------|
| FE-010 | Three top-level tabs render: Equity Share Configuration, Growth Configuration, OPU Configuration |
| FE-011 | Clicking Growth Configuration tab shows growth pipeline table |
| FE-012 | Clicking OPU Configuration tab shows sub-tabs |
| FE-013 | Six OPU sub-tabs render: Emission by Sources, Production, Emission by Gases, Energy Consumption, Intensity, Reduction |
| FE-014 | Emission by Sources is the default active sub-tab |

#### B.2.3 OPU Configuration — Emission by Sources (In-Memory Edit Pattern)

| ID | Criteria |
|----|----------|
| FE-020 | Filter row renders four dropdowns: BU, OPU, Scope, Sources |
| FE-021 | Filter dropdown options are populated from API (not hardcoded) |
| FE-022 | Comparative Total GHG Emissions chart renders with **two series**: Baseline (grey) and Scenario (blue) |
| FE-023 | Chart title defaults to "Comparative Total GHG Emissions" |
| FE-024 | Selecting OPU filter updates chart title to "Comparative Total GHG Emissions – {OPU}" |
| FE-025 | Selecting BU filter updates chart title to "Comparative Total GHG Emissions – {BU}" |
| FE-026 | Table title defaults to "Operational Control – Emission by Sources" |
| FE-027 | Table shows pivot layout: BU, OPU, Scope, Source, **Baseline Amount** columns + one column per year |
| FE-028 | Year column cells are editable via EditableCell |
| FE-029 | **Cell edit stores value in-memory (Map&lt;EditKey, number&gt;), NOT written to DB immediately** |
| FE-030 | **Edited cells show orange background (#fff7e6)** |
| FE-031 | **Reverting cell to original value removes orange highlight** |
| FE-032 | **Baseline Amount column shows sum of all year values per row from scenario_id='base'** |
| FE-033 | **Save Draft button flushes in-memory edits to DB via POST /api/v1/scenario/emission-sources** |
| FE-034 | **After Save Draft, orange highlights cleared** |
| FE-035 | Filter change refreshes both chart and table simultaneously |

#### B.2.4 Equity Share Configuration

| ID | Criteria |
|----|----------|
| FE-040 | Existing Assets table renders with BU, GPU, year columns |
| FE-041 | Growth Projects table renders with BU, Projects, year columns |
| FE-042 | Editing equity cell POSTs to `/api/v1/scenario/writeback` |
| FE-043 | Chart updates immediately on cell edit (optimistic UI) |
| FE-044 | Stats row shows Total Assets, Avg Equity Share, Max Equity, Min Equity |

#### B.2.5 Growth Configuration

| ID | Criteria |
|----|----------|
| FE-050 | Growth pipeline table renders with 5 rows (seed data) |
| FE-051 | FID Year, Capacity, Capex columns are editable |
| FE-052 | Status column uses a dropdown (On Track / Delayed / Cancelled) |
| FE-053 | Cell edit POSTs to `/api/v1/scenario/growth-config` |

---

## C. Playwright E2E Tests

### C.1 Existing Tests

| ID | File | Scenario |
|----|------|----------|
| E2E-001 | `playwright/tests/scenario.spec.ts` | Renders scenario chart, edits equity cell, verifies API 200 + toast, reverts |
| E2E-002 | `playwright/tests/scenario.spec.ts` | Clicks Growth Configuration tab, edits LNGC2 FID Year, reverts |
| E2E-003 | `playwright/tests/scenario.spec.ts` | Clicks OPU Configuration tab, edits base_equity_pct, reverts |
| E2E-004 | `playwright/tests/scenario-planning.spec.ts` | Navigates to `/superset/dashboard/scenario-planning/`, verifies chart container visible |
| E2E-005 | `playwright/tests/scenario-planning.spec.ts` | Captures full-page screenshot for visual regression |
| E2E-006 | `playwright/tests/scenario.spec.ts` | **In-memory edit flow: edit emission cell, verify orange highlight, Save Draft, verify API + highlight cleared** |

### C.2 Required Pre-conditions

| ID | Criteria |
|----|----------|
| INFRA-001 | Superset running at `http://localhost:8088` |
| INFRA-002 | Auth state saved at `playwright/.auth/user.json` (via `global-setup.ts`) |
| INFRA-003 | Chart at `explore/?slice_id=105` exists (scenario_chart viz_type) |
| INFRA-004 | Dashboard slug `scenario-planning` exists and is published |
| INFRA-005 | `silver_emission_by_sources` has rows with `scenario_id='base'` |
| INFRA-006 | `silver_scenario_growth_config` has 5 rows for `scenario_name=existing_assets` |
| INFRA-007 | `silver_scenario_opu_config` has 14 rows for `scenario_name=existing_assets` |

### C.3 Test Scripts

| Script | Command |
|--------|---------|
| Run all E2E tests | `npm run playwright:test` |
| Run scenario plugin tests | `npx playwright test playwright/tests/scenario.spec.ts` |
| Run dashboard visual test | `npx playwright test playwright/tests/scenario-planning.spec.ts` |
| Run with browser visible | `npm run playwright:headed` |
| Interactive debug | `npm run playwright:debug` |

---

## D. Acceptance Test Status

### D.1 Backend (verified via curl)

| ID | Status |
|----|--------|
| BE-001 GET emission-sources | PASS — 72 rows |
| BE-003 GET writeback | PASS — 35 rows |
| BE-005 GET growth-config | PASS — 5 rows |
| BE-007 GET opu-config | PASS — 14 rows |
| BE-009 GET metadata | PASS — 200 |

### D.2 Frontend (verified 2026-03-14)

| ID | Status |
|----|--------|
| FE-010 Three top-level tabs | PASS — visible in dashboard |
| FE-013 Six OPU sub-tabs | PASS — visible in dashboard |
| FE-022 Two-series GHG chart | PASS — Baseline (grey) + Scenario (blue) |
| FE-027 Pivot table with Baseline Amount column | PASS |
| FE-029 In-memory cell edit | PASS — no immediate DB write |
| FE-030 Orange cell highlight | PASS — #fff7e6 background |
| FE-033 Save Draft flushes edits | PASS — POST to emission-sources |
| FE-034 Highlights cleared after save | PASS |

### D.3 Unit Tests

| File | Status |
|------|--------|
| `plugins/plugin-chart-scenario/test/EmissionSources.test.tsx` | PASS — 19 tests |
| `plugins/plugin-chart-scenario/test/ScenarioChart.test.tsx` | PASS |

### D.4 Known Issues

| ID | Issue | Status |
|----|-------|--------|
| BUG-001 | OPU tab chart/table showed "No data available" | FIXED — scenario_id mismatch corrected |
| BUG-002 | Immediate DB write on cell edit | FIXED — in-memory edit pattern implemented |

---

## E. Requirement Traceability

| FR# | Description | Covered By |
|-----|-------------|-----------|
| FR-01 | Scenario Name input | FE-001, E2E-001 |
| FR-02 | Scenario Description input | FE-002 |
| FR-03 | Equity Share tab | FE-010, FE-040–043, E2E-001 |
| FR-04 | Growth Configuration tab | FE-011, FE-050–053, E2E-002 |
| FR-05 | OPU Configuration tab | FE-012, E2E-003 |
| FR-06 | Emission by Sources sub-tab | FE-014, FE-020–035 |
| FR-07 | Comparative GHG chart (two series) | FE-022–025 |
| FR-08 | Editable pivot table | FE-027–029 |
| FR-09–12 | Filters (BU/OPU/Scope/Sources) | FE-020–021, FE-035 |
| FR-13 | Dynamic chart title | FE-023–025 |
| FR-14 | Save Draft (flush in-memory edits) | FE-003–005, FE-033–034, BE-T400 |
| FR-15 | Submit for Approval | FE-006, BE-T402 |
| FR-16 | In-memory edit pattern | FE-029–031 |
| FR-17 | Orange cell highlight for edits | FE-030–031 |
| FR-18 | Baseline Amount column | FE-032 |

---

## F. Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-03-14 | 3.0 | Added Epic 16: In-memory edit pattern, two-series chart, orange cell highlight, Baseline Amount column; updated E2E tests |
| 2026-03-14 | 2.0 | Full rewrite — aligned with native dashboard architecture; removed fictional standalone route; updated all component paths, API endpoints, and table names to match production code |
| 2026-03-14 | 1.0 | Initial document |