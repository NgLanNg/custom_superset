---
type: todo
date: 2026-03-16
author: Fullstack Engineer
project: Writeback UI Testing - Hierarchical Filter Integration
---

# Writeback UI Testing Plan - Hierarchical Filter Integration

## Ground Truth

- **Test Framework:** Playwright (already in use for scenario tests)
- **Test Location:** `superset-frontend/playwright/tests/writeback-hierarchical.spec.ts`
- **Data Source:** `silver_emission_by_sources` table
- **API Endpoints:**
  - GET `/api/v1/scenario/emission-sources?scenario_id=base` - fetch data
  - POST `/api/v1/scenario/emission-sources/batch` - batch writeback

---

## Test Scenarios

### T1 - Create Scenario with Hierarchical Filters

**Purpose:** Verify Create Scenario feature works with hierarchical filtering

**Steps:**
1. Navigate to Scenario Planning dashboard
2. Click "OPU Configuration" tab
3. Click "Emission by Sources" sub-tab
4. Fill scenario name input with unique test name
5. Verify filter panels display correctly
6. Verify OPU dropdown shows filtered options based on selected BU

**Acceptance:**
- Scenario name can be entered
- Filter controls visible and functional
- Hierarchical relationship reflected in dropdowns

---

### T2 - Edit Cell with Hierarchical Filter

**Purpose:** Verify cell edit with active filters

**Steps:**
1. Click on an editable cell in the data table
2. Fill with new numeric value
3. Blur to trigger edit state
4. Verify cell shows orange highlight (edited state)
5. Verify chart updates to show scenario data series

**Acceptance:**
- Cell enters edit mode
- Orange highlight appears
- Chart shows scenario series

---

### T3 - Save Draft with Buffer Flush

**Purpose:** Verify Save Draft triggers in-memory buffer flush

**Steps:**
1. Click Save Draft button
2. Verify API call to `/api/v1/scenario/emission-sources/batch`
3. Verify batch endpoint receives edits array
4. Verify success toast appears
5. Verify orange highlight clears after save

**Acceptance:**
- Batch POST request made
- Response status 200
- Toast shows success
- UI returns to read-only state

---

### T4 - Verify DB Persistence

**Purpose:** Verify data persisted to `silver_emission_by_sources`

**Steps:**
1. Query the database directly or via GET endpoint
2. Verify new/updated values exist in table
3. Verify record has correct scenario_id
4. Verify record has correct BU/OPU/Scope/Source

**Acceptance:**
- Data exists in silver_emission_by_sources
- Values match what was edited
- Metadata fields populated correctly

---

### T5 - Hierarchical Filter Propagation

**Purpose:** Verify selecting BU filters OPU dropdown

**Steps:**
1. Select a BU from Business Unit filter
2. Verify OPU dropdown shows only OPUs associated with that BU
3. Select an OPU from filtered list
4. Verify Scope dropdown shows only Scopes for that OPU
5. Select a Scope
6. Verify Source dropdown shows only Sources for that Scope

**Acceptance:**
- BU selection filters OPU list
- OPU selection filters Scope list
- Scope selection filters Source list

---

## Test Implementation

### New Test File: `writeback-hierarchical.spec.ts`

```typescript
test.describe('Writeback: Hierarchical Filter + Save Draft Integration', () => {
  test('should create scenario, edit cell with filters, and save to DB', async ({ page }) => {
    // Navigate and load
    await loadScenarioPage(page);
    await clickEmissionSourcesTab(page);

    // Set up filter: select BU
    await selectFilterOption(page, 'filter-bu', 'LNGA');

    // Verify OPU filters
    const opuOptions = page.locator('[data-test="filter-opu"] .ant-select-item');
    await expect(opuOptions).toBeVisible();
    // Verify only LNGA-associated OPUs present

    // Edit a cell
    const editableInput = page.locator('tbody tr input').first();
    await editableInput.fill('100');
    await editableInput.blur();

    // Save Draft
    await page.locator('[data-test="scenario-name-input"]').fill('Test E2E Loop');
    await page.locator('[data-test="save-draft-btn"]').click();

    // Verify API call to batch endpoint
    const response = await page.waitForResponse(
      (resp) => resp.url().includes('/api/v1/scenario/emission-sources/batch')
    );
    expect(response.status()).toBe(200);

    // Verify toast
    await expect(page.locator('[data-test="toast-container"]')).toBeVisible();

    // Verify DB persistence (optional: direct query)
  });
});
```

---

## Implementation Tasks

| Task | File | Lines | Effort |
|------|------|-------|--------|
| T1 | writeback-hierarchical.spec.ts | 1-50 | 30 min |
| T2 | writeback-helper.ts (new) | 1-80 | 20 min |
| T3 | Update playwright config | - | 10 min |

---

## Assumptions

1. Database already seeded with emission sources data
2. Authentication handled via stored storageState
3. Scenario Planning dashboard already created
4. `silver_emission_by_sources` table has test data

---

## Rollback Plan

If tests fail due to environment issues:
1. Re-run global-setup: `npx playwright test --global-setup`
2. Verify DB has required tables
3. Check user has correct permissions
