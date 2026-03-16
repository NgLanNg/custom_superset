# Delegate Brief: Scenario Planning UI Modernization

**Created:** 2026-03-15
**Priority:** High
**Estimate:** 27.5 hours (~3.5 working days)
**Status:** Ready for Execution

---

## Mission Statement

Modernize the Scenario Planning dashboard UI to match the approved design mockup (`docs/design/new-design.html`). Transform the current functional but utilitarian interface into a polished, professional dashboard with modern visual design.

---

## Context of Truth

| Document | Purpose |
|----------|---------|
| `docs/design/new-design.html` | Visual design mockup (Tailwind prototype) |
| `docs/plans/2026-03-15-scenario-ui-modernization.md` | Implementation plan |
| `docs/epics.md` | Epics and user stories with Gherkin ACs |
| `vault/tasks/todo.md` | Atomic task breakdown (T77-T102) |
| `vault/active_context.md` | Current session context |

---

## Architecture Overview

```
Plugin Location: plugins/plugin-chart-scenario/src/

┌─────────────────────────────────────────────────────────┐
│  ScenarioChart.tsx (main container)                     │
│  ├── Metadata section (name, description, save buttons) │
│  └── Tabs (Equity, Growth, Operational, Registry)       │
│       └── EmissionSourcesTab.tsx                        │
│            ├── FilterPanel.tsx ← T81-T83                │
│            ├── ComparativeChart.tsx ← T91-T94           │
│            └── EditableDataTable.tsx ← T84-T90          │
└─────────────────────────────────────────────────────────┘

New Component: ChangeTracker.tsx ← T80
```

---

## Task Execution Order

### Phase 1: Foundation (T77-T80) — 3.5 hours

```
T77 → T78 → T79 → T80
```

| Task | File | Action | Risk |
|------|------|--------|------|
| T77 | ScenarioChart.styles.ts | Add indigo color tokens | Low |
| T78 | ScenarioChart.styles.ts | Add pulse + chart-pulse keyframes | Low |
| T79 | ScenarioChart.styles.ts | Create ChangeTracker styled components | Low |
| T80 | **NEW** ChangeTracker.tsx | Create component | Low |

**Acceptance:** Color tokens defined; animations work; ChangeTracker component renders

---

### Phase 2: Filter Panel (T81-T83) — 3.5 hours

```
T81 → T82 → T83
```

| Task | File | Action | Risk |
|------|------|--------|------|
| T81 | FilterPanel.tsx | Update wrapper styling | Low |
| T82 | FilterPanel.tsx | Convert to multi-select tags | Medium |
| T83 | FilterPanel.tsx | Add labels + Clear all | Low |

**Acceptance:** Tags display selected values; Clear all resets filters

---

### Phase 3: Data Table (T84-T90) — 8 hours

```
T84 → T85 → T86
         ↓
T87 → T88 → T89 → T90
```

| Task | File | Action | Risk |
|------|------|--------|------|
| T84 | EditableDataTable.tsx | Update wrapper styling | Low |
| T85 | EditableDataTable.tsx | Implement sticky headers | Medium |
| T86 | EditableDataTable.tsx | Implement sticky BU/OPU cols | Medium |
| T87 | EditableDataTable.tsx | Update edited cell styling | Low |
| T88 | EditableDataTable.tsx | Add MOD badge | Low |
| T89 | EditableDataTable.tsx | Add "Was X%" footnote | Medium |
| T90 | EditableDataTable.tsx | Create integrated action header | Medium |

**Acceptance:** Sticky columns work; edited cells show indigo + MOD + Was footnote; action header displays

---

### Phase 4: Chart (T91-T94) — 3.5 hours

```
T91 → T92 → T93 → T94
```

| Task | File | Action | Risk |
|------|------|--------|------|
| T91 | ComparativeChart.tsx | Update wrapper styling | Low |
| T92 | ComparativeChart.tsx | Add gradient fill | Medium |
| T93 | ComparativeChart.tsx | Update legend labels | Low |
| T94 | ComparativeChart.tsx | Add timestamp footer | Low |

**Acceptance:** Chart has gradient; legend shows Scenario A/B; timestamp displays

---

### Phase 5: Integration (T95-T100) — 6.5 hours

```
T95 (requires T80, T90, T93)
T96 → T97 → T98 → T99 → T100
```

| Task | File | Action | Risk |
|------|------|--------|------|
| T95 | EmissionSourcesTab.tsx | Wire ChangeTracker | Medium |
| T96 | ScenarioChart.styles.ts | Standardize card styling | Low |
| T97 | Multiple files | Standardize spacing | Low |
| T98 | EmissionSourcesTab.tsx | Update layout | Low |
| T99 | index.ts | Export ChangeTracker | Low |
| T100 | N/A | Manual visual verification | Low |

**Acceptance:** ChangeTracker shows count; Save/Discard work; 90%+ visual match

---

### Phase 6: QA (T101-T102) — 2.5 hours

```
T101 → T102
```

| Task | File | Action | Risk |
|------|------|--------|------|
| T101 | N/A | Run pre-commit | Low |
| T102 | scenario.spec.ts | Run E2E tests; fix selectors | Medium |

**Acceptance:** Pre-commit passes; all E2E tests pass

---

## Files Summary

### Files to Create (1)
| File | Purpose |
|------|---------|
| `plugins/plugin-chart-scenario/src/ChangeTracker.tsx` | Unsaved changes badge component |

### Files to Modify (7)
| File | Tasks | Scope |
|------|-------|-------|
| `ScenarioChart.styles.ts` | T77, T78, T79, T96, T97 | Color tokens, animations, styled components |
| `FilterPanel.tsx` | T81, T82, T83 | Multi-select tags, labels |
| `EditableDataTable.tsx` | T84, T85, T86, T87, T88, T89, T90 | Sticky cols, edit indicators, action header |
| `ComparativeChart.tsx` | T91, T92, T93, T94 | Gradient, legend, timestamp |
| `EmissionSourcesTab.tsx` | T95, T98 | ChangeTracker integration, layout |
| `index.ts` | T99 | Export ChangeTracker |
| `scenario.spec.ts` | T102 | Update selectors if needed |

---

## Design Specifications

### Color Palette

```typescript
// Indigo (new)
indigo50: '#EEF2FF'
indigo100: '#E0E7FF'
indigo500: '#6366F1'
indigo600: '#4F46E5'
indigo700: '#4338CA'

// Updated grays
gray50: '#F9FAFB'
gray100: '#F3F4F6'
gray200: '#E5E7EB'
gray900: '#111827'
```

### Animations

```css
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

@keyframes chart-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.8; }
}
```

### Key Visual Elements

| Element | Specification |
|---------|---------------|
| Edited cell bg | indigo-50 (#EEF2FF) |
| Edited cell border | 1px indigo-500 |
| MOD badge | 8px, indigo-600 bg, white text, 2px radius |
| Was footnote | 9px, indigo-400, 4px margin-top |
| ChangeTracker badge | indigo-50 pill, pulsing dot, indigo-700 text |
| Filter tags | blue-100 bg, blue-700 text, dismiss X |
| Sticky header | slate-50 (#F8FAFC), z-index: 30 |
| Sticky cols | white bg, z-index: 20, left: 0/50px |

---

## Acceptance Criteria Checklist

| ID | Criteria | Phase |
|----|----------|-------|
| AC-UI-01 | Indigo color palette applied throughout | Phase 1 |
| AC-UI-02 | Filter tags display with dismiss X | Phase 2 |
| AC-UI-03 | Clear all resets all filters | Phase 2 |
| AC-UI-04 | Edited cells show indigo + MOD + Was | Phase 3 |
| AC-UI-05 | ChangeTracker shows count with pulse | Phase 3 |
| AC-UI-06 | Save/Discard buttons functional | Phase 3 |
| AC-UI-07 | Sticky headers visible on scroll | Phase 3 |
| AC-UI-08 | Sticky columns (BU, OPU) visible | Phase 3 |
| AC-UI-09 | Chart gradient fill visible | Phase 4 |
| AC-UI-10 | Legend shows Scenario A/B | Phase 4 |
| AC-UI-11 | Data timestamp displays | Phase 4 |
| AC-UI-12 | Spacing consistent (24/16/12/8px) | Phase 5 |
| AC-UI-13 | Visual match 90%+ to mockup | Phase 5 |
| AC-UI-14 | All E2E tests pass | Phase 6 |

---

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Sticky column z-index conflicts | Medium | Medium | Test with overlapping elements; adjust z-indexes |
| E2E test selector breakage | Medium | High | Preserve data-test attributes; update selectors |
| ECharts gradient API complexity | Low | Medium | Refer to ECharts documentation |
| Multi-select filter behavior regression | Medium | Medium | Test filter thoroughly after changes |
| Animation performance | Low | Low | CSS-only animations; GPU-accelerated |

---

## Pre-Flight Checklist

- [ ] Read `docs/design/new-design.html` thoroughly
- [ ] Read `docs/plans/2026-03-15-scenario-ui-modernization.md`
- [ ] Understand current component structure in `plugin-chart-scenario/src/`
- [ ] Have Superset running locally (`npm run dev` on port 9000)
- [ ] Can access dashboard at `http://localhost:9000/superset/dashboard/scenario-planning/`

---

## Execution Protocol

1. **Start each phase** by reading the relevant source files
2. **Complete tasks in order** within each phase (dependencies matter)
3. **Test incrementally** — verify each task before proceeding
4. **Run pre-commit** after each file modification
5. **Archive any removed code** to `_archive/` — never use `rm`
6. **Preserve data-test attributes** for E2E compatibility

---

## Definition of Done

- [ ] All 26 tasks (T77-T102) completed
- [ ] All 14 acceptance criteria verified
- [ ] Pre-commit passes (`pre-commit run --all-files`)
- [ ] E2E tests pass (`npm run playwright:test`)
- [ ] Visual comparison with mockup at 90%+ accuracy
- [ ] No console errors on dashboard load
- [ ] `vault/active_context.md` updated with session summary

---

## Escape Hatches

**If a task fails 3 times:** Stop and escalate to user. Do not brute-force.

**If E2E tests fail:** Check if it's a selector issue vs. functional regression. Update selectors if needed.

**If stuck on sticky positioning:** Reference the mockup HTML for CSS patterns (`.sticky-col`, `.sticky-header` classes).

---

## Contact

**Source of Truth:** `vault/tasks/todo.md` (T77-T102)
**Design Reference:** `docs/design/new-design.html`
**Plan Document:** `docs/plans/2026-03-15-scenario-ui-modernization.md`
