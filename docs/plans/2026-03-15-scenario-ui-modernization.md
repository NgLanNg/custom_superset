# Scenario Planning UI Modernization Plan

**Date Created:** 2026-03-15
**Status:** Brainstorming Complete
**Priority:** High

---

## Executive Summary

Modernize the Scenario Planning dashboard UI to match the approved design mockup (`docs/design/new-design.html`). This plan covers the transformation from the current functional UI to a polished, professional interface.

---

## Current State vs Target State

### Current State
- Basic Ant Design tables with minimal styling
- Simple dropdown filters
- Functional chart with standard ECharts styling
- Orange highlight for edited cells
- Basic section headers

### Target State (per mockup)
- Modern color palette (blue/indigo accent system)
- Tag-based multi-select filters with chips
- Enhanced chart with gradient fills and polished legend
- Indigo highlight with MOD badges and "Was X%" footnotes
- Professional section headers with accent bars
- Unsaved changes indicator with animated sync dot
- Sticky headers and columns in table
- Integrated action bar with Save/Discard

---

## Implementation Tasks

### Phase 1: Foundation (Design Tokens)
**File:** `plugins/plugin-chart-scenario/src/ScenarioChart.styles.ts`

- [ ] **Task 1.1:** Add indigo color tokens to palette
  ```typescript
  indigo50: '#EEF2FF',
  indigo100: '#E0E7FF',
  indigo500: '#6366F1',
  indigo600: '#4F46E5',
  indigo700: '#4338CA',
  ```
- [ ] **Task 1.2:** Update gray palette to match mockup (slate warmer tones)
- [ ] **Task 1.3:** Add CSS keyframes for pulse animation (sync indicator)
- [ ] **Task 1.4:** Add CSS keyframes for chart-pulse animation

### Phase 2: Filter Panel
**File:** `plugins/plugin-chart-scenario/src/FilterPanel.tsx`

- [ ] **Task 2.1:** Replace single-select dropdowns with multi-select tag UI
- [ ] **Task 2.2:** Add section labels: "Business Unit", "Region" (stacked layout)
- [ ] **Task 2.3:** Implement "Clear all" button
- [ ] **Task 2.4:** Style selected tags with dismiss X buttons
- [ ] **Task 2.5:** Update panel wrapper styling (bg-gray-50, border)

### Phase 3: Data Table
**File:** `plugins/plugin-chart-scenario/src/EditableDataTable.tsx`

- [ ] **Task 3.1:** Update table header styling (sticky-header class equivalent)
- [ ] **Task 3.2:** Implement sticky first column (BU) with `position: sticky; left: 0`
- [ ] **Task 3.3:** Implement sticky second column (OPU) with offset `left: 50px`
- [ ] **Task 3.4:** Create new styled component for edit indicators:
  - Indigo background for edited cells
  - "MOD" badge (small pill, white text, indigo-600 bg)
  - "Was X%" footnote (indigo-400, 9px)
- [ ] **Task 3.5:** Create integrated action header:
  - Section title with accent bar
  - Unsaved changes badge (indigo-50 bg, indigo-700 text)
  - Animated sync indicator (pulsing dot)
  - Discard and Save buttons

### Phase 4: Chart Enhancement
**File:** `plugins/plugin-chart-scenario/src/ComparativeChart.tsx`

- [ ] **Task 4.1:** Add linear gradient fill under baseline area
- [ ] **Task 4.2:** Update legend to show "Scenario A" / "Scenario B" labels
- [ ] **Task 4.3:** Add "Pending Updates" badge with sync indicator
- [ ] **Task 4.4:** Add "Data last updated X minutes ago" footer
- [ ] **Task 4.5:** Enhance chart header with Filter Data button and menu icon

### Phase 5: Layout Polish
**Files:** `ScenarioChart.tsx`, `EmissionSourcesTab.tsx`, styles

- [ ] **Task 5.1:** Update section cards with shadow-sm, rounded-lg borders
- [ ] **Task 5.2:** Standardize padding (16px-20px throughout)
- [ ] **Task 5.3:** Update metadata section styling to match mockup form design
- [ ] **Task 5.4:** Verify all gaps and spacing match mockup (12px, 16px, 20px)

---

## New Components to Create

### 1. `ChangeTracker.tsx` (new)
Displays unsaved changes badge with animated indicator.

```typescript
interface ChangeTrackerProps {
  editCount: number;
  onDiscard: () => void;
  onSave: () => void;
}
```

### 2. `FilterSection.tsx` (new, optional)
Encapsulates the stacked filter UI with labels.

---

## Visual Design Specifications

### Color Palette
```
Primary Blue: #2563EB (blue-600)
Accent Indigo: #6366F1 (indigo-500)
Background: #F9FAFB (gray-50)
Surface: #FFFFFF (white)
Text Primary: #111827 (gray-900)
Text Secondary: #6B7280 (gray-500)
Border: #E5E7EB (gray-200)
```

### Typography
```
Font: Inter (400, 500, 600, 700)
Base Size: 14px
Small: 12px
Tiny: 11px
```

### Spacing Scale
```
xs: 4px
sm: 8px
md: 12px
lg: 16px
xl: 20px
2xl: 24px
```

### Border Radius
```
sm: 4px
md: 6px
lg: 8px
```

---

## Acceptance Criteria

1. **Visual Fidelity:** UI matches mockup at 90%+ accuracy
2. **Edit Feedback:** Edited cells clearly show:
   - Indigo background
   - MOD badge
   - Original value ("Was X%")
3. **Change Tracking:**
   - Badge shows correct count
   - Animated sync dot pulses
   - Save/Discard buttons work
4. **Filter UX:**
   - Tags display selected values
   - Clear all resets all filters
   - Multi-select works correctly
5. **Table Usability:**
   - Sticky columns stay fixed on scroll
   - Headers remain visible
   - Horizontal scroll works smoothly
6. **Chart Polish:**
   - Gradient fill visible
   - Legend shows both scenarios
   - Sync status indicator works

---

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| E2E test failures | Medium | High | Preserve data-test attributes; update selectors as needed |
| Sticky column z-index conflicts | Medium | Medium | Test carefully with overlapping elements |
| Animation performance | Low | Low | Use CSS-only animations, GPU-accelerated transforms |
| Design inconsistency | Low | Medium | Reference mockup constantly; pixel check before merge |

---

## Testing Strategy

### Visual Testing
1. Side-by-side comparison with mockup
2. Screenshot key states (empty, loaded, edited, saved)
3. Verify responsive behavior at 3 viewport widths

### Functional Testing
1. Edit cells and verify MOD badge appears
2. Verify "Was X%" shows correct original value
3. Test Save/Discard buttons
4. Test filter multi-select and clear all
5. Scroll table horizontally, verify sticky columns

### Regression Testing
1. Run existing Playwright E2E tests
2. Verify no new console errors
3. Check performance (no jank on scroll/resize)

---

## Files Summary

| File | Action | Scope |
|------|--------|-------|
| `ScenarioChart.styles.ts` | Modify | Add tokens, animations |
| `FilterPanel.tsx` | Rewrite | New tag-based UI |
| `EditableDataTable.tsx` | Modify | Sticky cols, edit indicators, action header |
| `ComparativeChart.tsx` | Modify | Gradient, legend, footer |
| `EmissionSourcesTab.tsx` | Modify | Layout, change tracker integration |
| `ScenarioChart.tsx` | Minor | Styling consistency |
| `ChangeTracker.tsx` | Create | New component |

---

## Implementation Order

1. Design tokens (foundation first)
2. Filter panel (independent, low risk)
3. Data table (core functionality)
4. Chart enhancement (visual polish)
5. Layout polish (final pass)

---

## Notes

- **Do NOT use rm** - Archive any removed code to `_archive/`
- **Preserve data-test attributes** for E2E compatibility
- **Run pre-commit** before committing
- **Update this doc** with any deviations discovered during implementation
