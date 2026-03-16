---
type: epics
date: 2026-03-12
author: Antigravity
project: Slide 1 — OPU GHG Summary Sheet (Superset)
source: {TBD PRD/Confluence}
---

# Epics and Stories

## Epic 1: Data Readiness (Gold Tables Available)
- Status: backlog
- Note: Depends on confirmation that `gold_summary_sheet` and `gold_decarb_capex` exist in target Postgres/Superset.

### Story 1.1: Confirm gold table availability
As a dashboard developer, I want to verify that `gold_summary_sheet` and `gold_decarb_capex` are materialized in the warehouse so that Superset datasets can be created.
- Acceptance Criteria:
  - Given I can query the warehouse, when I check for both tables, then I see them present with non-empty rows.
  - Given the tables exist, when I inspect columns, then schemas match slide_01.md definitions.

### Story 1.2: Validate data freshness
As a dashboard consumer, I want data to reflect the latest dbt run so that metrics are up-to-date.
- Acceptance Criteria:
  - Given I query `updated_at`, when I compare to latest dbt build time, then data is within agreed freshness SLO (TBD).

## Epic 2: Superset Datasets
- Status: backlog
- Depends on: Epic 1

### Story 2.1: Create dataset for gold_summary_sheet
As a dashboard developer, I want a Superset dataset pointing to `gold_summary_sheet` so that panels can be built.
- Acceptance Criteria:
  - Given Superset UI, when I create the dataset, then all columns (category, metric, type, uom, year, value) are available.
  - Given the dataset, when I preview data, then rows appear for both OC and ES types.

### Story 2.2: Create dataset for gold_decarb_capex
As a dashboard developer, I want a Superset dataset pointing to `gold_decarb_capex` so that the top band can be built.
- Acceptance Criteria:
  - Given Superset UI, when I create the dataset, then columns (kpi, lever, year, value) are available.
  - Given the dataset, when I preview data, then OC, ES, and CAPEX rows appear.

## Epic 3: Charts
- Status: backlog
- Depends on: Epic 2

### Story 3.1: Top band charts (OC/ES reduction and CAPEX)
As an exec viewer, I want OC/ES reduction and CAPEX by lever/year so that I can see decarb impact and spend.
- Acceptance Criteria:
  - Given dataset DS2, when I filter kpi IN (OC, ES), then a grouped bar (or line) shows values by lever/year.
  - Given dataset DS2, when I filter kpi = CAPEX, then a bar shows CAPEX RM Million by lever/year.

### Story 3.2: Left panel (Operational Control)
As an exec viewer, I want OC GHG intensity, total emission, upon reduction, and production so that I can assess OC basis.
- Acceptance Criteria:
  - Given type = 'operational control', when I render stacked area/lines, then intensity and emissions appear by year.
  - Given type = 'operational control' and category = 'Production', when I render table, then production metrics with uom appear.

### Story 3.3: Right panel (Equity Share)
As an exec viewer, I want ES GHG intensity, total emission, upon reduction, and production so that I can assess ES basis.
- Acceptance Criteria:
  - Given type = 'equity share', when I render stacked area/lines, then intensity and emissions appear by year.
  - Given type = 'equity share' and category = 'Production', when I render table, then production metrics with uom appear.

## Epic 4: Dashboard Assembly
- Status: backlog
- Depends on: Epic 3

### Story 4.1: Create dashboard shell
As a dashboard developer, I want a Superset dashboard named "OPU GHG Summary Sheet" so that charts can be placed.
- Acceptance Criteria:
  - Given Superset UI, when I create the dashboard, then it is accessible to intended viewers.

### Story 4.2: Layout panels
As a dashboard developer, I want top band and left/right panels arranged per slide_01 so that layout matches reference.
- Acceptance Criteria:
  - Given charts C1–C10, when I place them, then top band spans width and OC/ES panels split horizontally.

### Story 4.3: Add filters
As a dashboard consumer, I want filters (year range, OPU) so that I can slice the data.
- Acceptance Criteria:
  - Given dashboard filters, when I apply year or OPU, then all charts cross-filter consistently.

## Epic 5: Verification
- Status: backlog
- Depends on: Epic 4

### Story 5.1: Visual fidelity vs reference
As a stakeholder, I want the Superset dashboard to match Slide 1 so that migration from Tableau is acceptable.
- Acceptance Criteria:
  - Given the reference slide, when I compare, then all sections and labels are present and legible.

### Story 5.2: Data accuracy spot-check
As a stakeholder, I want to trust the numbers so that decisions are sound.
- Acceptance Criteria:
  - Given sampled years/levers, when I query warehouse directly, then chart values match SQL results.

### Story 5.3: Performance check
As a stakeholder, I want acceptable load time so that users aren’t blocked.
- Acceptance Criteria:
  - Given dashboard load, when I measure, then charts render within 5 seconds under typical filters.

---

# Scenario Creation Page — Epics and Stories

> **Source:** `vault/expect/desc.md`
> **Spec:** `docs/specs/2026-03-12-scenario-creation-page.md`
> **Status:** Draft

## Requirements Traceability Matrix

| FR ID | Requirement | Epic | Story |
|-------|-------------|------|-------|
| FR-001 | Scenario metadata entry (Name, Description) | E6 | S6.1 |
| FR-002 | Save Draft action | E6 | S6.2 |
| FR-003 | Submit for Approval action | E6 | S6.3 |
| FR-004 | Top-level tab navigation (Equity, Growth, OPU) | E7 | S7.1 |
| FR-005 | Sub-tab navigation (6 OPU data tabs) | E7 | S7.2 |
| FR-006 | Comparative chart with GHG emissions | E8 | S8.1 |
| FR-007 | Dynamic chart title based on filters | E8 | S8.2 |
| FR-008 | Filter panel (BU, OPU, Scope, Sources) | E8 | S8.3 |
| FR-009 | Cross-filter synchronization (chart + table) | E8 | S8.4 |
| FR-010 | Excel-style data table with year columns | E9 | S9.1 |
| FR-011 | Dynamic table title based on filters | E9 | S9.2 |
| FR-012 | Editable cells with persistence | E9 | S9.3 |
| NFR-001 | Page load < 5 seconds | E10 | S10.1 |
| NFR-002 | Authentication required | E10 | S10.2 |

---

## Epic 6: Scenario Metadata Management

> **Objective:** Enable users to create, name, describe, and manage scenario lifecycle.

### Story S6.1: Create Scenario with Metadata

**As a** scenario analyst,
**I want to** enter a scenario name and description,
**So that** I can identify and describe my scenario for future reference.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Enter scenario metadata
  Given I am on the Scenario Creation page
  When I enter "Q1 2026 Forecast" in the Name field
  And I enter "Annual emission forecast for Q1" in the Description field
  Then the Name field should display "Q1 2026 Forecast"
  And the Description field should display "Annual emission forecast for Q1"

Scenario: Name field is required
  Given I am on the Scenario Creation page
  When I leave the Name field empty
  And I click Save Draft
  Then an error message "Name is required" should be displayed
  And the scenario should not be saved
```

**Tasks:** T50 (DB), T54 (UI), validation logic
**Estimate:** 2 story points

---

### Story S6.2: Save Draft

**As a** scenario analyst,
**I want to** save my scenario as a draft,
**So that** I can continue editing it later without submitting for approval.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Save scenario as draft
  Given I have entered scenario name "Draft Scenario"
  When I click the "Save Draft" button
  Then the scenario status should be "draft"
  And a success notification "Scenario saved as draft" should appear
  And the scenario should remain editable

Scenario: Draft persists across sessions
  Given I have saved a scenario as draft
  When I navigate away and return to the scenario
  Then the scenario name and description should be preserved
  And the status should remain "draft"
```

**Tasks:** T52 (API), T54 (UI), localStorage
**Estimate:** 3 story points

---

### Story S6.3: Submit for Approval

**As a** scenario analyst,
**I want to** submit my scenario for approval,
**So that** it can be reviewed and approved by authorized users.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Submit scenario for approval
  Given I have a complete scenario with name "Q1 2026 Forecast"
  And the scenario status is "draft"
  When I click the "Submit for Approval" button
  Then the scenario status should change to "pending_approval"
  And a success notification "Scenario submitted for approval" should appear
  And the scenario should no longer be editable
```

**Tasks:** T52 (API), T54 (UI), status lock
**Estimate:** 3 story points

---

## Epic 7: Tab Navigation

> **Objective:** Enable users to navigate between configuration sections.

### Story S7.1: Top-Level Tab Navigation

**As a** scenario analyst,
**I want to** switch between Equity Share, Growth, and OPU Configuration tabs,
**So that** I can configure different aspects of my scenario.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Switch between top-level tabs
  Given I am on the Scenario Creation page
  When I click the "OPU Configuration" tab
  Then the OPU Configuration tab should be active
  And the sub-tab navigation should be visible
```

**Tasks:** T54 (component)
**Estimate:** 2 story points

---

### Story S7.2: Sub-Tab Navigation for OPU Configuration

**As a** scenario analyst,
**I want to** navigate between 6 OPU data sub-tabs,
**So that** I can view and edit different datasets.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: View OPU sub-tabs
  Given I have selected the "OPU Configuration" tab
  Then I should see 6 sub-tabs:
    | Emission by Sources | Production | Emission by Gases |
    | Energy Consumption  | Intensity  | Reduction         |

Scenario: Switch between sub-tabs
  Given I am on the "Emission by Sources" sub-tab
  When I click the "Production" sub-tab
  Then the Production sub-tab should be active
  And the table should display Production data
```

**Tasks:** T54 (component), data source mapping
**Estimate:** 3 story points

---

## Epic 8: Comparative Chart and Filtering

> **Objective:** Enable users to visualize and filter GHG emissions data.

### Story S8.1: Comparative GHG Emissions Chart

**As a** scenario analyst,
**I want to** view a comparative total GHG emissions chart,
**So that** I can understand the emission trends across years.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Chart renders with data
  Given I am on the "Emission by Sources" sub-tab
  Then a line chart should be displayed
  And the chart should show Total GHG Emissions on the Y-axis
  And the chart should show Year (2019-2050) on the X-axis

Scenario: Chart updates on data edit
  Given I am viewing the comparative chart
  When I edit a cell value in the data table
  Then the chart should update to reflect the new value
```

**Tasks:** T55 (component), data query
**Estimate:** 5 story points

---

### Story S8.2: Dynamic Chart Title

**As a** scenario analyst,
**I want to** see the chart title update based on my filter selection,
**So that** I know exactly what data is being displayed.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Default chart title
  Given no filters are selected
  Then the chart title should be "Comparative Total GHG Emissions"

Scenario: Chart title with BU filter
  Given I have selected BU = "LNGA"
  Then the chart title should be "Comparative Total GHG Emissions – LNGA"
```

**Tasks:** T55 (title logic)
**Estimate:** 2 story points

---

### Story S8.3: Filter Panel

**As a** scenario analyst,
**I want to** filter data by BU, OPU, Scope, and Sources,
**So that** I can focus on specific subsets of data.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Filter panel displays
  Given I am on the "Emission by Sources" sub-tab
  Then I should see a filter panel with 4 dropdowns:
    | BU | OPU | Scope | Sources |

Scenario: Select filter value
  Given I click the BU dropdown
  When I select "LNGA"
  Then the BU filter should display "LNGA"
  And the chart and table should update to show only LNGA data
```

**Tasks:** T56 (component), value fetching
**Estimate:** 5 story points

---

### Story S8.4: Cross-Filter Synchronization

**As a** scenario analyst,
**I want to** see both the chart and table update when I change filters,
**So that** I have a consistent view of the filtered data.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Filter applies to both chart and table
  Given I am viewing the comparative chart and data table
  When I select BU = "LNGA"
  Then the chart should show only LNGA data
  And the table should show only LNGA rows
```

**Tasks:** T56 (shared state), T55/T57 (subscription)
**Estimate:** 3 story points

---

## Epic 9: Editable Data Table

> **Objective:** Enable users to view and edit emission data in an Excel-style table.

### Story S9.1: Excel-Style Data Table

**As a** scenario analyst,
**I want to** view emission data in an Excel-style table with year columns,
**So that** I can easily compare values across years.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Table structure
  Given I am on the "Emission by Sources" sub-tab
  Then the table should have the following columns:
    | BU | OPU | Scope | Source | 2019 | 2020 | ... | 2050 |
  And each year should be a separate column
```

**Tasks:** T57 (component), pivot transformation
**Estimate:** 5 story points

---

### Story S9.2: Dynamic Table Title

**As a** scenario analyst,
**I want to** see the table title update based on my filter selection,
**So that** I know exactly what data is being displayed.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Default table title
  Given no filters are selected
  Then the table title should be "Operational Control – Emission by Sources"

Scenario: Table title with BU filter
  Given I have selected BU = "LNGA"
  Then the table title should be "Operational Control – Emission by Sources – LNGA"
```

**Tasks:** T57 (title logic)
**Estimate:** 1 story point

---

### Story S9.3: Editable Cells with Persistence

**As a** scenario analyst,
**I want to** edit cell values directly in the table,
**So that** I can modify scenario data efficiently.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Edit cell value
  Given I am viewing the data table
  When I click on a cell and enter "50"
  Then the cell should display "50"
  And the chart should update to reflect the new value

Scenario: Cell edit persists
  Given I have edited a cell value to "50"
  When I refresh the page
  Then the cell should still display "50"

Scenario: Invalid value rejection
  Given I am editing a cell
  When I enter "-10"
  Then an error message should appear "Value must be >= 0"
```

**Tasks:** T57 (EditableCell), T53 (API), validation
**Estimate:** 5 story points

---

## Epic 10: Non-Functional Requirements

> **Objective:** Ensure performance, security, and quality standards.

### Story S10.1: Page Performance

**As a** system administrator,
**I want to** ensure the page loads within acceptable time limits,
**So that** users have a responsive experience.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Page load time
  Given I am on the Scenario Creation page
  When the page finishes loading
  Then the load time should be less than 5 seconds
```

**Tasks:** Query caching, loading states
**Estimate:** 3 story points

---

### Story S10.2: Authentication Required

**As a** security administrator,
**I want to** ensure only authenticated users can access the scenario page,
**So that** unauthorized users cannot modify data.

#### Acceptance Criteria (Gherkin)

```gherkin
Scenario: Unauthenticated access blocked
  Given I am not logged in
  When I navigate to /scenario/create
  Then I should be redirected to the login page
```

**Tasks:** Route protection, @has_access_api
**Estimate:** 2 story points

---

## Story Summary

| Epic | Story | Points | Priority |
|------|-------|--------|----------|
| E6: Metadata | S6.1 Create Scenario | 2 | P0 |
| E6: Metadata | S6.2 Save Draft | 3 | P0 |
| E6: Metadata | S6.3 Submit for Approval | 3 | P1 |
| E7: Navigation | S7.1 Top-Level Tabs | 2 | P0 |
| E7: Navigation | S7.2 Sub-Tabs | 3 | P0 |
| E8: Chart/Filter | S8.1 Comparative Chart | 5 | P0 |
| E8: Chart/Filter | S8.2 Dynamic Chart Title | 2 | P1 |
| E8: Chart/Filter | S8.3 Filter Panel | 5 | P0 |
| E8: Chart/Filter | S8.4 Cross-Filter Sync | 3 | P0 |
| E9: Table | S9.1 Excel-Style Table | 5 | P0 |
| E9: Table | S9.2 Dynamic Table Title | 1 | P1 |
| E9: Table | S9.3 Editable Cells | 5 | P0 |
| E10: NFR | S10.1 Performance | 3 | P1 |
| E10: NFR | S10.2 Authentication | 2 | P0 |

**Total:** 44 story points

---

## Sprint Planning Suggestion

### Sprint 1 (18 points) — Core Infrastructure
- S6.1 Create Scenario (2)
- S7.1 Top-Level Tabs (2)
- S7.2 Sub-Tabs (3)
- S8.1 Comparative Chart (5)
- S10.2 Authentication (2)
- S9.1 Excel-Style Table (5) — stretch

### Sprint 2 (18 points) — Filtering & Editing
- S6.2 Save Draft (3)
- S8.3 Filter Panel (5)
- S8.4 Cross-Filter Sync (3)
- S9.3 Editable Cells (5)
- S6.3 Submit for Approval (3) — stretch

### Sprint 3 (8 points) — Polish & NFRs
- S8.2 Dynamic Chart Title (2)
- S9.2 Dynamic Table Title (1)
- S10.1 Performance (3)
- Buffer for bugs/refinements (2)

---

# Scenario Planning UI Modernization — Epics and Stories

**Date Created:** 2026-03-15
**Project:** Scenario Planning Dashboard — UI Modernization
**Track:** Frontend Modernization
**Priority:** High
**Source:** `docs/design/new-design.html`, `docs/plans/2026-03-15-scenario-ui-modernization.md`

---

## Requirements Traceability Matrix

| FR ID | Requirement | Source | Epic | Stories |
|-------|-------------|--------|------|---------|
| FR-01 | Modern color palette with blue/indigo accents | Design Mockup | EPIC-UI-01 | US-UI-01-01 |
| FR-02 | Tag-based multi-select filters | Design Mockup | EPIC-UI-02 | US-UI-02-01, US-UI-02-02, US-UI-02-03 |
| FR-03 | Visual feedback for edited cells (indigo + MOD badge + Was X%) | Design Mockup | EPIC-UI-03 | US-UI-03-01, US-UI-03-02, US-UI-03-03 |
| FR-04 | Unsaved changes tracking with animated indicator | Design Mockup | EPIC-UI-03 | US-UI-03-04, US-UI-03-05 |
| FR-05 | Sticky table headers and columns | Design Mockup | EPIC-UI-04 | US-UI-04-01, US-UI-04-02 |
| FR-06 | Chart with gradient fills and enhanced legend | Design Mockup | EPIC-UI-05 | US-UI-05-01, US-UI-05-02, US-UI-05-03 |
| FR-07 | Consistent spacing and typography | Design Mockup | EPIC-UI-06 | US-UI-06-01, US-UI-06-02 |

---

## Non-Functional Requirements

| NFR ID | Requirement | Acceptance Test |
|--------|-------------|-----------------|
| NFR-UI-01 | Performance: No jank on scroll | Scroll at 60fps on mid-range devices |
| NFR-UI-02 | Accessibility: Keyboard navigation | All interactive elements focusable via Tab |
| NFR-UI-03 | Responsive: Works at 1280px+ width | No horizontal page scroll, content adapts |
| NFR-UI-04 | E2E Compatibility: Preserve test selectors | All existing Playwright tests pass |
| NFR-UI-05 | No console errors | Chrome DevTools console clean on load |

---

## EPIC-UI-01: Design Foundation & Tokens

**Status:** Backlog
**Priority:** High
**Description:** Establish the visual design system foundation with updated color palette, typography, and animation keyframes that match the approved mockup.

**Business Value:** Consistent visual language across the entire dashboard; enables all subsequent UI modernization work.

**Technical Notes:** All changes confined to `ScenarioChart.styles.ts`. No behavioral changes.

---

### US-UI-01-01: Implement Modern Color Palette and Animations

**As a** frontend developer,
**I want** updated design tokens in the styles file,
**So that** all components can use the new blue/indigo color system and animations.

#### Acceptance Criteria

```gherkin
Scenario: Indigo color tokens are available
  Given the ScenarioChart.styles.ts file
  When the indigo palette is added
  Then these colors should be defined:
    | Token | Value |
    | indigo50 | #EEF2FF |
    | indigo100 | #E0E7FF |
    | indigo500 | #6366F1 |
    | indigo600 | #4F46E5 |
    | indigo700 | #4338CA |

Scenario: Gray palette uses warmer slate tones
  Given the existing gray palette
  When updated to match mockup
  Then colors should match:
    | Token | Value |
    | gray50 | #F9FAFB |
    | gray100 | #F3F4F6 |
    | gray200 | #E5E7EB |
    | gray900 | #111827 |

Scenario: Pulse animation is defined
  Given the styled-components file
  When CSS keyframes for pulse are added
  Then the animation should:
    | 0%, 100% | opacity: 1 |
    | 50% | opacity: 0.4 |

Scenario: Chart-pulse animation is defined
  Given the styled-components file
  When CSS keyframes for chart-pulse are added
  Then the animation should:
    | 0%, 100% | opacity: 1 |
    | 50% | opacity: 0.8 |
```

#### Definition of Done
- [ ] All color tokens added to `ScenarioChart.styles.ts`
- [ ] Pulse animation keyframes defined
- [ ] Chart-pulse animation keyframes defined
- [ ] No TypeScript errors
- [ ] Pre-commit hooks pass

**Estimate:** 2 story points

---

## EPIC-UI-02: Filter Panel Modernization

**Status:** Backlog
**Priority:** High
**Description:** Transform the filter panel from basic dropdowns to a modern tag-based multi-select interface with clear visual hierarchy and quick-clear functionality.

**Business Value:** Improved user experience with more intuitive filter management; reduces clicks to apply/clear filters.

---

### US-UI-02-01: Implement Tag-Based Multi-Select UI

**As a** scenario analyst,
**I want** to select multiple filter values with visual tags,
**So that** I can see all active filters at a glance and dismiss them individually.

#### Acceptance Criteria

```gherkin
Scenario: Filter tags display selected values
  Given the FilterPanel component
  When a user selects multiple values from BU dropdown
  Then each selected value displays as a tag chip with:
    | Background | blue-100 (#DBEAFE) |
    | Text color | blue-700 (#1D4ED8) |
    | Dismiss X button | on the right |

Scenario: Individual tag dismissal
  Given a filter tag is displayed
  When the user clicks the X button
  Then that specific filter value is removed
  And the remaining tags stay visible
  And the underlying data refreshes
```

#### Definition of Done
- [ ] Multi-select tags render correctly
- [ ] Individual tag dismissal works
- [ ] data-test attributes preserved
- [ ] Visual match with mockup

**Estimate:** 5 story points

---

### US-UI-02-02: Implement Section Labels and Clear All

**As a** scenario analyst,
**I want** labeled filter sections and a "Clear all" button,
**So that** I understand what each filter group represents and can quickly reset all filters.

#### Acceptance Criteria

```gherkin
Scenario: Filter section labels display
  Given the filter panel renders
  Then filters display under labeled sections:
    | "Business Unit" | above BU filter |
    | "Region" | above OPU filter |

Scenario: Clear all resets all filters
  Given one or more filters are active
  When the user clicks "Clear all"
  Then all filter selections are cleared
  And the filter panel returns to empty state
  And the data refreshes to show all results
```

#### Definition of Done
- [ ] Section labels display correctly
- [ ] "Clear all" button visible when filters active
- [ ] Clear all resets all filter state
- [ ] Data refreshes after clear

**Estimate:** 3 story points

---

### US-UI-02-03: Update Filter Panel Styling

**As a** UI consumer,
**I want** the filter panel to have consistent styling with the mockup,
**So that** the interface feels cohesive and professional.

#### Acceptance Criteria

```gherkin
Scenario: Filter panel background and border
  Given the FilterPanel wrapper component
  When rendered
  Then the panel has:
    | Background | #F9FAFB (gray-50) |
    | Border | 1px solid #E5E7EB (gray-200) |
    | Padding | 12px |
    | Gap between elements | 12px |
```

#### Definition of Done
- [ ] Background color matches mockup
- [ ] Border styling correct
- [ ] Spacing matches design spec

**Estimate:** 2 story points

---

## EPIC-UI-03: Edit Feedback & Change Tracking

**Status:** Backlog
**Priority:** Critical
**Description:** Create a comprehensive system for visualizing and managing cell edits, including real-time feedback, change counting, and save/discard actions.

**Business Value:** Users have clear visibility into what they've changed; reduces errors and improves confidence in data entry.

---

### US-UI-03-01: Implement Indigo Edit Cell Highlighting

**As a** scenario planner,
**I want** edited cells to have indigo background,
**So that** I can immediately identify which values I've modified.

#### Acceptance Criteria

```gherkin
Scenario: Edited cell shows indigo background
  Given a data cell in the table
  When the user edits the cell value
  Then the cell background changes to indigo-50 (#EEF2FF)
  And the cell has a 1px indigo-500 border
```

#### Definition of Done
- [ ] Edited cells show indigo background
- [ ] Border styling applied
- [ ] Unedited cells remain unchanged

**Estimate:** 3 story points

---

### US-UI-03-02: Implement MOD Badge for Edited Cells

**As a** scenario planner,
**I want** edited cells to show a "MOD" badge,
**So that** I have an explicit indicator that the value has been modified.

#### Acceptance Criteria

```gherkin
Scenario: MOD badge displays on edited cells
  Given a cell has been edited
  When the cell renders
  Then a "MOD" badge displays with:
    | Font size | 8px |
    | Background | indigo-600 (#4F46E5) |
    | Text color | white |
    | Border radius | 2px |
    | Position | right side of the value |
```

#### Definition of Done
- [ ] MOD badge renders on edited cells
- [ ] Badge styling matches mockup
- [ ] Badge position is correct

**Estimate:** 3 story points

---

### US-UI-03-03: Implement "Was X%" Footnote for Edited Cells

**As a** scenario planner,
**I want** to see the original value below edited cells,
**So that** I can compare what I changed it from.

#### Acceptance Criteria

```gherkin
Scenario: Original value footnote displays
  Given a cell was edited from 70% to 65%
  When the cell renders after edit
  Then below the new value displays:
    | Text | "Was 70%" |
    | Color | indigo-400 |
    | Font size | 9px |
    | Margin top | 4px |
```

#### Definition of Done
- [ ] Original value displays below edited value
- [ ] "Was" prefix included
- [ ] Correct color and sizing
- [ ] Original value updates when cell is edited again

**Estimate:** 3 story points

---

### US-UI-03-04: Create ChangeTracker Component

**As a** frontend developer,
**I want** a reusable ChangeTracker component,
**So that** unsaved changes can be displayed consistently across the UI.

#### Acceptance Criteria

```gherkin
Scenario: ChangeTracker renders with edit count
  Given the new ChangeTracker.tsx component
  When rendered with editCount={3}
  Then the component displays:
    | Background | indigo-50 (#EEF2FF) pill |
    | Animated dot | pulsing, indigo-600 |
    | Text | "3 unsaved changes" |
    | Text color | indigo-700 |
    | Font | uppercase tracking-tight |

Scenario: ChangeTracker provides callbacks
  Given the ChangeTracker component
  When onDiscard or onSave callbacks are provided
  Then Discard and Save buttons are available
  And clicking them triggers the respective callbacks
```

#### Definition of Done
- [ ] Component created in plugin-chart-scenario/src/
- [ ] Props interface defined (editCount, onDiscard, onSave)
- [ ] Pulse animation works
- [ ] Buttons trigger callbacks
- [ ] Exported for use in other components

**Estimate:** 5 story points

---

### US-UI-03-05: Integrate ChangeTracker into Table Header

**As a** scenario planner,
**I want** to see the unsaved changes count in the table header,
**So that** I know when I need to save my work.

#### Acceptance Criteria

```gherkin
Scenario: Table header shows change tracker
  Given the EditableDataTable component
  When cells have been edited but not saved
  Then the table header displays:
    | Section title | with accent bar |
    | ChangeTracker badge | showing count |
    | Discard and Save buttons |

Scenario: ChangeTracker hidden when no edits
  Given all edits have been saved
  When the edit count is zero
  Then the ChangeTracker badge is hidden
  And Save button is disabled or hidden
```

#### Definition of Done
- [ ] ChangeTracker integrated into EditableDataTable
- [ ] Badge visibility toggles with edit count
- [ ] Save/Discard buttons functional

**Estimate:** 3 story points

---

## EPIC-UI-04: Table Usability Enhancements

**Status:** Backlog
**Priority:** High
**Description:** Implement sticky headers and columns to improve data scanning and navigation in wide tables.

**Business Value:** Users can navigate large datasets without losing context; improves efficiency for power users.

---

### US-UI-04-01: Implement Sticky Table Headers

**As a** scenario analyst,
**I want** table headers to remain visible when scrolling vertically,
**So that** I always know which column I'm viewing.

#### Acceptance Criteria

```gherkin
Scenario: Headers remain visible on scroll
  Given a data table with many rows
  When the user scrolls down
  Then the header row stays fixed at the top
  And has:
    | Background | #F8FAFC (slate-50) |
    | z-index | 30 |
    | Proper shadow | for depth |
```

#### Definition of Done
- [ ] Headers remain visible on vertical scroll
- [ ] Header styling matches mockup
- [ ] z-index prevents overlap issues

**Estimate:** 3 story points

---

### US-UI-04-02: Implement Sticky First Two Columns

**As a** scenario analyst,
**I want** the BU and OPU columns to remain visible when scrolling horizontally,
**So that** I always know which row I'm viewing.

#### Acceptance Criteria

```gherkin
Scenario: BU column stays fixed on horizontal scroll
  Given a wide table requiring horizontal scroll
  When the user scrolls right
  Then the BU column stays fixed at left: 0
  And the OPU column stays fixed at left: 50px (or computed width)
  And both have:
    | Background | white |
    | z-index | 20 |
    | Proper shadow | on right edge |

Scenario: Hover state applies to sticky columns
  Given the sticky columns
  When hovering over rows
  Then the hover state applies to both sticky and scrollable cells
```

#### Definition of Done
- [ ] BU column sticky on left edge
- [ ] OPU column sticky next to BU
- [ ] No visual glitch on column boundaries
- [ ] Hover state works correctly

**Estimate:** 5 story points

---

## EPIC-UI-05: Chart Visualization Polish

**Status:** Backlog
**Priority:** Medium
**Description:** Enhance the comparative chart with gradient fills, improved legends, and status indicators for a more polished presentation.

**Business Value:** Better visual communication of scenario comparisons; professional appearance for executive presentations.

---

### US-UI-05-01: Add Gradient Fill Under Baseline Series

**As a** scenario analyst,
**I want** the baseline series to have a gradient fill,
**So that** the chart has visual depth and the baseline is clearly distinguished.

#### Acceptance Criteria

```gherkin
Scenario: Baseline series has gradient fill
  Given the ECharts comparative chart
  When the chart renders
  Then the baseline series has:
    | Gradient | linear from blue-500 (8% opacity) to transparent |
    | Direction | top to bottom |
    | Fill area | under the line |
```

#### Definition of Done
- [ ] Gradient defined in chart options
- [ ] Gradient applies to baseline series
- [ ] Visual match with mockup

**Estimate:** 3 story points

---

### US-UI-05-02: Update Chart Legend with Scenario Labels

**As a** scenario analyst,
**I want** the chart legend to show "Scenario A" and "Scenario B" labels,
**So that** I can distinguish between baseline and scenario projections.

#### Acceptance Criteria

```gherkin
Scenario: Legend displays scenario labels
  Given the chart legend
  When the chart renders
  Then the legend displays:
    | "Scenario A" | with blue circle indicator |
    | "Scenario B" | with indigo line indicator |
    | "Pending Updates" badge | if edits exist (indigo-50 bg) |
```

#### Definition of Done
- [ ] Legend labels updated
- [ ] Indicators match series styling
- [ ] Pending updates badge conditional

**Estimate:** 3 story points

---

### US-UI-05-03: Add Data Freshness Timestamp

**As a** scenario analyst,
**I want** to see when the data was last updated,
**So that** I know if I'm looking at current information.

#### Acceptance Criteria

```gherkin
Scenario: Timestamp displays below chart
  Given the chart component
  When the chart renders
  Then below the chart displays:
    | Text | "Data last updated X minutes ago" |
    | Color | gray-400 |
    | Font size | 11px |
    | Font style | italic |
```

#### Definition of Done
- [ ] Timestamp displays correctly
- [ ] Time value updates based on last fetch
- [ ] Styling matches mockup

**Estimate:** 2 story points

---

## EPIC-UI-06: Layout & Spacing Standardization

**Status:** Backlog
**Priority:** Medium
**Description:** Apply consistent spacing, borders, and typography across all components to create a cohesive visual experience.

**Business Value:** Professional, polished interface that feels intentional and well-designed.

---

### US-UI-06-01: Update Section Cards with Modern Styling

**As a** UI consumer,
**I want** section cards to have consistent borders and shadows,
**So that** the interface has visual depth and hierarchy.

#### Acceptance Criteria

```gherkin
Scenario: Section cards have consistent styling
  Given any section card (ChartPanel, SectionCard)
  When rendered
  Then the card has:
    | Background | white |
    | Border | 1px solid gray-200 |
    | Border radius | 8px (rounded-lg) |
    | Shadow | 0 1px 2px rgba(0,0,0,0.06) (shadow-sm) |
    | Padding | 16-20px |
```

#### Definition of Done
- [ ] All cards use consistent styling
- [ ] Shadow visible but subtle
- [ ] Border radius consistent

**Estimate:** 2 story points

---

### US-UI-06-02: Standardize Spacing Scale

**As a** UI consumer,
**I want** consistent spacing between all elements,
**So that** the interface feels balanced and professional.

#### Acceptance Criteria

```gherkin
Scenario: Spacing follows defined scale
  Given the entire dashboard layout
  When rendered
  Then spacing follows the defined scale:
    | Gap between sections | 24px (2xl) |
    | Gap within sections | 16px (lg) |
    | Gap between small elements | 12px (md) |
    | Internal padding | 8px (sm) |
```

#### Definition of Done
- [ ] All gaps use spacing scale
- [ ] Padding consistent throughout
- [ ] Visual review against mockup passes

**Estimate:** 3 story points

---

## Story Summary

| Epic | Story | Points | Priority |
|------|-------|--------|----------|
| EPIC-UI-01: Design Foundation | US-UI-01-01 Color Palette & Animations | 2 | P0 |
| EPIC-UI-02: Filter Panel | US-UI-02-01 Tag-Based Multi-Select | 5 | P0 |
| EPIC-UI-02: Filter Panel | US-UI-02-02 Section Labels & Clear All | 3 | P0 |
| EPIC-UI-02: Filter Panel | US-UI-02-03 Filter Panel Styling | 2 | P1 |
| EPIC-UI-03: Edit Feedback | US-UI-03-01 Indigo Edit Highlighting | 3 | P0 |
| EPIC-UI-03: Edit Feedback | US-UI-03-02 MOD Badge | 3 | P0 |
| EPIC-UI-03: Edit Feedback | US-UI-03-03 "Was X%" Footnote | 3 | P0 |
| EPIC-UI-03: Edit Feedback | US-UI-03-04 ChangeTracker Component | 5 | P0 |
| EPIC-UI-03: Edit Feedback | US-UI-03-05 ChangeTracker Integration | 3 | P0 |
| EPIC-UI-04: Table Usability | US-UI-04-01 Sticky Headers | 3 | P0 |
| EPIC-UI-04: Table Usability | US-UI-04-02 Sticky Columns | 5 | P0 |
| EPIC-UI-05: Chart Polish | US-UI-05-01 Gradient Fill | 3 | P1 |
| EPIC-UI-05: Chart Polish | US-UI-05-02 Enhanced Legend | 3 | P1 |
| EPIC-UI-05: Chart Polish | US-UI-05-03 Data Timestamp | 2 | P2 |
| EPIC-UI-06: Layout Polish | US-UI-06-01 Section Card Styling | 2 | P1 |
| EPIC-UI-06: Layout Polish | US-UI-06-02 Spacing Scale | 3 | P1 |

**Total:** 49 story points

---

## Sprint Planning Suggestion

### Sprint 1 (13 points) — Foundation & Edit Core
- US-UI-01-01 Design Tokens (2)
- US-UI-03-01 Indigo Edit Highlighting (3)
- US-UI-03-02 MOD Badge (3)
- US-UI-03-03 "Was X%" Footnote (3)
- US-UI-06-01 Section Card Styling (2)

### Sprint 2 (16 points) — Change Tracking & Table
- US-UI-03-04 ChangeTracker Component (5)
- US-UI-03-05 ChangeTracker Integration (3)
- US-UI-04-01 Sticky Headers (3)
- US-UI-04-02 Sticky Columns (5)

### Sprint 3 (12 points) — Filters & Chart
- US-UI-02-01 Tag-Based Multi-Select (5)
- US-UI-02-02 Section Labels & Clear All (3)
- US-UI-02-03 Filter Panel Styling (2)
- US-UI-05-01 Gradient Fill (3)

### Sprint 4 (8 points) — Polish & Completion
- US-UI-05-02 Enhanced Legend (3)
- US-UI-05-03 Data Timestamp (2)
- US-UI-06-02 Spacing Scale (3)
- Buffer for bugs/regression fixes

---

## Technical Debt Notes

1. **Future Optimization:** Batch API calls for save operations (currently sequential POSTs)
2. **Future Enhancement:** Add undo/redo for cell edits
3. **Future Enhancement:** Keyboard shortcuts for save/discard (Ctrl+S, Esc)

---

## Sign-Off

| Role | Name | Date |
|------|------|------|
| Product Owner | TBD | TBD |
| Tech Lead | TBD | TBD |
| Frontend Lead | TBD | TBD |
