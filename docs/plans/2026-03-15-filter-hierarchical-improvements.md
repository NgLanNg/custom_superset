# Hierarchical Filtering Improvement Plan

**Date Created:** 2026-03-15
**Status:** Design Complete - Ready for Implementation
**Priority:** High

---

## Executive Summary

This plan documents the implementation of **hierarchical filtering** for the Scenario Planning dashboard's FilterPanel component. Currently, when a user selects a Business Unit (BU), the OPU dropdown shows all OPUs regardless of their association with the selected BU. This causes confusion and makes filtering ineffective.

The solution implements **client-side data caching** for instant filter updates with hierarchical relationship support (BU filters OPUs, which in turn filter Scope and Source).

---

## Current State Analysis

### Problem: Flat Filter Options
```typescript
// Current FilterPanel.tsx (lines 113-132)
const fetchOptions = useCallback(async () => {
  try {
    const response = await SupersetClient.get({
      endpoint: `/api/v1/scenario/emission-sources?scenario_id=${scenarioId}`,
    });
    const rows: EmissionRow[] = (response.json as { data: EmissionRow[] }).data || [];

    setOptions({
      bu: [...new Set(rows.map(r => r.bu))].sort(),
      opu: [...new Set(rows.map(r => r.opu))].sort(), // ALL OPUs, regardless of BU
      scope: [...new Set(rows.map(r => r.scope))].sort(),
      source: [...new Set(rows.map(r => r.source))].sort(),
    });
  } catch {
    // keep empty options on error
  }
}, [scenarioId]);
```

**Root Cause:**
- FilterPanel fetches all emission sources and extracts unique values per field
- No relationship mapping between BU and OPU
- User sees all OPUs even when filtering by specific BUs

---

## Proposed Solution

### Architecture: Client-Side Data Caching with Hierarchical Filtering

```
┌───────────────────────────────────────────────────────────────────┐
│                    Component Mount                                │
│  Fetch ALL emission sources (no params)                          │
└────────────────────┬──────────────────────────────────────────────┘
                     │
                     ▼
┌───────────────────────────────────────────────────────────────────┐
│                  Data Caching Layer                               │
│  - Full dataset in useMemo                                       │
│  - BU->OPU mapping computed                                       │
│  - OPU->Scope mapping computed                                   │
│  - Scope->Source mapping computed                                │
└────────────────────┬──────────────────────────────────────────────┘
                     │
                     ├─ BU Filter Change ──→ Filter OPUs from mapping
                     ├─ OPU Filter Change ──→ Filter Scopes from mapping
                     ├─ Scope Filter Change ──→ Filter Sources from mapping
                     │
                     ▼
┌───────────────────────────────────────────────────────────────────┐
│                  Filtered Data                                    │
│  - Filtered dataset (all filters applied)                        │
│  - Filtered chart data                                           │
│  - No API calls needed for subsequent filter changes             │
└───────────────────────────────────────────────────────────────────┘
```

---

## Implementation Tasks

### Task 1: FilterPanel.tsx - Caching and Hierarchical Filtering

**File:** `plugins/plugin-chart-scenario/src/FilterPanel.tsx`

**Changes:**

```typescript
interface FilterPanelProps {
  filters: FilterState;
  scenarioId: string;
  onFilterChange: (next: FilterState) => void;
}

export function FilterPanel({ filters, scenarioId, onFilterChange }: FilterPanelProps) {
  const [allRows, setAllRows] = useState<EmissionRow[]>([]);
  const [options, setOptions] = useState<{
    bu: string[];
    opu: string[];
    scope: string[];
    source: string[];
  }>({ bu: [], opu: [], scope: [], source: [] });

  // Fetch ALL data once (no filter params)
  const fetchOptions = useCallback(async () => {
    try {
      const response = await SupersetClient.get({
        endpoint: `/api/v1/scenario/emission-sources?scenario_id=${encodeURIComponent(scenarioId)}`,
      });
      const rows: EmissionRow[] = (response.json as { data: EmissionRow[] }).data || [];
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
    }
  }, [scenarioId]);

  useEffect(() => {
    fetchOptions();
  }, [fetchOptions]);

  // Compute hierarchical mappings from cached data
  const buOpusMap = useMemo(() => {
    const map: Record<string, string[]> = {};
    filters.bu.forEach(bu => {
      map[bu] = [...new Set(
        allRows.filter(r => r.bu === bu).map(r => r.opu)
      )].sort();
    });
    return map;
  }, [allRows, filters.bu]);

  const opuScopesMap = useMemo(() => {
    const map: Record<string, string[]> = {};
    filters.opu.forEach(opu => {
      map[opu] = [...new Set(
        allRows.filter(r => r.opu === opu).map(r => r.scope)
      )].sort();
    });
    return map;
  }, [allRows, filters.opu]);

  const scopeSourcesMap = useMemo(() => {
    const map: Record<string, string[]> = {};
    filters.scope.forEach(scope => {
      map[scope] = [...new Set(
        allRows.filter(r => r.scope === scope).map(r => r.source)
      )].sort();
    });
    return map;
  }, [allRows, filters.scope]);

  // Get filtered options based on current selections
  const getFilteredOptions = useCallback(() => {
    // OPUs filtered by selected BUs
    let filteredOPUs = options.opu;
    if (filters.bu.length > 0) {
      filteredOPUs = [...new Set(
        filters.bu.flatMap(bu => buOpusMap[bu] || [])
      )].sort();
    }

    // Scopes filtered by selected OPUs
    let filteredScopes = options.scope;
    if (filters.opu.length > 0) {
      filteredScopes = [...new Set(
        filters.opu.flatMap(opu => opuScopesMap[opu] || [])
      )].sort();
    }

    // Sources filtered by selected Scopes
    let filteredSources = options.source;
    if (filters.scope.length > 0) {
      filteredSources = [...new Set(
        filters.scope.flatMap(scope => scopeSourcesMap[scope] || [])
      )].sort();
    }

    return { opu: filteredOPUs, scope: filteredScopes, source: filteredSources };
  }, [options, filters.bu, filters.opu, filters.scope, buOpusMap, opuScopesMap, scopeSourcesMap]);

  const filteredOptions = getFilteredOptions();

  const handle = (key: keyof FilterState) => (values: string[]) => {
    onFilterChange({ ...filters, [key]: values });
  };

  // ... rest of component uses filteredOptions
}
```

---

### Task 2: FilterPanel.tsx - Update Options in Select

**File:** `plugins/plugin-chart-scenario/src/FilterPanel.tsx` (lines 156-212)

```typescript
return (
  <PanelWrapper>
    <FilterField>
      <FilterLabel>Business Unit</FilterLabel>
      <StyledSelect
        mode="multiple"
        allowClear
        placeholder="Select BUs"
        value={filters.bu}
        onChange={handle('bu') as (v: unknown) => void}
        data-test="filter-bu"
        options={options.bu.map(v => ({ label: v, value: v }))}
      />
    </FilterField>

    <FilterField>
      <FilterLabel>Region / OPU</FilterLabel>
      <StyledSelect
        mode="multiple"
        allowClear
        placeholder="Select OPUs"
        value={filters.opu}
        onChange={handle('opu') as (v: unknown) => void}
        data-test="filter-opu"
        options={filteredOptions.opu.map(v => ({ label: v, value: v }))}
      />
    </FilterField>

    <FilterField>
      <FilterLabel>Scope</FilterLabel>
      <StyledSelect
        mode="multiple"
        allowClear
        placeholder="Select Scopes"
        value={filters.scope}
        onChange={handle('scope') as (v: unknown) => void}
        data-test="filter-scope"
        options={filteredOptions.scope.map(v => ({ label: v, value: v }))}
      />
    </FilterField>

    <FilterField>
      <FilterLabel>Emission Source</FilterLabel>
      <StyledSelect
        mode="multiple"
        allowClear
        placeholder="Select Sources"
        value={filters.source}
        onChange={handle('source') as (v: unknown) => void}
        data-test="filter-source"
        options={filteredOptions.source.map(v => ({ label: v, value: v }))}
      />
    </FilterField>

    <ClearButton onClick={handleClearAll}>{t('Clear all')}</ClearButton>
  </PanelWrapper>
);
```

---

### Task 3: EmissionSourcesTab.tsx - Chart Optimization

**File:** `plugins/plugin-chart-scenario/src/EmissionSourcesTab.tsx`

**Changes:** Computing chart data from already-filtered rows instead of re-aggregating:

```typescript
// After filtering rows, compute totals directly
const filteredRows = useMemo(() => {
  return baselineRows.filter(row => {
    if (filters.bu.length > 0 && !filters.bu.includes(row.bu)) return false;
    if (filters.opu.length > 0 && !filters.opu.includes(row.opu)) return false;
    if (filters.scope.length > 0 && !filters.scope.includes(row.scope)) return false;
    if (filters.source.length > 0 && !filters.source.includes(row.source)) return false;
    return true;
  });
}, [baselineRows, filters]);

// Compute totals from filtered rows
const scenarioTotals = useMemo(() => {
  const totals: Record<string, number> = {};
  filteredRows.forEach(r => {
    totals[r.year] = (totals[r.year] ?? 0) + r.value;
  });
  return totals;
}, [filteredRows]);

// Transform to chart data
const chartScenarioData = useMemo(() =>
  Object.entries(scenarioTotals).map(([yr, val]) => ({ year: Number(yr), value: val })).sort((a, b) => a.year - b.year)
, [scenarioTotals]);
```

---

## Design Details

### Hierarchical Relationship Mapping

| Parent | Child | Mapping Source |
|--------|-------|---------------|
| BU | OPU | `rows.filter(r => r.bu === selectedBU).map(r => r.opu)` |
| OPU | Scope | `rows.filter(r => r.opu === selectedOPU).map(r => r.scope)` |
| Scope | Source | `rows.filter(r => r.scope === selectedScope).map(r => r.source)` |

### Performance Characteristics

| Operation | Current | Optimized |
|-----------|---------|-----------|
| Initial Load | 1 API call | 1 API call |
| Filter Change (BU) | 0 API calls, but wrong data | 0 API calls, correct data |
| Filter Change (OPU) | 0 API calls, but wrong data | 0 API calls, correct data |
| Memory Usage | Small (filtered rows) | Medium (all rows + mappings) |
| Filter Responsiveness | Instant, but incorrect | Instant, correct |

---

## Acceptance Criteria

### Hierarchical Filtering
- [ ] Selecting a BU filters OPU dropdown to only show OPUs associated with that BU
- [ ] Selecting an OPU filters Scope dropdown to only show Scopes for that OPU
- [ ] Selecting a Scope filters Source dropdown to only show Sources for that Scope
- [ ] Clearing a filter restores the appropriate options
- [ ] All filters work independently and in combination

### Performance
- [ ] Chart updates immediately when filters change (no network delay)
- [ ] No new API calls on filter changes
- [ ] Filter selection is instant (< 50ms)
- [ ] Initial load acceptable (< 2 seconds for 1000+ rows)

### Edge Cases
- [ ] Empty selections show all options
- [ ] No matching data shows empty state
- [ ] Filter selection persists when data reloads

---

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Large dataset memory usage | Medium | Low | Add virtualization if needed; client-side filtering is still better than multiple API calls |
| Initial fetch timeout | Low | Low | Keep current error handling; options remain empty on error |
| Data not synced | Low | Medium | Add refresh button; data refreshes on re-mount |

---

## Testing Strategy

### Manual Testing Checklist
- [ ] Select LNGA BU → OPU shows only LNGA-associated OPUs
- [ ] Select OP1 OPU → Scope shows only OP1-associated Scopes
- [ ] Select "Scope 1" → Source shows only Scope 1-associated Sources
- [ ] Clear BU → All OPUs reappear
- [ ] Select multiple BUs → OPUs from all selected BUs shown
- [ ] Chart updates instantly when any filter changes

---

## Files Summary

| File | Action | Scope |
|------|--------|-------|
| `FilterPanel.tsx` | Modify | Caching, hierarchical mappings, filtered options |
| `EmissionSourcesTab.tsx` | Modify | Chart data computed from filtered rows |

---

## Implementation Order

1. **FilterPanel.tsx** - Add caching and hierarchical filtering
2. **EmissionSourcesTab.tsx** - Optimize chart data computation

---

## Notes

- **Do NOT use rm** - Archive any removed code to `_archive/`
- **Preserve data-test attributes** for E2E compatibility
- **Run pre-commit** before committing: `pre-commit run --all-files`
- Initial data fetch will return more data, but this is acceptable for the improved UX
- Charts update instantly because they use `useMemo` with filtered datasets
