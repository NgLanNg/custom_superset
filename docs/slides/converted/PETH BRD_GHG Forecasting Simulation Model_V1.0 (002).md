# PETH BRD_GHG Forecasting Simulation Model_V1.0 (002)
Source: PETH BRD_GHG Forecasting Simulation Model_V1.0 (002).pdf
Converted at: 2026-01-27T16:24:08.947740

---

## Page 1
For Internal Use - For Internal Distribution Only
Business Requirement
Documentation
Project name: G&M Sustainability Carbon Emissions Calculator
and Scenario Simulator
Class: Confidentiality
31 December 2025


## Page 2
For Internal Use - For Internal Distribution Only
Review and Approval
Name Date Signature
Prepared by
Sal Sim
(Asuene APAC Pte. 31 Dec 2025 Sal Sim
Director, Product Solutions
Ltd.)
Reviewed by
Mohamad Azfar Bin Hamdan
(PETRONAS G&M) Manager (Climate Change) 31/12/2025
Approved by
Fatimah Az-Zahra Bt Sha'ari
(PETRONAS G&M) Senior Manager (Sustainability) 31/12/2025
Page 2


## Page 3
For Internal Use - For Internal Distribution Only
User Date Content Note
Sal Sim Creation V 0.1
23 Oct 2025
V 0.2
Sal Sim 01 Dec 2025 Revised
after
RESTART
workshop
with PETH
team
V 0.3
Corvo Tan 06 Dec 2025 Provide
Specified
Details
V0.4
Sal Sim 08 Dec 2025 Reviewed
Rosie Trinh 22 Dec Update V0.5
2025 feedback
Sal Sim 23 Dec Reviewed V0.6
2025
Rosie Trinh 26 Dec Update V0.7
2025 feedback
G&M 29 Dec Update V0.8
Sustainabilit 2025 Feedback
y
Page 3


## Page 4
For Internal Use - For Internal Distribution Only
Rosie Trinh 29 Dec Update V0.9
2025 feedback
Sal Sim 31 Dec Created V1.0
2025 PDF for
sign off
Page 4


## Page 5
For Internal Use - For Internal Distribution Only
1 BACKGROUND
This project is to help the PETRONAS G&M Sustainability team design and implement an
automated Gas GHG Forecasting Model (GFM) engine, in compliance with PETRONAS Limit
of Authority (LOA) requirements, to deliver an automated, accurate, and scalable GHG
forecasting system that enhances sustainability reporting, streamlines operations, and aligns with
their NZCE Roadmap.
The Gas GHG Forecasting Model (GFM), developed in Q3 2024, is an Excel-based system
hosted on SharePoint. It consists of two main components:
1. The input template (iOPU) for data entry by OPUs and
2. The output template (oG&MS) for processing and reporting by G&M Sustainability.
The model is designed to streamline GHG forecasting but faces several challenges related to
manual processes and limited adoption.
This project aims to:
1. Replace the G&M calculation workbook with an automated, controlled solution in
Asuene.
2. Eliminate manual data transposition from OPU output files to G&M Input files
3. Enable near real-time “what-if” scenario analysis and decision support dashboards.
4. Provide full data lineage and auditability.
5. Strengthen data quality, PETH compliance, and error monitoring.
6. Optionally, recommend emission reduction levers aligned with targets, reducing reliance
on trial-and-error “guess and test” methods.
1.1 Current state:
1. Each OPU (Operating/Organisational Performance Unit) produces an OPU output
spreadsheet with detailed operational and emissions-related data.
2. A central G&M calculation workbook aggregates and transforms OPU data into group-
level metrics (e.g., total emissions, intensity metrics, progress vs. net-zero trajectory).
3. The process is manual, time-consuming, and error-prone, particularly:
Page 5


## Page 6
For Internal Use - For Internal Distribution Only
4. Manual copy-paste/transposition from OPU spreadsheets into the G&M workbook.
5. Complex formulas and cross-sheet references that are hard to audit.
6. Multiple versions of spreadsheets with inconsistent calculations.
7. Decision-makers (EVP, C-level) rely on slides and static charts that are manually created,
making it difficult to explore scenarios in real time
1.2 Business pain points:
1. High operational effort to prepare reporting cycles and management decks.
2. Risk of errors (rounding, formula errors, broken links) that can impact external reporting
and credibility.
3. Slow scenario analysis, limiting the ability to test different decarbonization strategies and
operational levers.
4. Limited transparency into how numbers were arrived at, making audits and internal
reviews difficult.
5. Increasing regulatory scrutiny on methodology, data quality, and evidence with
documentation for net-zero claims.
Page 6


## Page 7
For Internal Use - For Internal Distribution Only
2 PROJECT OBJECTIVES
2.1 Primary:
1. Eliminate manual data transposition
○ Automate ingestion of OPU output files into Asuene and fully replace the G&M
calculation workbook.
2. Improve calculation reliability and transparency
○ Implement centralised, controlled calculation logic with no rounding errors and
full decimal precision.
3. Enable fast, flexible scenario planning
○ Allow business users to configure multiple what-if scenarios (e.g., volume
changes, EF changes, abatement projects) and obtain near real-time (sub-15-min)
results on AA dashboards.
4. Enhance governance, auditability, and compliance
○ Provide end-to-end data lineage, error tracking, and PETH-compliant data quality
monitoring.
5. Improve executive reporting
○ Automate creation/update of key visualisations used in EVP and C-level decks.
2.2 Secondary (nice-to-have):
1. Provide intelligent recommendations
○ Use analytics/AI to recommend emission reduction levers to meet selected
targets, rather than purely manual “guess and test.”
______________________________________________________________________________
_______
Page 7


## Page 8
For Internal Use - For Internal Distribution Only
3 DELIVERABLES
BR-01 – Automated Data Ingestion from OPU Outputs
BR-01.1. Business Requirement Summary
The system shall automatically ingest OPU Output Year files—each containing pre-agreed data
sheets (ee BR 01.3) into Asuene, replacing the manual copy-paste process currently performed in
the G&M workbook.
In Phase 1, G&M Sustainability users upload the Output Year file (14 OPU refer to user journey
template) for each OPU.
In future phases, OPUs may upload directly.
BR-01.2. Business Rationale
Manual consolidation is time-consuming, inconsistent across OPUs, and prone to human error.
Automating ingestion ensures data accuracy, standardisation, and faster processing, enabling
reliable downstream forecasting, scenario modelling, emissions calculation, and reporting.
BR-01.3. In-Scope Functional Description
● System accepts an Output Year Excel file from user upload.
● File must contain pre-agreed standardised 9 sheets (including summary sheet) for our
business processing logic application. At this moment, these are the 11 data points
provided to Asuene:
1. GHG Emission
2. Methane Emission
3. Energy Consumption
4. GHG Intensity
5. Methane Intensity
6. Energy Intensity
7. Decarbonisation
8. Growth Projects
9. Production
10. Equity Share percentage & Operational Control Data for existing asset and
growth
Page 8


## Page 9
For Internal Use - For Internal Distribution Only
11. Green CAPEX
● System performs structural validation, data validation, transformation, mapping to
Asuene’s GFM structure, and produces a Data Quality Report (DQR).
BR-01.4. Workflow / Process Flow
Phase 1 — G&M Sustainability Uploads:
1. User selects OPU & reporting year.
2. Upload Output Year Excel file.
3. System validates file structure and template version.
4. System parses all sheets.
5. System applies data validations.
6. System transforms and maps data into Asuene model.
7. System generates the Data Submission Report (DSR) - which will include upload status
report and comments.
Future Phase — OPU Self-Upload:
● OPUs upload directly.
● RBAC but not limits each OPU to upload only their data.
● Completeness monitoring included.
BR-01.5. Data Requirements
5.1 Input Data
● File format: .xlsx, xls
Page 9


## Page 10
For Internal Use - For Internal Distribution Only
● Must contain pre-agreed sheets (BR01.3) -
● Mandatory yearly range: 2019 (based year) → 2050 (target year).
● Required identifiers: OPU, Facility/Field/Asset names.
5.2 Validation Rules
● Missing sheet → error.
● Missing mandatory columns → error.
● Data type mismatches → error.
● Negative numbers not allowed unless defined (CCS, offsets).
● Units must match template (e.g., mtpa, tCO2e, tonnes).
5.3 Transformation Rules
● Standardise column names to the Asuene naming convention.
● Calculate GHG totals, intensity, and reduction potential.
5.4 Output Data
● Raw Landing Layer storing original sheet data.
● Transformed Data Layer aligned to Asuene GFM.
● Upload metadata (user, timestamp, OPU, version).
● Data Quality Report output.
Page 10


## Page 11
For Internal Use - For Internal Distribution Only
BR-01.6. Business Rules
● Latest upload (same OPU) updates the previous dataset, not limited to how many updates
are conducted.
● Critical errors must be resolved before progressing.
BR-01.7. Non-Functional Requirements
● Validation accuracy must detect 100% missing mandatory fields.
● Fully secure upload (RBAC + file sanitisation).
BR-01.8. Dependencies / Assumptions
● Standard OPU template version is finalised.
● A mapping dictionary exists for all sheets.
● GFM data model is stable.
● User uploads valid template versions.
BR-01.9. Permissions / RBAC
Phase 1:
● G&M Sustainability users: upload, view DSR, trigger re-upload.
● Sustainability team: read-only review.
Future Phase:
Page 11


## Page 12
For Internal Use - For Internal Distribution Only
● OPU users: upload only their own data.
● G&M Sustainability: supervise, override, approve.
BR-01.10. Success Criteria
● All 11 data points were ingested and validated automatically.
● DQR identifies all structural & data errors.
● Each OPU can upload data independently in future phases.
BR-01.11. Out-of-Scope
● Cross-OPU aggregated comparison (handled downstream).
Page 12


## Page 13
For Internal Use - For Internal Distribution Only
BR-02 – Automated G&M Calculations
BR-02.1. Business Requirement Summary
The system shall implement all calculations currently performed in the G&M Excel workbook
within Asuene’s AA calculation engine.
This includes existing formulas, aggregations, year-by-year transformations, and any future
enhancements to the G&M logic.
BR-02.2. Business Rationale
Manual calculation in the G&M workbook is not scalable and requires repeated updates
whenever formulas change.
Centralising logic inside Asuene’s Advanced Analytics (AA) calculation engine ensures
consistency, removes dependency on Excel, and supports automated ingestion, forecasting, and
scenario workflows.
BR-02.3. In-Scope Functional Description
● Replicate all existing G&M Excel formulas inside the AA calculation engine.
● Apply calculations to all ingested OPU datasets.
● Maintain one standardised calculation logic applicable across all OPUs.
● Allow future enhancements to the calculation model without altering Excel.
● Ensure outputs match the current G&M workbook results.
● Ensure that the calculation logic is transparent and can be audited.
BR-02.4. Workflow / Process Flow
1. The input dataset is ingested from the OPU Output Year file.
Page 13


## Page 14
For Internal Use - For Internal Distribution Only
2. System triggers the AA calculation engine.
3. The engine executes all G&M formulas and logic.
4. The system stores calculation outputs into the transformed data layer.
5. Outputs become available for forecasting, scenario configuration, dashboards, and
reporting.
BR-02.5. Data Requirements
5.1 Input Data
● Data ingested from OPU data points (BR-01).
● All required fields are referenced by the Excel formulas.
5.2 Validation Rules
● All mandatory fields required by a formula must be present.
● If an upstream sheet contains invalid data, the calculation engine must not run.
● Year columns must cover 2019–2050.
5.3 Transformation Rules
● Follow the exact transformation logic defined in the G&M workbook.
● Maintain identical calculation ordering as in Excel.
● Apply unit conversions, GHG emissions calculations, reductions, intensity, and all
operational logic currently implemented in the workbook.
5.4 Output Data
● Yearly calculation outputs for all relevant metrics.
Page 14


## Page 15
For Internal Use - For Internal Distribution Only
● Store in transformed calculation tables within Asuene.
● Outputs are directly consumed by forecasting, scenario, and dashboard modules.
BR-02.6. Business Rules
● The calculation engine must replicate Excel results exactly for the same inputs.
● Any future updates to G&M logic must be implemented centrally in the AA engine, not
in Excel.
● Only approved datasets (or ingested datasets, depending on the workflow) will trigger
calculations.
BR-02.7. Non-Functional Requirements
● Calculation processing time < 60 seconds per OPU dataset.
● Formula engines must support 2019–2050 yearly processing.
● High accuracy: 100% match with Excel references.
● Must handle parallel processing for multiple OPUs.
BR-02.8. Dependencies / Assumptions
● G&M workbook logic is stable and provided in final version.
● Mapping between Excel formula inputs and Asuene fields is available.
● AA calculation engine supports the required formula types.
● Input dataset must pass ingestion validation (BR-01).
BR-02.9. Permissions / RBAC
● Calculation engine runs automatically; no manual formula editing allowed.
Page 15


## Page 16
For Internal Use - For Internal Distribution Only
● Standard users can view calculation results only.
BR-02.10. Success Criteria
● System replicates 100% of G&M Excel calculations.
● No reliance on Excel for operational workflows.
● Calculation results match Excel outputs for all OPUs.
● Model updates can be deployed without modifying any workbook
BR-02.11. Out-of-Scope
● Manual editing of calculation results.
● Scenario approval logic.
● Any new calculation models not included in the existing G&M logic.
Page 16


## Page 17
For Internal Use - For Internal Distribution Only
BR-03 – Precision & No Rounding Errors
BR-03.1. Business Requirement Summary
The system shall preserve full decimal precision exactly as provided in OPU input files and must
not apply unintended rounding during any intermediate or final calculations.
All roll-ups must follow a “sum-over-sum” approach, not aggregated averages or rounded
summaries.
BR-03.2. Business Rationale
OPUs provide emissions, energy, production, and financial data with varying decimal precision.
Any rounding during intermediate steps can significantly distort outcomes, especially when
aggregated across OPUs or across forecast years.
Ensuring precision is critical for customer trust, audit compliance, and accurate GHG reporting.
BR-03.3. In-Scope Functional Description
● Preservation of all decimals from the original OPU inputs.
● All calculations must operate on full-precision values.
● No rounding is allowed except for UI display formatting.
● All roll-ups (e.g., facility → OPU → portfolio) must use sum-over-sum logic.
● Averaging or derived ratios must be calculated using the raw underlying values, not pre-
rounded or pre-averaged numbers.
BR-03.4. Workflow / Process Flow
1. System ingests raw values from OPU sheets with full decimals.
2. Raw values stored in the landing layer retain exact precision.
3. The calculation engine uses full-precision numbers for all operations.
Page 17


## Page 18
For Internal Use - For Internal Distribution Only
4. Roll-ups aggregate underlying values using sum-over-sum.
5. Outputs stored with original or computed precision intact.
6. If UI requires formatting (e.g., display 2 decimals), formatting is non-destructive to the
underlying stored values.
BR-03.5. Data Requirements
5.1 Input Data
● All numeric fields from eleven OPU data points (BR-01).
● Decimal places may vary per OPU and per metric.
5.2 Validation Rules
● System must not trim or round decimals upon ingestion.
● Data type validation must allow high-precision decimals.
● Any transformation that may cause precision loss must be flagged.
5.3 Transformation Rules
● All arithmetic operations must use full-precision floating values.
● Ratios, intensities, GHG totals, and reductions based on raw, unrounded numbers.
● Roll-ups: always sum underlying numerators & denominators → then compute ratio.
● No averaging of pre-aggregated averages.
5.4 Output Data
● Stored outputs retain full precision.
● Roll-up tables maintain decimal values.
Page 18


## Page 19
For Internal Use - For Internal Distribution Only
● UI display rounding (if applied) must not affect stored values.
BR-03.6. Business Rules
● “Sum-over-sum” is mandatory for all aggregated outputs.
● No intermediate rounding allowed.
● Any required formatting must be applied at the presentation layer only.
● Calculations must remain mathematically identical to operating on raw inputs.
BR-03.7. Non-Functional Requirements
● The system must support high-precision decimal types.
● Performance must remain stable even when using high precision.
BR-03.8. Dependencies / Assumptions
● Upstream templates do not enforce fixed decimal length.
● Calculation engine supports high-precision decimal or double types.
BR-03.9. Permissions / RBAC
● All users view final values; no user may adjust precision settings.
● Admin may configure UI display formatting but not underlying precision rules.
BR-03.10. Success Criteria
● Stored values match OPU input decimal precision exactly.
● Intermediate and final outputs match calculations done using full precision.
Page 19


## Page 20
For Internal Use - For Internal Distribution Only
● Roll-ups verified to match sum-over-sum expectations.
● No discrepancy visible between Asuene outputs and original workbook outputs.
BR-03.11. Out-of-Scope
● UI visual rounding rules (outside data storage/processing).
● Data export formatting rules – this refers to the numerical decimal places. Meaning the
user can only download the data based the actual decimal places available
Page 20


## Page 21
For Internal Use - For Internal Distribution Only
BR-04 – Data Lineage & Auditability
BR-04.1. Business Requirement Summary
The system shall provide end-to-end data lineage that clearly explains how each reported value is
derived from source OPU data, scenario variables, variable changes, and user actions.
Lineage must include notes, timestamps (Malaysia local time), and the identity of users who
made changes.
The lineage presentation should follow standard data lineage practices but delivered in a way
that is easy for non-technical users to understand.
BR-04.2. Business Rationale
Stakeholders require full transparency and auditability to trust reported GHG, production,
intensity, and reduction values.
A non-technical user must be able to trace any dashboard number back to its origin and
understand:
● Which OPU provided the value,
● What transformations occurred,
● Whether scenario variables modified it,
● Who changed what, and when.
This is essential for governance, assurance, internal review, and external audit.
BR-04.3. In-Scope Functional Description
● System generates end-to-end lineage for each final reported metric.
● Lineage covers the entire path: OPU raw data → transformations → G&M calculations
→ scenario variables that changed → final output.
● Includes metadata for every change: user, timestamp (Malaysia time), description/note.
● Lineage view must be non-technical and explain numbers in simple terms.
● The user can click a dashboard number to see its lineage.
Page 21


## Page 22
For Internal Use - For Internal Distribution Only
BR-04.4. Workflow / Process Flow
1. User views a metric on the dashboard.
2. User selects “View Data Lineage.”
3. System retrieves lineage chain:
○ Original OPU sheet + cell/field value
○ Transformations applied
○ G&M calculations
○ Scenario overrides/variable adjustments
○ Final reporting value
4. System displays lineage in a simplified, readable flow.
5. System includes audit trail metadata (user, timestamp, note).
BR-04.5. Data Requirements
5.1 Input Data
● Raw values from all eleven OPU data points.
● Scenario variable data.
● User actions modify variables.
● Notes/justifications entered by users.
5.2 Validation Rules
● All lineage entries must include a timestamp (Malaysia time).
● All variable changes must include the user ID and notes.
Page 22


## Page 23
For Internal Use - For Internal Distribution Only
● Missing metadata triggers a validation error for the change entry.
5.3 Transformation Rules
● System captures every transformation exactly as applied by the calculation engine.
● For each transformation, store: input → rule → output.
5.4 Output Data
● A lineage dataset linking each final dashboard value to its entire derivation history.
● Audit log including user, timestamp, and notes.
● Visual lineage representation showing the data flow.
BR-04.6. Business Rules
● All reported values must have complete lineage.
● Users cannot modify or delete lineage entries.
● Scenario overrides must always generate an audit entry.
● Timestamps must follow Malaysia local time (GMT+8).
BR-04.7. Non-Functional Requirements
● The interface must be readable for non-technical users.
● High availability of lineage logs for audit (all for existing scenarios).
● Must support full traceability for all OPUs and all years (2019–2050).
Page 23


## Page 24
For Internal Use - For Internal Distribution Only
BR-04.8. Dependencies / Assumptions
● G&M calculation engine exposes transformation steps (Asuene will follow calculation
exist in G&M Dummy Data).
● The scenario module supports audit logging.
● User identity management is available for tagging changes.
● OPU input structure is consistent and traceable.
BR-04.9. Permissions / RBAC
● All standard users: view lineage.
● Scenario owners / G&M Sustainability: create variable changes and notes.
● Users: view full audit logs.
● No role is allowed to alter lineage records.
BR-04.10. Success Criteria
● Any dashboard value can be fully traced back to its origin.
● Non-technical users can understand how a number was derived.
● Audit logs include user, timestamp, and notes for every scenario change.
● Lineage accurately reflects OPU inputs, calculations, and scenario variables.
BR-04.11. Out-of-Scope
● Visualisation of complex technical dataflows for internal engineering.
● Editing or overriding lineage entries.
● External auditor workflow.
● Data masking rules (if any).
Page 24


## Page 25
For Internal Use - For Internal Distribution Only
BR-05 – Scenario Planning & Variable Management
BR-05.1. Business Requirement Summary
Business users shall be able to label scenario name, define, adjust, manage and export multiple
scenario variables to perform what-if analysis.
All scenario changes must update the calculated results and reflect on AA dashboards within
acceptable latency (below 1 minute).
BR-05.2. Business Rationale
Scenario planning is essential for forecasting, strategic decision-making, and evaluating
decarbonisation pathways.
Users must quickly test different assumptions (e.g., costs, volumes, reduction potentials,
methane factors) and immediately see how results change on dashboards.
BR-05.3. In-Scope Functional Description
● Ability to create multiple scenarios with respective labels.
● Ability to define and adjust scenario variables.
● Automatic recalculation when variables change.
● Updated results pushed to dashboards within < 1 minute.
● Each scenario is isolated and does not affect the baseline data.
● The system stores scenario values and uses them during calculations.
● Ability to export interim scenario generation.
BR-05.4. Workflow / Process Flow
1. User selects or creates a scenario and input the name of scenario.
2. User inputs or adjusts scenario variables.
3. System captures changes and triggers recalculation.
Page 25


## Page 26
For Internal Use - For Internal Distribution Only
4. The calculation engine applies updated variables.
5. Updated outputs are stored in scenario-specific datasets.
6. Dashboards refresh with recalculated values within the required latency.
7. User can choose to export the respective scenario.
BR-05.5. Data Requirements
5.1 Input Data
● Scenario variables are defined by business users.
● Baseline calculation results from the G&M model.
● Scenario metadata (name, description).
5.2 Validation Rules
● All variable fields must be numeric where expected.
● Mandatory variables must not be left blank.
● Invalid values (e.g., negative where not allowed) must be rejected.
5.3 Transformation Rules
● Scenario variables override corresponding baseline values.
● Scenario calculations follow the same logic as baseline G&M calculations.
● Only variable-specific fields are replaced; all other values remain from baseline.
5.4 Output Data
Page 26


## Page 27
For Internal Use - For Internal Distribution Only
● Scenario-specific calculation results.
● Updated metrics stored separately from baseline.
● Dashboard-ready data updated for visualisation and exporting.
BR-05.6. Business Rules
● Scenario changes must not modify baseline data.
● Each scenario must retain its own variable set.
● Calculation must always respect the most recent variable values.
BR-05.7. Non-Functional Requirements
● The system must support multiple scenarios without performance degradation.
● High accuracy and consistency across recalculations.
● The system must handle concurrent scenario users.
BR-05.8. Dependencies / Assumptions
● G&M calculation engine supports dynamic recalculation.
● Baseline dataset already successfully ingested and calculated.
● Variable definitions and data types are clearly defined.
BR-05.9. Permissions / RBAC
● Business users: create scenarios, modify variables.
● G&M Sustainability: review, approve, reject scenarios.
● No user may edit baseline values through scenario functionality.
BR-05.10. Success Criteria
Page 27


## Page 28
For Internal Use - For Internal Distribution Only
● Users can create and adjust scenario variables successfully.
● Recalculated results appear on dashboards within 1 minute.
● Scenario and baseline outputs remain fully separated.
● Scenario behaviour remains consistent across OPUs and years.
BR-05.11. Out-of-Scope
● Machine-learning-based scenario generation.
BR-06 – Scenario Persistence & Comparison
BR-06.1. Business Requirement Summary
Users shall be able to save scenarios, assign labels or names to them, compare their outputs
against the baseline scenario to support decision-making and export the outputs.
BR-06.2. Business Rationale
Scenario outputs must be preserved so that users can revisit assumptions, track different planning
options, and evaluate decisions.
Comparison against a baseline helps stakeholders understand the impact of variable changes and
supports clear, data-driven choices.
BR-06.3. In-Scope Functional Description
● Ability to save a scenario with a user-defined name or label.
● Ability to store scenario variable values and calculated results.
● Ability to select any saved scenario and compare its outputs against the baseline scenario.
● Comparison must show differences in key metrics (e.g., GHG, production, intensity,
reductions).
● Scenario states must persist across user sessions.
Page 28


## Page 29
For Internal Use - For Internal Distribution Only
● Ability to export interim scenario comparison.
BR-06.4. Workflow / Process Flow
1. User creates or adjusts a scenario.
2. User selects “Save Scenario” and provides a scenario name/label.
3. The system stores scenario variables and associated calculation outputs.
4. User selects a saved scenario for comparison.
5. System retrieves baseline and selected scenario outputs.
6. Dashboard displays side-by-side comparison or delta values.
7. User can choose to export the scenario.
BR-06.5. Data Requirements
5.1 Input Data
● Scenario variable values.
● Baseline calculation results.
● Scenario metadata (name, label, timestamp).
5.2 Validation Rules
● Scenario name must be unique per user/project context.
● Mandatory fields (scenario name, at least one variable) cannot be empty.
● Invalid numeric values for variables must be rejected.
5.3 Transformation Rules
Page 29


## Page 30
For Internal Use - For Internal Distribution Only
● Scenario calculations use the same G&M logic as baseline.
● Comparison outputs are derived by subtracting baseline values from scenario values or
by side-by-side mapping.
5.4 Output Data
● Persisted scenario data.
● Baseline vs scenario comparison dataset.
● Comparison metrics are available for dashboard display.
BR-06.6. Business Rules
● Saving a scenario creates a separate calculation dataset independent of the baseline.
● Users may store multiple scenarios.
● Only the latest variable set is saved per scenario version.
● Baseline scenario remains read-only.
BR-06.7. Non-Functional Requirements
● System must support several saved scenarios per user without performance issues.
● Scenarios must persist reliably across system updates.
BR-06.8. Dependencies / Assumptions
● Scenario calculation engine must already be functional (BR-05).
● Baseline dataset is available and calculated.
Page 30


## Page 31
For Internal Use - For Internal Distribution Only
● Dashboard supports the display of comparison data.
● Storage model supports versioned scenario datasets.
BR-06.9. Permissions / RBAC
● Business users: create, save, label, delete, and compare scenarios.
● G&M Sustainability: view scenarios.
● Admin: manage scenario storage settings.
BR-06.10. Success Criteria
● Users can successfully save scenarios with labels.
● Scenario values persist across sessions.
● Comparison against baseline displays correctly.
● No accidental overwriting of baseline or unrelated scenarios.
● Multi-scenario comparison is limited to 3 scenarios simultaneously
BR-06.11. Out-of-Scope
● Scenario sharing between projects (covered separately if needed).
BR-07 – Automated Executive Visualisations
BR-07.1. Business Requirement Summary
The system shall generate a single executive-level dashboard that automatically displays all
required charts used for EVP and C-level reporting for different stakeholders.
The dashboard must always reflect the latest baseline and scenario results, minimising manual
preparation of slides.
Page 31


## Page 32
For Internal Use - For Internal Distribution Only
BR-07.2. Business Rationale
Executives require consistent, accurate, and presentation-ready visuals without manual editing.
A single consolidated dashboard simplifies navigation, reduces operational workload, and
ensures alignment with the reporting format used in C-suite and governance meetings.
BR-07.3. In-Scope Functional Description
● A single executive dashboard containing all required charts (listed below).
● Charts must automatically update when baseline or scenario calculations are refreshed.
● Dashboard must follow the design/format provided in the reference PPT deck from
PETH.
● Filters (e.g., Business Unit, OPU, Year, OC/ES) must be updated consistently across all
charts including in export.
● All visuals must be high-resolution and suitable for direct use in leadership presentations.
Executive Charts Included:
1. Total GHG Emission Forecast Operational Control
2. Total GHG Emission Forecast Equity Share
3. GHG Emission Forecast Operational Control
4. GHG Intensity Forecast Operational Control
5. GHG Emission & Intensity Profile Equity Share
6. Growth Project Listing
7. GHG Reduction Forecast Operational Control & Equity Share
8. Decarbonisation Projects
9. GHG Reduction Forecast and Green CAPEX
10. Methane Emission &Intensity Forecast
11. Energy Consumption & Intensity Forecast
12. GHG Emission Equity Share for G&M Forecast
13. Traffic Lights NZCE
14. Upstream Feedgas + LNG Production Profile
15. Kerteh Feedgas & Salegas Production Profile
Page 32


## Page 33
For Internal Use - For Internal Distribution Only
16. NOJV Production Profile
BR-07.4. Workflow / Process Flow
1. Baseline or scenario data is calculated by the system.
2. Dashboard automatically updates all charts using the latest available dataset.
3. User applies filters (BU, OPU, Year, OC/ES).
4. All charts refresh simultaneously based on the selected filters.
5. Users view or export the visuals as needed for executive reporting (export as image &
PPTX file)
BR-07.5. Data Requirements
5.1 Input Data
● Baseline datasets.
● Scenario calculation outputs.
● OC/ES filter values.
● Shared filter metadata (BU, OPU, Year).
5.2 Validation Rules
● Shared filters must always apply globally.
● Missing required data for any chart triggers a user-visible warning.
5.3 Transformation Rules
● Charts draw data from baseline or scenario datasets.
Page 33


## Page 34
For Internal Use - For Internal Distribution Only
● OC/ES modifies underlying values before visualisation.
5.4 Output Data
● Fully rendered executive Dashboard showing identical chart layouts but different
scenario outputs.
BR-07.6. Business Rules
● Left and Right panels function independently for scenario and OC/ES logic.
● Shared filters override both panels.
● Only approved or valid datasets may drive visuals.
● Chart definitions must remain consistent across both panels.
BR-07.7. Non-Functional Requirements
● Only one dashboard is delivered; dual-panel comparison is out of scope.
● Dashboard must always reflect the most recent approved or selected scenario.
● Charts must follow the agreed format and styling from PETH’s PPT references.
BR-07.8. Dependencies / Assumptions
● Scenario engine and baseline calculations (BR-01 to BR-06) are functional.
● Executive chart definitions and PPT references are provided by PETH.
● No dual-scenario comparison is required.
Page 34


## Page 35
For Internal Use - For Internal Distribution Only
BR-07.9. Permissions / RBAC
● users: view and apply filters, scenario filters.
BR-07.10. Success Criteria
● All required charts appear correctly in the dashboard.
● Dashboard reflects the newest data without manual refresh.
● The executive team accepts the visual quality for use in slide decks.
● Zero manual data manipulation is needed to produce leadership visuals.
BR-07.11. Out-of-Scope
● Creation of new visual types outside the dashboard is defined.
● Non-executive dashboards or operational views.
BR-08 – Data Quality & PETH Compliance
1. Business Requirement Summary
The system shall measure, monitor, and surface key data quality metrics—such as completeness,
validity, accuracy, consistency, uniqueness, and timeliness—in accordance with PETH data
quality standards.
The system must also generate automated notifications when data fails to meet PETH
acceptance thresholds.
2. Business Rationale
Page 35


## Page 36
For Internal Use - For Internal Distribution Only
High-quality data is required for compliance with PETH’s governance, forecasting, and reporting
expectations.
Implementing basic data quality checks reduces ingestion errors, improves trust in forecast
outputs, and ensures readiness for NZCE-related reviews.
3. In-Scope Functional Description
● Apply PETH-standard data quality rules to all OPU input files during ingestion.
● Surface DQ results in a Data Submission Report (DSR).
● Trigger automated alerts when data does not meet minimum thresholds.
● Provide clear messaging for users to understand error types.
4. Workflow / Process Flow
1. User uploads an OPU file.
2. System runs PETH-aligned data quality checks (completeness, validity, accuracy,
consistency, uniqueness, timeliness).
3. The system generates a Data Quality Report (DQR) with pass/fail indicators.
4. If DQ fails → ingestion is blocked, and a notification is sent.
5. User reviews DQR, corrects data, and re-uploads the file.
5. Data Requirements
5.1 Input Data
● OPU Output Year file (9-sheet template).
● PETH reference lists (valid codes, value ranges, data types).
Page 36


## Page 37
For Internal Use - For Internal Distribution Only
● Expected year range (2019–2050).
5.2 Validation Rules
Completeness – Mandatory fields cannot be blank; all required sheets and years must exist.
Validity – Values must fall within valid ranges and codes defined by PETH.
Accuracy – Numeric fields must contain numeric values; no precision loss allowed.
Consistency – Related fields must align logically across sheets (e.g., totals = sum of
components).
Uniqueness – No duplicate OPU–year records or duplicate rows within a sheet.
Timeliness – Data must be uploaded within agreed processing timelines.
5.3 Transformation Rules
● No transformation beyond standard data type casting.
● Invalid records must be flagged, not automatically corrected.
5.4 Output Data
● Data Submission Report (DSR) including:
○ Error Type
○ Pass/Fail count
○ Error Details
6. Business Rules
● Mandatory DQ rules must execute on every ingestion.
● No dataset enters the calculation engine unless it passes the minimum DQ threshold.
● All DQ messages must be human-readable and traceable.
7. Non-Functional Requirements
Page 37


## Page 38
For Internal Use - For Internal Distribution Only
● DSR must be exportable.
● Error messages must be clear and actionable.
8. Dependencies / Assumptions
● PETH provides canonical parameter lists (e.g., valid codes, ranges).
● Template remains stable throughout the project.
● Users correct and re-upload files upon DQ failure.
9. Permissions / RBAC
● G&M Sustainability: run ingestion, view full DSR.
● OPU: future phase; view DSR only for their own uploads.
● Approvers/view-only: may view DSR but not upload.
10. Success Criteria
● Ingestions undergo PETH-compliant DQ checks.
● < 5% ingestion failure due to data issues after training period.
● All failed rules generate clear notifications.
● DQR is used consistently by G&M Sustainability for validation.
11. Out-of-Scope
● Advanced machine-learning data validation.
Page 38


## Page 39
For Internal Use - For Internal Distribution Only
● Auto-correction of invalid values.
● Modifying OPU templates.
Page 39


## Page 40
For Internal Use - For Internal Distribution Only
BR-09 – Change Rationale Capture
BR-09.1. Business Requirement Summary
The system shall capture annotations explaining the business rationale whenever key variables or
assumptions are changed within scenarios or model configurations.
BR-09.2. Business Rationale
Any change to assumptions or variables can significantly influence model outputs.
Capturing the rationale ensures transparency, supports audit requirements, and provides context
for future reviewers and decision-makers.
BR-09.3. In-Scope Functional Description
● When a user updates a key variable or assumption, the system prompts for a
rationale/annotation.
● The rationale is stored together with the variable change.
● The annotation becomes part of the scenario’s audit and lineage record.
● Rationale must be viewable whenever reviewing scenario details or lineage.
BR-09.4. Workflow / Process Flow
1. User adjusts a key variable or assumption.
2. System prompts for a rationale entry.
3. User submits the rationale.
4. System stores the rationale linked to:
○ the variable changed,
Page 40


## Page 41
For Internal Use - For Internal Distribution Only
○ the scenario,
○ the user,
○ timestamp (Malaysia time).
5. Rationale is displayed in scenario review and lineage views.
BR-09.5. Data Requirements
5.1 Input Data
● User-entered rationale text.
● Variable change metadata (old value, new value).
● Scenario context.
5.2 Validation Rules
● Rationale is mandatory for key variable changes.
● Empty rationale cannot be submitted.
5.3 Transformation Rules
● No transformation; rationale is stored as free text.
5.4 Output Data
● Structured record: variable → change → rationale → user → timestamp.
BR-09.6. Business Rules
Page 41


## Page 42
For Internal Use - For Internal Distribution Only
● Every key variable change requires a rationale.
● Rationale cannot be edited once submitted (append-only model).
● Rationale must appear in lineage and scenario audit records.
BR-09.7. Non-Functional Requirements
● Rationale text stored securely and durably.
● Must support typical text lengths for business explanations.
BR-09.8. Dependencies / Assumptions
● Scenario module is active (BR-05, BR-06).
● Lineage/audit framework available (BR-04).
● Key variable definitions are predefined.
BR-09.9. Permissions / RBAC
● Users changing variables: required to enter rationales.
● View-only users: can view rationales.
● Admins: can review full change logs.
BR-09.10. Success Criteria
Page 42


## Page 43
For Internal Use - For Internal Distribution Only
● 100% of key variable changes have a recorded rationale.
● Rationale appears correctly in lineage and scenario review.
● Audit teams can fully trace why assumptions were modified.
BR-09.11. Out-of-Scope
● Approval workflow for rationale.
● Automatic text summarisation.
● Rationale editing after submission.
Page 43


## Page 44
For Internal Use - For Internal Distribution Only
BR-10 – Notifications for Errors & Data Changes
BR-10.1. Business Requirement Summary
The system shall send outlook email notifications when an OPU file is uploaded, when a
scenario is created, and when a scenario is approved or rejected.
Each notification must include basic context such as user, timestamp, and the affected item.
BR-10.2. Business Rationale
Stakeholders must be informed when key actions occur in the system, such as new data uploads
or scenario decisions.
Notifications support transparency, coordination, and timely follow-up among users involved in
data management and scenario planning.
BR-10.3. In-Scope Functional Description
● Trigger email notification when an OPU file upload is completed.
● Trigger email notification when a new scenario is created.
● Trigger email notification when a scenario is approved.
● Trigger email notification when a scenario is rejected.
● Notifications include:
○ Action performed
○ Who performed it
○ Timestamp (Malaysia local time)
○ Relevant identifiers (OPU name, scenario name)
BR-10.4. Workflow / Process Flow
Page 44


## Page 45
For Internal Use - For Internal Distribution Only
1. User uploads an OPU file → system sends “File Upload Completed” email.
2. User creates a scenario → system sends “Scenario Created” email.
3. Reviewer approves a scenario → system sends “Scenario Approved” email.
4. Reviewer rejects a scenario → system sends “Scenario Rejected” email.
BR-10.5. Data Requirements
5.1 Input Data
● Upload metadata (user, datetime, OPU, year).
● Scenario metadata (scenario name, creator, datetime).
● Scenario approval/rejection metadata (reviewer, decision, datetime).
5.2 Validation Rules
● Notification must not trigger if the action fails (e.g., upload error).
● Approve/reject notifications only trigger after the decision is confirmed.
5.3 Transformation Rules
● Metadata formatted into a user-friendly email message content.
5.4 Output Data
● Email notifications summarising each event.
● Notification logs are stored internally.
BR-10.6. Business Rules
Page 45


## Page 46
For Internal Use - For Internal Distribution Only
● All upload, creation, approval, and rejection actions must trigger notifications.
● Emails must clearly indicate the type of action.
● Notifications must use Malaysian local time.
BR-10.7. Non-Functional Requirements
● Email delivery must be reliable and logged.
● Message content must be readable and concise.
BR-10.8. Dependencies / Assumptions
● Email service (SMTP) is available.
● User roles and email addresses are properly configured.
● Scenario management workflow exists (create → approve/reject).
BR-10.9. Permissions / RBAC
● Recipients: data owners, scenario owners, reviewers.
BR-10.10. Success Criteria
● Notifications are sent for 100% of file uploads and scenario events.
● Users consistently receive notifications within required latency.
● Notifications contain sufficient context for the recipient to act.
BR-10.11. Out-of-Scope
Page 46


## Page 47
For Internal Use - For Internal Distribution Only
● In-app alerts or notification centre.
● SMS or push notifications.
● Multi-level or escalated approval workflows. This means that if the approval workflow is
from A > B > C, if B does not respond, it will not automatically skip to C.
Page 47


## Page 48
For Internal Use - For Internal Distribution Only
BR-11 – Emissions Reduction Recommendations
OPTIONAL NICE TO HAVE. This will be subject to an addendum scoping document if both
parties (Asuene and PETH) jointly agree to undertake this and that it will not be construed as
part of the current contract agreed milestone delivery.
1. Business Requirement Summary
The system should provide simple recommendations on how to adjust variables when a user
targets a specific emissions reduction outcome (e.g., “reduce 500,000 tCO₂e by 2030”).
2. Business Rationale
Users often set high-level emission targets (e.g., a 2030 reduction amount) but may not know
how to distribute or apply the reduction across years or levers.
Providing basic recommendations improves usability and prevents unrealistic one-year changes.
3. In-Scope Functional Description
● When a user enters a target (e.g., “reduce 500,000 tCO₂e by 2030”), the system suggests
a simple, logical allocation approach.
● Example: distribute the reduction evenly across the remaining years (e.g., 2025–2030).
● System may also suggest concentrating reductions in earlier years, or proportionally to
current emissions levels (simple heuristics).
● Recommendations are optional; the user may override them.
4. Workflow / Process Flow
1. User defines a reduction goal for a target year.
2. System calculates required annual or period-based adjustments.
Page 48


## Page 49
For Internal Use - For Internal Distribution Only
3. System recommends how to distribute the reduction (e.g., average per year).
4. User accepts or modifies the suggested values.
5. Data Requirements
5.1 Input Data
● User’s reduction target (value + target year).
● Baseline emissions by year.
5.2 Validation Rules
● The target year must be within the available forecast years.
● Reduction value must be numeric.
5.3 Transformation Rules
● System computes recommended allocation = total reduction ÷ number of remaining
years.
5.4 Output Data
● Suggested per-year reductions or adjustments.
6. Business Rules
● Recommendations are advisory, not enforced.
● The system should not propose unrealistic negative values.
● If baseline already below the target, system shows “Target Already Met”.
Page 49


## Page 50
For Internal Use - For Internal Distribution Only
7. Non-Functional Requirements
● Display must be simple and understandable.
8. Dependencies / Assumptions
● Baseline emissions per year are available.
● Users can manually adjust scenario variables after seeing recommendations.
9. Permissions / RBAC
● All scenario-editing users can receive recommendations.
● Admins can configure simple recommendation formulas.
10. Success Criteria
● Users understand how to adjust variables to meet a target.
● System provides clear and simple suggestions (e.g., average distribution).
● Users can accept or override the recommendation smoothly.
11. Out-of-Scope
● Machine learning optimisation.
● Multi-lever or complex reduction modelling.
● Automatic scenario creation.
Page 50


## Page 51
For Internal Use - For Internal Distribution Only
4 SCOPE DEFINITION
4.1 In Scope
1. Automated Data Ingestion
● Full automation of OPU Output Year file ingestion (11-sheet structure).
● Removal of all manual copy-paste into the G&M workbook.
2. Data Validation & Zero-Error Processing
● Structural and data validation for all ingested files.
● Elimination of calculation and rounding errors (full precision, sum-over-sum).
3. Automated G&M Calculations
● Replication of all G&M workbook formulas within the AA calculation engine.
● Support for year-by-year (2019–2050) modelling.
4. Scenario Planning & Management
● Creating, adjusting, saving, approving, rejecting and export scenarios.
● Independent scenario selection for analysis.
● Simple reduction recommendations to help users meet emission targets (nice-to-have).
5. Scenario Variable Overrides & Tracking
● Application of variable overrides without changing baseline datasets.
● Capturing business rationale for variable/assumption changes.
6. Data Lineage & Auditability
Page 51


## Page 52
For Internal Use - For Internal Distribution Only
● End-to-end lineage from OPU source → ingestion → transformation → calculation →
scenario → dashboard.
● Tracking of user actions, timestamps (Malaysia time), and change notes.
7. Executive Dashboard
● Automated generation of C-level visualisations
● PPT included executive charts (GHG, Methane, Energy, Intensity, Reduction).
● Shared filters and independent OC/ES toggles.
8. RBAC
• Enable configurable filters so different stakeholders can view only the outputs relevant to
them.
9. Notifications
● Email notifications for:
○ File uploads
○ Scenario creation
○ Scenario approval and rejection
10. User Experience & Adoption
● System must be intuitive and meet usability expectations for OPU and G&M
Sustainability users.
● aligns with the broader NZCE/GFM transformation objectives.
11. Compliance
● Alignment with Gas NZCE Roadmap and reporting expectations for P4R, C-Suite, and
STAR
12. Export feature
Page 52


## Page 53
For Internal Use - For Internal Distribution Only
• The dashboard or chart from the Asuene platform will be exported to Image or PPTX file.
4.2 Out of Scope
1. Redesign of OPU Spreadsheets
● No changes to how OPUs prepare or compile their Output Year files.
● No development of new templates or automation for OPU-side processes.
2. Integration with Non-Sustainability Systems
● No integration with ERP, HR, finance, or production operations systems.
● No data exchange with external corporate systems in this phase.
3. Regulatory or Legal Interpretation
● System will not interpret, validate, or enforce regulatory or legal requirements beyond
what is provided.
4. Non-G&M Sustainability Modules
● Any sustainability reporting not related to G&M (e.g., biodiversity, waste, water) is
excluded.
5. Machine-Learning or Advanced Optimisation
● No automated optimisation, predictive modelling, or AI-driven scenario building.
6. OPU Self-Upload (Future Phase)
● Only G&M Sustainability uploads are in scope; OPU self-upload is planned for future
expansion.
______________________________________________________________________________
_______
Page 53


## Page 54
For Internal Use - For Internal Distribution Only
Page 54


## Page 55
For Internal Use - For Internal Distribution Only
5 HIGH-LEVEL ARCHITECTURE & DATA
FLOW DIAGRAM
Page 55


## Page 56
For Internal Use - For Internal Distribution Only
6. USER ROLES & ACCESS MATRIX (RBAC)
6.1 User Roles
Role Description
G&M Sustainability Team Primary operators: upload OPU files, manage
scenarios.
Create and adjust scenarios and variables.
OPU Representatives Provide OPU files (future phase), view outputs related
to their own OPU.
Scenario Owners Create and adjust scenarios and variables. For now are
G&M Sustainability TEAM.
Approvers (Leadership / Approve or reject scenarios.
Sustainability Leads)
View-Only Users (Exec / Reporting) Access dashboards and visuals only.
6.2 Access Matrix
Page 56


## Page 57
For Internal Use - For Internal Distribution Only
Function / G&M OPU Scenario Owners View-Only Users
Feature Sustainability Representatives
(Future)
Upload OPU File Yes Yes Yes (because No
Scenario Owner =
G&M
Sustainability)
View Data Yes Yes (own OPU) Yes Yes
Submission
Report (DSR)
View Baseline Yes Yes Yes Yes
Data
Create Scenario Yes No Yes No
Edit Scenario Yes No Yes No
Variables
View Scenario Yes Yes Yes Yes
Outputs
View Lineage / Yes Yes Yes Yes
Audit Trail
Page 57


## Page 58
For Internal Use - For Internal Distribution Only
View Executive Yes No Yes No
Dashboard
Adjust Yes Yes Yes Yes
Dashboard
Filters
Receive Upload Yes Yes Yes No
Notifications
Receive Scenario Yes No Yes No
Notifications
______________________________________________________________________________
_______
Page 58


## Page 59
For Internal Use - For Internal Distribution Only
7. REPORTING FREQUENCY & REFRESH
LOGIC
This section defines how often data is refreshed, when calculations run, and how quickly changes
propagate to dashboards and executive visualisations.
7.1 Data Ingestion & Baseline Refresh Frequency
Activity Trigger Refresh Behaviour
OPU File Upload Manual upload by G&M Baseline ingestion runs immediately after upload.
Sustainability (Phase 1)
Re-upload of User selects the same Baseline dataset for that OPU is overwritten and
OPU File OPU recalculated.
Validation During ingestion No baseline refresh; error notification is sent.
Failure
Summary:
● Baseline refresh = event-driven, not scheduled.
● Every successful upload → automatic ingestion + recalculation.
7.2 Calculation Engine Refresh Logic
Calculation Type Trigger Expected Latency
Page 59


## Page 60
For Internal Use - For Internal Distribution Only
Baseline Calculations Completion of ingestion < 120 seconds
Scenario Calculations When a scenario variable changes < 1 minute
Re-run Calculations Any baseline or scenario update Automatically triggered
Notes:
● All calculations must use full precision (BR-03).
● No scheduled batch loads; system is on-demand.
7.3 Scenario Engine Refresh Logic
Scenario Action Refresh Behaviour
Create Scenario Scenario dataset generated instantly
Modify Variables Variables Update
Submit for Approval Recalculation triggered & state change
Approve / Reject Scenario Notification sent
Important:
Scenario recalculation must complete within 1 minute, so users can immediately see updated
results in dashboards.
Page 60


## Page 61
For Internal Use - For Internal Distribution Only
7.4 Dashboard & Visual Refresh Logic
Executive Dashboard (BR-07)
Both Executive Dashboard refresh based on:
● Selected Scenario
● OC/ES toggle
● Global filters:
○ Business Unit
○ OPU
○ Year
Refresh Timing
Trigger Dashboard Response Time
Scenario change < 30 seconds
OC/ES toggle < 30 seconds
Shared filter change < 30 seconds
(BU/OPU/Year)
Baseline recalculation due to Dashboard updates automatically on next load or filter
ingestion interaction
Page 61


## Page 62
For Internal Use - For Internal Distribution Only
Display Logic
● No caching of stale data.
● Dashboard always pulls the latest approved or active scenario dataset.
7.5 Lineage & Audit Refresh Logic
Trigger Lineage Update Behaviour
Ingestion completion New lineage record added
Variable change New lineage entry with time/user
Scenario approval State-change entry recorded
Lineage updates are always < (input) seconds.
7.6 Notification Timing (BR-10)
Event Notification Timing
File upload completed Within 1 minute
Page 62


## Page 63
For Internal Use - For Internal Distribution Only
Scenario created Within 1 minute
Scenario approved Within 1 minute
Scenario rejected Within 1 minute
7.7 Summary of Refresh Logic
● Baseline updates → immediate ingestion + recalculation
● Scenario changes → recalculation within < 1 minute
● Dashboard → refresh on every interaction (filter/scenario)
● Lineage → real-time
● Notifications → within 1 minute
This ensures that all forecasting, executive views, and scenario outputs are always aligned with
the most current data.
7.8. Export follow:
The system supports direct export to an image or PowerPoint (BR-06, BR-07). Raw data can also
be exported to Excel upon user request. The figure below illustrates the export flow.
Page 63


## Page 64
For Internal Use - For Internal Distribution Only
______________________________________________________________________________
_______
Page 64


## Page 65
For Internal Use - For Internal Distribution Only
8. ASSUMPTIONS
This section outlines the conditions assumed to be true for the successful delivery and operation
of the system. These assumptions influence project scope, technical feasibility, and user
expectations.
8.1 Data & Template Assumptions
1. OPU Output Year files follow the standard 11-sheet template, including consistent
naming and column structures.
2. OPUs will not modify the structure (e.g., sheet names, number of columns) without
notifying the project team.
3. All year columns required for modelling (2019–2050) are present and populated.
4. Units used in OPU files (mtpa, tonnes, tCO₂e, GJ, etc.) remain consistent with the
template.
5. File sizes remain within expected operational limits for ingestion and processing.
8.2 Technical & System Assumptions
1. The AA calculation engine supports all G&M formulas and transformation rules required.
2. The system can store and compute values with full decimal precision (BR-03).
3. Scenario engine supports variable overrides, persistence, and approval workflows (BR-
05, BR-06).
4. Data lineage mechanisms can capture all required metadata: source, transformation,
users, timestamps (Malaysia time).
5. Notification system (email/SMTP) is available, stable, and configurable.
Page 65


## Page 66
For Internal Use - For Internal Distribution Only
6. System performance meets required SLAs (<1 min for scenario calculations, <30s
ingestion).
8.3 User & Operational Assumptions
1. G&M Sustainability remains the primary operator for ingestion and scenario management
during Phase 1.
2. OPU Representatives will provide input files on time and in the correct format.
3. Scenario Owners (currently G&M Sustainability) have the business understanding to
configure variables correctly.
4. Approvers will review scenarios within required timeframes.
5. View-only users have no requirement to modify data or scenarios.
6. Users will follow documented business rules and naming conventions for scenarios.
8.4 Governance & Compliance Assumptions
1. Forecasting logic provided in the G&M workbook is final and approved for migration
into the AA system.
2. No regulatory or legal interpretation is required from the system (out of scope).
3. NZCE, P4R, C-Suite, and STAR reporting expectations remain aligned with current
logic.
8.5 Future Phase Assumptions
1. OPU self-upload will be introduced later but is not required for Phase 1 delivery.
2. Additional scenario optimisation (e.g., ML-based recommendations) may be added in
future phases but is not required now.
Page 66


## Page 67
For Internal Use - For Internal Distribution Only
8.6 Project Delivery Assumptions
1. All required documentation (G&M logic, templates, PPT design references) will be
provided by PETH.
2. Stakeholders will participate in UAT to validate outputs and dashboards.
3. Any change in template or business rules must be communicated and approved prior to
implementation.
8.7 Summary
These assumptions form the basis of solution design and delivery.
Any change in assumptions may affect system behaviour, project timeline, or scope boundaries.
Page 67


## Page 68
For Internal Use - For Internal Distribution Only
9. CONSTRAINTS
This section outlines the technical, operational, and business limitations that constrain system
design, implementation, and operation.
9.1 Technical Constraints
1. AA Platform Capabilities
○ All calculations must operate within the technical limits of the AA calculation
engine (function library, performance ceiling, memory constraints).
2. File Format Limitations
○ Only the defined OPU Excel template (11-sheet structure) is supported.
○ No support for CSV, Google Sheets, or custom formats.
3. Performance Boundaries
○ Ingestion must be completed within < 120 seconds per file.
○ Scenario recalculation must be completed within < 1 minutes.
4. Precision Handling
○ Full decimal precision is required; no rounding allowed (BR-03).
○ The system must avoid floating-point precision loss, which may limit the
implementation approach.
5. Storage Limitations
○ All annual datasets (2019–2050) must remain tractable for storage and
computation within platform constraints.
Page 68


## Page 69
For Internal Use - For Internal Distribution Only
9.2 Data Constraints
1. Structured Input Requirement
○ System requires that OPUs follow the official template exactly; deviations
produce ingestion errors.
2. No Automated Correction
○ The system cannot correct invalid, missing, or inconsistent data—users must fix
and re-upload.
3. Year Range Fixed
○ Forecast logic and dashboards are limited to years 2019–2050, as defined in the
G&M model.
4. Baseline Overwrite Logic
○ Only one baseline dataset per OPU per year is stored at a time; latest upload
overwrites previous ones.
9.3 Business Process Constraints
1. Scenario Workflow
○ Only one approval workflow is supported (submit → approve/reject).
○ No multi-level or parallel approval chains.
2. OPU Self-Upload
○ Restricted for future phases; Phase 1 supports only G&M Sustainability uploads.
3. No Modification of Source Templates
Page 69


## Page 70
For Internal Use - For Internal Distribution Only
○ The project does not include redesign or automation of OPU spreadsheet creation.
4. Manual Rationale Requirements
○ Users must manually provide rationale for scenario variable changes (BR-09).
9.4 UI/UX Constraints
1. Standardised Visual Design
○ Executive charts must align with the PETH-provided PPT design and cannot be
arbitrarily modified.
2. Non-Editable Lineage
○ Users can view lineage but cannot edit or delete lineage components.
9.5 Compliance & Governance Constraints
1. Malaysia Time Zone Enforcement
○ All timestamps, lineage, and audit records must follow Malaysia local time.
2. Regulatory Neutrality
○ The system must not interpret regulatory frameworks or make validation
judgments beyond the provided logic.
3. P4R, C-Suite, and STAR Alignment
○ Compliance output is dependent on the provided G&M logic; the system cannot
self-adjust.
Page 70


## Page 71
For Internal Use - For Internal Distribution Only
9.6 Integration Constraints
No External System Integration
○ No ERP, HR, Finance, or other corporate systems will be integrated in this phase.
○ Future integrations require new scope.
9.7 Project Delivery Constraints
1. Template & Logic Stability
○ Any change to the OPU template or G&M logic during development will impact
scope, timeline, and rework.
2. Dependency on PETH Inputs
○ Timely provision of business rules, templates, and PPT references is necessary for
delivery.
3. Resource Availability
○ G&M Sustainability and PETH stakeholders must be available for validation,
UAT, and scenario review cycles.
9.8 Summary
These constraints define the boundary conditions of the solution.
Any relaxation or modification of these constraints may require redesign, additional
development scope, or changes to timelines and deliverables.
Page 71


## Page 72
For Internal Use - For Internal Distribution Only
10. EXECUTIVE SUMMARY
This Business Requirements Document defines the end-to-end solution for automating G&M
forecasting, scenario planning, and executive-level reporting within the Asuene Analytics (AA)
platform.
The solution replaces manual workbook-based processes with a fully digitised, traceable, and
scalable system aligned with PETH’s NZCE roadmap and G&M Sustainability operational
needs.
The core capabilities delivered through this BRD include:
● Automated ingestion of OPU Output Year files, eliminating manual consolidation and
ensuring structural consistency (BR-01).
● Accurate and fully automated G&M calculations using AA’s calculation engine,
ensuring formula fidelity and full decimal precision (BR-02, BR-03).
● Scenario creation, adjustment, approval, and persistence, enabling rapid what-if
analysis and structured decision workflows (BR-05, BR-06).
● Comprehensive data lineage, providing transparent end-to-end traceability for every
reported value, aligned with audit and governance expectations (BR-04, BR-09).
● Executive visualisation, allowing C-level users to see the chart without manual slide
preparation (BR-07).
● Automated notifications to keep stakeholders informed of key events such as file
uploads and scenario decisions (BR-10, nice-to-have).
● Simple emissions-reduction recommendations to assist users in reaching defined
targets (BR-11, nice-to-have).
The BRD further defines the roles and permissions (G&M Sustainability, OPU, Scenario
Owners, Approvers, View-Only Users), along with the complete data lifecycle—from ingestion
to dashboard visualisation—and the underlying governance model supporting accuracy,
auditability, and usability.
This solution provides a foundation for long-term scalability, including future OPU self-upload,
extended dashboards, and advanced optimisation capabilities.
By digitising the G&M forecasting pipeline, PETH and G&M Sustainability will benefit from:
Page 72


## Page 73
For Internal Use - For Internal Distribution Only
● Faster forecasting cycles
● Reduced manual effort and risk
● Greater transparency and auditability
● Consistent, executive-ready outputs
● Stronger alignment with NZCE and corporate sustainability targets
Overall, this BRD defines a unified and future-proof platform capable of supporting operational
and strategic decarbonisation planning across LNGA and G&P.
Page 73

