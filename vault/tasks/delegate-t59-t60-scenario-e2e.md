---
type: delegate-brief
date: 2026-03-13
epic: 14
tasks: T59, T60
owner: unassigned
status: ready
---

# Delegate Brief — T59 + T60: E2E Tests for Scenario Creation Page

## Objective

Write a complete Playwright E2E test suite for the **Scenario Creation Page** (`/scenario/create/`) and capture a full-page visual regression screenshot. The page was built in Sprint 1 (T50-T58) and is now pending verification.

---

## Context of Truth

| Resource | Path |
|----------|------|
| Task tracker | `vault/tasks/todo.md` (Epic 14, T59/T60) |
| Active context | `vault/active_context.md` |
| Spec | `docs/specs/2026-03-12-scenario-creation-page.md` |
| UI reference | `vault/expect/expected_scenario.png` |
| Requirements | `vault/expect/desc.md` |
| Playwright config | `tests/e2e/playwright.config.ts` |
| Reference test (pattern) | `tests/e2e/test_slide1_dashboard.spec.ts` |

### Key Files Created in Sprint 1

| Component | Path |
|-----------|------|
| Page component | `superset/superset-frontend/src/scenario/ScenarioCreationPage.tsx` |
| Comparative chart | `superset/superset-frontend/src/scenario/ComparativeChart.tsx` |
| Filter panel | `superset/superset-frontend/src/scenario/FilterPanel.tsx` |
| Editable table | `superset/superset-frontend/src/scenario/EditableDataTable.tsx` |
| Types | `superset/superset-frontend/src/scenario/types.ts` |
| Route | `superset/superset-frontend/src/views/routes.tsx` (`/scenario/create/`) |
| Backend API | `superset/superset/views/scenario_writeback.py` |
| Scenario metadata API | `superset/superset/views/scenario_metadata.py` |

---

## Environment

- **App URL:** `http://localhost:9000` (webpack dev server) or `http://localhost:8088` (Flask backend)
- **Login URL:** `http://localhost:8088/login/`  or `http://localhost:9000/login/`
- **Target URL:** `http://localhost:9000/scenario/create/`
- **Credentials:** `admin` / `admin`
- **Start command:** `./start.sh` (from `/Users/alan/dashboard/`)
- **Run tests:** `cd tests/e2e && npx playwright test scenario-creation.spec.ts`

---

## API Reference

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/scenario/metadata/` | List scenarios |
| POST | `/api/v1/scenario/metadata/` | Create scenario |
| PUT | `/api/v1/scenario/metadata/<id>` | Update scenario |
| POST | `/api/v1/scenario/metadata/<id>/submit` | Submit for approval |
| GET | `/api/v1/scenario/emission-sources?scenario_id=base` | Fetch emission data |
| POST | `/api/v1/scenario/emission-sources` | Upsert cell edits |

---

## Data-Test Attributes (Already in the Components)

| Selector | Element |
|----------|---------|
| `[data-test="scenario-name-input"]` | Scenario name input field |
| `[data-test="scenario-description-input"]` | Description textarea |
| `[data-test="save-draft-btn"]` | Save Draft button |
| `[data-test="submit-btn"]` | Submit for Approval button |
| `[data-test="top-tabs"]` | Top-level Ant Design Tabs |
| `[data-test="tab-opu-configuration"]` | OPU Configuration tab |
| `[data-test="sub-tabs"]` | OPU sub-tabs |
| `[data-test="subtab-emission-sources"]` | Emission by Sources sub-tab |
| `[data-test="chart-title"]` | Dynamic chart title text |
| `[data-test="filter-bu"]` | BU filter dropdown |
| `[data-test="filter-opu"]` | OPU filter dropdown |
| `[data-test="filter-scope"]` | Scope filter dropdown |
| `[data-test="filter-source"]` | Sources filter dropdown |

---

## Acceptance Criteria

These map to `todo.md` Epic 14 ACs and must ALL pass:

| AC | Description | Test Strategy |
|----|-------------|---------------|
| AC1 | Page loads with metadata inputs visible | `toBeVisible()` on scenario-name-input |
| AC2 | Top tabs: 3 tabs present and switchable | click each tab, verify active state |
| AC3 | OPU sub-tabs: 6 sub-tabs visible and switchable | count sub-tabs, click each |
| AC4 | ComparativeChart renders with dynamic title | verify `[data-test="chart-title"]` text |
| AC5 | EditableDataTable renders with year columns | count `th` elements for years |
| AC6 | Filter changes update chart title and table | select BU, verify chart title contains BU |
| AC7 | Cell edits POST to API and return 200 | intercept network, verify POST 200 |
| AC8 | Save Draft button creates scenario (POST 200) | intercept POST /metadata/, verify 200 |
| AC9 | Submit button transitions to pending_approval | intercept POST /submit, verify 200 |

---

## Task T59 — Write E2E Tests

**File:** NEW `tests/e2e/scenario-creation.spec.ts`

Follow the exact pattern of `tests/e2e/test_slide1_dashboard.spec.ts`:
- YAML frontmatter header
- Gherkin comments above each `test.describe`
- Shared `beforeEach` login helper
- Named test groups per AC
- `test()` names prefixed with `AC{n}:`

### T59.1 — Page Load Tests

```
Given I am logged in as admin
When I navigate to /scenario/create/
Then the page header is visible
And the scenario name input is visible (data-test="scenario-name-input")
And the scenario description input is visible (data-test="scenario-description-input")
And the Save Draft button is visible (data-test="save-draft-btn")
And the Submit button is visible (data-test="submit-btn")
And no error messages are displayed
```

### T59.2 — Tab Navigation Tests

```
Given I am on /scenario/create/
When I view the top tabs (data-test="top-tabs")
Then I see exactly 3 tabs: "Equity Share Configuration", "Growth Configuration", "OPU Configuration"

When I click "OPU Configuration"
Then the OPU tab panel becomes active
And I see 6 sub-tabs: Emission by Sources, Production, Emission by Gases, Energy Consumption, Intensity, Reduction

When I click "Emission by Sources" sub-tab
Then the ComparativeChart is visible
And the FilterPanel is visible (filter-bu, filter-opu, filter-scope, filter-source dropdowns)
And the EditableDataTable is visible with year column headers
```

### T59.3 — Chart and Filter Tests

```
Given I am on the Emission by Sources sub-tab
When I read the chart title (data-test="chart-title")
Then it contains "Comparative Total GHG Emissions"

When I select "LNGA" from the BU filter
Then the chart title contains "– LNGA"
And the table filters to LNGA rows

When I select "MLNG" from the OPU filter
Then the chart title contains "– MLNG" (OPU takes priority over BU)

When I clear all filters
Then the chart title returns to "Comparative Total GHG Emissions"
```

### T59.4 — Save Draft Integration Test

```
Given I am on /scenario/create/
When I enter "Test Scenario E2E" in the scenario name input
And I click the Save Draft button
Then a POST request is made to /api/v1/scenario/metadata/
And the response status is 200
And a success notification appears
And the Submit button becomes enabled
```

### T59.5 — Cell Edit Integration Test

```
Given the EditableDataTable is showing data
When I click on a year-value cell
Then an input field becomes editable
When I type a new numeric value and press Enter
Then a POST request is made to /api/v1/scenario/emission-sources
And the response status is 200
And the cell displays the new value
```

---

## Task T60 — Visual Regression Screenshot

**File:** NEW `tests/e2e/screenshots/scenario-creation.png`

Capture a full-page screenshot after the page fully loads with data:

1. Log in as admin
2. Navigate to `/scenario/create/`
3. Wait for the Emission by Sources sub-tab to be active
4. Wait for the ComparativeChart canvas to render (non-empty)
5. Wait for the EditableDataTable to show rows
6. Capture full-page screenshot → save to `tests/e2e/screenshots/scenario-creation.png`

This can be a standalone test or a helper script — agent's choice.

---

## Execution Order

```
T59.1 (page load) → T59.2 (navigation) → T59.3 (filters) → T59.4 (save) → T59.5 (cell edit) → T60 (screenshot)
```

---

## Done Criteria

- [ ] `tests/e2e/scenario-creation.spec.ts` exists
- [ ] All 9 ACs are covered by at least one test
- [ ] All tests pass: `npx playwright test scenario-creation.spec.ts`
- [ ] `tests/e2e/screenshots/scenario-creation.png` exists
- [ ] `vault/tasks/todo.md` — T59 and T60 marked `[x] DONE`
- [ ] `vault/active_context.md` updated with test results

---

## Hygiene Rules (Section 6 Compliance)

- NEVER write API keys or passwords into test files — use the `USERNAME`/`PASSWORD` constants pattern from `test_slide1_dashboard.spec.ts`
- Run `npx playwright test` from `tests/e2e/` directory
- Archive any temp files to `_archive/{date}/` — never `rm`
- If a test fails 3 times, STOP and escalate — do not loop

---

## Notes

- The frontend webpack dev server (port 9000) serves the React app with hot-reload. The Flask backend runs on port 8088. API calls use the Superset proxy so both ports work.
- Ant Design Tabs use `ant-tabs-tab-active` class for the active tab. Verify tab switching by checking this class.
- The `EditableCell` component renders as an `<input>` inside a `<td>`. Click the cell, then type the new value.
- `ComparativeChart` renders via `echarts.init()` on a `<div>` — wait for `canvas` element to appear inside the chart container.
- The GET emission-sources endpoint is authenticated (`@has_access_api`) — the Playwright session cookie handles this automatically after login.
