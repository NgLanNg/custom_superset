---
type: spec
date: 2026-03-10
updated: 2026-03-11
author: Antigravity
feature: Shared Write-back Package (@superset-ui/writeback)
status: draft
depends-on: docs/specs/2026-03-10-recreate-scenario-chart-dashboard.md
---

# Spec: Shared Write-back Package

## Problem

The Scenario plugin hardcodes write-back logic (editable cell, optimistic update, API call, error handling, notification) inside `ScenarioChart.tsx` (486 lines). It also uses raw `echarts/core` imports instead of the reusable `Echart` wrapper from `plugin-chart-echarts`. Future charts will need the same write-back pattern. Extracting the reusable primitives into a shared package avoids duplicating ~100 lines of boilerplate per plugin.

## Success Criteria

1. Any chart plugin can make a cell editable with `<EditableCell>` and `useWriteBack()`
2. Chart visualization reuses the existing `Echart` component from `plugin-chart-echarts`
3. The Scenario plugin still works identically after refactor (zero behavior change)
4. New package follows the exact monorepo conventions of existing `@superset-ui/*` packages
5. The Editor + Chart + Shared State pattern is established as the convention for future editable chart plugins

## Non-goals

- Changing the backend write-back API contract
- Moving Scenario-specific domain logic (stats, grid layout) into the shared package
- Building a generic form/grid framework
- Modifying the `Echart` component in `plugin-chart-echarts`

---

## Architectural Convention: Editor + Chart + Shared State

Every editable chart plugin follows this composition pattern:

```
Plugin (orchestrator)
  |-- Editor (editable grid using EditableCell from @superset-ui/writeback)
  |-- Chart  (Echart component from @superset-ui/plugin-chart-echarts)
  |-- useData hook (state + handleSave via useWriteBack, builds EChartsCoreOption)
```

**Why this pattern:**
- **Editor** uses `EditableCell` from the shared write-back package (reusable across all editable plugins)
- **Chart** uses the existing `Echart` wrapper from `plugin-chart-echarts` (theme-aware, handles resize/dispose)
- **useData hook** is domain-specific per plugin (each plugin builds its own ECharts options from its data shape)
- **Instant update**: Cell edit -> optimistic state update -> `useMemo` rebuilds `EChartsCoreOption` -> `Echart` re-renders

**Echart component interface** (from `plugin-chart-echarts/src/components/Echart.tsx`):

```typescript
interface EchartsProps {
  height: number;
  width: number;
  echartOptions: EChartsCoreOption;   // Raw ECharts config object
  eventHandlers?: EventHandlers;
  zrEventHandlers?: EventHandlers;
  selectedValues?: Record<number, string>;
  forceClear?: boolean;
  refs: Refs;                          // { echartRef?, divRef? }
  vizType?: string;
}
```

This component is internal to `plugin-chart-echarts` but accessible via monorepo path:
`import Echart from '@superset-ui/plugin-chart-echarts/src/components/Echart'`

**What this replaces in ScenarioChart.tsx:**
- Removes 11 lines of raw `echarts/core` imports (lines 28-37)
- Removes 6 lines of component registration (`echarts.use(...)`, lines 71-78)
- Removes 7 lines of type composition (`EChartsOption` type, lines 80-86)
- Removes manual `echarts.init()`, `setOption()`, `dispose()`, resize listener (lines 194-212)
- Total: ~35 lines of ECharts boilerplate replaced by one `<Echart>` component

---

## File Layout

```
packages/superset-ui-writeback/       NEW shared package
  src/
    EditableCell.tsx                   Generic editable cell component
    useWriteBack.ts                   Hook: optimistic update + POST + rollback + notify
    writeBackClient.ts                SupersetClient.post wrapper with error extraction
    types.ts                          WriteBackPayload, WriteBackConfig, EditableCellProps
    index.ts                          Barrel export

plugins/plugin-chart-scenario/        MODIFIED to consume shared package + Echart
  src/
    ScenarioChart.tsx                 Import EditableCell from writeback + Echart from echarts plugin
    ScenarioChart.styles.ts           Remove CellInput (moved to shared)
    useScenarioData.ts                NEW: state + handleSave + builds EChartsCoreOption
```

---

## Detailed Design

### 1. `types.ts`

```typescript
export interface WriteBackPayload {
  endpoint: string;
  jsonPayload: Record<string, unknown>;
}

export interface WriteBackConfig {
  onSuccess?: (payload: Record<string, unknown>) => void;
  onError?: (error: unknown) => void;
  onRollback?: () => void;
  successMessage?: string;
  errorMessage?: string;
  successDuration?: number;
}

export interface WriteBackResult {
  save: (payload: WriteBackPayload) => Promise<boolean>;
  saveBatch: (payloads: WriteBackPayload[]) => Promise<boolean>;
  isSaving: boolean;
}

export interface EditableCellProps {
  value: number;
  onSave: (nextValue: number) => void;
  min?: number;
  max?: number;
  disabled?: boolean;
  className?: string;
}
```

### 2. `writeBackClient.ts`

Wraps `SupersetClient.post` with standardized error extraction. This is the
logic currently at lines 252-277 of `ScenarioChart.tsx`.

```typescript
import { SupersetClient } from '@superset-ui/core';
import type { WriteBackPayload } from './types';

export function extractErrorMessage(error: unknown): string {
  if (error && typeof error === 'object') {
    const err = error as Record<string, unknown>;
    if (err.json && typeof err.json === 'object') {
      const json = err.json as Record<string, unknown>;
      if (typeof json.message === 'string') return json.message;
    }
    if (typeof err.message === 'string') return err.message;
  }
  return 'Check your connection or try again.';
}

export async function postWriteBack(
  payload: WriteBackPayload,
): Promise<void> {
  await SupersetClient.post({
    endpoint: payload.endpoint,
    jsonPayload: payload.jsonPayload,
  });
}
```

### 3. `useWriteBack.ts`

Generic hook that any chart plugin calls to get `save()` and `saveBatch()`
functions with optimistic notification behavior. On failure, calls
`onRollback` so the consumer can revert optimistic state.

```typescript
import { useCallback, useState } from 'react';
import { notification } from 'antd';
import { postWriteBack, extractErrorMessage } from './writeBackClient';
import type { WriteBackConfig, WriteBackPayload, WriteBackResult } from './types';

export function useWriteBack(config: WriteBackConfig = {}): WriteBackResult {
  const [isSaving, setIsSaving] = useState(false);
  const {
    onSuccess,
    onError,
    onRollback,
    successMessage = 'Saved',
    errorMessage = 'Write-back failed',
    successDuration = 1.5,
  } = config;

  const save = useCallback(
    async (payload: WriteBackPayload): Promise<boolean> => {
      setIsSaving(true);
      try {
        await postWriteBack(payload);
        notification.success({ message: successMessage, duration: successDuration });
        onSuccess?.(payload.jsonPayload);
        return true;
      } catch (error: unknown) {
        const description = extractErrorMessage(error);
        notification.error({ message: errorMessage, description });
        onRollback?.();
        onError?.(error);
        return false;
      } finally {
        setIsSaving(false);
      }
    },
    [successMessage, errorMessage, successDuration, onSuccess, onError, onRollback],
  );

  const saveBatch = useCallback(
    async (payloads: WriteBackPayload[]): Promise<boolean> => {
      if (payloads.length === 0) return true;
      setIsSaving(true);
      try {
        await Promise.all(payloads.map(p => postWriteBack(p)));
        notification.success({
          message: `${payloads.length} changes saved`,
          duration: successDuration,
        });
        payloads.forEach(p => onSuccess?.(p.jsonPayload));
        return true;
      } catch (error: unknown) {
        const description = extractErrorMessage(error);
        notification.error({ message: errorMessage, description });
        onRollback?.();
        onError?.(error);
        return false;
      } finally {
        setIsSaving(false);
      }
    },
    [successMessage, errorMessage, successDuration, onSuccess, onError, onRollback],
  );

  return { save, saveBatch, isSaving };
}
```

### 4. `EditableCell.tsx`

The universal editable cell. Currently lives as `ScenarioCell` inside
`ScenarioChart.tsx` (lines 91-118) with styling from `CellInput` (line 375
of styles). The shared version accepts min/max bounds and owns its own styling.

```typescript
import React, { useCallback, useEffect, useState } from 'react';
import styled from '@emotion/styled';
import type { EditableCellProps } from './types';

const CellInput = styled.input<{ $isChanged?: boolean }>`
  width: 100%;
  padding: 4px 8px;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 4px;
  font-size: 13px;
  text-align: right;
  outline: none;
  transition: all 150ms ease;

  &:hover {
    background: #fff;
    border-color: #d9d9d9;
  }

  &:focus {
    background: #fff;
    border-color: #1890ff;
    box-shadow: 0 0 0 3px rgba(24, 144, 255, 0.1);
  }

  ${({ $isChanged }) =>
    $isChanged &&
    `
    color: #1890ff;
    font-weight: 600;
  `}
`;

export function EditableCell({
  value,
  onSave,
  min,
  max,
  disabled = false,
  className,
}: EditableCellProps) {
  const [localVal, setLocalVal] = useState<string>(value.toString());

  useEffect(() => {
    setLocalVal(value.toString());
  }, [value]);

  const commit = useCallback(() => {
    if (localVal.trim() === '') return;
    const num = parseFloat(localVal);
    if (Number.isNaN(num)) return;
    if (num === value) return;
    if (min !== undefined && num < min) return;
    if (max !== undefined && num > max) return;
    onSave(num);
  }, [localVal, value, min, max, onSave]);

  return (
    <CellInput
      className={className}
      value={localVal}
      disabled={disabled}
      $isChanged={localVal !== value.toString()}
      onChange={e => setLocalVal(e.target.value)}
      onBlur={commit}
      onKeyDown={e => {
        if (e.key === 'Enter') {
          (e.target as HTMLInputElement).blur();
        }
      }}
    />
  );
}
```

### 5. `index.ts` (barrel export)

```typescript
export { EditableCell } from './EditableCell';
export { useWriteBack } from './useWriteBack';
export { postWriteBack, extractErrorMessage } from './writeBackClient';
export type {
  EditableCellProps,
  WriteBackConfig,
  WriteBackPayload,
  WriteBackResult,
} from './types';
```

---

## API Summary

| Export | Type | Purpose |
| ------ | ---- | ------- |
| `<EditableCell>` | Component | Editable numeric cell with min/max, change highlight, Enter/blur commit |
| `useWriteBack(config?)` | Hook | Returns `{ save, saveBatch, isSaving }` |
| `save(payload)` | Method | Single-cell POST with optimistic notify + rollback on failure |
| `saveBatch(payloads)` | Method | Multi-cell `Promise.all` POST with rollback on any failure |
| `onRollback` | Callback | Called on failure so consumer can revert optimistic state |
| `postWriteBack(payload)` | Function | Low-level `SupersetClient.post` wrapper |
| `extractErrorMessage(err)` | Function | Extracts human-readable message from Superset error objects |

---

## Monorepo Integration

### 5a. New `packages/superset-ui-writeback/package.json`

```json
{
  "name": "@superset-ui/writeback",
  "version": "0.1.0",
  "description": "Shared write-back primitives for editable Superset chart plugins",
  "sideEffects": false,
  "main": "src/index.ts",
  "module": "src/index.ts",
  "files": ["src"],
  "license": "Apache-2.0",
  "dependencies": {
    "@emotion/styled": "*"
  },
  "peerDependencies": {
    "@superset-ui/core": "*",
    "antd": "*",
    "react": "^16.13.1 || ^17.0.0"
  }
}
```

Note: `main` and `module` point to `src/` directly because the monorepo
Webpack config resolves via tsconfig paths during development. No build
step needed for local dev.

### 5b. Register in `superset-frontend/tsconfig.json`

Add path mapping:

```json
"@superset-ui/writeback": ["./packages/superset-ui-writeback/src"],
"@superset-ui/writeback/*": ["./packages/superset-ui-writeback/src/*"]
```

Add reference:

```json
{ "path": "./packages/superset-ui-writeback" }
```

### 5c. Register in `superset-frontend/package.json`

Add workspace dependency:

```json
"@superset-ui/writeback": "file:./packages/superset-ui-writeback"
```

### 5d. New `packages/superset-ui-writeback/tsconfig.json`

```json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "composite": true,
    "outDir": "lib",
    "rootDir": "src",
    "declarationDir": "lib"
  },
  "include": ["src/**/*"]
}
```

---

## Scenario Plugin Refactor

### 6a. New `useScenarioData.ts`

Extracts state management, domain-specific save handler, and **ECharts option
building** from `ScenarioChart.tsx`. The hook owns `existingData`, `growthData`,
`stats`, `chartOptions` (EChartsCoreOption), and delegates the actual POST to
`useWriteBack`. This is the domain-specific "useData" hook in the
Editor + Chart + Shared State pattern.

```typescript
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { notification } from 'antd';
import type { EChartsCoreOption } from 'echarts/core';
import { useWriteBack } from '@superset-ui/writeback';
import { YEARS, MOCK_EXISTING, MOCK_GROWTH } from './mockData';
import type { ExistingAssetRow, GrowthProjectRow, ScenarioStats } from './types';

const MIN_VALUE = 0;
const MAX_VALUE = 100;

interface UseScenarioDataArgs {
  existingData?: ExistingAssetRow[];
  growthData?: GrowthProjectRow[];
  scenarioName: string;
  bu: string;
}

export function useScenarioData({
  existingData: realExisting,
  growthData: realGrowth,
  scenarioName,
  bu,
}: UseScenarioDataArgs) {
  const [existingData, setExistingData] = useState<ExistingAssetRow[]>(
    realExisting?.length ? realExisting : MOCK_EXISTING,
  );
  const [growthData, setGrowthData] = useState<GrowthProjectRow[]>(
    realGrowth?.length ? realGrowth : MOCK_GROWTH,
  );

  // Snapshot for rollback on API failure
  const snapshotRef = useRef<{
    existing: ExistingAssetRow[];
    growth: GrowthProjectRow[];
  }>({ existing: existingData, growth: growthData });

  useEffect(() => {
    if (realExisting?.length) setExistingData(realExisting);
    if (realGrowth?.length) setGrowthData(realGrowth);
  }, [realExisting, realGrowth]);

  // -- Stats (derived) --
  const stats: ScenarioStats = useMemo(() => {
    const allValues = existingData.flatMap(row => row.vals);
    const totalAssets = existingData.length;
    const sum = allValues.reduce((acc, v) => acc + v, 0);
    const avgEquity = allValues.length ? sum / allValues.length : 0;
    const maxEquity = allValues.length ? Math.max(...allValues) : 0;
    const minEquity = allValues.length ? Math.min(...allValues) : 0;
    return { totalAssets, avgEquity, maxEquity, minEquity };
  }, [existingData]);

  // -- ECharts options (derived, rebuilds on data change for instant chart update) --
  const chartOptions: EChartsCoreOption = useMemo(
    () => ({
      tooltip: { trigger: 'axis' },
      legend: { top: 0 },
      grid: { top: 48, left: 32, right: 24, bottom: 32 },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: YEARS.map(String),
      },
      yAxis: { type: 'value', min: MIN_VALUE, max: MAX_VALUE },
      series: [
        ...existingData.map(row => ({
          name: row.gpu,
          type: 'line' as const,
          smooth: true,
          data: row.vals,
        })),
        ...growthData.map(row => ({
          name: row.project,
          type: 'line' as const,
          smooth: true,
          lineStyle: { type: 'dashed' as const },
          data: row.vals,
        })),
      ],
    }),
    [existingData, growthData],
  );

  // -- Rollback --
  const rollback = useCallback(() => {
    setExistingData(snapshotRef.current.existing);
    setGrowthData(snapshotRef.current.growth);
  }, []);

  const { save, saveBatch, isSaving } = useWriteBack({ onRollback: rollback });

  // -- Save handler (optimistic update + POST) --
  const handleSave = useCallback(
    async (
      kind: 'existing' | 'growth',
      rowIndex: number,
      yearIndex: number,
      nextVal: number,
    ) => {
      if (Number.isNaN(nextVal) || nextVal < MIN_VALUE || nextVal > MAX_VALUE) {
        notification.warning({ message: 'Enter a value between 0 and 100' });
        return;
      }

      // Snapshot before optimistic update
      snapshotRef.current = { existing: existingData, growth: growthData };

      const setter = kind === 'existing' ? setExistingData : setGrowthData;
      setter(prev => {
        const next = [...prev];
        const row = { ...next[rowIndex] };
        const vals = [...row.vals];
        vals[yearIndex] = nextVal;
        row.vals = vals;
        next[rowIndex] = row;
        return next;
      });

      await save({
        endpoint: '/api/v1/scenario/writeback',
        jsonPayload: {
          scenario_name: scenarioName,
          bu,
          opu:
            kind === 'existing'
              ? existingData[rowIndex].gpu
              : growthData[rowIndex].project,
          year: YEARS[yearIndex],
          value: nextVal,
        },
      });
    },
    [bu, existingData, growthData, scenarioName, save],
  );

  return {
    existingData,
    growthData,
    stats,
    chartOptions,   // EChartsCoreOption -- feed directly to <Echart>
    handleSave,
    saveBatch,
    isSaving,
  };
}
```

### 6b. Modify `ScenarioChart.tsx`

**Remove:**
- `ScenarioCell` function (lines 91-118) -- replaced by `EditableCell` import
- `handleSave` callback (lines 214-278) -- replaced by `useScenarioData` hook
- `existingData` / `growthData` / `stats` state (lines 123-149) -- moved to hook
- `chartOption` useMemo (lines 151-192) -- moved to hook as `chartOptions`
- All raw ECharts imports (lines 28-37): `echarts/core`, `echarts/charts`, `echarts/components`, `echarts/renderers`
- `echarts.use(...)` registration (lines 71-78)
- `EChartsOption` type composition (lines 80-86)
- Manual `echarts.init()`, `setOption()`, `dispose()`, resize listener (lines 194-212)
- `chartContainerRef` and `chartInstanceRef` refs (lines 127-128)
- `CellInput` import from styles
- `SupersetClient` import (moved to writeBackClient)

**Add:**
- `import { EditableCell } from '@superset-ui/writeback';`
- `import { useScenarioData } from './useScenarioData';`
- `import Echart from '@superset-ui/plugin-chart-echarts/src/components/Echart';`

**Replace chart rendering** -- manual ECharts lifecycle with `<Echart>`:

```tsx
// Before (lines 194-212, ~20 lines of init/setOption/dispose/resize)
const chartContainerRef = useRef<HTMLDivElement | null>(null);
const chartInstanceRef = useRef<EChartsType | null>(null);

useEffect(() => {
  if (!chartContainerRef.current) return;
  if (!chartInstanceRef.current) {
    chartInstanceRef.current = echarts.init(chartContainerRef.current, ...);
  }
  chartInstanceRef.current.setOption(chartOption);
}, [chartOption]);

useEffect(() => {
  const handleResize = () => chartInstanceRef.current?.resize();
  window.addEventListener('resize', handleResize);
  return () => { ... };
}, []);

<div style={{ width: '100%', height: 260 }} ref={chartContainerRef} />

// After (1 component, 0 lifecycle management)
const { chartOptions, ... } = useScenarioData({ ... });

<Echart
  width={chartWidth}
  height={260}
  echartOptions={chartOptions}
  refs={{}}
/>
```

**Replace** `ScenarioCell` usages with `EditableCell`:

```tsx
// Before
<ScenarioCell value={val} onSave={next => handleSave('existing', rowIndex, yearIndex, next)} />

// After
<EditableCell value={val} min={0} max={100} onSave={next => handleSave('existing', rowIndex, yearIndex, next)} />
```

**Net result:** `ScenarioChart.tsx` drops from ~486 lines to ~250 lines (render-only, no state management, no ECharts lifecycle).

**What stays in ScenarioChart.tsx (render-only orchestrator):**
- Layout: `ScenarioContainer`, `Tabs`, `SectionCard`, `DataTable`
- Stats display: `StatsRowWrap`, `StatCard`
- Data grid rendering: `<table>` with `EditableCell` in each `<td>`
- Chart display: `<Echart>` with `chartOptions` from hook
- Tab structure: equity, growth, OPU configuration

### 6c. Modify `ScenarioChart.styles.ts`

**Remove:** `CellInput` styled component (lines 375+). Now lives in `EditableCell.tsx`.

### 6d. Add dependency to plugin `package.json`

```json
"dependencies": {
  "@superset-ui/writeback": "*"
}
```

---

## Tasks (Ordered by Dependency)

| # | Task | File(s) | Risk |
| - | ---- | ------- | ---- |
| 1 | Create `packages/superset-ui-writeback/` with package.json, tsconfig.json | New dir | Low |
| 2 | Write `types.ts`, `writeBackClient.ts`, `useWriteBack.ts`, `EditableCell.tsx`, `index.ts` | New files | Low |
| 3 | Register package in root `tsconfig.json` (paths + references) | `superset-frontend/tsconfig.json` | Medium |
| 4 | Register package in root `package.json` (workspace dep) | `superset-frontend/package.json` | Medium |
| 5 | Run `npm install` to link workspace | Shell | Low |
| 6 | Create `useScenarioData.ts` with state + save + `chartOptions` | New file | Low |
| 7 | Refactor `ScenarioChart.tsx`: replace raw ECharts with `<Echart>`, `ScenarioCell` with `<EditableCell>`, state with hook | Modify | Medium |
| 8 | Remove `CellInput` from `ScenarioChart.styles.ts` | Modify | Low |
| 9 | Add `@superset-ui/writeback` + `@superset-ui/plugin-chart-echarts` deps to plugin `package.json` | Modify | Low |
| 10 | Verify frontend builds (`npm run build`) | Shell | Medium |
| 11 | Verify write-back still works in browser | Manual | Low |

---

## Scaffold Gate

- **Actionable**: Every task has a specific file path and operation
- **Dependency-Ordered**: Package created (1-5) before consumer refactored (6-9) before verified (10-11)
- **Self-Contained**: All code snippets, types, and monorepo config included -- no re-discovery needed

---

## Future Consumers (Example)

Any new editable chart plugin follows the **Editor + Chart + Shared State** pattern:

```typescript
// useBudgetData.ts -- domain-specific hook (the "Shared State" layer)
import { useCallback, useMemo, useRef, useState } from 'react';
import type { EChartsCoreOption } from 'echarts/core';
import { useWriteBack } from '@superset-ui/writeback';

export function useBudgetData({ initialData }) {
  const [rows, setRows] = useState(initialData);
  const snapshotRef = useRef(rows);

  const { save, isSaving } = useWriteBack({
    successMessage: 'Budget updated',
    onRollback: () => setRows(snapshotRef.current),
  });

  // Builds ECharts options -- rebuilds on every data change for instant chart update
  const chartOptions: EChartsCoreOption = useMemo(() => ({
    xAxis: { type: 'category', data: rows.map(r => r.label) },
    yAxis: { type: 'value' },
    series: [{ type: 'bar', data: rows.map(r => r.amount) }],
  }), [rows]);

  const handleSave = useCallback((rowId: string, field: string, value: number) => {
    snapshotRef.current = rows;
    setRows(prev => prev.map(r => r.id === rowId ? { ...r, [field]: value } : r));
    save({ endpoint: '/api/v1/budget/writeback', jsonPayload: { row_id: rowId, field, value } });
  }, [rows, save]);

  return { rows, chartOptions, handleSave, isSaving };
}
```

```typescript
// BudgetChart.tsx -- the orchestrator (Editor + Chart composition)
import { EditableCell } from '@superset-ui/writeback';
import Echart from '@superset-ui/plugin-chart-echarts/src/components/Echart';
import { useBudgetData } from './useBudgetData';

export default function BudgetChart({ width, height, data }) {
  const { rows, chartOptions, handleSave, isSaving } = useBudgetData({ initialData: data });

  return (
    <div>
      {/* Chart -- reuses Echart from plugin-chart-echarts */}
      <Echart width={width} height={300} echartOptions={chartOptions} refs={{}} />

      {/* Editor -- reuses EditableCell from @superset-ui/writeback */}
      <table>
        {rows.map(row => (
          <tr key={row.id}>
            <td>{row.label}</td>
            <td>
              <EditableCell
                value={row.amount}
                min={0}
                onSave={v => handleSave(row.id, 'amount', v)}
                disabled={isSaving}
              />
            </td>
          </tr>
        ))}
      </table>
    </div>
  );
}
```

**Convention recap:** Every editable chart plugin has 3 pieces:
1. `useXxxData` hook -- state + save + `chartOptions: EChartsCoreOption`
2. `<Echart>` -- from `plugin-chart-echarts`, fed `chartOptions` from hook
3. `<EditableCell>` -- from `@superset-ui/writeback`, calls `handleSave` from hook

Zero boilerplate for write-back plumbing or ECharts lifecycle management.
