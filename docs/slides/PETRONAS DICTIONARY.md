# 1. OPU Dictionary

## 1.1 Group OPU (Authoritative Definitions)

| Business Lens | PETRONAS Definition (Authoritative) | Composition | Notes |
| --- | --- | --- | --- |
| **Gas Business - PGB** | Gas downstream and transportation operations, excluding LNG liquefaction assets. | **GPU + GTR** | This is a **business lens**, not a physical OPU. |
| **Gas Processing** | The full gas value chain covering LNG and non-LNG gas operations. | **LNGA + GPU + GTR** | This is the **highest aggregation lens** for gas processing. |
| **LNGA** | LNG-related assets and LNG operations portfolio. | **MLNG, DUA, TIGA, Train 9, PFLNGs** | LNGA ⊂ Gas Processing |
| **G&P** | Reporting roll-up for non-LNG gas operations. | **GPU + GTR** | Often used as an alias of Gas Business in reporting. |
| **NOJV LNGA** | LNG assets and operations not under joint ventures. | **GLNG Upstream Ops, GLNG Ops, ELNG, LNGC** | Governance and disclosure lens. |
| **GROWTH** | Portfolio of growth projects grouped by business lens. | **Growth projects under LNGA / GPU / GTR** | Not an OPU. Scenario-only context. |

---

## 1.2 Level-1 OPUs (Reporting OPUs)

| OPU | Business Lens | PETRONAS Meaning | Source Upload File |
| --- | --- | --- | --- |
| **MLNG** | LNGA → Gas Processing | Malaysia LNG complex | Output PLC |
| **DUA** | LNGA → Gas Processing | MLNG Dua Train | Output PLC |
| **TIGA** | LNGA → Gas Processing | MLNG Tiga Train | Output PLC |
| **TRAIN 9** | LNGA → Gas Processing | MLNG Train 9 | Output PLC |
| **PFLNG 1** | LNGA → Gas Processing | Floating LNG 1 | Output PFLNG |
| **PFLNG 2** | LNGA → Gas Processing | Floating LNG 2 | Output PFLNG |
| **PFLNG 3 (ZLNG)** | LNGA → Gas Processing | Floating LNG 3 | G&M Template |
| **GLNG Upstream Ops** | LNGA → Gas Processing | GLNG upstream operations | Output NOJV GLNG |
| **GLNG Ops** | LNGA → Gas Processing | GLNG operations | Output NOJV GLNG |
| **ELNG** | LNGA → Gas Processing | Egypt LNG | Output NOJV ELNG |
| **LNGC** | LNGA → Gas Processing | LNG Canada | Output NOJV LNGC |
| **GPU** | Gas Business → Gas Processing | Gas processing / utilisation umbrella | Output GPU |
| **GTR** | Gas Business → Gas Processing | Gas transportation umbrella | Output GTR |
| **KPSB** | Gas Processing | Kerteh Processing | Output NOJV KPSB |
| **PGSSB** | Gas Processing | Peninsular Gas | Output NOJV PGSSB |
| **GMB** | Gas Processing | Gas Malaysia Berhad | Output NOJV GMB |
| **TTM (M)** | Gas Processing | TTM Malaysia | Output NOJV TTM (M) |
| **TTM (T)** | Gas Processing | TTM Thailand | Output NOJV TTM (T) |

---

## 1.3 Standard Aggregations (Canonical)

| Aggregation | Definition | Composition |
| --- | --- | --- |
| **GPP** | Gas Processing Plants grouping. | **GPK + GPS + TSET** |
| **UTILITIES** | Utilities and supporting operations. | **UK + UG** |
| **G&P (Reporting Alias)** | Roll-up used for non-LNG gas reporting. | **GPU + GTR** |

---

## 1.4 Shipping / Marine (Simplified)

| Term | Definition | Notes |
| --- | --- | --- |
| **MISC / Shipping & Marine** | LNG shipping, marine services, vessels, and maritime support activities. | Drill-down only. Not a reporting OPU. |

# 2. PRESENTATION DICTIONARY

## **2.1. Corporate & Programme Context Terms**

| Term | Business Definition | Primary Data Source (Excel Output Files) |
| --- | --- | --- |
| **P4R 2026–2030 Sustainability** | PETRONAS performance & reporting cycle for sustainability. | _Not stored in output files_ (presentation / governance context only) |
| **NZCE 2035 / NZCE 2050** | Net Zero Carbon Emissions milestones and commitments. | _Not stored in output files_ |
| **G&M Business** | PETRONAS Gas & Maritime Business portfolio. | _Implicit across all Output files_ |
| **Gas & Maritime Business** | Combined gas and maritime operations. | _Implicit across all Output files_ |
| **FAB Corporate** | Finance governance for CAPEX validation. | _Not stored in output files_ |

**2. Business Portfolios & Groupings**

| Term | Business Definition | Primary Data Source (Excel Output Files) |
| --- | --- | --- |
| **Gas Business** | Gas downstream and transportation operations. | `Output GPU.xlsx` + `Output GTR.xlsx` |
| **Gas Processing** | Full gas value chain including LNG and non-LNG operations. | `Output PLC.xlsx`, `Output PFLNG.xlsx`, `Output GPU.xlsx`, `Output GTR.xlsx`,  |
| **LNG Assets (LNGA)** | LNG-related assets and LNG operations portfolio. | `Output PLC.xlsx`, `Output PFLNG.xlsx`, `Output NOJV GLNG.xlsx`, `Output NOJV ELNG.xlsx`, `Output NOJV LNGC.xlsx` |
| **Gas & Power (G&P)** | Reporting grouping for non-LNG gas operations. | `Output GPU.xlsx` + `Output GTR.xlsx` |
| **Maritime** | Shipping and marine operations. | `Output MISC.xlsx` |
| **NOJV Assets** | Assets not under joint venture arrangements. | All files prefixed with `Output NOJV *.xlsx` |

---

## **3. Emissions & Control Framework Language**

| Term | Business Definition | Primary Data Source (Excel Output Files) |
| --- | --- | --- |
| **Operational Control (OC)** | Emissions under operational control. | Emission sheets in **all Output files** (OC columns / labels) |
| **Equity Share (ES)** | Emissions based on equity ownership. | Emission sheets in **all Output files** (ES columns / labels) |
| **GHG Emission Forecast** | Projected GHG emissions over time. | Emission summary sheets in all Output files |
| **GHG Intensity** | Emissions per unit of production. | Derived from intensity  sheets in Output files |

---

## **4. Decarbonisation & Reduction Language**

| Term | Business Definition | Primary Data Source (Excel Output Files) |
| --- | --- | --- |
| **GHG Reduction** | Reduction relative to reference operations. | Reduction / abatement rows in emission sheets |
| **Zero Routine Flaring (ZRF)** | Elimination of routine flaring. | Rows with this data represented in Levers column in Reduction Sheet of All output files |
| **Energy Efficiency** | Reduced energy use via improvements. | Rows with this data represented in Levers column in Reduction Sheet of All output files |
| **Electrification** | Fuel switching to electricity. | Rows with this data represented in Levers column in Reduction Sheet of All output files |
| **Carbon Capture and Storage (CCS)** | Capture and storage of CO₂. | Rows with this data represented in Levers column in Reduction Sheet of All output files |
| **Others (Decarbonisation)** | Miscellaneous decarbonisation initiatives. | Rows with this data represented in Levers column in Reduction Sheet of All output files |

---

## **5. Capital & Investment Terms**

| Term | Business Definition | Primary Data Source (Excel Output Files) |
| --- | --- | --- |
| **Green CAPEX** | Capital expenditure for decarbonization. | `all files, reduction sheet` |
| **Green OPEX** | Capital expenditure for decarbonization. | `all files, reduction sheet` |

---

## **6. Growth & Project Portfolio Language**

| Term | Business Definition | Primary Data Source (Excel Output Files) |
| --- | --- | --- |
| **Growth Projects** | New gas / LNG projects. | `Output SBD Growth.xlsx` |
| **Project Sanction** | Approval status of projects. | `Output SBD Growth.xlsx` |
| **COD (Commercial Operation Date)** | Start of commercial operations. | `Output SBD Growth.xlsx` |
| **Annual GHG Reduction Contribution** | Annual emission reduction from projects. | `Output SBD Growth.xlsx` |

---

## **7. Methane-Specific Business Language**

| Term | Business Definition | Primary Data Source (Excel Output Files) |
| --- | --- | --- |
| **Methane Emission** | Methane released from operations. | Emission-by-gas sheets in Output files |
| **Methane Intensity** | Methane per unit of production. | Emission-by-gas sheets in Output files |
| **OGMP 2.0 Level 2 / Level 3** | Methane reporting maturity levels. | Emission-by-gas sheets in Output files |

---

## **8. Energy & Production Language**

| Term | Business Definition | Primary Data Source (Excel Output Files) |
| --- | --- | --- |
| **Energy Consumption** | Total energy used. | Energy consumption sheets in Output files |
| **Energy Intensity** | Energy per unit of output. | Energy + production sheets |
| **LNG Production Profile** | LNG production volumes. | `Output PLC.xlsx`, `Output PFLNG.xlsx`, `Output NOJV LNGC.xlsx` |
| **Feedgas Profile** | Feedgas supply profile. | Production sheet with parameter = feeedgas |
| **Kerteh Feedgas** | Feedgas profile for Kerteh. with Parameter = Salegas Production  | `Output NOJV GPU.xlsx` |
| **Salesgas Production** | Processed gas supplied. | Production sheets with parameter = production |
| **Utilities Consumption** | Utilities usage. UK + UG | Utilities sheets in `Output GPU.xlsx` |

---

## **9. Pathway & Progress Language**

> Nhóm này **là reporting construct**, không tồn tại trực tiếp trong Excel output.

| Term | Business Definition | Primary Data Source (Excel Output Files) |
| --- | --- | --- |
| **NZCE Pathway** | Trajectory toward net zero. | _Derived in reporting layer_ |
| **Traffic Lights** | Target progress indicator. | _Derived in reporting layer_ |
| **Forecasted GHG Reduction Contribution** | Expected reduction by portfolio. | Aggregated from emission & reduction fields |
| **Target Achievement Status** | Whether targets are met or at risk. | _Derived in reporting layer_ |

‌