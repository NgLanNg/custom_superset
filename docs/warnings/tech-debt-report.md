# Tech Debt Report -- Scenario Plugin

**Date:** 2026-03-11
**Scope:** Custom scenario plugin code only

## Summary

| Severity | Count | Key Categories |
| -------- | ----- | -------------- |
| HIGH | 8 | Test gaps, type safety, code duplication, hardcoded data |
| MEDIUM | 12 | Dead code, coupling, naming, inline styles |
| LOW | 7 | Formatting, constants, license headers |

---

## HIGH

### H-01 -- No Tests for Growth/OPU Views or Any Frontend Files

Only `test_scenario_writeback.py` exists. Zero coverage for:
- `growth_config_view.py` (both endpoints)
- `opu_config_view.py` (both endpoints)
- All frontend hooks and components

**Action:** Create `test_growth_config_view.py`, `test_opu_config_view.py`. Add Jest tests for `EditableCell`, `useWriteBack`, `useGrowthConfig`, `useOPUConfig`.

### H-02 -- `any[]` State in Both Config Hooks

**Files:** `useGrowthConfig.ts:6`, `useOPUConfig.ts:6`

`useState<any[]>` defeats TypeScript type system. Violates CLAUDE.md "NO any types" rule.

**Action:** Define `GrowthConfigRow` and `OPUConfigRow` interfaces. Replace `any[]`.

### H-04 -- Three Backend Views Are Identical with No Shared Base

**Files:** All 3 views

Duplicated patterns: user resolution (10 lines), `_MAX_FIELD_LEN`, text validation loop, error handling.

**Action:** Extract `BaseScenarioView` with `_resolve_user_email()`, `_validate_text_fields()`, `_db_write()`.

### H-05 -- useGrowthConfig and useOPUConfig Are Near-Identical

Both hooks share identical: state pattern, fetch pattern, optimistic update, rollback logic. Only differ in endpoint URL and primary key field.

**Action:** Extract generic `useConfigRows<T>` hook. Both become thin wrappers.

### H-06 -- Hardcoded Growth Asset List in transformProps.ts

**File:** `transformProps.ts:34`

```
['LNGC2', 'Suriname F2', 'Lake Charles', 'Calathea', 'Asters'].includes(opu)
```

Business entity names baked into transform code. Will silently miscategorize new projects.

**Action:** Remove array. Fix backend to always return `is_growth` field.

### H-07 -- `row: any` in transformProps.ts

**File:** `transformProps.ts:31`

`rawData.forEach((row: any)` -- all field accesses unchecked.

**Action:** Define `RawScenarioRow` interface.

### H-08 -- saveBatch Has No Partial-Failure Handling

**File:** `useWriteBack.ts:59-82`

`Promise.all` fails fast. Partial DB writes + UI rollback = data inconsistency.

**Action:** Use `Promise.allSettled`, report partial success, or add server-side batch endpoint.

---

## MEDIUM

### M-01 -- `TableWrap` Styled Component Is Dead Code

**File:** `ScenarioChart.styles.ts:268-310` -- exported, never imported.

### M-02 -- `CellTooltip` and `EmptyState` Styled Components Unused

**File:** `ScenarioChart.styles.ts:375-425` -- exported, never used.

### M-03 -- `ScenarioRow` Interface Is Unused and Unsound

**File:** `types.ts:32-36` -- dead code with conflicting index signature.

### M-04 -- Inline Styles on Native HTML Elements

**File:** `ScenarioChart.tsx:285,329,338,359` -- bare `<select>` with hardcoded styles. Should use Ant Design `<Select>`.

### M-05 -- Filter Buttons Are Non-Functional

**File:** `ScenarioChart.tsx:149-154,193-198` -- visible "Filter" buttons with no `onClick` handler.

### M-06 -- `bu` Parameter Unused in useGrowthConfig Fetch

**File:** `useGrowthConfig.ts:5,13-16,30` -- accepted but not sent in query, missing from dependency array.

### M-07 -- useOPUConfig Spreads Entire Row into Payload

**File:** `useOPUConfig.ts:55-61` -- `...currentRow` sends all fields including internal ones.

### M-08 -- Health Endpoint Docstring Says "SQLite" but Returns "postgresql"

**File:** `scenario_writeback.py:18,161` -- misleading documentation.

### M-09 -- f-string Logger Calls

**Files:** `scenario_writeback.py:81,84,105,107` -- should use `%s` lazy interpolation.

### M-10 -- controlPanel.ts Imports from Wrong Package

**File:** `controlPanel.ts:19` -- `@apache-superset/core/translation` should be `@superset-ui/core`.

### M-11 -- `ScenarioChartStylesProps` Interface Unused

**File:** `types.ts:21-24` -- orphaned interface.

### M-12 -- `saveBatch` and `isSaving` Returned but Never Used

**File:** `useScenarioData.ts:163-171` -- `ScenarioChart.tsx` only destructures `handleSave`.

---

## LOW

| ID | File | Issue |
| -- | ---- | ----- |
| L-01 | `useGrowthConfig.ts`, `useOPUConfig.ts` | 4-space indent, rest of project uses 2-space |
| L-02 | `useScenarioData.ts:23`, `transformProps.ts:21` | `YEARS` imported from `mockData.ts` in prod code |
| L-03 | `useGrowthConfig.ts`, `useOPUConfig.ts` | Missing ASF license headers (frontend) |
| L-04 | All 3 backend views | Inconsistent error response structure (`json_response` vs `jsonify`) |
| L-05 | `growth_config_view.py`, `opu_config_view.py` | Missing ASF license headers (backend) |
| L-06 | Multiple files | Default business constants (`LNGA`, `existing_assets`) scattered |
| L-07 | `scenario_writeback.py:55-60` | `year` not type-validated (inconsistent with growth view) |

---

## Remediation Roadmap

### Sprint 1 -- Security and Correctness

- H-03/F-01: Remove raw exceptions from responses
- H-01: Add tests for growth/OPU views
- H-06: Remove hardcoded growth asset list
- L-07: Add `year` validation

### Sprint 2 -- Type Safety and Dead Code

- H-02: Replace `any[]` with typed interfaces
- H-07: Type `rawData` rows
- M-01/M-02/M-03/M-11: Remove dead code
- M-10: Fix wrong import path

### Sprint 3 -- Architecture

- H-04: Extract `BaseScenarioView`
- H-05: Extract `useConfigRows<T>`
- H-08: Fix `saveBatch` partial failure
- L-02: Move `YEARS` to `constants.ts`

### Sprint 4 -- Hygiene

- L-03/L-05: Add ASF license headers
- M-09: Fix f-string logger calls
- M-04: Replace inline styles with Ant Design
- L-01: Normalize indentation
