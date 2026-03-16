# Sprint Status — Scenario Creation Page

```yaml
sprint:
  id: sprint-1
  name: "Core Infrastructure"
  project: "Scenario Creation Page"
  start_date: "2026-03-13"
  end_date: "2026-03-26"
  velocity_target: 18
  status: planning

capacity:
  developer: "Claude (Full-stack)"
  story_points_available: 18
  buffer: 2
```

---

## Sprint 1 Backlog

### Must Have — 16 points

| Story | Size | Points | Status | Tasks |
|-------|------|--------|--------|-------|
| S6.1 Create Scenario with Metadata | S | 2 | ready-for-dev | T50, T54-partial |
| S7.1 Top-Level Tab Navigation | S | 2 | ready-for-dev | T54-partial |
| S7.2 Sub-Tab Navigation for OPU | M | 3 | ready-for-dev | T54-partial |
| S8.1 Comparative GHG Emissions Chart | L | 5 | ready-for-dev | T55 |
| S10.2 Authentication Required | S | 2 | ready-for-dev | T52-auth, T58-auth |
| S9.1 Excel-Style Data Table | L | 5 | stretch | T57 |

### Should Have — 2 points

| Story | Size | Points | Status | Dependencies |
|-------|------|--------|--------|--------------|
| S8.2 Dynamic Chart Title | S | 2 | backlog | S8.1 |

---

## Story Details

### S6.1 — Create Scenario with Metadata (S, 2pts)

**User Story:** As a scenario analyst, I want to enter a scenario name and description, so that I can identify and describe my scenario for future reference.

**Acceptance Criteria:**
- Given I am on the Scenario Creation page, when I enter a name and description, then the fields should display the entered values
- Given I leave the Name field empty and click Save Draft, then an error message should appear

**Tasks:**
- [ ] T50: Create scenario_metadata table (0.5h)
- [ ] T54-partial: Build NameInput and DescriptionInput components (2h)

---

### S7.1 — Top-Level Tab Navigation (S, 2pts)

**User Story:** As a scenario analyst, I want to switch between Equity Share, Growth, and OPU Configuration tabs, so that I can configure different aspects of my scenario.

**Acceptance Criteria:**
- Given I am on the Scenario Creation page, when I click a tab, then that tab should be active

**Tasks:**
- [ ] T54-partial: Implement TabNavigation component (2h)

---

### S7.2 — Sub-Tab Navigation for OPU Configuration (M, 3pts)

**User Story:** As a scenario analyst, I want to navigate between 6 OPU data sub-tabs, so that I can view and edit different datasets.

**Acceptance Criteria:**
- Given I select OPU Configuration, then I should see 6 sub-tabs
- Given I click a sub-tab, then that sub-tab should be active

**Sub-Tabs:**
| ID | Label | Data Source |
|----|-------|-------------|
| emission-sources | Emission by Sources | silver_emission_by_sources |
| production | Production | silver_production |
| emission-gases | Emission by Gases | silver_emission_by_gases |
| energy-consumption | Energy Consumption | silver_energy_consumption |
| intensity | Intensity | gold_ghg_intensity |
| reduction | Reduction | silver_decarb |

**Tasks:**
- [ ] T54-partial: Implement SubTabNavigation component (3h)

---

### S8.1 — Comparative GHG Emissions Chart (L, 5pts)

**User Story:** As a scenario analyst, I want to view a comparative total GHG emissions chart, so that I can understand the emission trends across years.

**Acceptance Criteria:**
- Given I am on the Emission by Sources sub-tab, then a line chart should be displayed
- Given I edit a cell value, then the chart should update

**Chart Config:**
- Type: Line
- X-axis: Year (2019-2050)
- Y-axis: Total GHG Emissions (tCO2e)
- Group by: Scenario

**Tasks:**
- [ ] T55: Create ComparativeChart component (4h)
- [ ] T55-query: Implement data query from silver_emission_by_sources (2h)
- [ ] T55-render: Render ECharts line chart (2h)

---

### S10.2 — Authentication Required (S, 2pts)

**User Story:** As a security administrator, I want to ensure only authenticated users can access the scenario page, so that unauthorized users cannot modify data.

**Acceptance Criteria:**
- Given I am not logged in, when I navigate to /scenario/create, then I should be redirected to login

**Tasks:**
- [ ] T52-auth: Add @has_access_api decorator to API endpoints (1h)
- [ ] T58-auth: Implement route protection in React (1h)

---

### S9.1 — Excel-Style Data Table (L, 5pts) — STRETCH

**User Story:** As a scenario analyst, I want to view emission data in an Excel-style table with year columns, so that I can easily compare values across years.

**Acceptance Criteria:**
- Given I am on the Emission by Sources sub-tab, then the table should have BU, OPU, Scope, Source columns plus year columns

**Table Config:**
- Row dimensions: BU, OPU, Scope, Source
- Column dimension: Year (2019-2050)

**Tasks:**
- [ ] T57: Create EditableDataTable component (4h)
- [ ] T57-pivot: Implement pivot transformation (2h)

---

## Dependency Graph

```
T50 (DB) ─────────────────────────────────────────┐
                                                   │
T52-auth (API auth) ──────────────────────────────┤
                                                   │
T54 (UI shell) ───────────────────────────────────┤
  ├── S6.1 (Metadata inputs)                      │
  ├── S7.1 (Top-level tabs)                       │
  └── S7.2 (Sub-tabs) ← depends on S7.1           │
                                                   │
T55 (Chart) ──────────────────────────────────────┤
  └── S8.1 (Comparative chart)                     │
                                                   │
T57 (Table) ──────────────────────────────────────┤
  └── S9.1 (Excel-style table) ← STRETCH          │
                                                   │
T58-auth (Route protection) ──────────────────────┘
  └── S10.2 (Authentication)
```

---

## Sprint Schedule

| Day | Date | Focus | Stories |
|-----|------|-------|---------|
| 1 | 2026-03-13 | Database + API | T50, T52-auth |
| 2 | 2026-03-14 | UI Shell | T54 (S6.1, S7.1) |
| 3 | 2026-03-15 | Tab Navigation | T54 (S7.2) |
| 4 | 2026-03-16 | Chart Component | T55 (S8.1 start) |
| 5 | 2026-03-17 | Chart Data Query | T55 (S8.1 cont.) |
| 6 | 2026-03-18 | Chart Rendering | T55 (S8.1 complete) |
| 7 | 2026-03-19 | Route Protection | T58-auth (S10.2) |
| 8 | 2026-03-20 | Table Component | T57 (S9.1 start) |
| 9 | 2026-03-21 | Table Pivot | T57 (S9.1 cont.) |
| 10 | 2026-03-24 | Testing | All stories |
| 11 | 2026-03-25 | Bug fixes | Buffer |
| 12 | 2026-03-26 | Sprint Review | Demo |

---

## Definition of Done

### Story Level
- [ ] All acceptance criteria pass
- [ ] Code reviewed
- [ ] Unit tests written and passing
- [ ] No linting errors

### Sprint Level
- [ ] All P0 stories complete
- [ ] E2E tests passing
- [ ] Documentation updated
- [ ] Demo prepared
