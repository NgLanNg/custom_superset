# Slide 14: NOJV Production Profile (TTM + KPSB/PGSSB Utilities)

![Slide Reference](Presentation%20Deck%20Template%20for%20Asuene(Blurred%20Version)/image14.png)

> **Gold table:** NONE — reads `silver_production` directly
> **Source sheet:** `Production`
> **dbt model:** None (direct silver read)

---

## What This Slide Shows

| Section | Content |
| --- | --- |
| **Left chart** | Production (tonne/year): area chart by TTM (T) and TTM (M) — 2026-2030 |
| **Left table** | Production per OPU-variant: TTM (T) + TTM (M) — 2026-2030 columns |
| **Right chart** | Utilities (MWh/year): area chart by KPSB and PGSSB — 2026-2030 |
| **Right table** | Utilities per OPU: KPSB + PGSSB — 2026-2030 columns |

---

## Data Flow Diagram

```mermaid
flowchart TD

    subgraph EXCEL["📄 OPU Excel File — sheets loaded per OPU"]
        SH1["Sheet: Production
Fields: BU, OPU, Parameters
UOM: tonne/year (production), MWh/year (utilities)
Year cols: 2019…2050
Type: operational control (forced)
OPUs: TTM (T), TTM (M), KPSB, PGSSB"]
    end

    subgraph TRANSFORM["⚙️ Lambda: extract_excel_base_scenario
detect header → classify columns
→ type forced = 'operational control'
→ melt wide→long → append to postgres"]
    end

    subgraph SILVER["🥈 Silver Tables — peth_dev schema (read directly)"]
        SPROD["silver_production
Rows: BU, OPU, Parameters, UOM, Year, Value
Type = 'operational control'
Filter: OPU IN (TTM (T), TTM (M)) → Production tonne/yr
        OPU IN (KPSB, PGSSB) → Utilities MWh/yr
Years: 2026-2030"]
    end

    SH1 --> TRANSFORM
    TRANSFORM --> SPROD

    SPROD -.->|"direct — NOJV OPUs filtered by Tableau"| SLIDE

    SLIDE["🖼️ Slide 14 — NOJV Production Profile
Gold table: NONE (direct silver_production read)
Left: TTM (T) + TTM (M) Production (tonne/yr) 2026-2030
Right: KPSB + PGSSB Utilities (MWh/yr) 2026-2030
Source: TTM (M) received 12 Sep 2025; TTM (T) + KPSB/PGSSB from STAR 2026-2030"]

    style SLIDE fill:#1B5E20,color:#fff,stroke:#388E3C
    style EXCEL fill:#1A237E,color:#fff,stroke:#283593
    style TRANSFORM fill:#E65100,color:#fff,stroke:#BF360C
    style SILVER fill:#37474F,color:#fff,stroke:#546E7A
```

![slide_14.md diagram](assets/mermaid/slide_14_adaa0318.svg)

---

## Gold Table Used

**NONE.** Direct `silver_production` read. Tableau filters for NOJV OPUs (TTM T/M, KPSB, PGSSB), years 2026-2030.

---

## Calculation Logic

| Step | Logic | Code Reference |
| --- | --- | --- |
| 1 | Lambda forces `type = 'operational control'` | `lambda_handler.py` (production type logic) |
| 2 | Tableau filters: `OPU IN ('TTM (T)', 'TTM (M)')` for left panel, `OPU IN ('KPSB', 'PGSSB')` for right | (Tableau filter) |
| 3 | UOM filter: tonne/year (production), MWh/year (utilities) | (Tableau filter on `uom`) |
| 4 | Area chart + table = direct silver rows; Tableau sums stacked bars | `silver_production.value` |

---

## Source Files

| File | Role |
| --- | --- |
| `functions/extract_excel_base_scenario/lambda_handler.py` | Parses Production sheet → silver_production |
| `dbt_project/models/sources.yml` | Registers silver_production |

---

## Key Invariants

| # | Invariant | Code Reference |
| --- | --- | --- |
| 1 | No gold model — all aggregation is Tableau-side | (no gold SQL) |
| 2 | TTM has two variants: TTM (T) from STAR 2026-2030 and TTM (M) submitted separately on 12 Sep 2025 | Image footnote |
| 3 | KPSB and PGSSB are Utilities (MWh/yr) — different UOM from production panel (tonne/yr) | Image right panel header |

---

## BRD Reference

- **BR-14**: NOJV production profile — authoritative reference for NOJV G&P GHG emission projection.

---

## Suggestions

| # | Gap / Suggestion | Evidence | Impact |
| --- | --- | --- | --- |
| 1 | **TTM (T) and TTM (M) are separate submissions** — two data sources for the same NOJV entity. If both are in silver simultaneously, Tableau SUM will mix approved and submitted data. Dedup reconciliation not handled in pipeline. | Image footnote | Submission version conflict |
| 2 | **No gold model means no validation layer** — there is no dbt test or assertion that NOJV production values are within expected ranges. A gold model with `WHERE` guards could enforce this. | No gold SQL | Missing data quality gate |
