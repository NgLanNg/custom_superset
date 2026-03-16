# Scenario Planning UX Improvements Plan

**Date Created:** 2026-03-15
**Status:** Brainstorming Complete - Ready for Implementation
**Priority:** High

---

## Executive Summary

This plan documents UX and performance improvements for the Scenario Planning dashboard in the plugin-chart-scenario Superset plugin. The improvements address three specific pain points identified through user feedback:

1. **Arrow key navigation issue** - Arrow keys navigate between cells instead of enabling number editing within the input field
2. **Writeback performance** - Individual API calls for each cell edit cause network overhead
3. **Chart reflect performance** - Full chart re-renders on each edit instead of incremental updates
4. **UI overlapping** - Data table columns overlap due to z-index conflicts

The recommended approach is **Batched Write + Selective Re-render** - a balanced solution that delivers high impact with medium feasibility and risk.

---

## Current State Analysis

### Components Involved
| File | Purpose | Current Issue |
|------|---------|---------------|
| `EditableDataTable.tsx` | Pivot table with editable cells | Arrow keys navigate even while typing |
| `ComparativeChart.tsx` | GHG line chart | Re-renders completely on data change |
| `ScenarioChart.styles.ts` | Styling definitions | Sticky columns may overlap |
| `EmissionSourcesTab.tsx` | Tab orchestrator | No batching mechanism |
| `useScenarioData.ts` | Data management | Individual save calls |

### Root Cause Assessment

**Issue 1: Arrow Key Navigation**
- `handleKeyDown` in ScenarioEditableCell triggers navigation for ALL arrow key events
- No distinction between editing mode (`isFocused=true`) and navigation mode
- Users cannot move cursor within input field while editing

**Issue 2: Writeback Performance**
- Each `onCellEdit` triggers immediate `handleSave` call
- `handleSave` in `useScenarioData.ts` calls `save()` which posts individually
- No buffering or debouncing mechanism
- N edits = N API calls (e.g., 100 edits = 100 POST requests)

**Issue 3: Chart Reflect Performance**
- Chart receives updated `scenarioData` via props from EmissionSourcesTab
- ECharts' `useEffect` re-initializes chart on every data change
- No incremental update support - full `setOption` call each time
- Excessive re-renders cause UI jank

**Issue 4: UI Overlapping**
- `StickyTh` (z-index: 40) and `StickyTd` (z-index: 20) use different contexts
- Table has `position: relative` on rows but not on sticky elements
- No explicit stacking context for proper z-index ordering

---

## Proposed Solution: Batched Write + Selective Re-render

### Design Principles

1. **Optimistic UI** - Update display immediately, persist asynchronously
2. **Batching** - Collect multiple edits, send in single API call
3. **Incremental Updates** - Modify chart data in-place, not full re-init
4. **Proper Stacking** - Explicit z-index and positioning for sticky columns

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Interaction                          │
│  (Click cell, type number, press Enter/Blur)                    │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ScenarioEditableCell                           │
│  - handleKeyDown: Only navigate when !isFocused                 │
│  - onChange: Update localValue (state)                          │
│  - onBlur: Trigger onSave (optimistic update)                   │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                    In-Memory Buffer                              │
│                    Map<EditKey, number>                          │
│  - Edited cells stored here                                      │
│  - Immediate visual feedback (no API needed)                    │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ├─ Blur + Debounce (500ms) ──► Batch Save API
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Incremental Chart Update                       │
│  - useMemo for chart data (memoized selector)                   │
│  - ECharts setOption with notMerge: false                       │
│  - Only changed series re-rendered                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Tasks

### Phase 1: Arrow Key Fix (Low Effort, High Impact)
**File:** `plugins/plugin-chart-scenario/src/EditableDataTable.tsx`

**Task 1.1:** Modify `handleKeyDown` to only navigate when not focused

```typescript
// Current (BROKEN):
const handleKeyDown = (e: React.KeyboardEvent) => {
  if (e.key === 'ArrowUp') {
    e.preventDefault();
    onNavigation?.('up', rowKey, year);
  }
  // ... other arrows
};

// Fixed:
const handleKeyDown = (e: React.KeyboardEvent) => {
  // Navigate only when input is not focused (typing)
  if (!isFocused) {
    if (e.key === 'ArrowUp') {
      e.preventDefault();
      onNavigation?.('up', rowKey, year);
    }
    // ... other arrows
  }
  // Enter and Escape work both during and outside editing
  if (e.key === 'Enter') {
    (e.target as HTMLInputElement).blur();
  }
  if (e.key === 'Escape') {
    setLocalValue(String(initialValue));
    (e.target as HTMLInputElement).blur();
  }
};
```

**Estimated Effort:** 15 minutes
**Risk:** Low
**Dependencies:** None

---

### Phase 2: Writeback Batching (Medium Effort, High Impact)
**Files:** `plugins/plugin-chart-scenario/src/EditableDataTable.tsx`, `useScenarioData.ts`

**Task 2.1:** Add edit buffer state to `EditableDataTable`

```typescript
// Add to EditableDataTable component:
const [editBuffer, setEditBuffer] = useState<Map<EditKey, number>>(new Map());
const bufferTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

// Modify handleCellEdit to buffer instead of immediate save:
const handleCellEdit = useCallback((editKey: EditKey, newValue: number) => {
  // Update display immediately (optimistic)
  onCellEdit(editKey, newValue);

  // Buffer the actual save
  setEditBuffer(prev => {
    const next = new Map(prev);
    next.set(editKey, newValue);
    return next;
  });

  // Debounced flush - 500ms after last edit
  if (bufferTimeoutRef.current) {
    clearTimeout(bufferTimeoutRef.current);
  }
  bufferTimeoutRef.current = setTimeout(() => {
    flushEditBuffer();
  }, 500);
}, [onCellEdit]);
```

**Task 2.2:** Create `flushEditBuffer` function

```typescript
const flushEditBuffer = useCallback(async () => {
  if (editBuffer.size === 0) return;

  const edits = Array.from(editBuffer.entries()).map(([key, value]) => {
    const [bu, opu, scope, source, yearStr] = key.split('|');
    return {
      bu,
      opu,
      scope,
      source,
      year: Number(yearStr),
      value,
      scenario_id: effectiveScenarioId,
    };
  });

  try {
    // Send all edits in a single batch request
    await SupersetClient.post({
      endpoint: '/api/v1/scenario/emission-sources/batch',
      jsonPayload: { edits },
    });

    // Clear buffer on success
    setEditBuffer(new Map());
  } catch (error) {
    console.error('Batch save failed:', error);
    // Could implement retry logic here
  }
}, [editBuffer, effectiveScenarioId]);
```

**Task 2.3:** Create batch endpoint on backend

```python
# In scenario_writeback.py
@has_access_api
@permission_name("write")
@expose("/emission-sources/batch", methods=("POST",))
def batch_write_emission_sources(self) -> Any:
    """Accept multiple edits in a single request."""
    payload = request.get_json(silent=True, force=True) or {}
    edits = payload.get("edits", [])

    if not edits:
        return jsonify({"status": "error", "message": "No edits provided"}), 400

    # Use executemany for bulk insert
    stmt = text("""
        INSERT INTO silver_emission_by_sources (
            id, bu, opu, scope, source, year, value, type, scenario_id, user_email, updated_at
        ) VALUES (
            :id, :bu, :opu, :scope, :source, :yr, :val, :type, :sid, :email, :ts
        )
        ON CONFLICT(bu, opu, scope, source, year, scenario_id, user_email)
        DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at
    """)

    params = []
    for edit in edits:
        params.append({
            "id": str(uuid.uuid4()),
            "bu": edit["bu"],
            "opu": edit["opu"],
            "scope": edit["scope"],
            "source": edit["source"],
            "yr": int(edit["year"]),
            "val": float(edit["value"]),
            "type": edit.get("type") or "operational_control",
            "sid": edit.get("scenario_id") or "base",
            "email": current_user.email if hasattr(current_user, "email") else "anonymous",
            "ts": datetime.now(timezone.utc),
        })

    db.session.execute(stmt, params)
    db.session.commit()

    return jsonify({
        "status": "success",
        "count": len(edits),
    })
```

**Task 2.4:** Flush on explicit save

```typescript
// Add to handleSaveDraft:
const handleSaveDraft = async () => {
  // Flush any pending edits before saving
  await flushEditBuffer();
  // ... rest of save logic
};
```

**Estimated Effort:** 3-4 hours
**Risk:** Medium (state management complexity)
**Dependencies:** None (backend endpoint can be added)

---

### Phase 3: Incremental Chart Updates (Medium Effort, High Impact)
**File:** `plugins/plugin-chart-scenario/src/ComparativeChart.tsx`

**Task 3.1:** Add incremental update option to chart

```typescript
// Current: Full re-render on every data change
useEffect(() => {
  if (!containerRef.current) return;

  const currentDataStr = JSON.stringify({ baselineData, scenarioData });
  if (currentDataStr === lastDataRef.current && chartRef.current) {
    return; // Skip if data hasn't changed
  }
  lastDataRef.current = currentDataStr;

  // ... re-init chart
  chartRef.current.setOption(chartOptions, true); // notMerge=true
}, [baselineData, scenarioData]);

// Modified: Use incremental updates
const updateChartIncrementally = useCallback(() => {
  if (!chartRef.current) return;

  const years = baselineData.map(d => d.year);
  const baselineValues = baselineData.map(d => Math.round(d.value * 10) / 10);
  const scenarioValues = scenarioData.map(d => Math.round(d.value * 10) / 10);

  chartRef.current.setOption({
    series: [
      { data: baselineValues },
      { data: scenarioValues },
    ],
  }, { notMerge: false, lazyUpdate: true }); // Incremental update
}, [baselineData, scenarioData]);

// Call on data change
useEffect(() => {
  if (baselineData.length > 0 && scenarioData.length > 0) {
    updateChartIncrementally();
  }
}, [baselineData, scenarioData, updateChartIncrementally]);
```

**Task 3.2:** Add debounced update (optional)

```typescript
// Add debounce to prevent too many updates during rapid editing
const debouncedUpdate = useRef(
  debounce(updateChartIncrementally, 16) // ~60fps
);

// Use in useEffect
useEffect(() => {
  if (baselineData.length > 0 && scenarioData.length > 0) {
    debouncedUpdate.current();
  }
}, [baselineData, scenarioData]);
```

**Estimated Effort:** 2-3 hours
**Risk:** Low (ECharts supports incremental updates)
**Dependencies:** None

---

### Phase 4: UI Overlap Fixes (Low Effort, High Impact)
**File:** `plugins/plugin-chart-scenario/src/ScenarioChart.styles.ts`

**Task 4.1:** Fix z-index stacking for sticky columns

```typescript
// Current:
export const StickyTh = styled.th<{ left: number; $last?: boolean }>`
  position: sticky;
  left: ${props => props.left}px;
  z-index: 40;
  background-color: ${colors.slate50} !important;
  ...
`;

export const StickyTd = styled.td<{ left: number; $last?: boolean }>`
  position: sticky;
  left: ${props => props.left}px;
  z-index: 20;
  background-color: inherit;
  ...
`;

// Fixed - ensure proper stacking:
export const StickyTh = styled.th<{ left: number; $last?: boolean }>`
  position: sticky;
  left: ${props => props.left}px;
  z-index: 40;
  background-color: ${colors.slate50} !important;

  // Ensure proper stacking context
  &::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0; bottom: 0;
    z-index: -1;
  }

  ${props => props.$last && `
    border-right: 2px solid ${colors.gray200} !important;
    box-shadow: 2px 0 4px rgba(0,0,0,0.05);
  `}
`;

export const StickyTd = styled.td<{ left: number; $last?: boolean }>`
  position: sticky;
  left: ${props => props.left}px;
  z-index: 20;
  background-color: inherit;

  // Ensure proper stacking context
  &::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0; bottom: 0;
    z-index: -1;
  }

  ${props => props.$last && `
    border-right: 2px solid ${colors.gray200} !important;
    box-shadow: 2px 0 4px rgba(0,0,0,0.05);
  `}
`;
```

**Task 4.2:** Add explicit row context

```typescript
// Update DataTable to ensure rows have relative positioning:
export const DataTable = styled.table`
  ...
  tbody {
    tr {
      position: relative; // Added for proper z-index context
      ...
    }
  }
`;
```

**Estimated Effort:** 30 minutes
**Risk:** Low (CSS-only change)
**Dependencies:** None

---

## Task Summary

| Task | File | Effort | Risk | Status |
|------|------|--------|------|--------|
| 1.1: Arrow key fix | EditableDataTable.tsx | 15 min | Low | Pending |
| 2.1: Edit buffer state | EditableDataTable.tsx | 1 hour | Medium | Pending |
| 2.2: Flush function | EditableDataTable.tsx | 1 hour | Medium | Pending |
| 2.3: Batch endpoint | scenario_writeback.py | 1 hour | Medium | Pending |
| 2.4: Save integration | EditableDataTable.tsx | 30 min | Low | Pending |
| 3.1: Incremental update | ComparativeChart.tsx | 1.5 hours | Low | Pending |
| 3.2: Debounced update | ComparativeChart.tsx | 1 hour | Low | Pending |
| 4.1: Z-index fix | ScenarioChart.styles.ts | 15 min | Low | Pending |
| 4.2: Row context | ScenarioChart.styles.ts | 15 min | Low | Pending |
| **Total** | | **~6-7 hours** | | |

---

## Acceptance Criteria

### Arrow Key Fix
- [ ] Can type numbers in a cell without interfering with navigation
- [ ] Arrow keys navigate between cells when NOT focused on input
- [ ] Arrow keys move cursor within input when focused (browser default behavior)
- [ ] Enter finalizes edit and navigates down
- [ ] Escape cancels edit and returns to original value

### Writeback Batching
- [ ] Edits are buffered in memory
- [ ] Buffer flushes after 500ms of inactivity
- [ ] Buffer flushes on explicit Save Draft
- [ ] Single API call sends all buffered edits
- [ ] N edits result in 1 API call (not N calls)
- [ ] Edited cells show immediate visual feedback (blue highlight)
- [ ] Success toast shows number of rows saved
- [ ] Error handling shows which edits failed

### Incremental Chart Updates
- [ ] Chart updates without full re-initialization
- [ ] No jank or white flash during updates
- [ ] Cursor position preserved in chart (if hovering)
- [ ] Tooltips remain functional during updates
- [ ] Performance diagram shows smooth line (not choppy)

### UI Overlap Fixes
- [ ] Sticky columns (BU, OPU) stay fixed on horizontal scroll
- [ ] No visual overlap between columns
- [ ] Column headers remain visible above body
- [ ] Z-index stacking is linear and predictable

---

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| State synchronization bugs | High | Medium | Thorough testing of buffer state; add DevTools extension for debugging |
| Edge cases (empty buffer, rapid edits) | Medium | Low | Unit tests for flush logic; integration tests for E2E |
| Backend batch endpoint failure | Medium | Low | Grade 2 fallback to individual saves; error messages for users |
| ECharts incremental update issues | Low | Low | Fallback to full re-init if incremental fails; test across browsers |
| CSS z-index conflicts | Low | Low | Test in multiple browsers; check with screen readers |

---

## Testing Strategy

### Unit Tests
1. **handleKeyDown** - Verify navigation only when `!isFocused`
2. **flushEditBuffer** - Verify single POST request with array of edits
3. **incremental chart update** - Verify ECharts setOption parameters

### Integration Tests (Playwright)
1. Edit multiple cells rapidly, verify single API call
2. Type in cell, verify arrow keys work for cursor movement
3. Press escape, verify value resets correctly
4. Scroll horizontally, verify sticky columns don't overlap

### Manual Testing Checklist
- [ ] Edit 10 cells in sequence within 1 second
  - Expected: 1 API call (not 10)
- [ ] Type "123" in a cell
  - Expected: All three characters appear; arrow keys move cursor
- [ ] Press Escape after typing
  - Expected: Value reverts to original
- [ ] Press Enter after typing
  - Expected: Focus moves to cell below; value saved
- [ ] Scroll table horizontally
  - Expected: BU and OPU columns remain fixed
- [ ] chart displays without jank when editing

---

## Files Summary

| File | Action | Scope |
|------|--------|-------|
| `EditableDataTable.tsx` | Modify | Arrow key fix, edit buffering, batch flush |
| `ComparativeChart.tsx` | Modify | Incremental chart updates |
| `ScenarioChart.styles.ts` | Modify | Z-index stacking for sticky columns |
| `scenario_writeback.py` | Modify | Add batch endpoint |

---

## Implementation Order

1. **Arrow key fix** (15 min) - Fast win, no risk
2. **UI overlap fixes** (30 min) - CSS only, separate from logic
3. **Writeback batching** - Core performance improvement
4. **Incremental chart updates** - Polish finalperformance

---

## Next Steps

1. [ ] User approves implementation plan
2. [ ] Create PR for arrow key fix and UI fixes (low-risk)
3. [ ] Merge and verify in staging
4. [ ] Create PR for writeback batching (medium-risk)
5. [ ] Merge and verify in staging
6. [ ] Create PR for incremental chart updates (low-risk)
7. [ ] Final E2E testing
8. [ ] Deploy to production

---

## Notes

- **Do NOT use rm** - Archive any removed code to `_archive/`
- **Preserve data-test attributes** for E2E compatibility
- **Run pre-commit** before committing: `pre-commit run --all-files`
- **Update this doc** with any deviations discovered during implementation
- Batch endpoint URL: `/api/v1/scenario/emission-sources/batch`
- Debounce timer: 500ms (adjustable via config if needed)
