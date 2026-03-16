---
type: dashboard-spec
date: {{ date }}
author: {{ author }}
project: {{ project_name }}
stepsCompleted: []
inputDocuments: []
---

# Dashboard Specification: [Dashboard Name]

## 1. VISION & OBJECTIVE
>
> What is the primary question this dashboard answers? Who is the audience?

## 2. WIREFRAME MAPPING (FIGMA)

| Component ID | Description | Source Wireframe Link |
| :--- | :--- | :--- |
| W-001 | Header KPIs (Total Revenue, Monthly Growth) | [Link] |
| W-002 | Trend Chart (Revenue over Time) | [Link] |
| W-003 | Distribution (Revenue by Region) | [Link] |

## 3. DATA ARCHITECTURE MAPPING (Developer)

| Metric Name | Table/View Name | Base Columns | Calculation/Logic |
| :--- | :--- | :--- | :--- |
| Total Revenue | `gold.fact_sales` | `amount_usd` | `SUM(amount_usd)` |
| Growth % | `gold.fact_sales_monthly` | `revenue`, `prev_revenue` | `(rev - prev_rev) / prev_rev` |

## 4. FILTERS & INTERACTIVITY

- [ ] Date Range Selector (Default: Last 30 Days)
- [ ] Regional Filter (Multi-select)
- [ ] Product Category Drill-down

## 5. REFRESH & PERFORMANCE

- **Refresh Frequency**: Daily at 06:00 UTC
- **SLA**: Loads in < 3 seconds
- **Data Grain**: Day / Region / Product
