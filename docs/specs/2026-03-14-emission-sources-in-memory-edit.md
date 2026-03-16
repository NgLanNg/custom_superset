# Technical Spec: Emission Sources In-Memory Edit with Save Draft

**Date:** 2026-03-14
**Status:** Draft
**Scope:** OPU Configuration > Emission by Sources sub-tab

---

## 1. Problem Statement

The current implementation has three critical issues:

1. **Immediate DB writes on cell edit** — `EditableDataTable.tsx:104-132` writes to the database on every cell blur, corrupting the immutable `scenario_id='base'` baseline data.

2. **Single-series chart** — `ComparativeChart.tsx` shows only one line (current scenario). Users cannot compare baseline vs edited scenario.

3. **No visual feedback for edits** — Edited cells have no orange highlight; no "Baseline Amount" reference column exists.

---

## 2. Solution Overview

Implement an **In-Memory Diff Pattern**:

1. Edits are stored in React state (`Map<editKey, number>`) — NOT written to DB immediately.
2. Chart shows **two series**: Baseline (immutable) vs Scenario (baseline + in-memory diffs).
3. Cells with edits show **orange background**.
4. New **"Baseline Amount"** column shows reference total per row.
5. **"Save Draft"** button flushes all in-memory edits to DB via batch POST.

---

## 3. Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      EmissionSourcesTab                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ editedValues: Map<editKey, number>                      │   │
│  │ editKey = `${bu}|${opu}|${scope}|${source}|${year}`     │   │
│  └─────────────────────────────────────────────────────────┘   │
│              │                    │                    │        │
│              ▼                    ▼                    ▼        │
│     ComparativeChart       EditableDataTable      (registerSave │
│     ─────────────────      ─────────────────       Flusher)    │
│     - Fetches baseline     - Receives edits       - Called by  │
│     - Adds diff series     - Shows orange cells    ScenarioChart│
│                            - Baseline Amount col   on Save     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Implementation Details

### 4.1 Edit Key Format

```typescript
type EditKey = `${string}|${string}|${string}|${string}|${number}`;
// Example: "LNGA|MLNG|Scope 1|Combustion|2025"
```

Components of the key:
- `bu` — Business Unit
- `opu` — Operating Performance Unit
- `scope` — Emission Scope
- `source` — Emission Source
- `year` — Year (number)

---

### 4.2 EmissionSourcesTab.tsx Changes

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/EmissionSourcesTab.tsx`

**Current state:** Stateless orchestrator that only passes `scenarioId` to children.

**New responsibilities:**
1. Own `editedValues: Map<EditKey, number>` state.
2. Provide `onCellEdit(editKey: EditKey, value: number)` callback.
3. Expose `registerSaveFlusher(flusher: () => Promise<void>)` for parent.

**New Props:**
```typescript
interface EmissionSourcesTabProps {
  scenarioId: string;
  onRegisterSaveFlusher?: (flusher: () => Promise<void>) => void;
}
```

**New Implementation:**

```typescript
import { useCallback, useState, useEffect } from 'react';
import type { FilterState } from './types';

type EditKey = `${string}|${string}|${string}|${string}|${number}`;

export function EmissionSourcesTab({ scenarioId, onRegisterSaveFlusher }: EmissionSourcesTabProps) {
  const [filters, setFilters] = useState<FilterState>({ bu: null, opu: null, scope: null, source: null });
  const [editedValues, setEditedValues] = useState<Map<EditKey, number>>(new Map());

  const handleCellEdit = useCallback((editKey: EditKey, value: number) => {
    setEditedValues(prev => new Map(prev).set(editKey, value));
  }, []);

  const handleClearEdit = useCallback((editKey: EditKey) => {
    setEditedValues(prev => {
      const next = new Map(prev);
      next.delete(editKey);
      return next;
    });
  }, []);

  const flushEdits = useCallback(async () => {
    if (editedValues.size === 0) return;

    // Batch POST all edits
    const edits = Array.from(editedValues.entries()).map(([key, value]) => {
      const [bu, opu, scope, source, yearStr] = key.split('|');
      return { bu, opu, scope, source, year: Number(yearStr), value, scenario_id: scenarioId };
    });

    await SupersetClient.post({
      endpoint: '/api/v1/scenario/emission-sources',
      jsonPayload: { edits },  // Backend must support batch
    });

    // Clear in-memory state after successful save
    setEditedValues(new Map());
  }, [editedValues, scenarioId]);

  // Register flusher with parent for Save Draft button
  useEffect(() => {
    onRegisterSaveFlusher?.(flushEdits);
  }, [flushEdits, onRegisterSaveFlusher]);

  return (
    <SubTabContent>
      <FilterPanel filters={filters} scenarioId={scenarioId} onFilterChange={setFilters} />
      <ComparativeChart
        filters={filters}
        scenarioId={scenarioId}
        editedValues={editedValues}
      />
      <EditableDataTable
        filters={filters}
        scenarioId={scenarioId}
        editedValues={editedValues}
        onCellEdit={handleCellEdit}
        onClearEdit={handleClearEdit}
      />
    </SubTabContent>
  );
}
```

---

### 4.3 ComparativeChart.tsx Changes

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/ComparativeChart.tsx`

**Current behavior:** Single series from `scenarioId` data.

**New behavior:**
1. Fetch baseline data from `scenario_id='base'` (always).
2. Fetch scenario data from `scenarioId` prop.
3. Compute "Edited" series: baseline + in-memory diffs.
4. Render two series with distinct colors.

**New Props:**
```typescript
interface ComparativeChartProps {
  filters: FilterState;
  scenarioId: string;
  editedValues: Map<EditKey, number>;
}
```

**Chart Series Configuration:**

```typescript
const series = [
  {
    name: 'Baseline',
    type: 'line',
    data: baselineValues,  // from scenario_id='base'
    lineStyle: { width: 2, color: '#8c8c8c' },  // Grey
    itemStyle: { color: '#8c8c8c' },
    symbol: 'circle',
    symbolSize: 4,
  },
  {
    name: 'Scenario',
    type: 'line',
    data: scenarioValues,  // baseline + editedValues diffs
    lineStyle: { width: 2, color: '#1890ff' },  // Blue
    itemStyle: { color: '#1890ff' },
    symbol: 'circle',
    symbolSize: 5,
    areaStyle: { color: 'rgba(24,144,255,0.06)' },
  },
];
```

**Legend:** Show both "Baseline" and "Scenario" entries.

**Aggregation Logic:**

```typescript
// For each year, sum all baseline values
const baselineByYear: Record<number, number> = {};
baselineRows.forEach(r => {
  baselineByYear[r.year] = (baselineByYear[r.year] ?? 0) + r.value;
});

// Apply in-memory diffs to create scenario series
const scenarioByYear: Record<number, number> = { ...baselineByYear };
editedValues.forEach((value, key) => {
  const [, , , , yearStr] = key.split('|');
  const year = Number(yearStr);
  // Note: This is a simplified diff. Real implementation should
  // check if the editKey matches current filter context.
  scenarioByYear[year] = value;  // Replace or add
});
```

---

### 4.4 EditableDataTable.tsx Changes

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/EditableDataTable.tsx`

**Current behavior:**
- Calls `useWriteBack.save()` on every cell edit (line 106-117).
- Writes directly to DB with `scenario_id: scenarioId` (line 115).

**New behavior:**
1. Remove DB write on cell edit.
2. Accept `editedValues` and `onCellEdit` props.
3. Show **orange background** for cells with edits.
4. Add **"Baseline Amount"** column showing sum of all years per row.

**New Props:**
```typescript
interface EditableDataTableProps {
  filters: FilterState;
  scenarioId: string;
  editedValues: Map<EditKey, number>;
  onCellEdit: (editKey: EditKey, value: number) => void;
  onClearEdit?: (editKey: EditKey) => void;
}
```

**Orange Cell Highlight:**

```typescript
const OrangeCell = styled.div<{ $hasEdit: boolean }>`
  background: ${props => props.$hasEdit ? '#fff7e6' : 'transparent'};
  border-radius: 2px;
  padding: 2px 4px;
`;

// In render:
const getEditKey = (record: PivotRow, year: number): EditKey =>
  `${record.bu}|${record.opu}|${record.scope}|${record.source}|${year}`;

const renderYearCell = (cellValue: number | undefined, record: PivotRow, year: number) => {
  const editKey = getEditKey(record, year);
  const hasEdit = editedValues.has(editKey);
  const displayValue = hasEdit ? editedValues.get(editKey)! : (cellValue ?? 0);

  return (
    <OrangeCell $hasEdit={hasEdit}>
      <EditableCell
        value={displayValue}
        onSave={next => {
          if (next === cellValue) {
            onClearEdit?.(editKey);  // Reverted to original
          } else {
            onCellEdit(editKey, next);
          }
        }}
      />
    </OrangeCell>
  );
};
```

**Baseline Amount Column:**

```typescript
// Fetch baseline data (scenario_id='base') for comparison
const [baselineRows, setBaselineRows] = useState<EmissionRow[]>([]);

useEffect(() => {
  // Always fetch baseline for comparison
  SupersetClient.get({
    endpoint: `/api/v1/scenario/emission-sources?scenario_id=base`,
  }).then(res => setBaselineRows((res.json as { data: EmissionRow[] }).data || []));
}, []);

// Compute baseline sum per pivot row
const baselineSums = useMemo(() => {
  const sums: Record<string, number> = {};
  baselineRows.forEach(r => {
    const key = `${r.bu}|${r.opu}|${r.scope}|${r.source}`;
    sums[key] = (sums[key] ?? 0) + r.value;
  });
  return sums;
}, [baselineRows]);

// Add column after Source column
const baselineColumn = {
  title: 'Baseline Amount',
  dataIndex: 'baselineAmount',
  key: 'baselineAmount',
  width: 100,
  align: 'right' as const,
  render: (_: unknown, record: PivotRow) => {
    const key = `${record.bu}|${record.opu}|${record.scope}|${record.source}`;
    return baselineSums[key]?.toLocaleString() ?? '-';
  },
};
```

---

### 4.5 ScenarioChart.tsx Changes

**File:** `superset-frontend/plugins/plugin-chart-scenario/src/ScenarioChart.tsx`

**Current `handleSaveDraft` (FAKE):**
```typescript
const handleSaveDraft = async () => {
  setSaving(true);
  try {
    await new Promise(resolve => setTimeout(resolve, 1000));  // FAKE!
    setMetadata(prev => ({ ...prev, status: 'draft' }));
    message.success('Draft saved successfully');
  } finally {
    setSaving(false);
  }
};
```

**New `handleSaveDraft` (REAL):**

```typescript
const saveFlusherRef = useRef<(() => Promise<void>) | null>(null);

const registerSaveFlusher = useCallback((flusher: () => Promise<void>) => {
  saveFlusherRef.current = flusher;
}, []);

const handleSaveDraft = async () => {
  if (!metadata.name.trim()) {
    message.error('Scenario name is required');
    return;
  }
  setSaving(true);
  try {
    // 1. Create or update scenario metadata
    let scenarioUuid = metadata.id;
    if (!scenarioUuid) {
      const createRes = await SupersetClient.post({
        endpoint: '/api/v1/scenario/metadata/',
        jsonPayload: { name: metadata.name, description: metadata.description },
      });
      scenarioUuid = (createRes.json as { id: string }).id;
      setMetadata(prev => ({ ...prev, id: scenarioUuid }));
    } else {
      await SupersetClient.put({
        endpoint: `/api/v1/scenario/metadata/${scenarioUuid}`,
        jsonPayload: { name: metadata.name, description: metadata.description },
      });
    }

    // 2. Flush in-memory emission edits to DB
    await saveFlusherRef.current?.();

    message.success('Draft saved successfully');
  } catch (err) {
    message.error('Failed to save draft');
    console.error(err);
  } finally {
    setSaving(false);
  }
};
```

**Pass `registerSaveFlusher` to EmissionSourcesTab:**
```tsx
<EmissionSourcesTab
  scenarioId={metadata.id || 'base'}
  onRegisterSaveFlusher={registerSaveFlusher}
/>
```

---

### 4.6 Backend Considerations

**Current POST endpoint:** `/api/v1/scenario/emission-sources`

The endpoint currently accepts single-row upsert. For batch save, either:

**Option A: Multiple sequential POSTs** (simpler, already works)
```typescript
for (const edit of edits) {
  await SupersetClient.post({
    endpoint: '/api/v1/scenario/emission-sources',
    jsonPayload: edit,
  });
}
```

**Option B: Batch POST** (requires backend change)
```python
@expose('/emission-sources', methods=['POST'])
def emission_sources_post(self) -> Response:
    data = request.json
    if isinstance(data, list):
        # Handle batch upsert
        for row in data:
            # ... upsert logic
    else:
        # Handle single row upsert
```

**Recommendation:** Use Option A for MVP; Option B can be optimized later.

---

## 5. Acceptance Criteria

| ID | Given | When | Then |
|----|-------|------|------|
| AC-001 | User edits a cell | On blur | Cell shows orange background; edit stored in memory |
| AC-002 | User edits multiple cells | On blur | All edits show orange; chart shows updated "Scenario" line |
| AC-003 | User reverts a cell to original value | On blur | Orange highlight disappears |
| AC-004 | User clicks "Save Draft" | With edits | All edits POSTed to DB; orange highlights cleared |
| AC-005 | User clicks "Save Draft" | Without edits | No API calls for emissions; metadata saved if changed |
| AC-006 | Chart loads | With filter context | Two lines render: Baseline (grey) and Scenario (blue) |
| AC-007 | Table loads | With filter context | "Baseline Amount" column shows reference totals |
| AC-008 | User refreshes page | After edits not saved | Edits lost; baseline data preserved |

---

## 6. File Change Summary

| File | Change Type | Description |
|------|-------------|-------------|
| `EmissionSourcesTab.tsx` | Rewrite | Own `editedValues` state; provide callbacks; register save flusher |
| `EditableDataTable.tsx` | Rewrite | Remove DB write; accept `editedValues`/`onCellEdit`; orange highlight; Baseline column |
| `ComparativeChart.tsx` | Modify | Accept `editedValues`; compute two series; dual-line rendering |
| `ScenarioChart.tsx` | Modify | Real `handleSaveDraft` API calls; register save flusher |
| `types.ts` | Modify | Add `EditKey` type alias |

---

## 7. Implementation Order

1. **types.ts** — Add `EditKey` type.
2. **EmissionSourcesTab.tsx** — Implement state ownership and callbacks.
3. **EditableDataTable.tsx** — Remove DB write; add orange highlight; add Baseline column.
4. **ComparativeChart.tsx** — Two-series chart.
5. **ScenarioChart.tsx** — Real Save Draft implementation.
6. **Manual testing** — Verify all ACs.
7. **E2E test** — Update Playwright test to verify in-memory edit + Save Draft.

---

## 8. Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Large `editedValues` map for many cells | Performance | Use Map for O(1) lookup; cap at reasonable edit count |
| Baseline data fetch adds latency | UX | Fetch baseline once in parent; pass down |
| Save Draft fails mid-batch | Data integrity | Wrap in try/catch; show partial success message |
| User navigates away without saving | Data loss | Browser beforeunload warning if `editedValues.size > 0` |