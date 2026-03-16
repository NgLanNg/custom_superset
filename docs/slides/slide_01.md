# Slide 01: OPU GHG Summary Sheet

![Slide Reference](Presentation%20Deck%20Template%20for%20Asuene(Blurred%20Version)/image1.jpg)

> **Gold tables:** `gold_summary_sheet` + `gold_decarb_capex`
> **Source sheets:** `GHG Emission`, `GHG Emission by Sources`, `Production`, `GHG Emission Reduction (tCO2e)`
> **dbt models:** `gold_summary_sheet.sql`, `gold_decarb_capex.sql`

---

## What This Slide Shows

A per-OPU full GHG summary with two panels (OC and ES basis):

| Section | Content |
| --- | --- |
| **Top band** | GHG Reduction Forecast + Green CAPEX by decarb lever (Zero Routine Flaring, Energy Efficiency, Electrification, CCS, Others) — OC and ES values + CAPEX in RM Million |
| **Left panel** | Total GHG Emission Forecast — Operational Control: GHG Intensity rows (Gas Processing, Utilities, Shipping) + Total GHG Emission line + Upon Reduction line + Production (LNG MMT, Kerteh Salesgas mmscfd) |
| **Right panel** | Same layout — Equity Share basis |

---

## Data Flow Diagram

```mermaid
flowchart TD

    subgraph EXCEL["📄 OPU Excel File — sheets loaded per OPU"]
        SH1["Sheet: GHG Emission
Fields: BU, OPU, Scope
Year cols: 2019…2050
Row above header: Operational Control / Equity Share"]
        SH2["Sheet: GHG Emission by Sources
Fields: BU, OPU, Scope, Source
Year cols: 2019…2050"]
        SH3["Sheet: Production
Fields: BU, OPU, Parameters, UOM
Year cols: 2019…2050
(type forced = operational control)"]
        SH4["Sheet: GHG Emission Reduction (tCO2e)
Fields: BU, OPU, Levers, Targeted Source, Scope
Project Name, COD, Status
Year cols: 2019…2050
+ Green CAPEX/OPEX columns (separate pivot)"]
    end

    subgraph TRANSFORM["⚙️ Lambda: extract_excel_base_scenario
detect header → classify columns
→ map OC/Equity types → melt wide→long
→ trim strings → append to postgres"]
    end

    subgraph SILVER["🥈 Silver Tables — peth_dev schema"]
        SE["silver_emission
Rows: BU, OPU, Scope, Year, Value, Type
(equity rows dropped — OC only)"]
        SEBS["silver_emission_by_sources
Rows: BU, OPU, Scope, Source, Year, Value, Type"]
        SPROD["silver_production
Rows: BU, OPU, Parameters, UOM, Year, Value
(type = operational control)"]
        SD["silver_decarb
Rows: BU, OPU, Levers, COD, Status, Year, Value, Type"]
        SCO["silver_capex_opex
Rows: BU, OPU, Levers, Project
green_capex_rm per year (pivot of CAPEX columns)"]
    end

    subgraph GOLD["🥇 Gold Tables — dbt models"]
        GGE["gold_ghg_emission
UNION silver_emission + silver_emission_by_sources
ROW_NUMBER() OVER (PARTITION BY bu, opu, scope, year, type
  ORDER BY updated_at DESC) → rn=1
SUM(value) GROUP BY bu, opu, year, type
Regex: vessel/charter OPU names → reassigned to MISC
Static rows: LNGA, PGB, NOJV G&P, MISC*, Total BAU"]

        GGIR["gold_ghg_intensity_rollup
SUM(emission) / SUM(production)
JOIN opu_intensity_mapping ON opu → rollup_opu + uom
Excludes: LNGA, NOJV G&P, NOJV LNGA, PGB, MISC*, Total BAU"]

        GGEUR["gold_ghg_emission_upon_reduction
Emission baseline minus decarb reductions"]

        GS["gold_summary_sheet  ← UNION ALL 4 CTEs
┌─ CTE 1: ghg_intensity_rollup
│  category='GHG Intensity', opu as metric
│  type, uom (from intensity mapping), year, value (as-is)
│  source: gold_ghg_intensity_rollup
│
├─ CTE 2: ghg_emission (total across all OPUs)
│  category='GHG Emission', metric='Total GHG Emission'
│  type, uom (as-is, tCO2e), year
│  value = SUM(value)  ← NO ÷1M here
│  source: gold_ghg_emission  (no OPU exclusions)
│
├─ CTE 3: ghg_emission_upon_reduction
│  category='GHG Emission', metric='Upon Reduction'
│  type, uom, year
│  value = SUM(value)  ← NO ÷1M here
│  source: gold_ghg_emission_upon_reduction
│
└─ CTE 4: production
   category='Production'
   Parameters rename: Salesgas → 'Kerteh Salegas', LNG bu=LNGA → 'LNG'
   ROW_NUMBER() dedup by updated_at
   metric IS NOT NULL filter
   SUM(value) GROUP BY metric, type, uom, year"]

        GDC["gold_decarb_capex  ← UNION ALL 2 blocks
┌─ Block 1: CAPEX (from silver_capex_opex)
│  kpi='CAPEX', lever bucketed into:
│  Electrification / Energy efficiency /
│  Zero Routine Flaring & Venting / CCS / others
│  value = SUM(green_capex_rm)
│  CROSS JOIN year_range × unique_levers → NULL padding
│
└─ Block 2: decarb (from silver_decarb)
   KPI: OC → 'OC', ES → 'ES'
   lever bucketed same as above
   value = SUM(value / 1,000,000) → million tCO2e
   ROW_NUMBER() dedup by updated_at"]
    end

    SH1 --> TRANSFORM
    SH2 --> TRANSFORM
    SH3 --> TRANSFORM
    SH4 --> TRANSFORM

    TRANSFORM --> SE & SEBS & SPROD & SD & SCO

    SE & SEBS --> GGE
    GGE & SPROD --> GGIR
    GGE & SD --> GGEUR

    GGE & GGIR & GGEUR & SPROD --> GS
    SD & SCO --> GDC

    GS & GDC --> SLIDE["🖼️ Slide 01 — OPU GHG Summary Sheet
Gold tables: gold_summary_sheet + gold_decarb_capex
Top band: GHG Reduction OC/ES + Green CAPEX by lever (RM Million)
Left panel: OC basis — GHG Intensity + Emission + Upon Reduction + Production
Right panel: ES basis — same metrics"]

    style SLIDE fill:#1B5E20,color:#fff,stroke:#388E3C
    style EXCEL fill:#1A237E,color:#fff,stroke:#283593
    style TRANSFORM fill:#E65100,color:#fff,stroke:#BF360C
    style SILVER fill:#37474F,color:#fff,stroke:#546E7A
    style GOLD fill:#F57F17,color:#fff,stroke:#E65100
```

![slide_01.md diagram](assets/mermaid/slide_01_fa3b1635.svg)

---

## Gold Tables Used

| Table | Feeds |
| --- | --- |
| `gold_summary_sheet` | GHG Intensity rows, Total GHG Emission line, Upon Reduction line, Production rows (both OC and ES panels) |
| `gold_decarb_capex` | Top CAPEX band — OC/ES decarb lever totals in million tCO2e + CAPEX in RM Million |

---

## Calculation Logic

### `gold_summary_sheet`

| Step | Logic | Code Reference |
| --- | --- | --- |
| 1 | `ghg_intensity_rollup` CTE: intensity value as-is, uom from `opu_intensity_mapping` | `gold_summary_sheet.sql` L1–13 |
| 2 | `ghg_emission` CTE: `SUM(value)` — **no ÷1M** (raw tCO2e), metric = 'Total GHG Emission' | `gold_summary_sheet.sql` L14–31 |
| 3 | `ghg_emission_upon_reduction` CTE: `SUM(value)` from `gold_ghg_emission_upon_reduction` | `gold_summary_sheet.sql` L32–49 |
| 4 | `production` CTE: `ROW_NUMBER()` dedup, rename Parameters → metric (LNG/Kerteh Salegas), `SUM(value)` | `gold_summary_sheet.sql` L50–94 |
| 5 | Final `UNION ALL` of all 4 CTEs + `current_timestamp` | `gold_summary_sheet.sql` L95–115 |

### `gold_decarb_capex`

| Step | Logic | Code Reference |
| --- | --- | --- |
| 1 | `decarb` CTE: dedup silver_decarb, bucket levers (non-4 → 'others'), type OC/ES → KPI label, `SUM(value/1,000,000)` → million tCO2e | `gold_decarb_capex.sql` L1–34 |
| 2 | `capex` CTE: dedup silver_capex_opex, same lever bucketing, `SUM(green_capex_rm)` as CAPEX value | `gold_decarb_capex.sql` L35–65 |
| 3 | `year_range` × `unique_levers` CROSS JOIN → NULL padding for missing lever/year combos | `gold_decarb_capex.sql` L66–105 |
| 4 | `UNION ALL` CAPEX block + decarb block + `current_timestamp` | `gold_decarb_capex.sql` L106–110 |

---

## Source Files

| File | Role |
| --- | --- |
| `functions/extract_excel_base_scenario/lambda_handler.py` | Parses all 4 sheets, writes silver tables |
| `dbt_project/models/gold_table/gold_ghg_emission.sql` | Base emission gold layer |
| `dbt_project/models/gold_table/gold_ghg_intensity_rollup.sql` | Intensity = emission / production |
| `dbt_project/models/gold_table/gold_ghg_emission_upon_reduction.sql` | Emission after decarb reductions |
| `dbt_project/models/gold_table/gold_summary_sheet.sql` | UNION: intensity + emission + upon_reduction + production |
| `dbt_project/models/gold_table/gold_decarb_capex.sql` | UNION: CAPEX + decarb lever reductions |
| `functions/tableau_load/lambda_handler.py` | Pushes both gold tables to Tableau |

---

## Key Invariants

| # | Invariant | Code Reference |
| --- | --- | --- |
| 1 | `gold_summary_sheet` does **NOT** divide emission by 1,000,000 — raw tCO2e (unlike `gold_slide2_slide3`) | `gold_summary_sheet.sql` L20, L38 |
| 2 | `gold_decarb_capex` decarb values **DO** divide by 1,000,000 → million tCO2e | `gold_decarb_capex.sql` L24 |
| 3 | CAPEX CROSS JOIN pads NULL for any lever/year combination with no data | `gold_decarb_capex.sql` L91–104 |
| 4 | Production: `Salesgas Production` → renamed `Kerteh Salegas`; LNG (bu=LNGA) → `LNG` | `gold_summary_sheet.sql` L61–63 |
| 5 | Shipping OPUs reassigned to `MISC` in production CTE | `gold_summary_sheet.sql` L55–57 |
| 6 | All CTEs filtered by `scenario_id` + `user_email` dbt vars | throughout both SQL files |

---

## BRD Reference

- **BR-07.3**: Executive charts — Total GHG Emission Forecast, GHG Intensity Forecast, Upon Reduction.
- **BR-02**: Both Operational Control and Equity Share panels displayed.
- **BR-03**: Full decimal precision at silver; division to million tCO2e only at gold layer.
- **BR-06**: Green CAPEX by decarb lever shown in RM Million.
