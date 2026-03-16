# Implementation Brief: Hierarchical Filtering for Scenario Planning Dashboard

**Project:** Superset Scenario Planning Dashboard
**Feature:** Hierarchical Filtering Improvement
**Date:** 2026-03-15
**Spec:** `docs/specs/2026-03-15-filter-hierarchical-improvements.md`
**Design:** `docs/plans/2026-03-15-filter-hierarchical-improvements.md`

---

## Executive Summary

Implement hierarchical filtering in the Scenario Planning dashboard so that selecting a Business Unit (BU) filters the OPU dropdown to only show OPUs associated with that BU, similarly for OPU->Scope and Scope->Source relationships. All filtering happens client-side with no API calls after initial data fetch.

---

## Context of Truth

### Project Structure
- **Platform:** Superset (Flask backend + React frontend)
- **Plugin:** `superset/superset-frontend/plugins/plugin-chart-scenario/`
- **_API Backend:** `superset/superset/views/scenario_writeback.py`

### Files to Modify (in order)
1. `superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx` (Lines 1-213)
2. `superset-frontend/plugins/plugin-chart-scenario/src/EmissionSourcesTab.tsx` (Lines 1-191)

---

## Problem Statement

**Current Behavior:**
- FilterPanel.tsx fetches all emission sources and extracts unique values per field independently
- When selecting a BU, the OPU dropdown shows ALL OPUs regardless of their association
- Chart re-fetches data on every filter change

**Desired Behavior:**
- Hierarchical filtering: BU filters OPUs, OPU filters Scopes, Scope filters Sources
- Client-side data caching for instant filter updates
- No API calls on filter changes

---

## Implementation Requirements

### Phase 1: FilterPanel.tsx Modifications

#### Step 1.1: Add Data Caching State (Line 112)
Add state to store all rows fetched from the API:
```typescript
const [allRows, setAllRows] = useState<EmissionRow[]>([]);
```

#### Step 1.2: Update fetchOptions (Lines 113-149)
Modify the fetchOptions callback to:
1. Store `allRows` from the response
2. Set `setLoading(true)` at start and `setLoading(false)` in finally block

Current code ends at line 136 with `}, [scenarioId]);` - replace with:
```typescript
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

#### Step 1.3: Add Hierarchical Mappings (Lines 150-198)
After the useEffect, add these three useMemo hooks:
```typescript
// Compute hierarchical mappings from cached data
const buOpusMap = useMemo(() => {
  const map: Record<string, string[]> = {};
  allRows.forEach(row => {
    if (!map[row.bu]) {
      map[row.bu] = [];
    }
    if (!map[row.bu].includes(row.opu)) {
      map[row.bu].push(row.opu);
    }
  });
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

#### Step 1.4: Add Filtered Options Logic (Lines 199-230)
After the mappings, add:
```typescript
// Get filtered options based on current selections
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

#### Step 1.5: Update Select Dropdowns (Lines 248-275)
Change the `options` prop on three Select components:
- **Line 248-255 (OPU Select):** Change `options={options.opu.map(...)` to `options={filteredOptions.opu.map(...)`
- **Line 262-269 (Scope Select):** Change `options={options.scope.map(...)` to `options={filteredOptions.scope.map(...)`
- **Line 276-283 (Source Select):** Change `options={options.source.map(...)` to `options={filteredOptions.source.map(...)`

#### Step 1.6: Verify handleClearAll (Lines 147-154)
No changes needed - existing clear handler already resets all filters.

---

### Phase 2: EmissionSourcesTab.tsx Modifications

#### Step 2.1: Simplify fetchBaseline (Lines 60-91)
change `fetchBaseline` to use `scenario_id=base` and remove `filters` from dependency:

```typescript
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
}, []);  // Removed filters from dependency array
```

#### Step 2.2: Add filteredRows and Optimize scenarioTotals (Lines 144-170)
Replace the existing scenarioTotals computation:

```typescript
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

// NEW: Compute totals from filtered rows
const scenarioTotals = useMemo(() => {
  const totals: Record<number, number> = {};
  filteredRows.forEach(r => {
    totals[r.year] = (totals[r.year] ?? 0) + r.value;
  });
  return totals;
}, [filteredRows]);

// Chart data - unchanged
const chartBaselineData = useMemo(() =>
  Object.entries(baselineTotals).map(([yr, val]) => ({ year: Number(yr), value: val })).sort((a, b) => a.year - b.year)
, [baselineTotals]);

const chartScenarioData = useMemo(() =>
  Object.entries(scenarioTotals).map(([yr, val]) => ({ year: Number(yr), value: val })).sort((a, b) => a.year - b.year)
, [scenarioTotals]);
```

---

## Data Models

### FilterState (existing - no changes)
```typescript
export interface FilterState {
  bu: string[];
  opu: string[];
  scope: string[];
  source: string[];
}
```

### EmissionRow (existing - no changes)
```typescript
export interface EmissionRow {
  bu: string;
  opu: string;
  scope: string;
  source: string;
  year: number;
  value: number;
}
```

---

## Dependency Chain

```
FilterPanel.tsx
├── allRows (fetched on mount, useEffect)
│   └── buOpusMap (useMemo, depends on allRows)
│       └── getFilteredOptions (useCallback, depends on filters.bu + buOpusMap)
│           └── filteredOptions.opu (Select options)
│   └── opuScopesMap (useMemo, depends on allRows)
│       └── getFilteredOptions (depends on filters.opu + opuScopesMap)
│           └── filteredOptions.scope (Select options)
│   └── scopeSourcesMap (useMemo, depends on allRows)
│       └── getFilteredOptions (depends on filters.scope + scopeSourcesMap)
│           └── filteredOptions.source (Select options)

EmissionSourcesTab.tsx
├── baselineRows (fetched on mount, useEffect)
│   └── filteredRows (useMemo, depends on baselineRows + filters)
│       └── scenarioTotals (useMemo, depends on filteredRows)
│           └── chartScenarioData (Select options)
```

---

## Order of Execution

**WARNING: Execute in this exact order to prevent broken builds**

### FilterPanel.tsx (Lines 1-213)
1. Add `const [allRows, setAllRows] = useState<EmissionRow[]>([]);` after line 111
2. Update `fetchOptions` callback (lines 113-149) to store allRows and setLoading
3. Add `buOpusMap`, `opuScopesMap`, `scopeSourcesMap` (lines 150-198)
4. Add `getFilteredOptions` and `filteredOptions` (lines 199-230)
5. Update OPU Select options (line 248)
6. Update Scope Select options (line 262)
7. Update Source Select options (line 276)

### EmissionSourcesTab.tsx (Lines 1-191)
8. Simplify `fetchBaseline` (lines 60-91) to use `scenario_id=base`, remove filters from deps
9. Replace `scenarioTotals` with `filteredRows` and filtered-based computation (lines 144-170)

---

## Prevention of Common Issues

| Issue | Prevention |
|-------|------------|
| TypeScript errors on useMemo | Ensure allRows is EmissionRow[] (use type assertion from API response) |
| Filter not working | Verify filteredOptions uses .sort() to maintain consistent ordering |
| Circular dependencies | filteredOptions depends on filters, not the reverse |
| Empty selection | handleClearAll already resets to empty arrays |

---

## Pre-Commit Validation

```bash
cd superset
git add .
pre-commit run --all-files
npx tsc --noEmit
```

---

## Testing Checklist

- [ ] OPU dropdown filters when BU is selected
- [ ] Scope dropdown filters when OPU is selected
- [ ] Source dropdown filters when Scope is selected
- [ ] Clearing BU affects OPU, Scope, Source dropdowns
- [ ] Chart updates instantly (<50ms) when filtering
- [ ] No network calls after initial fetch
- [ ] Clear all button resets all filters

---

## Rollback Plan

If issues occur:
```bash
git checkout HEAD -- superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx
git checkout HEAD -- superset-frontend/plugins/plugin-chart-scenario/src/EmissionSourcesTab.tsx
```

---

## Success Criteria

- [ ] Hierarchical filtering works (BU->OPU->Scope->Source)
- [ ] Chart updates immediately without network calls
- [ ] All filters work independently and in combination
- [ ] Edge cases handled (empty selection, no matches)
- [ ] Pre-commit hooks pass
- [ ] TypeScript compiles without errors

---

**End of Implementation Brief**
