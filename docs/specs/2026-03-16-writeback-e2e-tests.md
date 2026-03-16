---
type: spec
date: 2026-03-16
author: Fullstack Engineer
project: Writeback E2E Tests
status: draft
---

# Technical Spec: Writeback E2E Tests

## Executive Summary

Create Playwright E2E tests for the Scenario Planning Dashboard's writeback functionality. Tests will verify the complete user workflow: create scenario, edit cell values, save to database with hierarchical filtering integration.

**Scope:** E2E testing only (Playwright)
**Target:** `superset-frontend/plugins/plugin-chart-scenario/`
**Database:** `silver_emission_by_sources`

---

## Ground Truth

### Current State

| Component | Location | Status |
|-----------|----------|--------|
| Test file | `playwright/tests/writeback-hierarchical.spec.ts` | Created |
| Backend API | `superset/superset/views/scenario_writeback.py` | Complete |
| Edit buffer hook | `plugin-chart-scenario/src/useEditBuffer.ts` | Complete |
| EmissionSourcesTab | `plugin-chart-scenario/src/EmissionSourcesTab.tsx` | Complete |
| FilterPanel | `plugin-chart-scenario/src/FilterPanel.tsx` | Complete |

### Key Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/scenario/emission-sources?scenario_id=base` | Fetch baseline data |
| POST | `/api/v1/scenario/emission-sources/batch` | Batch writeback edits |
| GET | `/api/v1/scenario/emission-sources?scenario_id=...` | Fetch scenario data |

### Database Table

**Table:** `silver_emission_by_sources`

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| bu | VARCHAR | Business Unit |
| opu | VARCHAR | Operational Unit |
| scope | VARCHAR | Emissions Scope |
| source | VARCHAR | Emission Source |
| year | INTEGER | Year |
| value | DECIMAL | Emission value |
| type | VARCHAR | Type (e.g., "operational_control") |
| scenario_id | VARCHAR | Scenario identifier |
| user_email | VARCHAR | User who made edit |
| updated_at | TIMESTAMP | Last update timestamp |

---

## Test Coverage breadth

### In Scope

| Test | Scope |
|------|-------|
| T1 | E2E Writeback Flow: Filter chain + Edit cell + Save Draft + Batch endpoint verification |
| T2 | Filter Clear Verification: Clear BU filter and verify OPU dropdown expands |
| T3 | Multiple Filter Combinations: Test BU/OPU/Scope chaining with multiple selections |
| T4 | Hierarchical Filter Dependencies: BU->OPU->Scope->Source cascading |
| T5 | Batch Edit Performance: Verify single POST for multiple edits |
| T6 | Database Persistence: Verify data in `silver_emission_by_sources` |
| T7 | Toggle Switch Verified: If Emission Sources toggle works |

### Out of Scope

| Item | Reason |
|------|--------|
| Unit tests | Covered by Jest in frontend |
| Component tests | Covered by React Testing Library |
| Backend unit tests | Covered by pytest |
| Performance benchmarks | Not in scope |
| Security testing | Not in scope |

---

## Success Criteria

1. **Writeback Flow:** All 3 test scenarios pass with valid API responses and database persistence
2. **Batch Endpoint:** Single POST request with array of edits (not N individual requests)
3. **Hierarchical Filtering:** OPU dropdown properly filters based on BU selection
4. **UI Feedback:** Orange highlight appears on edit, clears after save
5. **Database:** Data persisted to `silver_emission_by_sources` with correct scenario_id

---

## Test Scenarios

### T1.1: End-to-End Writeback with Hierarchical Filters

**Purpose:** Verify complete workflow from filter application to database persistence

**Steps:**

1. Navigate to `/explore/?slice_id=2`
2. Handle login redirect (if needed)
3. Wait for chart container visibility
4. Click "Operational Data" tab
5. Click "Emission by Sources" sub-tab
6. Verify filter panel visibility
7. Select BU: `LNGA`
8. Verify OPU dropdown shows only LNGA-associated OPUs
9. Select first OPU from filtered list
10. Verify Scope dropdown shows only Scopes for selected OPU
11. Select Scope from filtered list
12. Find first editable input in table body
13. Capture original value
14. Fill input with new value (e.g., "100")
15. Blur input
16. Verify orange highlight (CSS: `rgb(255, 247, 230)`)
17. Fill scenario name input: `WritebackIntegrationTest_<timestamp>`
18. Wait for batch endpoint POST response
19. Click Save Draft button
20. Verify batch endpoint responds with 200
21. Verify response contains `"status": "success"` and `"Processed N edits"`
22. Verify success toast visibility
23. Verify orange highlight clears after save
24. Verify scenario name persists

**API Contract Verification:**

```json
// Request
POST /api/v1/scenario/emission-sources/batch
Content-Type: application/json
{
  "edits": [
    {
      "bu": "LNGA",
      "opu": "OPU001",
      "scope": "Scope1",
      "source": "SourceA",
      "year": 2024,
      "value": 100,
      "type": "operational_control",
      "scenario_id": "WritebackIntegrationTest_1234567890"
    }
  ]
}

// Response
{
  "status": "success",
  "message": "Processed 1 edits"
}
```

---

### T1.2: Filter Clear Verification

**Purpose:** Verify hierarchical filter clearing behavior

**Steps:**

1. Navigate to `/explore/?slice_id=2`
2. Wait for chart load
3. Load Emission by Sources tab
4. Select BU: `LNGA`
5. Click OPU dropdown input
6. Count visible OPU options (filtered count)
7. Verify count > 0
8. Click clear button on BU filter
9. Wait 500ms for filter reset
10. Click OPU dropdown input again
11. Count visible OPU options (unfiltered count)
12. Verify unfiltered count >= filtered count

---

### T1.3: Multiple Filter Combinations

**Purpose:** Verify Edit with Multiple Hierarchical Filters Active

**Steps:**

1. Navigate to `/explore/?slice_id=2`
2. Wait for chart load
3. Load Emission by Sources tab
4. Select BU: `LNGA`
5. Click OPU dropdown and select first option
6. Click Scope dropdown and select first option
7. Verify chart legend shows scenario series
8. Edit a cell value
9. Verify orange highlight appears
10. Set scenario name
11. Click Save Draft
12. Verify batch endpoint receives correct payload

---

### T2.1: Batch Edit Performance

**Purpose:** Verify multiple edits are batched into single API call

**Steps:**

1. Navigate to `/explore/?slice_id=2`
2. Load Emission by Sources tab
3. Select a BU to filter data
4. Edit 5 different cells within 500ms (rapid edits)
5. Verify only 1 POST to `/api/v1/scenario/emission-sources/batch` occurs
6. Click Save Draft
7. Verify batch response shows `Processed 5 edits`

**Verify:** API call count = 1 (not 5)

---

### T3.1: Database Persistence Verification

**Purpose:** Verify data persists to `silver_emission_by_sources`

**Steps:**

1. Complete T1.1 test successfully
2. Query database directly or via GET endpoint
3. Verify record exists in `silver_emission_by_sources` with:
   - `scenario_id = WritebackIntegrationTest_<timestamp>`
   - `bu = LNGA`
   - `value = 100` (edited value)
4. Verify metadata fields:
   - `user_email` populated
   - `updated_at` timestamp recent
   - `type = operational_control`

**Query:**

```sql
SELECT bu, opu, scope, source, year, value, scenario_id, user_email, updated_at
FROM silver_emission_by_sources
WHERE scenario_id = 'WritebackIntegrationTest_<timestamp>'
ORDER BY updated_at DESC
LIMIT 1;
```

---

## Helper Functions

### Common Helpers (reuse from `scenario.spec.ts`)

```typescript
// From scenario.spec.ts
async function loadScenarioPage(page: Page, sliceId: number = 2): Promise<void>
async function editCellAndRevert({ page, tableSelector, rowText, ... }): Promise<void>
```

### New Helpers (writeback-hierarchical.spec.ts)

```typescript
// Helper: Select filter option from Ant Design Select
async function selectFilterOption(
  page: Page,
  filterId: string,
  optionValue: string
): Promise<void>

// Helper: Edit cell and verify orange highlight
async function editCell(
  page: Page,
  newValue: string
): Promise<string>

// Helper: Set scenario name
async function setScenarioName(page: Page, name: string): Promise<void>

// Helper: Load Emission Sources tab
async function loadEmissionSourcesTab(page: Page): Promise<void>
```

---

## API Contracts

### Batch Writeback Request

**Endpoint:** `POST /api/v1/scenario/emission-sources/batch`

**Headers:**
- `Content-Type: application/json`
- `Cookie: session=...` (via storageState)

**Request Body:**

```json
{
  "edits": [
    {
      "bu": "LNGA",
      "opu": "OPU001",
      "scope": "Scope1",
      "source": "SourceA",
      "year": 2024,
      "value": 100,
      "type": "operational_control",
      "scenario_id": "WritebackIntegrationTest_1234567890"
    }
  ]
}
```

**Response (200):**

```json
{
  "status": "success",
  "message": "Processed 1 edits"
}
```

**Response (400 - validation error):**

```json
{
  "status": "error",
  "message": "No edits provided"
}
```

**Response (500 - server error):**

```json
{
  "status": "error",
  "message": "An internal error occurred."
}
```

---

## Test Configuration

### Environment Variables

```bash
PLAYWRIGHT_ADMIN_USERNAME=admin
PLAYWRIGHT_ADMIN_PASSWORD=admin
PLAYWRIGHT_BASE_URL=http://localhost:8088
```

### Storage State

```bash
playwright/.auth/user.json  # Session cookie persistence
```

### Timeout Constants

```typescript
export const TIMEOUT = {
  PAGE_LOAD: 10000,      // 10s for page transitions
  API_RESPONSE: 15000,   // 15s for API responses
  FORM_LOAD: 5000,       // 5s for forms to become visible
};
```

---

## Pre-requisites

### Environment Setup

1. **Superset Running:**
   ```bash
   flask run --host=0.0.0.0 --port=8088
   ```

2. **Database Seeded:**
   ```bash
   # silver_emission_by_sources table must exist
   # Base scenario data must be populated
   ```

3. **Authentication:**
   ```bash
   # Run global-setup to create storage state
   npx playwright test --global-setup
   ```

### Database Tables

```sql
-- silver_emission_by_sources
CREATE TABLE silver_emission_by_sources (
    id UUID PRIMARY KEY,
    bu VARCHAR(128),
    opu VARCHAR(128),
    scope VARCHAR(128),
    source VARCHAR(128),
    year INT,
    value DECIMAL,
    type VARCHAR(64),
    scenario_id VARCHAR(128),
    user_email VARCHAR(128),
    updated_at TIMESTAMP
);

-- Index for hierarchical filtering
CREATE INDEX idx_emission_hierarchy ON silver_emission_by_sources (bu, opu, scope, source);
CREATE INDEX idx_emission_scenario ON silver_emission_by_sources (scenario_id);
```

---

## Running Tests

### Execute Single Test File

```bash
cd superset
npx playwright test playwright/tests/writeback-hierarchical.spec.ts
```

### Execute with UI Mode

```bash
npx playwright test playwright/tests/writeback-hierarchical.spec.ts --ui
```

### Execute with Debug

```bash
npx playwright test playwright/tests/writeback-hierarchical.spec.ts --debug
```

### Run All Playwright Tests

```bash
npm run playwright:test
```

---

## Expected Test Results

### Pass Criteria

| Test | Pass Condition |
|------|----------------|
| T1.1 | All 24 steps complete, batch endpoint returns 200, DB has record |
| T1.2 | Unfiltered OPU count >= filtered count |
| T1.3 | Edit visible, scenario created, batch endpoint called |
| T2.1 | Only 1 POST to batch endpoint for 5 rapid edits |
| T3.1 | Record exists in silver_emission_by_sources with correct data |

### Failure Modes

| Failure | Action |
|---------|--------|
| Login redirect | Verify storage state valid |
| Chart not loading | Verify slice_id=2 exists |
| Filter panel invisible | Verify Emission Sources tab active |
| Batch endpoint 400 | Verify edits array format |
| Batch endpoint 500 | Check server logs |
| DB record missing | Verify transaction committed |

---

## Maintenance

### Adding New Tests

1. Create new test case in `writeback-hierarchical.spec.ts`
2. Use existing helper functions
3. Follow same naming convention: `should <action> when <condition>`
4. Verify storage state is preserved

### Updating API Contracts

1. Update spec if backend changes endpoint response
2. Update test expectations accordingly
3. Verify pre-commit hooks pass

### Test Data Changes

If emission sources test data changes:

1. Update BU values in tests (currently assumes `LNGA` exists)
2. Update expected filter counts
3. Verify hierarchical relationships in DB

---

## Related Documents

| Document | Location | Purpose |
|----------|----------|---------|
| Implementation Brief | `docs/implementation_briefs/2026-03-15-hierarchical-filter-implementation.md` | Filter implementation details |
| Task Tracker | `vault/tasks/todo_scenario-improvements-2026-03-15.md` | Progress tracking |
| Design Doc | `docs/plans/2026-03-16-writeback-hierarchical-tests.md` | Non-technical design |

---

## Rollback Plan

If tests fail due to environment issues:

1. **Re-run global-setup:**
   ```bash
   npx playwright test --global-setup
   ```

2. **Verify database tables:**
   ```sql
   SELECT COUNT(*) FROM silver_emission_by_sources;
   ```

3. **Check user permissions:**
   ```bash
   # Verify admin user has "Scenario" permissions with write access
   ```

4. **Restart Superset server:**
   ```bash
   #killall -9 python
   flask run --host=0.0.0.0 --port=8088
   ```

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Test execution time | < 60 seconds total |
| Pass rate | 100% (when env is ready) |
| Flakiness | < 1% (no race conditions) |
| API calls per batch edit | 1 (not N) |
| Chart re-render delay | < 100ms |

---

**End of Spec**
