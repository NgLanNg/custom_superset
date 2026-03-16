# Slide 04: Growth Projects 2026-2030

![Slide Reference](Presentation%20Deck%20Template%20for%20Asuene(Blurred%20Version)/image4.png)

> **Gold table:** `gold_slide4`
> **Source sheets:** `Growth` (Table A: Growth Projects Emission, Table B: Growth Petronas Effective Equity), `GHG Emission Reduction (tCO2e)` (growth_proposed_reduction)
> **dbt model:** `dbt_project/models/gold_table/gold_slide4.sql`

---

## What This Slide Shows

| Section | Content |
| --- | --- |
| **Full-page table** | Growth Projects 2026-2030 Listing: Sector (BU), Project Name, Project Description, Project Sanction, Petronas Effective Equity (%), COD, Annual GHG Emission (Equity Share, Mil tCO2e/year), Annual GHG Reduction (Equity Share, Mil tCO2e/year) |
| **Rows** | One row per growth project × year (e.g. Tango, Peony, Calathea, Silica, Asters, Rancha for G&P; Suriname F2 for LNGA) — FID Status = Yes only |

---

## Data Flow Diagram

```mermaid
flowchart TD

    subgraph EXCEL["📄 OPU Excel File — sheets loaded per OPU"]
        SHA["Sheet: Growth — Table A: Growth Projects Emission
Fields: BU, Growth Project, Business Model, Project Description
FID Status (Yes/No), COD
Year cols: emission values 2019…2050"]
        SHB["Sheet: Growth — Table B: Growth Petronas Effective Equity
Fields: BU, Projects (project name), Year, Value (% equity)"]
        SHR["Sheet: GHG Emission Reduction (tCO2e)
(growth_proposed section)
Fields: BU, Growth Project, Business Model, Project Description
FID Status, COD
Year cols: reduction values 2019…2050"]
    end

    subgraph TRANSFORM["⚙️ Lambda: extract_excel_base_scenario
Sheet 'Growth': get_table_section_indices()
  → 2 table sections (Table A + Table B)
table_name from row 0 col 0 → normalize → map name
detect header with find_table_header_row_with_range()
classify → melt → write_df_to_postgres()"]
    end

    subgraph SILVER["🥈 Silver Tables — peth_dev schema"]
        SGE["silver_growth_projects_emission
Rows: BU, Growth Project, Business Model
Project Description, FID Status, COD
Year, Value, Type (OC / ES)"]
        SGPEE["silver_growth_petronas_effective_equity
Rows: BU, Projects (name), Year, Value (% equity)"]
        SGPR["silver_proposed_growth_projects_reduction
Rows: BU, Growth Project, Business Model
Project Description, FID Status, COD
Year, Value, Type"]
    end

    subgraph GOLD["🥇 Gold Table — dbt model"]
        G4["gold_slide4  ← 3-way JOIN
CTE 1: growth_emission (silver_growth_projects_emission)
  ROW_NUMBER() OVER (PARTITION BY bu, growth_project,
    business_model, year, type ORDER BY updated_at DESC)
  WHERE fid_status_yes_no = 'Yes'
  SUM(value) GROUP BY bu, growth_project, project_description,
    cod, year, type
CTE 2: growth_reduction (silver_proposed_growth_projects_reduction)
  Same dedup + FID filter + SUM(value)
CTE 3: growth_petronas_ee (silver_growth_petronas_effective_equity)
  ROW_NUMBER() OVER (PARTITION BY bu, projects, year)
  SELECT * where rn=1
Final JOIN:
  growth_emission INNER JOIN growth_reduction
    ON bu, growth_project, year, type
  LEFT JOIN growth_petronas_ee
    ON bu, growth_project (→projects), year
Output cols: sector(bu), project_name, project_description,
  project_sanction(NULL), petronas_effective_equity,
  cod, year, type, annual_ghg_emission, annual_ghg_reduction"]
    end

    SHA --> TRANSFORM
    SHB --> TRANSFORM
    SHR --> TRANSFORM

    TRANSFORM --> SGE & SGPEE & SGPR

    SGE & SGPR & SGPEE --> G4

    G4 --> SLIDE["🖼️ Slide 04 — Growth Projects 2026-2030
Gold table: gold_slide4
Table: Sector | Project Name | Description | Sanction | Equity % | COD
  Annual GHG Emission ES (Mil tCO2e/yr) | Annual GHG Reduction ES
FID filter: only Yes projects shown"]

    style SLIDE fill:#1B5E20,color:#fff,stroke:#388E3C
    style EXCEL fill:#1A237E,color:#fff,stroke:#283593
    style TRANSFORM fill:#E65100,color:#fff,stroke:#BF360C
    style SILVER fill:#37474F,color:#fff,stroke:#546E7A
    style GOLD fill:#F57F17,color:#fff,stroke:#E65100
```

![slide_04.md diagram](assets/mermaid/slide_04_d1e4e1cc.svg)

---

## Gold Table Used

`gold_slide4` — 3-way JOIN: growth emission × growth reduction × petronas effective equity.
Only FID = Yes projects included. `project_sanction` is always `NULL` (not sourced from Excel).

---

## Calculation Logic

| Step | Logic | Code Reference |
| --- | --- | --- |
| 1 | `growth_emission` CTE: dedup `silver_growth_projects_emission` via `ROW_NUMBER()`, filter `fid_status_yes_no = 'Yes'`, `SUM(value)` per project + year + type | `gold_slide4.sql` L1–34 |
| 2 | `growth_reduction` CTE: same dedup + FID filter on `silver_proposed_growth_projects_reduction`, `SUM(value)` | `gold_slide4.sql` L35–68 |
| 3 | `growth_petronas_ee` CTE: dedup `silver_growth_petronas_effective_equity` via `ROW_NUMBER()`, SELECT * where rn=1 | `gold_slide4.sql` L69–83 |
| 4 | Final INNER JOIN: `growth_emission` JOIN `growth_reduction` on bu, growth_project, year, type, scenario_id, user_email | `gold_slide4.sql` L96–103 |
| 5 | LEFT JOIN `growth_petronas_ee` on bu, growth_project → projects, year, scenario_id, user_email | `gold_slide4.sql` L104–109 |
| 6 | `project_sanction` hardcoded `null` — not available from any source | `gold_slide4.sql` L88 |

---

## Source Files

| File | Role |
| --- | --- |
| `functions/extract_excel_base_scenario/lambda_handler.py` | Parses Growth sheet multi-table sections + GHG Reduction sheet |
| `dbt_project/models/gold_table/gold_slide4.sql` | 3-way JOIN — growth emission + reduction + Petronas equity |
| `dbt_project/models/sources.yml` | Registers silver_growth_projects_emission, silver_proposed_growth_projects_reduction, silver_growth_petronas_effective_equity |

---

## Key Invariants

| # | Invariant | Code Reference |
| --- | --- | --- |
| 1 | Only FID = `'Yes'` projects included — pre-FID/concept projects excluded | `gold_slide4.sql` L25, L59 |
| 2 | INNER JOIN emission + reduction — project must exist in both silvers or row is dropped | `gold_slide4.sql` L96–103 |
| 3 | `petronas_effective_equity` may be `NULL` if project absent from equity table (LEFT JOIN) | `gold_slide4.sql` L104 |
| 4 | `project_sanction` always `NULL` — column reserved but not populated | `gold_slide4.sql` L88 |
| 5 | Both emission and reduction deduplicated separately before JOIN | `gold_slide4.sql` L2–11, L36–45 |

---

## BRD Reference

- **BR-08**: Growth projects — FID-approved only; Petronas Effective Equity % sourced from SBD Integrated Portfolio Team.
- **BR-05**: Scenario-filtered (scenario_id + user_email vars).

---

## Suggestions

| # | Gap / Suggestion | Evidence | Impact |
| --- | --- | --- | --- |
| 1 | **`project_sanction` always NULL** — column exists in output schema but no Excel source populates it. Either the source field was never added to the Growth sheet, or it comes from a separate system (SBD portal). | `gold_slide4.sql` L88: `null as project_sanction` | Blank column in Tableau slide |
| 2 | **`business_model` in dedup partition key but not in SELECT** — used for dedup uniqueness but dropped from final output. If projects differ only by business model, the row is correctly deduped but business model visibility is lost. | `gold_slide4.sql` L5, L39 vs L12–33 | Silent dimension drop |
| 3 | **INNER JOIN may silently drop projects** — if a growth project exists in `silver_growth_projects_emission` but not in `silver_proposed_growth_projects_reduction`, it is excluded from the slide with no error. | `gold_slide4.sql` L96–103 | Data loss without alert |
| 4 | **Equity % data source not in the pipeline** — slide references SBD Integrated Portfolio Team as source. Confirm whether `silver_growth_petronas_effective_equity` is populated from the same Excel or a separate manual upload. | References footnote on image | Provenance gap |
