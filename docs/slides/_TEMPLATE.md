# Slide NN: [Title]

> **Gold table:** `gold_<table_name>` — or **NONE** (static template)
> **Source sheets:** `<SheetName1>`, `<SheetName2>`
> **dbt model:** `dbt_project/models/gold_table/gold_<table_name>.sql`

---

## Data Flow Diagram

```mermaid
flowchart TD

    subgraph EXCEL["📄 OPU Excel File — sheets loaded per OPU"]
        SH1["Sheet: <SheetName1>
Fields: BU, OPU, <field3>, <field4>
Year cols: 2019…2050
<Row above header: Operational Control / Equity Share — delete if not applicable>"]
        SH2["Sheet: <SheetName2>
Fields: BU, OPU, <field3>
Year cols: 2019…2050"]
    end

    subgraph TRANSFORM["⚙️ Lambda: extract_excel_base_scenario
detect header → classify columns
→ map OC/Equity types → melt wide→long
→ trim strings → append to postgres"]
    end

    subgraph SILVER["🥈 Silver Tables — peth_dev schema"]
        S1["silver_<table1>
Rows: BU, OPU, <col3>, Year, Value, Type"]
        S2["silver_<table2>
Rows: BU, OPU, <col3>, <col4>, Year, Value"]
    end

    subgraph GOLD["🥇 Gold Table — dbt model"]
        G1["gold_<table_name>
<UNION / JOIN logic>
<DEDUP: ROW_NUMBER() OVER (...) if applicable>
<Aggregate: SUM(value) GROUP BY ... if applicable>
<Filters: WHERE / regex if applicable>
<Scaling: ÷ 1,000,000 → million tCO2e if applicable>"]
    end

    SH1 --> TRANSFORM
    SH2 --> TRANSFORM
    TRANSFORM --> S1 & S2
    S1 & S2 --> G1
    G1 --> SLIDE["🖼️ Slide NN — <Title>
Gold table: gold_<table_name>
Displays: <metric / chart type>
Unit: <tCO2e / million tCO2e / %>"]

    style SLIDE fill:#1B5E20,color:#fff,stroke:#388E3C
    style EXCEL fill:#1A237E,color:#fff,stroke:#283593
    style TRANSFORM fill:#E65100,color:#fff,stroke:#BF360C
    style SILVER fill:#37474F,color:#fff,stroke:#546E7A
    style GOLD fill:#F57F17,color:#fff,stroke:#E65100
```

![_TEMPLATE.md diagram](assets/mermaid/_TEMPLATE_c5c2e7fd.svg)

> **Note — static/cover slide:** If this slide has no gold table, replace the `G1 --> SLIDE` arrow with:
>
> ```
> G1 -.->|"not used"| SLIDE["🖼️ ...
> Gold table: NONE
> ..."]
> ```

---

## Gold Table Used

`gold_<table_name>` — or **None** (static template, no query).

---

## Calculation Logic

| Step | Logic | Code Reference |
| --- | --- | --- |
| 1 | `<UNION / JOIN description>` | `gold_<model>.sql` L<N> |
| 2 | `<DEDUP ROW_NUMBER() OVER (PARTITION BY ...)>` | `gold_<model>.sql` L<N> |
| 3 | `<SUM(value) / 1,000,000>` | `gold_<model>.sql` L<N> |
| 4 | `<Filter: WHERE scenario_id = var('scenario_id')>` | `gold_<model>.sql` L<N> |

---

## Source Files

| File | Role |
| --- | --- |
| `functions/extract_excel_base_scenario/lambda_handler.py` | Parses Excel, writes silver tables |
| `dbt_project/models/gold_table/gold_<model>.sql` | Gold transform — calculation logic |
| `dbt_project/models/sources.yml` | Silver table registration |
| `functions/tableau_load/lambda_handler.py` | Pushes gold table to Tableau |

---

## Key Invariants

| # | Invariant | Code Reference |
| --- | --- | --- |
| 1 | `<e.g. Equity rows dropped — OC only>` | `lambda_handler.py` L<N> |
| 2 | `<e.g. Values scaled ÷ 1,000,000>` | `gold_<model>.sql` L<N> |
| 3 | `<e.g. Filtered by scenario_id + user_email>` | `gold_<model>.sql` L<N> |

---

## BRD Reference

- **BR-<N>**: <Business rule description>
- **BR-<N>**: <Business rule description>

---

<!--
CHECKLIST — delete before publishing:
[ ] Every table name verified against sources.yml or dbt_project/models/gold_table/
[ ] Every sheet name verified against lambda_handler.py sheet handling logic
[ ] No \n escape sequences in the Mermaid block (real newlines only)
[ ] Gold table is NONE for static/template slides — dashed arrow used
[ ] BRD references checked against docs/features/brd.md
[ ] All code references cite exact line numbers
-->
