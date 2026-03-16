# Delegate Brief: UI Modernization Phase 2 - Filter Panel

**Date:** 2026-03-15
**Priority:** Medium
**Phase:** Phase 2 of 6 (Filter Panel Modernization)
**Estimate:** 3.5 hours
**Owner:** Subagent (claude/gemini)
**Status:** READY FOR DELEGATION

---

## Mission

Modernize the Filter Panel component to match the approved design mockup with tag-based multi-select filters, section labels, and a Clear All button.

---

## Context of Truth

| Document | Purpose |
|----------|---------|
| `docs/design/new-design.html` | Visual design mockup (Tailwind prototype) |
| `vault/tasks/todo.md` | Task T81, T82, T83 |
| `docs/epics.md` | EPIC-UI-02 (Filter Panel) |
| `superset/superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx` | Target file |

---

## Tasks

### T81 — Update FilterPanel wrapper styling

**File:** `superset/superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx`

**Changes:**
```typescript
const PanelWrapper = styled.div`
  padding: 12px 16px;
  background: #F9FAFB;
  border-bottom: 1px solid #E5E7EB;
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  align-items: flex-end;
`;
```

**Acceptance:** Panel matches mockup spacing and borders

---

### T82 — Convert filter dropdowns to multi-select tags

**File:** `superset/superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx`

**Status:** Already has `mode="multiple"` on all Select components

**Verify:**
- All 4 filters allow multiple selection
- Selected tags display with dismiss X
- Tags have blue-100 background, blue-700 text

**Required styling (if not present):**
```typescript
/* Tag chip styling */
.ant-select-selection-item {
  background: #DBEAFE !important;
  border-color: #BFDBFE !important;
  border-radius: 4px !important;
  color: #1D4ED8 !important;
  font-size: 12px !important;
  font-weight: 500 !important;
}
```

---

### T83 — Add section labels and Clear All button

**File:** `superset/superset-frontend/plugins/plugin-chart-scenario/src/FilterPanel.tsx`

**Status:** Labels already exist; verify Clear All button functionality

**Verify:**
- Labels visible: "Business Unit", "Region / OPU", "Scope", "Emission Source"
- "Clear all" button visible when filters active
- Clicking "Clear all" resets all 4 filters to empty arrays

---

## Design Specifications

### Color Palette
| Token | Value | Usage |
|-------|-------|-------|
| gray-50 | #F9FAFB | Panel background |
| gray-100 | #F3F4F6 | Subtle borders |
| gray-200 | #E5E7EB | Section borders |
| blue-100 | #DBEAFE | Selected tag background |
| blue-700 | #1D4ED8 | Selected tag text |
| indigo-600 | #4F46E5 | Clear all button |

### Spacing Scale (from mockup)
| Component | Padding | Gap |
|-----------|---------|-----|
| Filter Panel | 12px 16px | 12px |
| Filter Field | n/a | 6px |

---

## Acceptance Criteria

| ID | Criteria | Source |
|----|----------|--------|
| AC-Filter-01 | Panel padding matches mockup (12px) | T81 |
| AC-Filter-02 | All filters support multi-select | T82 |
| AC-Filter-03 | Section labels visible | T83 |
| AC-Filter-04 | Clear all resets all filters | T83 |

---

## Files to Review

| File | Purpose |
|------|---------|
| `FilterPanel.tsx` | Filter panel component (T81-T83) |

---

## Pre-Flight Checklist

- [ ] Superset running locally (`npm run dev` on port 9000)
- [ ] Dashboard accessible at `http://localhost:9000/superset/dashboard/scenario-planning/`
- [ ] Check current FilterPanel implementation vs mockup

---

## Responsive Considerations

**Key Concern:** The design mockup (new-design.html) uses `flex-wrap: wrap` for the filter panel. Verify that:
1. Filter tags wrap properly on narrow screens
2. Filter labels remain readable on small viewports
3. Clear all button stays accessible when filters wrap

---

## Next Phase

After Filter Panel is verified, proceed to **Phase 3: Data Table** (T84-T90)

---

## Contact

**Source of Truth:** `vault/tasks/todo.md` (T81-T83)
**Design Reference:** `docs/design/new-design.html`
