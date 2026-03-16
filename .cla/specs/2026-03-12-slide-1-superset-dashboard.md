---
title: Slide 1 — OPU GHG Summary Sheet (Superset Dashboard)
date: 2026-03-12
author: Antigravity
status: Draft
---

# Technical Specification: Slide 1 — OPU GHG Summary Sheet (Superset)

## Executive Summary

Build a read-only Superset dashboard to replace existing Tableau visualization of OPU GHG Summary Sheet (Slide 1). Uses native Superset chart types connected to dbt-generated Gold tables.

---

## 1. Objectives

| ID | Objective | Priority |
| --- | --- | --- |
| O1 | Replicate Tableau Slide 1 visualization in Superset | P0 |
| O2 | Use dbt Gold tables as single source of truth | P0 |
| O3 | Read-only dashboard (no write-back) | P1 |
| O4 | Acceptable performance for end users (< 5s load) | P1 |

---

## 2. Architecture Overview

```mermaid
flowchart LR
    Excel["Excel Files"]
    Lambda["Lambda: extract_excel_base_scenario"]
    Silver["Silver Tables (PostgreSQL)"]
    Dbt["dbt Gold Models"]
    Superset["Superset Dashboard"]

    Excel --> Lambda
    Lambda --> Silver
    Silver --> Dbt
    Dbt --> Superset

    style Excel fill:#E65100,color:#fff
    style Silver fill:#37474F,color:#fff
    style Dbt fill:#F57F17,color:#fff
    style Superset fill:#1B5E20,color:#fff
```

---

## 3. Data Sources

### 3.1 Gold Tables

| Table | Source | Purpose |
| --- | --- | --- |
| `gold_summary_sheet` | dbt model | GHG Intensity, Total GHG Emission, Upon Reduction, Production (OC & ES panels) |
| `gold_decarb_capex` | dbt model | CAPEX and decarb lever reductions (top band) |

### 3.2 Table Schemas

#### `gold_summary_sheet`

| Column | Type | Description |
| --- | --- | --- |
| category | TEXT | 'GHG Intensity', 'GHG Emission', 'Production' |
| metric | TEXT | OPU name or 'Total GHG Emission', 'Upon Reduction' |
| type | TEXT | 'operational control' or 'equity share' |
| uom | TEXT | Unit of measure (tCO2e, MMT, mmscfd, etc.) |
| year | INTEGER | Forecast year (2019–2050) |
| value | NUMERIC | Metric value |

#### `gold_decarb_capex`

| Column | Type | Description |
| --- | --- | --- |
| kpi | TEXT | 'CAPEX', 'OC', 'ES' |
| type | TEXT | Decarbonization lever bucket (CCS, Electrification, Energy efficiency, Zero Routine Flaring & Venting) |
| year | TEXT | Forecast year |
| uom | TEXT | Unit of measure (million tCO2e for OC/ES; blank for CAPEX) |
| value | NUMERIC | RM Million (CAPEX) or million tCO2e (OC/ES) |

> **Note:** The `lever` column referenced in slide documentation maps to `type` in the actual table.

---

## 4. Superset Components

### 4.1 Datasets

| Dataset ID | Name | Source Table | Schema |
| --- | --- | --- | --- |
| DS1 | GHG Summary Sheet | `gold_summary_sheet` | `peth_dev` |
| DS2 | Decarb CAPEX | `gold_decarb_capex` | `peth_dev` |

### 4.2 Charts

| Chart ID | Name | Type | Dataset | Dimensions | Metrics |
| --- | --- | --- | --- | --- | --- |
| C1 | GHG Reduction OC/ES | Grouped Bar Chart | DS2 | `type` (lever), `year` | `value` (filter: `kpi IN ('OC', 'ES')`) |
| C2 | Green CAPEX | Bar Chart | DS2 | `type` (lever), `year` | `value` (filter: `kpi = 'CAPEX'`) |
| C3 | OC GHG Intensity | Stacked Area Chart | DS1 | `year` | `value` (filter: `category = 'GHG Intensity'`, `type = 'operational control'`) |
| C4 | OC Total GHG Emission | Line Chart | DS1 | `year` | `value` (filter: `metric = 'Total GHG Emission'`, `type = 'operational control'`) |
| C5 | OC Upon Reduction | Line Chart | DS1 | `year` | `value` (filter: `metric = 'Upon Reduction'`, `type = 'operational control'`) |
| C6 | OC Production | Table | DS1 | `metric`, `year`, `uom` | `value` (filter: `category = 'Production'`, `type = 'operational control'`) |
| C7 | ES GHG Intensity | Stacked Area Chart | DS1 | `year` | `value` (filter: `category = 'GHG Intensity'`, `type = 'equity share'`) |
| C8 | ES Total GHG Emission | Line Chart | DS1 | `year` | `value` (filter: `metric = 'Total GHG Emission'`, `type = 'equity share'`) |
| C9 | ES Upon Reduction | Line Chart | DS1 | `year` | `value` (filter: `metric = 'Upon Reduction'`, `type = 'equity share'`) |
| C10 | ES Production | Table | DS1 | `metric`, `year`, `uom` | `value` (filter: `category = 'Production'`, `type = 'equity share'`) |

### 4.3 Dashboard Layout

| Section | Charts | Grid Position |
| --- | --- | --- |
| Top Band | C1, C2 | Row 0, Columns 0–11 (full width) |
| Left Panel | C3, C4, C5, C6 | Rows 1–2, Columns 0–5 (left half) |
| Right Panel | C7, C8, C9, C10 | Rows 1–2, Columns 6–11 (right half) |

---

## 5. Implementation Plan

### Phase 1: Data Source Setup

1. Verify dbt Gold tables exist and have data
2. Confirm PostgreSQL connection from Superset
3. Create Superset Database connection (if not exists)

### Phase 2: Dataset Registration

1. Create Dataset DS1 from `gold_summary_sheet`
2. Create Dataset DS2 from `gold_decarb_capex`
3. Verify column types and metrics are correct

### Phase 3: Chart Creation

1. Create Top Band charts (C1, C2)
2. Create Left Panel charts (C3, C4, C5, C6)
3. Create Right Panel charts (C7, C8, C9, C10)

### Phase 4: Dashboard Assembly

1. Create new Superset Dashboard: "OPU GHG Summary Sheet"
2. Add all charts to dashboard
3. Arrange grid layout (3 sections)
4. Set dashboard filters (year range, OPU selection)

### Phase 5: Verification

1. Visual verification against Tableau reference
2. Data accuracy spot-check
3. Performance testing

---

## 6. Dependencies

| Dependency | Required | Notes |
| --- | --- | --- |
| PostgreSQL Gold tables | YES | `gold_summary_sheet`, `gold_decarb_capex` must exist |
| dbt | YES | Must generate Gold tables before Superset connection |
| Superset instance | YES | Must be accessible with DB connection permissions |

---

## 7. Non-Goals

| NGID | Non-Goal | Rationale |
| --- | --- | --- |
| NG1 | Write-back capability | Explicitly excluded per requirements |
| NG2 | Custom React plugins | Native charts sufficient for read-only use case |
| NG3 | Real-time data streaming | Batch ETL from Excel is acceptable |

---

## 8. Acceptance Criteria

| ACID | Description | Verification Method |
| --- | --- | --- |
| AC1 | Dashboard loads without errors | Manual test |
| AC2 | Top band shows OC/ES + CAPEX by lever | Visual inspection |
| AC3 | Left panel shows OC basis data only | Verify `type = 'operational control'` filter |
| AC4 | Right panel shows ES basis data only | Verify `type = 'equity share'` filter |
| AC5 | Dashboard layout matches reference design | Side-by-side comparison |
| AC6 | All charts render with correct data units | Spot-check metric values |

---

## 9. Risk Register

| Risk ID | Risk Description | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- | --- |
| R1 | Gold tables don't exist in Superset DB | Medium | High | Verify dbt run before implementation |
| R2 | Native charts can't match Tableau layout exactly | Low | Medium | Use CSS grid for layout control |
| R3 | Performance issues with large datasets | Low | Medium | Add query timeouts, pre-aggregation |
| R4 | Superset lacks required chart type | Very Low | High | Use alternative chart type or plugin |

---

## 10. Success Metrics

| Metric | Target | Measurement |
| --- | --- | --- |
| Dashboard load time | < 5 seconds | Browser DevTools |
| Data accuracy | 100% match to Gold tables | SQL comparison |
| Visual fidelity | 90%+ match to Tableau design | Stakeholder review |
| User satisfaction | Positive feedback | End-user survey |

---

## 11. References

| Ref | Location |
| --- | --- |
| Slide 1 Spec | `docs/slides/slide_01.md` |
| dbt Gold Models | `dbt_project/models/gold_table/` |
| Superset Docs | https://superset.apache.org/docs/ |
