# Technical Spec: Hierarchical Filtering for Scenario Planning Dashboard

**Date:** 2026-03-15
**Status:** Draft - Ready for Implementation
**Priority:** High
**Assignee:** Fullstack Engineer (Gemma)

---

## Ground Truth

| File | Purpose |
|------|---------|
| `superset-frontend/plugins/plugin-chart-scenario/src/types.ts` | TypeScript interfaces for FilterState, EmissionRow, EditKey |
| `superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx` | Filter dropdowns for BU, OPU, Scope, Source |
| `superset-frontend/plugins/plugin-chart-scenario/src/EmissionSourcesTab.tsx` | Tab orchestrator with filters, chart, and data table |
| `superset-frontend/plugins/plugin-chart-scenario/src/useEditBuffer.ts` | Hook for managing edit buffering |
| `superset-frontend/plugins/plugin-chart-scenario/src/ComparativeChart.tsx` | ECharts-based GHG emissions chart |
| `superset-frontend/plugins/plugin-chart-scenario/src/EditableDataTable.tsx` | Pivot table with editable cells |
| `superset/views/scenario_writeback.py` | Backend API endpoints for emission sources |

---

## 1. Problem Statement

### Current Behavior
- When selecting a Business Unit (BU) in the filter panel, the OPU dropdown shows ALL OPUs regardless of their association with that BU
- Same issue applies to OPU->Scope and Scope->Source relationships
- Chart updates slowly when filters change (re-fetches data on every filter change)

### Desired Behavior
- **Hierarchical filtering:** Selecting BU filters OPU options to only those associated with that BU
- **Cascading filters:** Selecting OPU filters Scope options; selecting Scope filters Source options
- **Instant updates:** Chart updates immediately without network re-fetches
- **No API calls on filter changes:** All filtering happens client-side

### Root Cause
The `FilterPanel.tsx` component fetches all emission sources and extracts unique values per field independently:
```typescript
// Current - lines 127-132
setOptions({
  bu: [...new Set(rows.map(r => r.bu))].sort(),
  opu: [...new Set(rows.map(r => r.opu))].sort(),  // ALL OPUs, no BU filter
  scope: [...new Set(rows.map(r => r.scope))].sort(),
  source: [...new Set(rows.map(r => r.source))].sort(),
});
```

---

## 2. Solution Architecture

### Client-Side Data Caching with Hierarchical Mappings

```
┌────────────────────────────────────────────────────────────────────┐
│                    Component Mount                                 │
│  Fetch ALL emission sources (no filter params)                    │
│  Store in: allRows (useMemo)                                      │
└─────────────────────┬──────────────────────────────────────────────┘
                      │
                      ▼
┌────────────────────────────────────────────────────────────────────┐
│                  Data Caching Layer                                │
│  - Full dataset in useMemo (allRows)                              │
│  - BU->OPU mapping computed (buOpusMap)                           │
│  - OPU->Scope mapping computed (opuScopesMap)                     │
│  - Scope->Source mapping computed (scopeSourcesMap)               │
└─────────────────────┬──────────────────────────────────────────────┘
                      │
                      ├─ BU Filter Change ──→ Filter OPUs from buOpusMap
                      │                      Filter Rows from allRows
                      ├─ OPU Filter Change ──→ Filter Scopes from opuScopesMap
                      │                      Filter Rows from allRows
                      ├─ Scope Filter Change ──→ Filter Sources from scopeSourcesMap
                      │                      Filter Rows from allRows
                      │
                      ▼
┌────────────────────────────────────────────────────────────────────┐
│                  Filtered Data                                     │
│  - Filtered dataset (all filters applied)                         │
│  - Filtered chart data computed from filtered rows                │
│  - Filtered options computed from mappings                        │
│  - No API calls needed for filter changes                         │
└────────────────────────────────────────────────────────────────────┘
```

### Data Structures

```typescript
// FilterState (existing in types.ts)
export interface FilterState {
  bu: string[];
  opu: string[];
  scope: string[];
  source: string[];
}

// EmissionRow (existing in types.ts)
export interface EmissionRow {
  bu: string;
  opu: string;
  scope: string;
  source: string;
  year: number;
  value: number;
}

// New: Hierarchical mappings (computed from dataset)
const buOpusMap: Record<string, string[]> = {};  // BU -> [OPUs]
const opuScopesMap: Record<string, string[]> = {};  // OPU -> [Scopes]
const scopeSourcesMap: Record<string, string[]> = {};  // Scope -> [Sources]
```

---

## 3. Implementation Tasks

### Task 1: FilterPanel.tsx - Add Data Caching

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx`
**Lines:** 112-140 (add new state and modify fetchOptions)

```typescript
// Lines 112-132: Current fetchOptions - REPLACE
const fetchOptions = useCallback(async () => {
  setLoading(true);
  try {
    const response = await SupersetClient.get({
      endpoint: `/api/v1/scenario/emission-sources?scenario_id=${encodeURIComponent(scenarioId)}`,
    });
    const rows: EmissionRow[] = (response.json as { data: EmissionRow[] }).data || [];

    // NEW: Store all rows for filtering
    setAllRows(rows);

    const unique = {
      bu: [...new Set(rows.map(r => r.bu))].sort(),
      opu: [...new Set(rows.map(r => r.opu))].sort(),
      scope: [...new Set(rows.map(r => r.scope))].sort(),
      source: [...new Set(rows.map(r => r.source))].sort(),
    };
    setOptions(unique);
  } catch {
    setAllRows([]);
    setOptions({ bu: [], opu: [], scope: [], source: [] });
  } finally {
    setLoading(false);
  }
}, [scenarioId]);
```

**New state to add (after line 111):**
```typescript
const [allRows, setAllRows] = useState<EmissionRow[]>([]);
```

---

### Task 2: FilterPanel.tsx - Compute Hierarchical Mappings

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx`
**Lines:** 134-161 (add after useEffect)

```typescript
// NEW: Compute hierarchical mappings from cached data
const buOpusMap = useMemo(() => {
  const map: Record<string, string[]> = {};
  // Map each BU to its associated OPUs
  allRows.forEach(row => {
    if (!map[row.bu]) {
      map[row.bu] = [];
    }
    if (!map[row.bu].includes(row.opu)) {
      map[row.bu].push(row.opu);
    }
  });
  // Sort OPUs within each BU
  Object.keys(map).forEach(bu => {
    map[bu] = map[bu].sort();
  });
  return map;
}, [allRows]);

const opuScopesMap = useMemo(() => {
  const map: Record<string, string[]> = {};
  allRows.forEach(row => {
    if (!map[row.opu]) {
      map[row.opu] = [];
    }
    if (!map[row.opu].includes(row.scope)) {
      map[row.opu].push(row.scope);
    }
  });
  Object.keys(map).forEach(opu => {
    map[opu] = map[opu].sort();
  });
  return map;
}, [allRows]);

const scopeSourcesMap = useMemo(() => {
  const map: Record<string, string[]> = {};
  allRows.forEach(row => {
    if (!map[row.scope]) {
      map[row.scope] = [];
    }
    if (!map[row.scope].includes(row.source)) {
      map[row.scope].push(row.source);
    }
  });
  Object.keys(map).forEach(scope => {
    map[scope] = map[scope].sort();
  });
  return map;
}, [allRows]);
```

---

### Task 3: FilterPanel.tsx - Filter Options Based on Selections

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx`
**Lines:** 163-190 (add after mappings)

```typescript
// NEW: Get filtered options based on current selections
const getFilteredOptions = useCallback(() => {
  // Step 1: OPUs filtered by selected BUs
  let filteredOPUs = options.opu;
  if (filters.bu.length > 0) {
    const buFilteredOPUs = new Set<string>();
    filters.bu.forEach(bu => {
      if (buOpusMap[bu]) {
        buFilteredOPUs.add(...buOpusMap[bu]);
      }
    });
    filteredOPUs = Array.from(buFilteredOPUs).sort();
  }

  // Step 2: Scopes filtered by selected OPUs
  let filteredScopes = options.scope;
  if (filters.opu.length > 0) {
    const opuFilteredScopes = new Set<string>();
    filters.opu.forEach(opu => {
      if (opuScopesMap[opu]) {
        opuFilteredScopes.add(...opuScopesMap[opu]);
      }
    });
    filteredScopes = Array.from(opuFilteredScopes).sort();
  }

  // Step 3: Sources filtered by selected Scopes
  let filteredSources = options.source;
  if (filters.scope.length > 0) {
    const scopeFilteredSources = new Set<string>();
    filters.scope.forEach(scope => {
      if (scopeSourcesMap[scope]) {
        scopeFilteredSources.add(...scopeSourcesMap[scope]);
      }
    });
    filteredSources = Array.from(scopeFilteredSources).sort();
  }

  return {
    opu: filteredOPUs,
    scope: filteredScopes,
    source: filteredSources
  };
}, [options, filters.bu, filters.opu, filters.scope, buOpusMap, opuScopesMap, scopeSourcesMap]);

const filteredOptions = getFilteredOptions();
```

---

### Task 4: FilterPanel.tsx - Update Select Dropdowns

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx`
**Lines:** 173-207 (update Select options)

```typescript
// Line 173-181: OPU Select - CHANGE options prop
<StyledSelect
  mode="multiple"
  allowClear
  placeholder="Select OPUs"
  value={filters.opu}
  onChange={handle('opu') as (v: unknown) => void}
  data-test="filter-opu"
  options={filteredOptions.opu.map(v => ({ label: v, value: v }))}  // Changed from options.opu
/>

// Line 186-194: Scope Select - CHANGE options prop
<StyledSelect
  mode="multiple"
  allowClear
  placeholder="Select Scopes"
  value={filters.scope}
  onChange={handle('scope') as (v: unknown) => void}
  data-test="filter-scope"
  options={filteredOptions.scope.map(v => ({ label: v, value: v }))}  // Changed from options.scope
/>

// Line 199-207: Source Select - CHANGE options prop
<StyledSelect
  mode="multiple"
  allowClear
  placeholder="Select Sources"
  value={filters.source}
  onChange={handle('source') as (v: unknown) => void}
  data-test="filter-source"
  options={filteredOptions.source.map(v => ({ label: v, value: v }))}  // Changed from options.source
/>
```

---

### Task 5: FilterPanel.tsx - Clear All Handler

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx`
**Lines:** 147-154 (update handleClearAll)

```typescript
const handleClearAll = () => {
  onFilterChange({
    bu: [],
    opu: [],
    scope: [],
    source: [],
  });
};
```

**No change needed** - the clear handler already resets all filters.

---

### Task 6: FilterPanel.tsx - Add Loading State

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx`
**Line 112-140 (add setLoading)**

```typescript
// Inside fetchOptions - add setLoading
const fetchOptions = useCallback(async () => {
  setLoading(true);  // NEW
  try {
    // ... existing logic
  } catch {
    // ...
  } finally {
    setLoading(false);  // NEW
  }
}, [scenarioId]);
```

**Add loading prop to Selects (optional):**
```typescript
<StyledSelect
  mode="multiple"
  allowClear
  placeholder={loading ? "Loading options..." : "Select BUs"}
  value={filters.bu}
  onChange={handle('bu') as (v: unknown) => void}
  data-test="filter-bu"
  loading={loading}  // NEW
  options={options.bu.map(v => ({ label: v, value: v }))}
/>
```

---

### Task 7: EmissionSourcesTab.tsx - Optimize Chart Data Computation

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/EmissionSourcesTab.tsx`
**Lines:** 144-164 (replace scenarioTotals computation)

```typescript
// Lines 144-164: REPLACE the scenarioTotals computation
// NEW: Filter baselineRows based on current filters
const filteredRows = useMemo(() => {
  return baselineRows.filter(row => {
    if (filters.bu.length > 0 && !filters.bu.includes(row.bu)) return false;
    if (filters.opu.length > 0 && !filters.opu.includes(row.opu)) return false;
    if (filters.scope.length > 0 && !filters.scope.includes(row.scope)) return false;
    if (filters.source.length > 0 && !filters.source.includes(row.source)) return false;
    return true;
  });
}, [baselineRows, filters]);

// NEW: Compute totals from filtered rows (not baselineTotals + diffs)
const scenarioTotals = useMemo(() => {
  const totals: Record<number, number> = {};
  filteredRows.forEach(r => {
    totals[r.year] = (totals[r.year] ?? 0) + r.value;
  });
  return totals;
}, [filteredRows]);

// Chart data unchanged - already correctly memoized
const chartBaselineData = useMemo(() =>
  Object.entries(baselineTotals).map(([yr, val]) => ({ year: Number(yr), value: val })).sort((a, b) => a.year - b.year)
, [baselineTotals]);

const chartScenarioData = useMemo(() =>
  Object.entries(scenarioTotals).map(([yr, val]) => ({ year: Number(yr), value: val })).sort((a, b) => a.year - b.year)
, [scenarioTotals]);
```

**Note:** Remove unused `editedValues` dependency from scenarioTotals since we now re-compute from filteredRows directly.

---

### Task 8: EmissionSourcesTab.tsx - Remove Filter-Dependent fetchBaseline

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/EmissionSourcesTab.tsx`
**Lines:** 58-87 (simplify fetchBaseline)

```typescript
// Lines 58-87: MODIFY fetchBaseline to use 'base' scenario_id only
const fetchBaseline = useCallback(async () => {
  setLoading(true);
  try {
    // Simplified: fetch all data once (no filter params)
    // Filter happens client-side in filteredRows useMemo
    const response = await SupersetClient.get({
      endpoint: `/api/v1/scenario/emission-sources?scenario_id=base`,
    });
    const rows = (response.json as { data: EmissionRow[] }).data || [];
    setBaselineRows(rows);

    // Initial totals for chart display
    const totals: Record<number, number> = {};
    rows.forEach(r => {
      totals[r.year] = (totals[r.year] ?? 0) + r.value;
    });
    setBaselineTotals(totals);
  } catch {
    setBaselineRows([]);
    setBaselineTotals({});
  } finally {
    setLoading(false);
  }
}, []);  // Removed filters from dependency array - no reload on filter change
```

**Why:** Data is fetched once on mount, all filtering happens client-side via `filteredRows`.

---

## 4. Data Models and API Contracts

### API Contract (Unchanged)
```
GET /api/v1/scenario/emission-sources?scenario_id={id}&bu={}&opu={}&scope={}&source={}
Response: {
  status: "success",
  data: [
    {
      bu: "string",
      opu: "string",
      scope: "string",
      source: "string",
      year: number,
      value: number
    }
  ],
  count: number
}
```

**Note:** For new implementation, use `scenario_id=base` with no filter params.

### Type Definitions (Existing - No Changes)
```typescript
// From types.ts (existing)
export interface FilterState {
  bu: string[];
  opu: string[];
  scope: string[];
  source: string[];
}

export interface EmissionRow {
  bu: string;
  opu: string;
  scope: string;
  source: string;
  year: number;
  value: number;
}
```

### FilterState Shape
| Field | Type | Description |
|-------|------|-------------|
| bu | `string[]` | Selected Business Units |
| opu | `string[]` | Selected Regions / OPUs |
| scope | `string[]` | Selected Scope categories |
| source | `string[]` | Selected Emission Sources |

---

## 5. Dependency Graph

```
FilterPanel.tsx
├── allRows (fetched on mount)
│   └── buOpusMap (computed from allRows)
│       └── filteredOptions.opu (computed from buOpusMap + filters.bu)
│           └── OPU Select options
│   └── opuScopesMap (computed from allRows)
│       └── filteredOptions.scope (computed from opuScopesMap + filters.opu)
│           └── Scope Select options
│   └── scopeSourcesMap (computed from allRows)
│       └── filteredOptions.source (computed from scopeSourcesMap + filters.scope)
│           └── Source Select options
│
└── filters.bu, filters.opu, filters.scope
    └── filteredOptions (updated when filters change)

EmissionSourcesTab.tsx
├── baselineRows (fetched on mount)
│   └── filteredRows (computed from baselineRows + filters)
│       └── scenarioTotals (computed from filteredRows)
│           └── chartScenarioData
│
└── baselineTotals (fetched on mount)
    └── chartBaselineData
```

---

## 6. Order of Execution

Implement in this exact order to prevent broken builds:

### Phase 1: FilterPanel.tsx Modifications (Lines 1-213)
1. **Line 112:** Add `const [allRows, setAllRows] = useState<EmissionRow[]>([]);`
2. **Lines 113-140:** Update `fetchOptions` to store `allRows` and add `setLoading`
3. **Lines 134-161:** Add `buOpusMap`, `opuScopesMap`, `scopeSourcesMap` computed via `useMemo`
4. **Lines 163-190:** Add `getFilteredOptions` function and `filteredOptions` result
5. **Lines 173-181:** Update OPU Select options to use `filteredOptions.opu`
6. **Lines 186-194:** Update Scope Select options to use `filteredOptions.scope`
7. **Lines 199-207:** Update Source Select options to use `filteredOptions.source`
8. **Lines 147-154:** Verify `handleClearAll` clears all filters

### Phase 2: EmissionSourcesTab.tsx Modifications (Lines 1-191)
9. **Lines 58-87:** Simplify `fetchBaseline` to use `scenario_id=base` only, remove filters from dependency
10. **Lines 144-164:** Replace `scenarioTotals` computation with `filteredRows` and `filteredRows`-based totals

---

## 7. Testing Requirements

### Unit Tests
| Test | Expected Result |
|------|-----------------|
|BU filter filters OPU options| Selecting "LNGA" shows only LNGA-associated OPUs |
|Multiple BU selection| Selecting ["LNGA", "LNGH"] shows OPUs from both BUs |
|OPU filter filters Scope options| Selecting "OP1" shows only OP1-associated Scopes |
|Scope filter filters Source options| Selecting "Scope 1" shows only Scope 1-associated Sources |
|Clear all filters| All dropdowns show all options |
|Empty selection| Shows all options for that level |

### Integration Tests (Playwright)
| Test | Expected Result |
|------|-----------------|
|Chart updates instantly| Filter change completes in <50ms |
|No network calls on filter| SupersetClient.get not called after mount |
|Multiple sequential filters| Each filter updates dropdowns correctly |
|Filter + edit + save| Edits persist correctly with filtered data |

### Manual Testing
1. Select LNGA BU -> OPU shows only LNGA OPUs
2. Select OP1 OPU -> Scope shows only OP1 Scopes
3. Clear BU -> All OPUs reappear
4. Select multiple BUs -> OPUs from all BUs shown
5. Chart updates instantly when any filter changes
6. Clear all -> All filters reset

---

## 8. Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Large dataset memory usage | Medium | Low | Client-side filtering acceptable; add virtualization if needed |
| Initial fetch timeout | Low | Low | Keep error handling; options remain empty on error |
| Data not synced | Low | Medium | Data refreshes on component re-mount |
|deps on allRows causing re-renders | Medium | Low | `useMemo` caching for mappings; filteredOptions only re-runs on filter changes |

---

## 9. Files Modified Summary

| File | Lines Modified | Type of Change |
|------|---------------|----------------|
| `superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx` | 1-213 | Add caching, mappings, filtered options |
| `superset-frontend/plugins/plugin-chart-scenario/src/EmissionSourcesTab.tsx` | 1-191 | Simplify fetchBaseline, optimize scenarioTotals |

---

## 10. Pre-Commit Validation

```bash
# Run pre-commit before committing
cd superset
pre-commit run --all-files

# Check TypeScript types
npx tsc --noEmit

# Check for linting errors (if applicable)
npm run eslint
```

---

## 11. Rollback Plan

If issues occur:
1. Revert `FilterPanel.tsx` and `EmissionSourcesTab.tsx` to previous commit
2. No database changes required (all client-side)
3. No API changes (backward compatible)

**Git rollback:**
```bash
git checkout HEAD -- superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx
git checkout HEAD -- superset-frontend/plugins/plugin-chart-scenario/src/EmissionSourcesTab.tsx
```

---

## 12. Success Criteria

- [ ] Selecting a BU filters OPU dropdown to only show associated OPUs
- [ ] Selecting an OPU filters Scope dropdown to only show associated Scopes
- [ ] Selecting a Scope filters Source dropdown to only show associated Sources
- [ ] Clearing a filter restores appropriate options
- [ ] Chart updates immediately (<50ms) when filters change
- [ ] No network API calls after initial fetch
- [ ] All filters work independently and in combination
- [ ] Edge cases (empty selection, no matches) handled gracefully

---

**End of Technical Spec**
