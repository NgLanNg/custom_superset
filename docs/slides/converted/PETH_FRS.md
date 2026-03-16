 
FUNCTIONAL REQUIREMENTS 
SPECIFICATIONS 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

TABLE OF CONTENTS 
TABLE OF CONTENTS​
2 
1. INTRODUCTION​
10 
1.1 Purpose​
10 
1.2 Background​
10 
1.3 Scope​
11 
1.3.1 In Scope​
11 
1.3.2 Out of Scope​
11 
1.3.3 Scope Clarification​
11 
1.4 Audience​
12 
2. SYSTEM OVERVIEW​
13 
2.1 System Objectives​
13 
2.2 High-Level Architecture​
14 
2.2.1 Physical Architecture Explanation​
14 
a) Purpose​
14 
b) Key actors / touchpoints​
14 
c) Inputs​
15 
d) Control gates / governance checkpoints​
15 
e) Data states & storage zones​
15 
f) Processing / transformation​
15 
g) Outputs (data products)​
16 
h) Consumption (dashboards / users)​
16 
i) Auditability & lineage​
16 
j) Security / access boundaries (physical)​
17 
k) Executive summary​
17 
2.2.2 Logical Architecture Explanation​
18 
a) Purpose​
18 
b) Key actors / touchpoints​
18 
c) Inputs​
18 
d) Control gates / governance checkpoints​
19 
e) Data states & storage zones​
19 
f) Processing / transformation​
20 
g) Outputs (data products)​
20 
h) Consumption (dashboards / users)​
21 
i) Auditability & lineage​
21 
j) Security / access boundaries (logical)​
21 
k) Executive summary​
22 
2.3 User Roles & Permissions​
22 
3. FUNCTIONAL REQUIREMENTS​
22 
3.1 BR-01 – Automated Data Ingestion from OPU Outputs​
22 

3.1.1 Summary​
22 
3.1.2 Story Details​
23 
S-01-01 – OPU Data Upload​
23 
A. Description​
23 
B. Functional Requirements​
23 
B.1 Data Logic​
23 
B.2 Filter Logic​
25 
B.3 Groupings​
25 
C. Visualisation Requirements​
26 
C.1 Layout​
26 
C.2 Filter​
26 
C.3 Tooltips​
26 
S-01-02 – Data Submission Report​
26 
A. Description​
26 
B. Functional Requirements​
26 
B.1 Data Logic​
27 
B.1.4 Two-Dimensional Data Handling (Year × Data)​
28 
B.2 Filter Logic​
28 
B.3 Groupings​
28 
C. Visualisation Requirements​
29 
C.1 Layout​
29 
C.2 Filter​
29 
C.3 Tooltips​
30 
3.2 BR-02 – Automated G&M Calculations​
30 
3.3 BR-03 – Precision & No Rounding Errors​
30 
3.4 BR-04 – Data Lineage & Auditability​
30 
3.5 BR-05 – Scenario Planning & Variable Management​
30 
3.6 BR-06 – Scenario Persistence & Comparison​
30 
3.6.1 Summary​
30 
Scenario Management (CRUD & Approval) – Story Overview​
31 
Scenario Comparison – Story Overview​
31 
3.6.2 Story Details​
32 
S-06-01 – Scenario Management Page​
32 
A. Description​
32 
B. Functional Requirements​
33 
B.1 Data Logic​
33 
B.2 Filter Logic​
33 
B.3 Groupings​
33 
C. Visualization Requirements​
34 
C.1 Layout​
34 
C.2 Filter​
34 

C.3 Tooltips​
34 
S-06-02 – Scenario Creation Page​
34 
A. Description​
34 
B. Functional Requirements​
35 
B.1 Data Logic​
35 
B.2 Filter Logic​
38 
B.3 Groupings​
38 
C. Visualisation Requirements​
38 
C.1 Layout​
38 
C.2 Interaction Rules​
38 
C.3 Tooltips​
39 
S-06-03 – Scenario Preview​
39 
A. Description​
39 
B. Functional Requirements​
39 
B.1 Data Logic​
39 
B.2 Filter Logic​
40 
B.3 Groupings​
41 
C. Visualisation Requirements​
41 
C.1 Layout​
41 
C.2 Filter​
42 
C.3 Tooltips​
42 
S-06-04 – Scenario Approval & Notification​
43 
A. Description​
43 
B. Functional Requirements​
43 
B.1 Data Logic​
43 
B.2 Filter Logic​
44 
B.3 Groupings​
44 
C. Visualisation Requirements​
44 
C.1 Layout​
44 
C.2 Filter​
45 
C.3 Tooltips​
45 
S-06-05 – Comparative Total GHG Emission Dashboard​
45 
B. Functional Requirements​
45 
B.1 Data Logic​
45 
B.2 Filter Logic​
46 
B.3 Groupings​
46 
C. Visualisation Requirements​
47 
C.1 Layout​
47 
C.2 Filter​
47 
C.3 Tooltips​
47 
S-06-06 – Comparative Post-Reduction GHG Emission Dashboard​
48 

A. Description​
48 
B. Functional Requirements​
48 
B.1 Data Logic​
48 
B.2 Filter Logic​
49 
B.3 Groupings​
49 
C. Visualisation Requirements​
49 
C.1 Layout​
49 
C.2 Filter​
50 
C.3 Tooltips​
50 
S-06-07 – Comparative Total Production Dashboard​
50 
A. Description​
50 
B. Functional Requirements​
51 
B.1 Data Logic​
51 
B.2 Filter Logic​
51 
B.3 Groupings​
52 
C. Visualisation Requirements​
52 
C.1 Layout​
52 
C.2 Filter​
53 
C.3 Tooltips​
53 
S-06-08 – Comparative Methane Emission Chart​
53 
A. Description​
53 
B. Functional Requirements​
53 
B.1 Data Logic​
53 
B.2 Filter Logic​
54 
B.3 Groupings​
55 
C. Visualisation Requirements​
55 
C.1 Layout​
55 
C.2 Filter​
55 
C.3 Tooltips​
55 
S-06-09 – Comparative Energy Consumption Chart​
56 
A. Description​
56 
B. Functional Requirements​
56 
B.1 Data Logic​
56 
B.2 Filter Logic​
57 
B.3 Groupings​
57 
C. Visualisation Requirements​
57 
C.1 Layout​
58 
C.2 Filter​
58 
C.3 Tooltips​
58 
3.7 BR-07 – Automated Executive Visualisations​
58 
3.7.1 Summary​
59 

3.7.2 Story Details​
60 
S-07-01. Total GHG Emission Forecast – Operational Control & Equity Share​
60 
A. Description​
60 
B. Functional Requirements​
61 
B.1 Data Logic​
61 
B.2 Filter Logic​
63 
B.3 Groupings​
64 
C. Visualisation Requirements​
64 
C.1 Layout​
64 
C.2 Filter​
64 
C.3 Tooltips​
64 
S-07-02. GHG Emission & GHG Intensity Forecast – Operational Control​
66 
A. Description​
66 
B. Functional Requirements​
66 
B.1 Data Logic​
66 
B.2 Filter Logic​
69 
B.3 Groupings​
69 
C. Visualisation Requirements​
69 
C.1 Layout​
69 
C.2 Filter​
70 
C.3 Tooltips​
70 
S-07-03. GHG Emission & GHG Intensity Profile – Equity Share​
71 
A. Description​
71 
B. Functional Requirements​
71 
B.1 Data Logic​
71 
B.2 Filter Logic​
74 
B.3 Groupings​
74 
B.3 Groupings​
74 
C. Visualisation Requirements​
75 
C.1 Layout​
75 
C.2 Filter​
75 
C.3 Tooltips​
75 
Story S-07-04. Growth Project Listing in Year Range​
76 
A. Description​
76 
B. Functional Requirements​
76 
B.1 Data Logic​
76 
B.2 Filter Logic​
77 
B.3 Groupings​
77 
C. Visualisation Requirements​
78 
C.1 Layout​
78 
C.2 Filter​
78 

C.3 Tooltips​
78 
Story S-07-05. GHG Reduction Forecast by Decarbonisation Projects​
78 
A. Description​
79 
B. Functional Requirements​
79 
B.1 Data Logic​
79 
B.2 Filter Logic​
80 
B.3 Groupings​
80 
C. Visualization Requirements​
80 
C.1 Layout​
80 
C.2 Filter​
81 
C.3 Tooltips​
81 
S-07-07. GHG Reduction Forecast & Green CAPEX​
82 
A. Description​
82 
B. Functional Requirements​
82 
B.1 Data Logic​
82 
B.2 Filter Logic​
83 
B.3 Groupings​
84 
C. Visualization Requirements​
84 
C.1 Layout​
84 
C.2 Filter​
85 
C.3 Tooltips​
85 
S-07-08. Methane Emission & Intensity Forecast (Operational Control)​
86 
A. Description​
86 
B. Functional Requirements​
86 
B.1 Data Logic​
86 
B.2 Filter Logic​
90 
B.3 Groupings​
90 
C. Visualization Requirements​
90 
C.1 Layout​
90 
C.2 Filter​
91 
C.3 Tooltips​
91 
S-07-09. Energy Consumption & Energy Intensity Forecast (Operational Control)​
91 
A. Description​
92 
B. Functional Requirements​
92 
B.1 Data Logic​
92 
B.2 Filter Logic​
94 
B.3 Groupings​
94 
C. Visualization Requirements​
95 
C.1 Layout​
95 
C.2 Filter​
95 
C.3 Tooltips​
96 

Story S-07-10. NZCE Pathway: GHG Emission (Equity Share)​
96 
A. Description​
96 
B. Functional Requirements​
97 
B.1 Data Logic​
97 
B.2 Filter Logic​
97 
B.3 Groupings​
97 
C. Visualization Requirements​
97 
C.1 Layout​
97 
C.2 Filter​
98 
C.3 Tooltips​
98 
D. Acceptance Criteria​
98 
Story S-07-11 – NZCE 2050 Traffic Lights (Equity Share)​
99 
A. Description​
99 
B. Functional Requirements​
99 
B.1 Data Logic​
99 
B.2 Filter Logic​
100 
B.3 Groupings​
101 
C. Visualization Requirements​
101 
C.1 Layout​
101 
C.2 Filter​
101 
C.3 Tooltips​
102 
Story S-07-12. Upstream Feedgas and LNG Production Profile (LNGA)​
102 
A. Description​
102 
B. Functional Requirements​
102 
B.1 Data Logic​
102 
B.2 Filter Logic​
104 
B.3 Groupings​
104 
C. Visualisation Requirements​
104 
C.1 Layout​
104 
C.2 Filter​
105 
C.3 Tooltips​
105 
Story S-07-13. Kerteh Feedgas and Salesgas Production Profile (G&P)​
105 
A. Description​
105 
B. Functional Requirements​
105 
B.1 Data Logic​
105 
B.3 Groupings​
105 
C. Visualization Requirements​
106 
C.1 Layout​
106 
C.2 Filter​
106 
C.3 Tooltips​
106 
Story S-07-14. NOJV Production Profile (G&P)​
107 

A. Description​
107 
B. Functional Requirements​
107 
B.1 Data Logic​
107 
Refer Data logic from s07.01​
107 
B.2 Filter Logic​
107 
B.3 Groupings​
107 
C. Visualization Requirements​
108 
C.1 Layout​
108 
C.2 Filter​
108 
C.3 Tooltips​
108 
3.8 BR-08 – Data Quality & Compliance​
109 
3.9 BR-09 – Change Rationale Capture​
109 
3.10 BR-10 – Notifications for Errors & Data Changes​
109 
3.11 BR-11 – Emissions Reduction Recommendations​
109 
5. NON-FUNCTIONAL REQUIREMENTS​
109 
5.1 Performance​
109 
5.2 Security & Access Control​
109 
5.3 Scalability​
109 
5.4 Availability​
109 
5.5 Usability​
109 
5.6 Audit & Logging​
109 
6. ASSUMPTION & CONSTRAINT​
110 
6.1 Assumptions​
110 
6.2 Constraints​
110 
7. CONCLUSION​
110 
8. APPENDENCIES​
110 
8.1 Glossary​
110 
 
 
 
 
 
 
 
 

 
 
1. INTRODUCTION 
1.1 Purpose 
The purpose of this Functional Requirements Specification (FRS) is to define the functional capabilities, 
behaviours, and system interactions required for the platform. This document translates the approved 
Business Requirements (BRs) into actionable, traceable, and testable functional specifications that will 
guide system design, development, data engineering, and quality assurance activities. 
The FRS ensures a shared understanding between business stakeholders and the delivery team regarding: 
●​ The expected system features across dashboards, data processing modules, and workflow 
components​
 
●​ Functional logic supporting scenario modelling, data quality enforcement, and approval 
mechanisms​
 
●​ How each functional requirement maps back to the originating business requirement (BR)​
 
●​ The boundaries and interactions of the components within the end-to-end data ecosystem​
 
This document serves as the single source of truth for all functional expectations of the Project solution. 
1.2 Background 
The platform is being developed to support enterprise-wide greenhouse gas (GHG) forecasting, scenario 
modelling, data quality monitoring, and compliance reporting aligned with Petronas  standards. Current 
forecasting and scenario workflows are fragmented, manually maintained, and lack consistency in data 
lineage, approval control, and comparability across scenarios. 
To address these gaps, Asuene solution consolidates operational, decarbonisation, methane, growth, and 
production datasets into a unified system that enables: 
●​ A consistent and transparent forecasting methodology​
 
●​ Executive-level insights through consolidated dashboards​
 
●​ Scenario comparison with variance analysis and lineage tracing​
 

●​ Automated data quality checks aligned to requirements​
 
●​ A structured approval workflow ensuring data governance and auditability​
 
This FRS provides the functional definition required to implement these capabilities based on the 
Business Requirements (BRs) approved by stakeholders. 
 
1.3 Scope 
1.3.1 In Scope 
This FRS covers all functional requirements necessary to implement the the platform as defined in the 
approved Business Requirements. The scope includes: 
●​ Consolidation and processing of data across operational, decarbonisation, methane, production, 
energy, and growth datasets​
 
●​ Executive dashboards presenting high-level GHG emissions, reductions, and forecast insights​
 
●​ Scenario comparison dashboards, including line/area visualisations, variance analysis, and lineage 
tracing​
 
●​ Data quality measurement and compliance checks based on Petronas standards​
 
●​ Writeback, scenario modification, and approval workflows are governed by Gas Sustainability 
Team  Leader as the final approval authority​
 
●​ Role-based access and permissions for viewing, editing, approving, and reviewing data​
 
1.3.2 Out of Scope 
●​ Detailed technical design, data modelling, and solution architecture (documented separately)​
 
●​ Non-functional infrastructure setup (DevOps, CI/CD, environment provisioning)​
 
●​ External system enhancements beyond what is required for data exchange with the Project​
 
●​ Historical data backfill beyond the baseline period defined in the BRD​
 
●​ Machine learning–based forecasting or optimisation models (future expansion)​
 

1.3.3 Scope Clarification 
The scope defines what the system must do, not the technical implementation details. 
All functional requirements in this FRS will map directly to the corresponding Business Requirements 
(BRs). 
1.4 Audience 
This FRS is intended for all stakeholders involved in the design, development, validation, and governance 
of the  platform. The primary audiences include: 
●​ Gas Sustainability Team and  Leader​
​
 Responsible for reviewing, validating, and approving scenario updates and key data submissions 
within the Project.​
 
●​ Business Owners / Functional Stakeholders (Asuene)​
​
 Provide direction, validate business alignment, and ensure the Project outcomes support 
organisational GHG forecasting and reporting needs.​
 
●​ Product Owner / Business Analyst Team (Asuene)​
​
 Translate business requirements into functional specifications and ensure traceability across all 
the Project features.​
​
 
●​ Data Engineers / ETL Developers (Asuene)​
​
 Implement data pipelines, transformations, and backend processes required to support the Project 
functionalities.​
 
●​ Dashboard Developers / BI Specialists (Asuene)​
​
 Build executive dashboards, scenario comparison visualisations, data lineage views, and data 
quality reporting.​
 
●​ Quality Assurance / Testers (Asuene)​
​
 Validate end-to-end system behaviour against the functional requirements defined in this 
document.​
 
●​ System Administrators / Platform Operators (Asuene)​
​

 Manage access control, system configuration, and operational maintenance related to the Project 
.​
 
This document ensures all audiences share a consistent understanding of the expected system 
functionalities and how they support the the Project business objectives.​
 
2. SYSTEM OVERVIEW 
2.1 System Objectives 
The objective of the  system is to provide a governed, transparent, and consistent platform for greenhouse 
gas (GHG) forecasting, scenario management, and executive decision support. 
Specifically, this Project aims to: 
●​ Enable reliable long-term GHG forecasting across operational, decarbonisation, methane, 
production, energy, and growth domains​
 
●​ Support structured scenario creation, comparison, and analysis to evaluate alternative future 
pathways​
 
●​ Provide executive-level visibility through consolidated dashboards and trend-based visualisations​
 
●​ Ensure data quality, consistency, and compliance in alignment with the requirements​
 
●​ Maintain full traceability of data inputs, calculations, and scenario-driven changes through 
lineage and audit mechanisms​
 
●​ Enforce governance through role-based access and a controlled approval workflow culminating in 
GBOX Leader endorsement​
 
Through these objectivest establishes a single, trusted source for emissions forecasting and scenario-based 
decision-making. 

2.2 High-Level Architecture 
2.2.1 Physical Architecture Explanation 
 
 
​
​
​
​
Image 1.1: Physical Architecture 
a) Purpose 
Describe the updated physical deployment of the Project across EC2, AWS managed services, databases, 
and Tableau extensions, showing how data is ingested, processed, stored, and consumed through 
embedded dashboards and governed writeback. 
 
b) Key actors / touchpoints 
●​ End users accessing dashboards through Asuene Portal (EC2 Webapp instance)​
 
●​ Tableau Server (EC2 Tableau instance) serving embedded dashboards​
 
●​ Infotopics apps for Tableau (agents + writeback components)​
 
●​ AWS ingestion + processing services (S3, EventBridge, Step Functions, Lambda, dbt)​
 
●​ Databases:​
 

○​ Aurora for RDS as the data warehouse​
 
○​ Repository Writeback Postgres DB for writeback persistence​
 
c) Inputs 
●​ Excel files (OPU / PM / other input files) uploaded into the system flow​
 
●​ User-entered changes captured through Tableau writeback input tables (Writeback Extreme)​
 
d) Control gates / governance checkpoints 
●​ Ingestion trigger gate: file arrival into S3 emits events → routed through EventBridge​
 
●​ Workflow gate: Step Functions controls execution sequencing for validation and transformations​
 
●​ Warehouse write gate: only processed outputs are written into Aurora data warehouse​
 
●​ Writeback gate (governed persistence): writeback submissions are stored into the repository 
writeback Postgres database (not directly overwriting warehouse tables)​
 
●​ Approval gate: final promotion/usage of scenario results remains governed by the approval rules 
(GBOX Leader final authority)​
 
e) Data states & storage zones 
●​ Raw file zone: Amazon S3 stores incoming Excel files​
 
●​ Processed / curated zone: Aurora for RDS (Datawarehouse) stores standardised inputs and 
calculated outputs​
 
●​ Writeback repository zone: Repository Writeback Postgres DB stores user-submitted updates 
and writeback payloads​
 
●​ Application/runtime zone: EC2 instances (Asuene Webapp + Tableau Server) host runtime 
services and embedded UI delivery​
 
f) Processing / transformation 
Processing is physically implemented through the AWS workflow block: 

●​ EventBridge receives S3 events and triggers execution​
 
●​ Step Functions orchestrates the end-to-end workflow​
 
●​ Lambda Functions perform validation, parsing, and operational processing steps​
 
●​ dbt applies structured transformations and modelling logic before persisting outputs to the data 
warehouse​
 
g) Outputs (data products) 
●​ Curated datasets in Aurora data warehouse supporting:​
 
○​ scenario-ready input tables​
 
○​ calculated outputs used by dashboards (e.g., emissions, intensities, forecast metrics)​
 
●​ Writeback records in repository Postgres supporting:​
 
○​ input table submissions​
 
○​ traceable updates required for scenario updates and governance​
 
h) Consumption (dashboards / users) 
●​ Users access the dashboard through Asuene Portal, which embeds Tableau dashboards 
(bidirectional embedding shown between Portal and Tableau)​
 
●​ Tableau connects to the data warehouse via live connection (data sync) to ensure dashboards 
reflect the latest governed data​
 
●​ Infotopics components support writeback interactions within Tableau​
 
i) Auditability & lineage 
Auditability is supported physically by: 
●​ Retaining original input files in S3​
 
●​ Persisting curated outputs in the Aurora data warehouse​
 

●​ Storing user writeback actions separately in the repository Postgres DB​
 
●​ Maintaining clear separation between raw inputs, processed warehouse data, and writeback 
submissions to support lineage tracing and governance audits​
 
j) Security / access boundaries (physical) 
The updated physical layout implies distinct security boundaries across: 
●​ Asuene Webapp EC2 (user-facing portal boundary)​
 
●​ Tableau EC2 (analytics boundary)​
 
●​ Database boundary (Aurora data warehouse + writeback repository DB)​
 
●​ Extension boundary (Infotopics agents and apps operating as Tableau extensions)​
 
Access should remain controlled so writeback actions do not bypass governance and do not directly 
overwrite governed warehouse data. 
k) Executive summary 
The updated physical architecture delivers governed analytics through an embedded Tableau experience 
inside the Asuene Portal. Data ingestion is event-driven (S3 → EventBridge → Step Functions), 
processing is orchestrated and standardised (Lambda + dbt), and curated outputs are stored centrally in an 
Aurora data warehouse accessed via live connections. Scenario changes are captured through Infotopics 
Writeback Extreme and stored separately in a writeback repository database, preserving governance, 
auditability, and controlled promotion of data under GBOX Leader approval. 
 

2.2.2 Logical Architecture Explanation 
 
Image 1.2: Logical Architecture 
a) Purpose  
Define the logical rules and control flow governing how the system handles historical data, scenario 
updates, and recalculations, ensuring historical integrity while enabling scenario-based modifications. 
b) Key actors / touchpoints 
●​ Users interacting with the dashboards​
 
●​ Logical commit mechanism within the dashboard​
 
●​ Scenario governance logic​
 
●​ GBOX / GBOX Leader as the final authority over approved outcomes​
 
c) Inputs 
●​ Approved historical data serving as the baseline scenario​
 

●​ User-proposed value changes for Decarbonisation, Methane, and Energy domains​
 
These inputs are logically treated as proposals, not immediate system truth. 
 
d) Control gates / governance checkpoints 
The logical flow enforces multiple mandatory control gates: 
●​ Edit Gate: Users may only propose changes against an existing baseline​
 
●​ Staging Gate: All user changes are written to a staging state​
 
●​ Commit Gate: An explicit commit action is required to formalise changes​
 
●​ Approval Gate: Final scenario validity depends on governance approval (GBOX Leader)​
 
No gate may be bypassed. 
 
e) Data states & storage zones 
The logical data model distinguishes three states: 
●​ Baseline State​
 
○​ Approved, historical, immutable​
 
○​ Used as reference for new scenario creation​
 
●​ Staging Scenario State​
 
○​ Editable​
 
○​ User-specific​
 
○​ Temporary​
 
○​ Not used for reporting or calculations​
 
●​ Final Scenario State​
 

○​ Committed​
 
○​ Assigned a unique scenario identifier​
 
○​ Time-stamped and user-attributed​
 
○​ Eligible for calculation and reporting​
 
f) Processing / transformation 
Once data transitions from staging to final state: 
●​ Logical validation is applied​
 
●​ Scenario identity is fixed​
 
●​ Calculation logic is triggered​
 
Calculations are executed independently per scenario and never overwrite existing results. 
 
g) Outputs (data products) 
For each committed scenario, the system logically produces: 
●​ Finalised scenario input records​
 
●​ Scenario-specific calculation outputs, including:​
 
○​ GHG emissions​
 
○​ GHG intensity​
 
○​ Methane intensity​
 
○​ Energy intensity​
 
○​ Growth intensity​
 
Each output is explicitly linked to a single scenario identifier. 
 

h) Consumption (dashboards / users) 
Dashboards consume only: 
●​ Baseline data​
 
●​ Final, committed scenario data​
 
Staging data is excluded from analytical consumption to prevent accidental exposure of unapproved 
values. 
 
i) Auditability & lineage 
The logical architecture guarantees: 
●​ Every change is attributable to a user​
 
●​ Every committed scenario has a timestamp​
 
●​ Inputs and outputs are linked via scenario identifiers​
 
●​ Historical baselines remain preserved indefinitely​
 
This enables full lineage tracing from baseline to derived scenarios. 
 
j) Security / access boundaries (logical) 
Logical access rules enforce that: 
●​ Only authorised users may edit staging data​
 
●​ Only committed data progresses to calculation​
 
●​ Approved scenarios become read-only​
 
●​ Governance roles control final approval status​
 
These rules protect historical data from modification. 
 

k) Executive summary 
The logical architecture ensures the process never overwrites historical data. All changes are introduced 
through controlled scenario creation, gated by staging, commit, and approval checkpoints. Each scenario 
is independently calculated and traceable, enabling transparent comparison, strong governance, and 
audit-ready historical integrity. 
2.3 User Roles & Permissions 
 
 
3. FUNCTIONAL REQUIREMENTS 
3.1 BR-01 – Automated Data Ingestion from OPU Outputs  
3.1.1 Summary 
BR-01 defines the capability to submit OPU output data into the PET system and provide 
transparent submission reporting. 
This Business Requirement consists of two core functions only: 
1.​ Data Upload​
​
 Enables OPUs to upload structured output files into PET, where the data is validated and ingested 
as the official input for downstream processing.​
 
2.​ Data Submission Report​
​
 Provides visibility into submitted data, including submission status, data coverage, and ingestion 
outcomes, supporting governance, traceability, and audit requirements.​
 
 
Story 
ID 
Story Name 
Brief Description 

S-01-01 
OPU Data Upload 
Allows OPUs to upload output files, perform validation, and ingest 
data into PET as the source dataset. 
S-01-02 
Data Submission 
Report 
Provides reporting and status visibility for all submitted OPU data, 
supporting governance and audit readiness. 
3.1.2 Story Details​
 
S-01-01 – OPU Data Upload 
A. Description 
The OPU Data Upload function enables OPUs to submit structured output files into the PET system as the 
official and authoritative source data for downstream processing. 
All uploaded files must strictly follow the predefined output formats that were distributed at the beginning 
of the programme. PET (via Asuene) does not support ad-hoc, flexible, or partially structured uploads. 
The purpose of this story is to ensure that all ingested data is structurally consistent, complete, and 
auditable before it is used for calculations, scenario creation, or reporting. 
B. Functional Requirements 
B.1 Data Logic 
B.1.1 Supported File Types 
Asuene accepts only the following categories of files: 
1.​ Standard Output Files​
 
○​ Regular OPU output files​
 
○​ Must follow the exact structure of the official Output templates​
 
2.​ NOJV Output Files​
 
○​ Output files for non-operated joint ventures​
 
○​ May differ in content availability (e.g. missing “Emission by Sources” sheet)​
 

○​ Still required to follow the approved NOJV output format​
 
3.​ MISC Output Files​
 
○​ Files related to Shipping or other miscellaneous activities​
 
○​ Must follow the approved MISC output format​
 
No other file types or custom templates are accepted. 
B.1.2 Mandatory Format Compliance 
All uploaded files must strictly comply with the predefined formats that were provided earlier, including: 
●​ Required sheet names​
 
●​ Required sheet order and structure​
 
●​ Required column names​
 
●​ Required column positions​
 
●​ Required units of measurement​
 
This applies to: 
●​ Standard Output files​
 
●​ NOJV Output files​
 
●​ MISC Output files​
 
Any deviation from the provided output format results in upload failure. 
B.1.3 Validation Rules 
During upload, the system validates: 
●​ File type and naming convention​
 
●​ Presence of all mandatory sheets​
 
●​ Presence and position of all mandatory columns​
 

●​ Data type consistency within columns 
 
B.1.4 Data Ingestion 
●​ Successfully validated files are ingested into PET standard tables.​
 
●​ Each ingested record retains full metadata:​
 
○​ Source file name​
 
○​ File category (Standard / NOJV / MISC)​
 
○​ Sheet name​
 
○​ Row reference​
 
○​ Upload timestamp​
 
○​ Uploaded by (user)​
 
●​ Uploaded data becomes the baseline input for all subsequent Business Requirements.​
 
B.2 Filter Logic 
Not Applicable for this Story. 
B.3 Groupings 
●​ Data is logically grouped by:​
 
○​ Submission event​
 
○​ File category (Standard / NOJV / MISC)​
 
○​ OPU​
 
○​ Sheet​
 
●​ No aggregation or transformation is applied at upload stage.​
 

C. Visualisation Requirements 
C.1 Layout 
●​ The upload page provides:​
 
○​ File upload area supporting files submission​
 
○​ Submission page will authorize role permission to each account only upload the file from 
there specific Group OPU, file ingestion and category will get from hierarchy permission 
from Asuene setup 
C.2 Filter 
Not Applicable for this Story. 
C.3 Tooltips 
Not Applicable for this Story. 
 
S-01-02 – Data Submission Report 
A. Description 
The Data Submission Report provides post-upload visibility into the quality and completeness of data 
submitted via S-01-01 – OPU Data Upload. 
This report is designed to: 
●​ Highlight data issues detected during upload​
 
●​ Surface structural format problems and invalid numeric values​
 
●​ Support governance and correction without blocking submission unnecessarily​
 
The report focuses only on exceptions and issues. 
Valid and complete data is not redundantly displayed. 
 
B. Functional Requirements 

B.1 Data Logic 
The Data Submission Report evaluates uploaded data against three rule categories. 
B.1.1 Empty / Missing Data Handling 
●​ Data values are allowed to be empty (null).​
 
●​ Empty values:​
 
○​ Are not treated as errors​
 
○​ Are not blocked from ingestion​
 
○​ Are not highlighted unless required columns are missing​
 
B.1.2 Negative Value Validation 
●​ Any numeric input value < 0 is treated as an error.​
 
●​ Negative values are:​
 
○​ Ingested for traceability​
 
○​ Flagged as Invalid Value​
 
○​ Displayed explicitly in the report​
 
This applies to all numeric datasets (e.g. production, emission, energy). 
 
B.1.3 Format & Column Completeness Check 
●​ Uploaded files are validated against the official output templates.​
 
●​ Validation checks:​
 
○​ Required sheets exist​
 
○​ Required columns/ data rows (UOM, OPUs, BU, Parameters, Levers)  exist​
 
○​ Column names and positions match the template​
 

If a required column is missing: 
●​ The issue is flagged as Missing Data​
 
●​ No attempt is made to infer or reconstruct the data​
 
B.1.4 Two-Dimensional Data Handling (Year × Data) 
●​ Uploaded data follows a two-dimensional structure:​
 
○​ One dimension = Year​
 
○​ One dimension = Data row ( ứOPU / Parameter / Project, etc.)​
 
Reporting logic: 
●​ The Data Submission Report does not display full datasets​
 
●​ It displays only the problematic intersections, including:​
 
○​ Missing required columns​
 
○​ Cells containing negative values​
 
No other data is surfaced in the report. 
B.2 Filter Logic 
●​ Filters available:​
 
○​ File name​
 
○​ File category (Standard / NOJV / MISC)​
 
○​ OPU​
​
 
B.3 Groupings 
●​ Issues are grouped by:​
 

○​ Submission event​
 
○​ File​
 
○​ Sheet​
 
●​ No aggregation or calculation is performed.​
 
C. Visualisation Requirements 
C.1 Layout 
The Data Submission Report page consists of two sections: 
1.​ Submission Issue Summary​
 
○​ High-level list of detected issues per submission​
 
○​ Displays:​
 
■​ File name​
 
■​ Sheet name​
 
■​ Issue type​
 
■​ Issue count​
 
2.​ Issue Detail Table​
 
○​ Displays only:​
 
■​ Missing required columns​
 
■​ Tables data row  containing negative values​
​
 
C.2 Filter 
●​ File name​
 
●​ File category (Standard / NOJV / MISC)​
 

●​ OPU​
 
C.3 Tooltips 
Not Applicable for this Story.​
 
 
3.2 BR-02 – Automated G&M Calculations  
●​ FS-02.x (list only)​
 
3.3 BR-03 – Precision & No Rounding Errors 
●​ FS-03.x​
 
3.4 BR-04 – Data Lineage & Auditability 
●​ FS-04.x​
 
3.5 BR-05 – Scenario Planning & Variable Management  
●​ FS-05.x​
 
 
3.6 BR-06 – Scenario Persistence & Comparison 
3.6.1 Summary 
BR-06 defines the capability to create, manage, and compare scenarios within the system to support 
structured scenario planning, review, and executive-level analysis. 
This BR covers two core functional areas: 
1.​ Scenario Management (CRUD & Approval)​
 Enables users to create, edit, preview, and manage scenarios, including structured approval and 
rejection workflows to ensure governance and data integrity.​
 

2.​ Scenario Comparison​
 Enables users to compare multiple scenarios within a single comparison dashboard, allowing 
side-by-side evaluation of emissions, production, energy, and variance impacts across scenarios.​
 
Together, these capabilities ensure scenarios can be properly governed, reviewed, and analytically 
compared before being used for executive reporting and decision-making. 
Scenario Management (CRUD & Approval) – Story Overview 
Story 
ID 
Story Name 
Brief Description 
S-06-01 
Scenario Management 
Page 
List all scenario possible 
S-06-02 
Scenario Edit Page 
Supports editing of an existing scenario. 
S-06-03 
Scenario Preview Page 
Displays a preview of scenario data prior to submission or 
approval. 
S-06-04 
Scenario Approval & 
Rejection 
Supports approval and rejection of scenarios as part of the 
governance workflow. 
 
Scenario Comparison – Story Overview 
Story 
ID 
Story Name 
Brief Description 
S-06-05 
Comparative Total GHG Emission 
Dashboard 
Displays comparative total GHG emissions across 
selected scenarios. 

S-06-06 
Comparative Post-Reduction 
Emission Dashboard 
Displays comparative post-reduction GHG emissions 
across selected scenarios. 
S-06-07 
Comparative Total Production 
Dashboard 
Displays comparative total production across selected 
scenarios. 
S-06-08 
Comparative Methane Emission 
Chart 
Displays comparative methane emissions across 
selected scenarios. 
S-06-09 
Comparative Energy Consumption 
Chart 
Displays comparative energy consumption across 
selected scenarios. 
S-06-10 
Comparative Growth Chart 
 
S-06-11 
Scenario Variance Summary KPIs 
Displays summary KPIs highlighting variances 
between selected scenarios. 
 
3.6.2 Story Details 
S-06-01 – Scenario Management Page 
A. Description 
The Scenario Management Page provides a centralised view of all existing scenarios in the system. 
It allows users to review scenario metadata and approval status, and enables designated approvers to 
approve or reject scenarios. 
Scenarios are created by the Gas Sustainability Team and submitted to the Gas Sustainability Leader 
for approval. 
Approved scenarios are locked and cannot be edited, while rejected scenarios may be revised and 
resubmitted. 

B. Functional Requirements 
B.1 Data Logic 
●​ The page displays all existing scenarios stored via the writeback mechanism.​
 
●​ Each scenario record includes the following fields:​
 
○​ Scenario ID​
 
○​ Scenario Father ID​
​
 (Indicates whether the scenario is derived from a baseline or another scenario)​
 
○​ Scenario Name​
 
○​ Description​
 
○​ Approval Status​
 
○​ Remark​
 
●​ Approval Status values include:​
 
○​ Pending Approval (default status upon creation)​
 
○​ Approved​
 
○​ Rejected​
 
●​ Once a scenario is marked as Approved, it is considered final and must not be editable.​
 
●​ Scenarios marked as Rejected remain editable.​
 
B.2 Filter Logic 
●​ Not Applicable for this Story​
 
B.3 Groupings 
●​ Not Applicable for this Story​
 

 
C. Visualization Requirements 
C.1 Layout 
●​ Scenarios are displayed in a tabular format.​
 
●​ Each row represents one scenario.​
 
●​ Columns displayed:​
 
○​ Scenario ID​
 
○​ Scenario Father ID​
 
○​ Scenario Name​
 
○​ Description​
 
○​ Approval Status​
 
○​ Remark​
 
C.2 Filter 
●​ Not Applicable for this Story​
 
C.3 Tooltips 
●​ Not Applicable for this Story​
 
S-06-02 – Scenario Creation Page 
A. Description 
The Scenario Creation Page enables the Gas Sustainability Team to create new planning scenarios by 
editing structured datasets derived directly from the uploaded OPU output files. 
This page supports controlled “what-if” adjustments while preserving the baseline dataset.​
 All edits are performed in a tabular, Excel-like interface to maintain user familiarity and minimise 
learning friction. 

The page is designed to: 
●​ Reflect the original uploaded data structure with full fidelity​
 
●​ Allow controlled edits across Equity Share, Growth, and Operational datasets​
 
●​ Automatically propagate edits into the scenario dataset in real time​
 
●​ Prepare the scenario for submission into the approval workflow​
 
B. Functional Requirements 
B.1 Data Logic 
Scenario creation is organised into three controlled sections, strictly aligned with the uploaded source 
files. 
Section 1 – Equity Share Configuration 
Data Source 
●​ Sheet: Equity Share​
 
●​ File: “Output SBD Growth only”​
 
Structure​
 Two editable tables are presented: 
1.​ Equity Share – Existing Assets​
 
○​ Equity Share values by OPU​
 
○​ Year-based columns (Excel-style)​
 
2.​ Equity Share – Growth Projects​
 
○​ Equity Share values by Growth Project​
 
○​ Year-based columns​
 
Logic 

●​ Values are copied from baseline into the scenario dataset on scenario creation​
 
●​ User edits override baseline values only within the scenario​
 
●​ Equity Share changes affect all downstream calculations (GHG, production, intensity)​
 
Section 2 – Growth Data Configuration 
Data Source 
●​ File: “Output SBD Growth”​
 
Structure​
 Four editable tables reflecting the uploaded structure: 
1.​ Growth Project Production​
 
2.​ Growth Project Emission​
 
3.​ Growth Project Reduction​
 
4.​ Growth Project Metadata (if present in file)​
 
Logic 
●​ Tables must mirror the uploaded file column-for-column​
 
●​ All numeric values are scenario-specific overrides​
 
●​ Growth data contributes only to Growth-related calculations​
 
●​ No baseline overwrite is allowed​
 
Section 3 – Operational Data Configuration 
Data Sources 
●​ Output PLC​
 
●​ Output PFLNG​
 

●​ Output GTR​
 
●​ Output GPU​
 
●​ NOJV files where applicable​
 
Editable Tables 
1.​ Production​
 
2.​ Emission by Sources​
 
3.​ Emission by Gases​
 
4.​ Energy Consumption​
 
5.​ Energy Saved​
 
6.​ Intensity​
 
7.​ GHG Emission Reduction​
 
Special Rule – NOJV Data 
●​ NOJV files do not contain an “Emission by Sources” sheet​
 
●​ These records are still mapped into Emission by Sources with:​
 
○​ Source = "N/A"​
 
Logic 
●​ All values originate from baseline on scenario creation​
 
●​ Any edit applies only to the scenario​
 
●​ Calculations follow the same logic as baseline (BR-02)​
 
●​ Full decimal precision is preserved (BR-03)​
 

B.2 Filter Logic 
User can filter in the edit table by “Search” input data by column 
B.3 Groupings 
●​ Data is grouped by:​
 
○​ Section → Table → OPU / Project → Year​
 
●​ Grouping strictly follows the uploaded Excel structure​
 
●​ No re-aggregation or restructuring is allowed​
 
C. Visualisation Requirements 
C.1 Layout 
The page follows a two-tier layout for every table group: 
1.​ Upper Table – Display Table​
 
○​ Readable, Excel-style layout​
 
○​ Year-based columns​
 
○​ Read-only​
 
○​ Reflects current scenario values​
 
2.​ Lower Table – Edit Table​
 
○​ Editable​
 
○​ Auto-populated based on user selection in the upper table​
 
○​ Represents rows as database-style records​
 
C.2 Interaction Rules 
●​ Clicking a single cell (e.g., MLNG – 2030) loads that row into the edit table​
 
●​ Selecting an entire year loads all rows for that year​
 

●​ Editing values in the edit table:​
 
○​ Immediately updates the display table above​
 
○​ Immediately updates the scenario dataset 
C.3 Tooltips 
Tooltips must display: 
●​ Original baseline value (check if possible)​
 
●​ Scenario value​
 
●​ Unit of measurement​
 
●​ Source file and sheet 
 
S-06-03 – Scenario Preview  
A. Description 
The Scenario Preview (Comparison) page allows users to review and validate a scenario by comparing 
it against a reference scenario (e.g. Baseline or another approved scenario) before submission for 
approval. 
This page is read-only and serves as a sanity-check and validation step, enabling users to visually 
confirm that changes made during scenario creation produce the intended impacts across emissions, 
production, energy, and intensity metrics. 
 
B. Functional Requirements 
B.1 Data Logic 
●​ Data displayed on this page is sourced from:​
 
○​ The Baseline  scenario, and​
 
○​ A previewing  scenario (Baseline or other approved scenario)​
 
●​ No recalculation logic is introduced on this page.​
 

●​ All values are retrieved from pre-computed scenario summary tables generated during scenario 
creation (S06-02).​
 
●​ Each comparison chart uses:​
 
○​ Scenario A: Baseline Scenario​
 
○​ Scenario B: Preview Scenario​
 
●​ Metrics displayed follow existing calculation logic defined in BR-02 and BR-07, including:​
 
○​ GHG Emission​
 
○​ Post-Reduction Emission​
 
○​ Production​
 
○​ Methane Emission​
 
○​ Energy Consumption​
 
○​ Growth ​
 
○​ Scenario KPI deltas​
 
B.2 Filter Logic 
The following filters apply globally across all charts: 
●​ Scenario Selector​
 
○​ Primary Scenario (default: baseline scenario)​
 
○​ Comparison Scenario (default: preview)​
 
●​ Control Approach​
 
○​ Operational Control​
 
○​ Equity Share​
 
●​ Year​
 

○​ Single year selection​
 
○​ Multi-year range (where applicable)​
 
●​ BU / OPU​
 
○​ Filters data visibility only​
 
○​ Does not alter underlying scenario calculations​
 
B.3 Groupings 
●​ Data is grouped consistently across all charts by:​
 
○​ Scenario​
 
○​ Year​
 
○​ BU / OPU (where applicable)​
 
●​ Grouping logic mirrors BR-07 executive dashboard groupings to ensure visual consistency.​
 
C. Visualisation Requirements 
C.1 Layout 
●​ The page contains a single comparison dashboard.​
 
●​ Each comparison metric is displayed as a separate chart, with:​
 
1.​ Scenario A vs Scenario B clearly distinguished​
 
2.​ Consistent colour mapping across charts​
 
●​ Charts included on this page:​
 
1.​ Comparative Total GHG Emission​
 
2.​ Comparative Post-Reduction Emission​
 
3.​ Comparative Total Production​
 

4.​ Comparative Methane Emission​
 
5.​ Comparative Energy Consumption​
 
6.​ Growth Comparision​
 
7.​ Scenario Variance Summary KPIs​
 
C.2 Filter 
●​ Filters are positioned at the top of the page.​
 
●​ All charts refresh simultaneously upon filter changes.​
 
●​ Default state:​
 
○​ Primary Scenario = Current Scenario​
 
○​ Comparison Scenario = Baseline​
 
○​ Year​
 
C.3 Tooltips 
Each chart tooltip must display: 
●​ Scenario name​
 
●​ Year​
 
●​ Metric value​
 
●​ Unit of measurement​
 
●​ Absolute difference vs baseline scenario​
 
●​ Percentage variance (where applicable) 
 

S-06-04 – Scenario Approval & Notification 
A. Description 
S-06-04 defines the capability for official scenario approval and rejection, executed from the Scenario 
Management Page (S06-01). 
This function allows an authorized Gas Sustainability Leader to formally approve or reject submitted 
scenarios. Approval actions update the scenario status, lock or unlock editability accordingly, and trigger 
email notifications to relevant stakeholders. 
 
B. Functional Requirements 
B.1 Data Logic 
●​ Scenario approval actions operate on the Scenario Master table used by S06-01.​
 
●​ Approval updates the following fields:​
 
○​ scenario_status​
 
○​ approval_date​
 
○​ approved_by​
 
○​ approval_remark​
 
●​ Status transitions:​
 
○​ Pending Approval → Approved​
 
○​ Pending Approval → Rejected​
 
●​ Status behavior:​
 
○​ Approved​
 
■​ Scenario is locked​
 
■​ No further edits allowed​
 
■​ Eligible for comparison and executive reporting​
 

○​ Rejected​
 
■​ Scenario becomes editable again​
 
■​ User may revise and re-submit​
 
●​ No recalculation is triggered during approval.​
 
●​ Approval does not alter scenario data content—status-only mutation.​
 
B.2 Filter Logic 
N/A 
B.3 Groupings 
N/A​
 
C. Visualisation Requirements 
C.1 Layout 
●​ Approval controls are embedded directly within S06-01 Scenario Management Page.​
 
●​ For each scenario row:​
 
○​ Approve button​
 
○​ Reject button​
 
○​ Remark input (mandatory for rejection, optional for approval)​
 
●​ Buttons are disabled if:​
 
○​ Scenario is already Approved​
 
○​ Scenario is already Rejected​
 
○​ User lacks required role 
Email Notification will be sent to Creators of the Scenario for Review.​
 

C.2 Filter 
N/A​
 
C.3 Tooltips 
N/A​
 
S-06-05 – Comparative Total GHG Emission Dashboard 
A. Description 
This story provides a comparative dashboard that allows users to compare Total GHG Emission 
trajectories across multiple scenarios on a single view. 
Up to five (5) scenarios can be selected simultaneously. Each selected scenario is rendered as an 
independent data series, enabling direct visual comparison of long-term emission trends from 2019 to 
2050. 
B. Functional Requirements 
B.1 Data Logic 
●​ Data source:​
 
○​ Use the scenario summary output generated for each approved scenario.​
 
○​ Only Total GHG Emission values are used.​
 
●​ Scenario handling:​
 
○​ Each selected scenario is treated as an independent dataset.​
 
○​ No aggregation or blending between scenarios.​
 
●​ Time range:​
 
○​ X-axis spans from 2019 to 2050.​
 
○​ Values are taken exactly as stored in each scenario’s summary.​
 
●​ Control approach:​
 

○​ Uses the control approach already defined within each scenario (Operational Control or 
Equity Share).​
 
○​ No conversion or harmonisation across scenarios.​
 
●​ Units:​
 
○​ Remain Mil tCO2e, unchanged from scenario output.​
 
B.2 Filter Logic 
●​ Scenario selector:​
 
○​ Allow selection of up to 5 scenarios.​
 
○​ Only Approved scenarios are selectable.​
 
●​ Organisational filters:​
 
○​ BU​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Filters apply consistently across all selected scenarios.​
 
B.3 Groupings 
●​ Grouping is applied by:​
 
○​ Scenario (each scenario = one line)​
 
○​ Year (2019–2050)​
 
●​ No further grouping or roll-up logic is applied within this story.​
 

C. Visualisation Requirements 
C.1 Layout 
●​ Single line chart:​
 
○​ X-axis: Year (2019–2050)​
 
○​ Y-axis: Total GHG Emission (Mil tCO2e)​
 
●​ Visual rules:​
 
○​ Each scenario is displayed as one distinct line.​
 
○​ Maximum of five lines shown at any time.​
 
●​ Legend:​
 
○​ Displays scenario name corresponding to each line.​
 
C.2 Filter 
●​ Scenario multi-select (max 5)​
 
●​ BU selector​
 
●​ Group OPU selector​
 
●​ OPU selector​
 
C.3 Tooltips 
●​ Tooltip displays:​
 
○​ Scenario name​
 
○​ Year​
 
○​ Total GHG Emission value (Mil tCO2e)​
 
 

S-06-06 – Comparative Post-Reduction GHG Emission Dashboard 
A. Description 
This story provides a comparative dashboard that enables users to compare Post-Reduction GHG 
Emission trajectories across multiple scenarios within a single view. 
Up to five (5) scenarios can be selected simultaneously. Each selected scenario is rendered as an 
independent data series, allowing direct comparison of GHG emissions after applying decarbonisation 
impacts over the period 2019 to 2050. 
B. Functional Requirements 
B.1 Data Logic 
●​ Data source:​
 
○​ Use the scenario summary output generated for each approved scenario.​
 
○​ Use GHG Emission Upon Reduction values only.​
 
●​ Scenario handling:​
 
○​ Each selected scenario is treated as an independent dataset.​
 
○​ No aggregation, averaging, or blending across scenarios.​
 
●​ Time range:​
 
○​ X-axis spans from 2019 to 2050.​
 
○​ Values are taken directly from each scenario’s post-reduction output.​
 
●​ Reduction logic:​
 
○​ Emission values already reflect applied decarbonisation levers.​
 
○​ No recalculation or adjustment occurs at the dashboard layer.​
 
●​ Control approach:​
 
○​ Uses the control approach defined within each scenario (Operational Control or Equity 
Share).​
 

●​ Units:​
 
○​ Remain Mil tCO2e, unchanged from scenario output.​
 
B.2 Filter Logic 
●​ Scenario selector:​
 
○​ Allow selection of up to 5 scenarios.​
 
○​ Only Approved scenarios are selectable.​
 
●​ Organisational filters:​
 
○​ BU​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Filters apply consistently across all selected scenarios.​
 
 
B.3 Groupings 
●​ Grouping is applied by:​
 
○​ Scenario (each scenario = one line)​
 
○​ Year (2019–2050)​
 
●​ No additional grouping or roll-up logic is applied.​
 
C. Visualisation Requirements 
C.1 Layout 
●​ Single line chart:​
 
○​ X-axis: Year (2019–2050)​
 

○​ Y-axis: Post-Reduction GHG Emission (Mil tCO2e)​
 
●​ Visual rules:​
 
○​ Each scenario is displayed as one distinct line.​
 
○​ Maximum of five lines displayed concurrently.​
 
●​ Legend:​
 
○​ Displays scenario name corresponding to each line.​
 
C.2 Filter 
●​ Scenario multi-select (maximum 5)​
 
●​ BU selector​
 
●​ Group OPU selector​
 
●​ OPU selector​
 
C.3 Tooltips 
●​ Tooltip displays:​
 
○​ Scenario name​
 
○​ Year​
 
○​ Post-Reduction GHG Emission value (Mil tCO2e)​
 
S-06-07 – Comparative Total Production Dashboard 
A. Description 
This story provides a comparative dashboard that enables users to compare Total Production 
trajectories across multiple scenarios within a single view. 
Up to five (5) scenarios can be selected simultaneously. Each selected scenario is rendered as an 
independent data series, allowing direct comparison of production trends over the period 2019 to 2050. 

 
B. Functional Requirements 
B.1 Data Logic 
●​ Data source:​
 
○​ Use the scenario summary output generated for each approved scenario.​
 
○​ Use Total Production values only.​
 
●​ Scenario handling:​
 
○​ Each selected scenario is treated as an independent dataset.​
 
○​ No aggregation, averaging, or blending across scenarios.​
 
●​ Time range:​
 
○​ X-axis spans from 2019 to 2050.​
 
○​ Values are taken directly from each scenario’s production output.​
 
●​ Production definition:​
 
○​ Production values follow the definition and calculation logic established in BR-02 and 
BR-07.​
 
○​ No recalculation is performed at the dashboard layer.​
 
●​ Units:​
 
○​ Use the unit as defined in the scenario output (e.g. MMT, tonne, or equivalent).​
 
○​ No unit conversion is applied.​
 
B.2 Filter Logic 
●​ Scenario selector:​
 
○​ Allow selection of up to 5 scenarios.​
 

○​ Only Approved scenarios are selectable.​
 
●​ Organisational filters:​
 
○​ BU​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Filters apply consistently across all selected scenarios.​
 
B.3 Groupings 
●​ Grouping is applied by:​
 
○​ Scenario (each scenario = one line)​
 
○​ Year (2019–2050)​
 
●​ No additional grouping or roll-up logic is applied.​
 
C. Visualisation Requirements 
C.1 Layout 
●​ Single line chart:​
 
○​ X-axis: Year (2019–2050)​
 
○​ Y-axis: Total Production (unit as per scenario output)​
 
●​ Visual rules:​
 
○​ Each scenario is displayed as one distinct line.​
 
○​ Maximum of five lines displayed concurrently.​
 
●​ Legend:​
 
○​ Displays scenario name corresponding to each line.​
 

C.2 Filter 
●​ Scenario multi-select (maximum 5)​
 
●​ BU selector​
 
●​ Group OPU selector​
 
●​ OPU selector​
 
C.3 Tooltips 
●​ Tooltip displays:​
 
○​ Scenario name​
 
○​ Year​
 
○​ Total Production value​
 
○​ Unit of measurement​
 
S-06-08 – Comparative Methane Emission Chart 
A. Description 
This story provides a comparative dashboard that enables users to compare Methane Emission 
trajectories across multiple scenarios within a single view. 
Up to five (5) scenarios can be selected simultaneously. Each selected scenario is rendered as an 
independent data series, allowing direct comparison of methane emission trends over the period 2019 to 
2050. 
B. Functional Requirements 
B.1 Data Logic 
●​ Data source:​
 
○​ Use the scenario summary output generated for each approved scenario.​
 
○​ Use Methane Emission values only.​
 

●​ Scenario handling:​
 
○​ Each selected scenario is treated as an independent dataset.​
 
○​ No aggregation, averaging, or blending across scenarios.​
 
●​ Time range:​
 
○​ X-axis spans from 2019 to 2050.​
 
○​ Values are taken directly from each scenario’s methane emission output.​
 
●​ Methane definition:​
 
○​ Methane emission values follow the definition and calculation logic established in the 
methane stories (e.g. Breakdown by Gases).​
 
○​ No recalculation is performed at the dashboard layer.​
 
●​ Units:​
 
○​ Use the unit as defined in the scenario output (e.g. ktCH₄ or tonne CH₄).​
 
○​ No unit conversion is applied.​
 
B.2 Filter Logic 
●​ Scenario selector:​
 
○​ Allow selection of up to 5 scenarios.​
 
○​ Only Approved scenarios are selectable.​
 
●​ Organisational filters:​
 
○​ BU​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Filters apply consistently across all selected scenarios.​
 

B.3 Groupings 
●​ Grouping is applied by:​
 
○​ Scenario (each scenario = one line)​
 
○​ Year (2019–2050)​
 
●​ No additional grouping or roll-up logic is applied.​
 
C. Visualisation Requirements 
C.1 Layout 
●​ Single line chart:​
 
○​ X-axis: Year (2019–2050)​
 
○​ Y-axis: Methane Emission (unit as per scenario output)​
 
●​ Visual rules:​
 
○​ Each scenario is displayed as one distinct line.​
 
○​ Maximum of five lines displayed concurrently.​
 
●​ Legend:​
 
○​ Displays scenario name corresponding to each line.​
 
C.2 Filter 
●​ Scenario multi-select (maximum 5)​
 
●​ BU selector​
 
●​ Group OPU selector​
 
●​ OPU selector​
 
C.3 Tooltips 

●​ Tooltip displays:​
 
○​ Scenario name​
 
○​ Year​
 
○​ Methane emission value​
 
○​ Unit of measurement 
 
S-06-09 – Comparative Energy Consumption Chart 
A. Description 
This story provides a comparative dashboard that enables users to compare Energy Consumption 
trajectories across multiple scenarios within a single view. 
Up to five (5) scenarios can be selected simultaneously. Each selected scenario is rendered as an 
independent data series, allowing direct comparison of energy consumption trends over the period 2019 
to 2050. 
B. Functional Requirements 
B.1 Data Logic 
●​ Data source:​
 
○​ Use the scenario summary output generated for each approved scenario.​
 
○​ Use Total Energy Consumption values only.​
 
●​ Scenario handling:​
 
○​ Each selected scenario is treated as an independent dataset.​
 
○​ No aggregation, averaging, or blending across scenarios.​
 
●​ Time range:​
 
○​ X-axis spans from 2019 to 2050.​
 
○​ Values are taken directly from each scenario’s energy consumption output.​
 

●​ Energy definition:​
 
○​ Energy consumption values follow the definition and calculation logic established in the 
Energy Consumption stories.​
 
○​ No recalculation is performed at the dashboard layer.​
 
●​ Units:​
 
○​ Use the unit as defined in the scenario output (e.g. GJ, Million GJ).​
 
○​ No unit conversion is applied.​
 
B.2 Filter Logic 
●​ Scenario selector:​
 
○​ Allow selection of up to 5 scenarios.​
 
○​ Only Approved scenarios are selectable.​
 
●​ Organisational filters:​
 
○​ BU​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Filters apply consistently across all selected scenarios.​
 
B.3 Groupings 
●​ Grouping is applied by:​
 
○​ Scenario (each scenario = one line)​
 
○​ Year (2019–2050)​
 
●​ No additional grouping or roll-up logic is applied.​
 
C. Visualisation Requirements 

C.1 Layout 
●​ Single line chart:​
 
○​ X-axis: Year (2019–2050)​
 
○​ Y-axis: Total Energy Consumption (unit as per scenario output)​
 
●​ Visual rules:​
 
○​ Each scenario is displayed as one distinct line.​
 
○​ Maximum of five lines displayed concurrently.​
 
●​ Legend:​
 
○​ Displays scenario name corresponding to each line.​
 
C.2 Filter 
●​ Scenario multi-select (maximum 5)​
 
●​ BU selector​
 
●​ Group OPU selector​
 
●​ OPU selector​
 
C.3 Tooltips 
●​ Tooltip displays:​
 
○​ Scenario name​
 
○​ Year​
 
○​ Total Energy Consumption value​
 
○​ Unit of measurement​
 
3.7 BR-07 – Automated Executive Visualisations  

3.7.1 Summary 
BR-07 defines the capability to deliver a single, executive-level dashboard that automatically presents 
all required charts for EVP and C-Level reporting.​
 The dashboard must always reflect the latest baseline or selected scenario results, eliminate manual 
slide preparation, and align fully with the executive reporting format. 
This BR intends to ensure executives receive consistent, accurate, and presentation-ready visuals 
directly from the system. 
Story 
ID 
Story Name 
Brief Description 
S-07-01 
Total GHG Emission Forecast – Operational 
Control 
Displays total GHG emission forecast under 
operational control. 
S-07-02 
Total GHG Emission Forecast – Equity 
Share 
Displays the total GHG emission forecast 
under the equity share. 
S-07-03 
GHG Emission Forecast – Operational 
Control 
Shows operational-control GHG emission 
trends over time. 
S-07-04 
Growth Project Year Range 
Displays Growth Project details 
S-07-05 
GHG Reduction Forecast by 
Decarbonisation Projects 
Presents a reduction forecast for both equity 
shares and operational control 
S-07-06 
Decarbonization Project Listing 
List decarbonization projects contributing to 
forecast changes. 
S-07-07 
Green Capex 
Shows forecasted Green Capex 5-year Plan 

S-07-08 
Methane Emission & Intensity Forecast 
Operational Control 
Displays the Methane quantity an 
d intensity of Operational Control 
S-07-09 
Energy Consumption & Intensity Forecast 
Operational Control 
Displays the consumption quantity and 
intensity of Operational Control 
S-07-10 
GHG Emission (Equity Share) for G&M 
Forecast 
Displays the GHG emission equity share by 
year of all OPUs by time series 
S-07-11 
Traffic Lights – NZCE 
Visual indicator of NZCE status using 
traffic-light logic. 
S-07-12 
Upstream Feedgas + LNG Production 
Profile 
Displays upstream feedgas and LNG 
production profiles. 
S-07-13 
Kerteh Feedgas & Salegas Production 
Profile 
Displays Kerteh feedgas and Salegas 
production profiles. 
S-07-14 
NOJV Production Profile 
Displays NOJV production forecast profile. 
 
3.7.2 Story Details 
S-07-01. Total GHG Emission Forecast – Operational Control & Equity Share 
A. Description 
Displays the Total GHG Emission Forecast chart and its associated supporting sections exactly as per 
the approved executive PowerPoint reference, including GHG intensity indicators, GHG emission 
trend lines, production profiles (LNG and Kerteh Salesgas), and Key highlights text. 

B. Functional Requirements 
B.1 Data Logic 
Section 1: GHG Reduction Forecast and Green CAPEXData Source​
All data is sourced from the Decarbonisation (Decarb) table in the database, or GHG Emission 
Reduction (tco2e) in the provided upload data.​
​
OC: Sum data of GHG Reduction in Operational Control (sum data of YEP till YEP +5 data) 
ES: Sum data of GHG Reduction in Equity Share (sum data of YEP till YEP +5 data) 
Levers Covered​
 Data must be aggregated by decarbonisation “Levers”, including: 
○​ Zero Routine Flaring​
 
○​ Energy Efficiency​
 
○​ Electrification​
 
○​ Carbon Capture & Storage (Database mapping: CCS)​
 
○​ Others: All decarbonisation data not represented by the four levers above​
 
GHG Reduction Amount Logic 
○​ Retrieve the total GHG reduction for each lever.​
 
○​ Unit conversion rule:​
Values must be converted to Million tCO₂e before display.​
Formula: Displayed Value = Total tCO₂e / 1,000,000​
 
○​ Displayed values are fully aggregated, with no drill-down behaviour.​
 
●​ CAPEX Logic​
 
○​ CAPEX values are retrieved per corresponding lever from the CAPEX table, or GHG 
Emission Reduction (tco2e) in the provided upload data.​
 
○​ CAPEX values are displayed as-is, with no unit conversion applied.​
 
○​ CAPEX-less display when there is no data of CAPEX of that “Levers” in respective 6 
years 

 
Section 2: GHG Intensity (Gas Processing / Utilities / Shipping) 
●​ Gas Processing (tCO₂e/tonne)​
 
○​ Numerator (GHG Emission): total GHG emission aggregated from the following 
BUs/OPUs:​
 MLNG, MLNG DUA, MLNG TIGA, Train 9, PFLNG1, PFLNG2, PFLNG3, GPP 
(GPK + GPS + TSET), GTR​
 
○​ Denominator (Production): total production aggregated for the corresponding OPUs 
listed above.​
 
○​ Formula:​
 Gas Processing Intensity = (Σ GHG Emission of listed OPUs) / (Σ Production of the 
corresponding OPUs)​
 
●​ Utilities (tCO₂e/MWh)​
 
○​ Scope: only UT(GPU) = UK + UG.​
 
○​ Numerator (GHG Emission): total GHG emission for UT.​
 
○​ Denominator (Production): total production for UT.​
 
○​ Formula:​
 Utilities Intensity = (GHG Emission of UT) / (Production of UT)​
 
●​ Shipping (gCO₂e/t-nm)​
 
○​ MISC 
As Shipping use Gram CO2, need to covert before usage: gC02 = TONNE C02 x 1,000,000  
Section 3: GHG Emission Trend (Total vs Upon Reduction) 
●​ Data Source:​
 Use only the Summary Table already generated for this story.​
 
●​ Total GHG Emission​
 
○​ Value is taken directly from the Summary Table.​
 

○​ Represents Total GHG Emission for the selected control approach (Operational Control 
or Equity Share, depending on the chart).​
​
 
●​ Upon Reduction​
 
○​ Value is taken directly from the Summary Table.​
 
○​ Represents GHG emission after applying reduction impacts.​
​
 
●​ Units​
 
○​ Unit remains Mil tCO₂e, exactly as stored in the Summary Table.​
 
Section 4: Production Trend (LNG & Kerteh Salesgas) 
●​ Data Source:​
​
 Use only production data already available for this story from the underlying production datasets.​
 
●​ LNG Production​
​
 ○ Value is taken from all records where Parameter = Production and BU  = LNGA.​
​
 ○ Represents total LNG production aggregated across all LNGA OPUs for the selected year 
range. 
●​ Kerteh Salesgas Production​
​
 ○ Value is taken from all records where Parameter = Salesgas Production and OPU  = GPU.​
​
 ○ Represents total Kerteh Salesgas production for the selected year range.​
 
●​ Units​
​
 ○ LNG Production unit remains MMT (converted from MTPA), exactly as stored in the source 
production data.​
​
 ○ Kerteh Salesgas Production unit remains mmscfd, exactly as stored in the source production 
data.​
 

B.2 Filter Logic 
Scenario selection affects the displayed emission forecast. 
Year selection applies across the full chart (5-years range).  
B.3 Groupings 
●​ Grouped by Year.​
 
●​ Emission values grouped under Operational Control.​
 
●​ Intensity and production indicators grouped by:​
 
○​ Gas Processing​
 
○​ Utilities ​
 
○​ Shipping 
C. Visualisation Requirements 
C.1 Layout 
The entire chart block must match the executive PowerPoint reference exactly, including: 
●​ Title: TOTAL GHG EMISSION FORECAST – OPERATIONAL CONTROL​
 
●​ Left-side mini panel for GHG Intensity​
 
●​ Main line chart for GHG Emission​
 
●​ Reference guidance line/text displayed under the chart (as shown in PPT)​
 
●​ Bottom Production section showing LNG and Kerteh Salesgas profiles​
 
●​ Bottom Key highlights section displayed as a bullet list 
C.2 Filter 
Global filters available for this chart: 
●​ Scenario​
 
●​ Year 

Filters apply consistently and refresh the chart automatically. 
C.3 Tooltips 
GHG Intensity – Gas Processing​
 
●​ Tooltip displays:​
 
○​ Amount (tCO2e/tonne)​
 
GHG Intensity – Utilities​
 
●​ Tooltip displays:​
 
○​ Amount (tCO2e/MWh)​
 
GHG Intensity – Shipping​
 
●​ Tooltip displays:​
 
○​ Amount (gCO2e/t-nm)​
 
GHG Emission – Total GHG Emission (OC)​
 
●​ Tooltip displays:​
 
○​ Year​
 
○​ Amount (Mil tCO2e)​
 
GHG Emission – Upon Reduction​
 
●​ Tooltip displays:​
 
○​ Year​
 

○​ Amount (Mil tCO2e)​
 
Production – LNG​
 
●​ Tooltip displays:​
 
○​ Year​
 
○​ Amount (MMT)​
 
Production – Kerteh Salesgas 
●​ Tooltip displays:​
 
○​ Year​
 
○​ Amount (mmscfd) 
 
S-07-02. GHG Emission & GHG Intensity Forecast – Operational Control 
A. Description 
Displays the GHG Emission Forecast and GHG Intensity Forecast under Operational Control for the 
G&M Business, following the same structure, layout, and visual arrangement as the approved  
executive PowerPoint reference. 
B. Functional Requirements 
B.1 Data Logic 
Section 1: GHG Emission Forecast – Operational Control 
Data Source 
●​ Data is derived from GHG emission datasets under Operational Control.​
 
●​ Emissions are aggregated by OPU grouping, as defined below.​
 
●​ The unit remains Mil tCO₂e.​
 

OPU Grouping Logic: 
The stacked bars are constructed using the following explicit OPU mappings: 
●​ MLNG 
●​ MLNG DUA 
●​ MLNG TIGA 
●​ TRAIN 9 
●​ PFLNG1 
●​ PFLNG2 
●​ ZLNG: PFLNG3 
●​ GPU: GPK + GPS + TSET + UK + UG 
●​ GTR: GT + RGTP + RGTSU 
●​ MISC: MISC 
Each bar segment represents the sum of GHG emissions from all OPUs mapped into that group. 
 
YEP (Year-End Projection) Handling: 
●​ YEP year is selectable.​
 
●​ When a YEP year is selected:​
 
○​ The chart anchors on that YEP base year.​
 
○​ All derived values reference that selected YEP. 
Business as Usual (BAU) Logic 
●​ BAU values represent emissions without decarbonisation impact.​
 
●​ BAU is displayed for:​
 
○​ YEP + 1​
 
○​ YEP + 5 
Formula: BAU GHG = Total GHG Emission (Operational Control) 
 
Upon Reduction Logic: 

●​ Upon Reduction values represent emissions after applying decarbonisation impacts.​
 
●​ Reduction is derived from the Decarb dataset.​
 
●​ Displayed for:​
 
○​ YEP + 1​
 
○​ YEP + 5​
 
Formula: Upon Reduction GHG = BAU GHG − Total Decarbonisation Impact (for the same year). 
 
Section 2: GHG Intensity Forecast – Operational Control 
Data Source: 
●​ Intensity values are calculated from:​
 
○​ GHG Emission (Operational Control) for the relevant OPU set, and​
 
○​ Production for the corresponding OPU set (same year alignment).​
 
●​ Three sub-sections exist in the chart:​
 
○​ Gas Processing (tCO₂e/tonne)​
 
○​ Utilities (tCO₂e/MWh)​
 
○​ Shipping (gCO₂e/t-nm)​
 
Grouping / Mapping Logic: 
The lines shown in the Gas Processing area must be built from these group definitions: 
Base OPU Set 
●​ Gas Processing (overall OPU list)  = MLNG + MLNG DUA + MLNG TIGA + Train 9 + 
PFLNG1 + PFLNG2 + PFLNG3 + GPP + GTR​
 
Derived Groups 

●​ Gas Business = GPP + GTR​
 
●​ LNGA (LNG Assets) = PLC + PFLNG​
 
●​ PLC  = MLNG + MLNG DUA + MLNG TIGA + TRAIN 9​
 
●​ PFLNG1&2 = PFLNG1 + PFLNG2​
 
●​ ZLNG  = PFLNG3​
 
●​ UTILITIES  = UK + UG​
 
B.2 Filter Logic 
●​ Scenario selection affects all charts and tables.​
 
●​ Year selection applies across all visuals (also will affect YEP).​
 
B.3 Groupings 
●​ GHG Emissions grouped by Year.​
 
●​ GHG Intensity grouped by:​
 
○​ Gas Processing​
 
○​ Utilities​
 
○​ Shipping​
 
●​ Summary tables grouped by metric type and YEP reference year.​
 
C. Visualisation Requirements 
C.1 Layout 
●​ Layout must follow the executive PowerPoint reference exactly, including:​
 
○​ Left panel:​
 
■​ GHG Emission Forecast – Operational Control​
 

○​ Right panel:​
 
■​ GHG Intensity Forecast – Operational Control​
 
○​ Bottom left table:​
 
■​ YEP xxxx: GHG Emission​
 
○​ Bottom right table:​
 
■​ YEP xxxx: GHG Intensity​
 
●​ Titles, units, legends, annotations, and structure must not be altered. 
​
 
C.2 Filter 
●​ Filters available:​
 
○​ Scenario​
 
○​ Year - Affect YEP​
 
●​ Filters refresh all charts and tables simultaneously. 
Note: The hierarchy filter will only affect “GHG Intensity Forecast” chart, since ghg emission forecast 
has displayed all OPU in it.​
 
C.3 Tooltips 
●​ GHG Emission – Total GHG Emission (OC)​
 
○​ Year​
 
○​ Amount (Mil tCO2e)​
 
●​ GHG Emission – Upon Reduction​
 
○​ Year​
 
○​ Amount (Mil tCO2e)​
 

●​ GHG Intensity – Gas Processing​
 
○​ Amount (tCO2e/tonne)​
 
●​ GHG Intensity – Utilities​
 
○​ Amount (tCO2e/MWh)​
 
●​ GHG Intensity – Shipping​
 
○​ Amount (gCO2e/t-nm) 
 
S-07-03. GHG Emission & GHG Intensity Profile – Equity Share 
A. Description 
Displays the GHG Emission Profile and GHG Intensity Profile under Equity Share (ES) for the G&M 
Business, following the same structure, layout, and visual arrangement as the approved executive 
PowerPoint reference. 
B. Functional Requirements 
B.1 Data Logic 
Section 1: GHG Emission Forecast – Equity Share 
Data Source 
●​ Data is derived from GHG emission datasets under Equity Share..​
 
●​ Emissions are aggregated by OPU grouping, as defined below.​
 
●​ The unit remains Mil tCO₂e.​
 
OPU Grouping Logic: 
The stacked bars are constructed using the following explicit OPU mappings: 
●​ MLNG 
●​ MLNG DUA 
●​ MLNG TIGA 
●​ TRAIN 9 

●​ PFLNG1 
●​ PFLNG2 
●​ ZLNG: PFLNG3 
●​ GPU: GPK + GPS + TSET + UK + UG 
●​ GTR: GT + RGTP + RGTSU 
●​ MISC: Shipping 
●​ NOJV G&P: All NOJV OPU data with BU = G&P 
●​ NOJV LNGA: All NOJV OPU data with BU = LNGA 
●​ Growth: growth Emission data 
Each bar segment represents the sum of GHG emissions from all OPUs mapped into that group. 
 
YEP (Year-End Projection) Handling: 
●​ YEP year is selectable.​
 
●​ When a YEP year is selected:​
 
○​ The chart anchors on that YEP base year.​
 
○​ All derived values reference that selected YEP. 
Business as Usual (BAU) Logic 
●​ BAU values represent emissions without decarbonisation impact.​
 
●​ BAU is displayed for:​
 
○​ YEP + 1​
 
○​ YEP + 5 
Formula: BAU GHG = Total GHG Emission (Operational Control) 
 
Upon Reduction Logic: 
●​ Upon Reduction values represent emissions after applying decarbonisation impacts.​
 
●​ Reduction is derived from the Decarb dataset.​
 

●​ Displayed for:​
 
○​ YEP + 1​
 
○​ YEP + 5​
 
Formula: Upon Reduction GHG = BAU GHG − Total Decarbonisation Impact (for the same year). 
 
Section 2: GHG Intensity Forecast – Equity Share 
Data Source: 
●​ Intensity values are calculated from:​
 
○​ GHG Emission (Equity Share) for the relevant OPU set, and​
 
○​ Production for the corresponding OPU set (same year alignment).​
 
●​ Three sub-sections exist in the chart:​
 
○​ Gas Processing (tCO₂e/tonne)​
 
○​ Utilities (tCO₂e/MWh)​
 
○​ Shipping (gCO₂e/t-nm)​
 
Grouping / Mapping Logic: 
The lines shown in the Gas Processing area must be built from these group definitions: 
Base OPU Set 
●​ Gas Processing (overall OPU list)  = MLNG + MLNG DUA + MLNG TIGA + Train 9 + 
PFLNG1 + PFLNG2 + PFLNG3 + GPP + GTR​
 
Derived Groups 
●​ Gas Business = GPP + GTR​
 

●​ LNGA (LNG Assets) = PLC + PFLNG​
 
●​ PLC  = MLNG + MLNG DUA + MLNG TIGA + TRAIN 9​
 
●​ PFLNG1&2 = PFLNG1 + PFLNG2​
 
●​ ZLNG  = PFLNG3​
 
●​ UTILITIES  = UK + UG​
 
Note: “PFLNG” here is represented through its components PFLNG1&2 and ZLNG (PFLNG3). 
B.2 Filter Logic 
●​ Scenario selection affects all charts and tables. 
●​ Year selection applies across all visuals (also will affect YEP).​
 
B.3 Groupings 
●​ GHG Emissions grouped by Year.​
 
●​ GHG Intensity grouped by:​
 
○​ Gas Processing​
 
○​ Utilities​
 
○​ Shipping​
 
●​ Summary tables grouped by metric type and YEP reference year. 
B.3 Groupings 
●​ GHG Emissions grouped by Year.​
 
●​ GHG Intensity grouped by:​
 
○​ Gas Processing​
 
○​ Utilities​
 
○​ Shipping​
 

●​ Summary tables grouped by metric type and YEP reference year.​
 
 
C. Visualisation Requirements 
C.1 Layout 
●​ Layout must follow the executive PowerPoint reference exactly, including:​
 
○​ Left panel:​
 
■​ GHG Emission Profile – Equity Share​
 
○​ Right panel:​
 
■​ GHG Intensity Profile – Equity Share​
 
○​ Bottom left table:​
 
■​ YEP xxxx: GHG Emission​
 
○​ Bottom right table:​
 
■​ YEP xxxx: GHG Intensity​
 
●​ Titles, units, legends, annotations, colours, and structure must not be altered.​
 
 
C.2 Filter 
●​ Filters available:​
 
○​ Scenario​
 
○​ Year affects YEP​
 
●​ Filters refresh all charts and tables simultaneously.​
​
 

C.3 Tooltips 
●​ GHG Emission – Total GHG Emission (ES)​
 
○​ Year​
 
○​ Amount (Mil tCO2e)​
 
●​ GHG Emission – Upon Reduction​
 
○​ Year​
 
○​ Amount (Mil tCO2e)​
 
●​ GHG Intensity – Gas Processing​
 
○​ Amount (tCO2e/tonne)​
 
●​ GHG Intensity – Utilities​
 
○​ Amount (tCO2e/MWh)​
 
●​ GHG Intensity – Shipping​
 
○​ Amount (gCO2e/t-nm)​
 
 
Story S-07-04. Growth Project Listing in Year Range 
A. Description 
Displays the Growth Projects listing for the selected year range, following the same table structure 
and visual layout as the approved executive PowerPoint reference, with the year range limited to a 
maximum of 5 years. 
 
B. Functional Requirements 
B.1 Data Logic 
●​ Displays a tabular list of Growth Projects.​
 

●​ Only projects marked as FID = Yes are included.​
 
●​ Data fields displayed include:​
 
○​ Sector​
 
○​ Project Name​
 
○​ Project Description​
 
○​ Project Sanction​
 
○​ Petronas Effective Equity​
 
○​ COD​
 
○​ Annual GHG Emission (Equity Share) – Mil tCO2e/year​
 
○​ Annual GHG Reduction (Equity Share) – Mil tCO2e/year​
 
●​ Data source aligns with the growth project datasets shown in the Excel input.​
 
 
B.2 Filter Logic 
●​ Hierarchy filters apply as follows:​
 
○​ Business Unit (BU)​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Year range selection applies to the listing.​
 
●​ The selected year range is limited to a maximum of 5 years.​
 
●​ Scenario selection​
 

B.3 Groupings 
●​ Projects grouped as displayed in the PPT reference:​
 
○​ By Sector (e.g. G&P, LNGA)​
 
●​ No additional grouping beyond the table structure shown in PPT.​
 
C. Visualisation Requirements 
C.1 Layout 
●​ Table layout must follow the executive PowerPoint reference exactly, including:​
 
○​ Column order​
 
○​ Column headers​
 
○​ Units displayed in headers​
 
●​ Visual styling (colour bands, section separation) must not be altered.​
 
C.2 Filter 
●​ Filters available:​
 
○​ Business Unit (BU)​
 
○​ Group OPU​
 
○​ OPU​
 
○​ Year Range (max 5 years)​
 
●​ Filters refresh the table content automatically.​
 
●​ No additional filters beyond those shown in the PPT reference.​
 
C.3 Tooltips 
●​ Not Applicable for this Story​
 

 
Story S-07-05. GHG Reduction Forecast by Decarbonisation Projects 
A. Description 
Displays the GHG Reduction Forecast driven by Decarbonisation Projects for the G&M Business, 
shown under both Operational Control and Equity Share, following the same structure, layout, and 
visual arrangement as the approved executive PowerPoint reference. 
 
B. Functional Requirements 
B.1 Data Logic 
Section 1: GHG Reduction Forecast – Operational Control (by Decarbonisation Lever) 
Data Source 
●​ Use the Decarb table as the single source for this section.​
 
Grouping Rules 
Data must be aggregated by Decarbonisation “Levers” and displayed as separate components: 
1.​ Zero Routine Flaring​
 
2.​ Energy Efficiency​
 
3.​ Electrification​
 
4.​ Carbon Capture & Storage​
 
○​ Database mapping: Lever = CCS​
 
5.​ Others​
 
○​ Definition: All decarbonisation data not represented by the four levers above.​
 
Calculation / Aggregation Logic 
For each Year in the displayed range: 

●​ Lever Value (Mil tCO₂e)​
 = SUM(Decarb amount) for records where Lever = that lever, under Operational Control, for 
the selected scope (xxx), year (xxx), and hierarchy filters (xxx).​
 
●​ Others (Mil tCO₂e)​
 = SUM(Decarb amount) for all records where Lever NOT IN​
 {Zero Routine Flaring, Energy Efficiency, Electrification, CCS} 
Section 2: GHG Reduction Forecast – Equity Share 
Refer to Section 1: This Section only change to equity share 
​
 
B.2 Filter Logic 
●​ Scenario selection affects both Operational Control and Equity Share charts.​
 
●​ Year selection applies across both charts and summary tables.​
​
 
B.3 Groupings 
●​ GHG Reduction grouped by Year.​
 
●​ Reduction values grouped by decarbonisation lever:​
 
○​ Zero Flaring & Venting​
 
○​ Energy Efficiency​
 
○​ Electrification​
 
○​ CCS​
 
○​ Others​
 

C. Visualization Requirements 
C.1 Layout 
●​ Layout must follow the executive PowerPoint reference exactly, including:​
 
○​ Left panel:​
 
■​ GHG Reduction Forecast – Operational Control​
 
○​ Right panel:​
 
■​ GHG Reduction Forecast – Equity Share​
 
○​ Lever legend displayed vertically on the right side of each chart.​
 
○​ Bottom summary table:​
 
■​ YEP XXXX: GHG Reduction​
 
●​ Titles, units, legends, annotations, colours, and structure must not be altered.​
 
C.2 Filter 
●​ Filters available:​
 
○​ Scenario​
 
○​ Year (Affect YEP)​
 
●​ Filters refresh all charts and tables simultaneously.​
 
 
C.3 Tooltips 
●​ GHG Reduction – Total (Post Reduction)​
 
○​ Year​
 
○​ Amount (Mil tCO2e)​
 

●​ Zero Flaring & Venting​
 
○​ Year​
 
○​ Amount (Mil tCO2e)​
 
●​ Energy Efficiency​
 
○​ Year​
 
○​ Amount (Mil tCO2e)​
 
●​ Electrification​
 
○​ Year​
 
○​ Amount (Mil tCO2e)​
 
●​ CCS​
 
○​ Year​
 
○​ Amount (Mil tCO2e)​
 
●​ Others​
 
○​ Year​
 
○​ Amount (Mil tCO2e) 
 
S-07-07. GHG Reduction Forecast & Green CAPEX 
A. Description 
Displays the GHG Reduction Forecast alongside Green CAPEX for the G&M Business, showing the 
relationship between decarbonisation levers, GHG reduction outcomes, and CAPEX phasing over 
FY2026–2030, following exactly the approved executive PowerPoint structure and layout. 
B. Functional Requirements 

B.1 Data Logic 
​
Section 1: GHG Reduction Forecast and Green CAPEX (Refer S-07-01) 
Section X: Green CAPEX Forecast (FY2026–2030) 
Data Source 
●​ Use only the CAPEX table as the authoritative data source for this section.​
​
 
Data Selection Logic 
●​ Include all records in the CAPEX table that fall within:​
 
○​ Fiscal Years​
 
○​ CAPEX Type: Green / Decarbonisation CAPEX (as defined in the table)​
 
Aggregation Logic 
●​ Annual CAPEX (RM ’000,000)​
 = SUM(CAPEX amount) grouped by Year.​
 
●​ 5-Year CAPEX (Total)​
 = SUM(CAPEX amount) across 5 FY years.​
 
●​ Sector Split (if shown in chart):​
 
○​ LNGA​
 
○​ G&P​
 Aggregation is based directly on the Sector field in the CAPEX table.​
 
B.2 Filter Logic 
●​ Scenario selection applies to:​
 
○​ GHG Reduction values​
 

○​ CAPEX figures​
 
●​ Hierarchy filters apply as follows:​
 
○​ Business Unit (BU)​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Year range filter by 5 year range 
 
B.3 Groupings 
●​ GHG Reduction grouped by:​
 
○​ Decarbonisation lever​
 
●​ CAPEX grouped by:​
 
○​ Year​
 
○​ Sector (G&P, LNGA)​
 
●​ Project table grouped by:​
 
○​ Sector​
 
○​ OPU​
 
○​ Project​
 
C. Visualization Requirements 
C.1 Layout 
●​ Layout must strictly follow the the ProjectH executive PowerPoint reference:​
 
○​ Top section:​
 
■​ GHG Reduction Forecast and Green CAPEX summary strip​
 

○​ Bottom left:​
 
■​ FYxxxx–xxxx Green CAPEX bar chart​
 
○​ Bottom right:​
 
■​ Project CAPEX phasing table​
 
○​ Colour, icons, legend placement, and spacing must not be altered.​
 
●​ The 5-Year CAPEX total row must be displayed as per PPT.​
 
C.2 Filter 
●​ Filters available:​
 
○​ Scenario​
 
○​ Business Unit (BU)​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Filters refresh all visuals simultaneously. 
 
C.3 Tooltips 
●​ GHG Reduction (by lever)​
 
○​ Lever name​
 
○​ Amount (Mil tCO2e)​
 
●​ CAPEX (bar chart)​
 
○​ Year​
 
○​ Sector (G&P / LNGA)​
 
○​ Amount (RM Million)​
 

●​ Project CAPEX table​
 
○​ Project name​
 
○​ Year​
 
○​ CAPEX amount (RM Million)​
 
○​ Total 5-Year CAPEX (RM Million) 
 
S-07-08. Methane Emission & Intensity Forecast (Operational Control) 
A. Description 
Displays the Methane Emission Forecast and Methane Intensity Forecast under Operational 
Control, showing projected methane emissions and intensity trends for LNG, gas processing, and 
utilities, aligned with OGMP 2.0 progression (Level 1 to Level 3) and following the exact executive 
PowerPoint structure and layout. 
B. Functional Requirements 
B.1 Data Logic 
Section 1: Methane Emission Forecast (Operational Control) 
Data Source 
●​ Use only the “Breakdown by Gases” table.​
 
●​ Filter Gas Type = Methane (CH₄).​
 
Data Selection Logic 
●​ Select records where:​
 
○​ Control Approach = Operational Control​
 
○​ UOM = tonne CH₄​
 
○​ Year range follows the forecast horizon shown in the chart.​
 

Aggregation Logic 
●​ Methane Emission (ktCH₄)​
 = SUM(Methane emission in tonne CH₄) aggregated by:​
 
○​ Year​
 
○​ OPU​
 
●​ Convert unit:​
 
○​ ktCH₄ = tonne CH₄ / 1,000​
 
OPU Breakdown 
Methane emissions are grouped and displayed by the following OPUs: 
●​ MLNG​
 
●​ MLNG DUA​
 
●​ MLNG TIGA​
 
●​ Train 9​
 
●​ PFLNG1​
 
●​ PFLNG2​
 
●​ GPU​
 
●​ GTR 
Total Methane Emission 
●​ Total L3 CH₄ = SUM(ktCH₄) across all OPUs for the corresponding year. 
Section 2: Methane Intensity Forecast (Operational Control) 
Data Sources: 
●​ Methane Emission:​
 Use the “Breakdown by Gases” table, filtered to:​
 

○​ Control Approach = Operational Control​
 
○​ UOM = tonne CH₄​
 
●​ Production / Activity Data:​
 
○​ LNG / Gas Processing: Production table (tonne)​
 
OPU Grouping Rules: 
Gas Processing 
Includes the following OPUs: 
●​ MLNG​
 
●​ MLNG DUA​
 
●​ MLNG TIGA​
 
●​ Train 9​
 
●​ PFLNG1​
 
●​ PFLNG2​
 
●​ PFLNG3​
 
●​ GPP​
 
●​ GTR 
Gas Business: Gas Business = GPP + GTR 
LNG Assets (LNGA) 
●​ LNGA = PLC + PFLNG​
 
○​ PLC = MLNG + MLNG DUA + MLNG TIGA + Train 9​
 
○​ PFLNG = PFLNG1 + PFLNG2​
 
○​ ZLNG is treated as PFLNG3 

Utilities = UK + UG​
 
Calculation Logic 
Methane Emission (Numerator) 
●​ Aggregate Methane Emission (tonne CH₄) by:​
 
○​ Year​
 
○​ Relevant OPU grouping (as defined above)​
 
Production / Activity (Denominator) 
●​ Gas Processing / LNG Assets / Gas Business​
 
○​ Use Production (tonne) for the corresponding OPUs​
 
●​ Utilities​
 
○​ Use Electricity consumption (MWh) for UK + UG​
 
Methane Intensity Formulas: 
Gas Processing Methane Intensity​
​
 Methane Intensity = Total CH₄ Emission (tonne CH₄) / Total Production (tonne) 
●​  Unit: tCH₄ / tonne 
Gas Business Methane Intensity​
​
 (CH₄ from GPP + GTR) / (Production of GPP + GTR) 
●​  Unit: tCH₄ / tonne​
 
LNG Assets (LNGA) Methane Intensity​
​
 (CH₄ from PLC + PFLNG) / (Production of PLC + PFLNG) 
●​  Unit: tCH₄ / tonne​
 

Utilities Methane Intensity​
​
 CH₄ Emission (UK + UG) / Electricity Consumption (MWh) 
●​  Unit: tCH₄ / MWh 
 
 
B.2 Filter Logic 
●​ Scenario selection applies to:​
 
○​ Methane emission values​
 
○​ Methane intensity values​
​
 
●​ Year range filter by 5 year range​
 
B.3 Groupings 
●​ Methane Emission:​
 
○​ Grouped by asset/ OPU​
 
●​ Methane Intensity:​
 
○​ Grouped by:​
 
■​ LNG Processing​
 
■​ Gas Processing​
 
■​ Utilities​
 
C. Visualization Requirements 
C.1 Layout 
●​ Layout must strictly follow the executive PowerPoint:​
 

○​ Left panel:​
 
■​ Methane Emission Forecast (Operational Control)​
 
○​ Right panel:​
 
■​ Methane Intensity Forecast (Operational Control)​
 
○​ Bottom:​
 
■​ Existing Operation & Methane Emission summary table​
 
■​ Methane Intensity summary table​
 
●​ Colours, legends, axis titles, annotations, and OGMP references must not be modified.​
 
C.2 Filter 
●​ Filters available:​
 
○​ Scenario 
○​ Year Range (5 years)​
 
●​ Filters refresh all charts and tables simultaneously.​
​
 
C.3 Tooltips 
●​ Methane Emission bars​
 
○​ Asset / OPUS name​
 
○​ Year​
 
○​ Methane Emission (ktCH4)​
 
○​ Methane Emission (ktCO2e)​
 
●​ Methane Intensity lines​
 
○​ Category (LNG Processing / Gas Processing / Utilities)​
 

○​ Year​
 
○​ Amount:​
 
■​ tCH4/tonne or tCO2e/tonne​
 
■​ tCH4/MWh or tCO2e/MWh (Utilities) 
S-07-09. Energy Consumption & Energy Intensity Forecast (Operational Control) 
A. Description 
Displays the Energy Consumption Forecast and Energy Intensity Forecast under Operational 
Control, reflecting the sustained impact of energy efficiency measures implemented across operations, 
while maintaining the exact executive PowerPoint structure, layout, and visual design. 
B. Functional Requirements 
B.1 Data Logic 
Section 1: Energy Consumption Forecast (Operational Control) 
Unit: GJ/year​
 Control Approach: Operational Control​
 Time Range: As per dashboard configuration​
 Data Source: OPU Output – Energy Consumption dataset 
Energy Consumption Forecast – Data Logic (Upper Chart) 
Data Source: 
●​ Use records from the Energy Consumption dataset where:​
 
○​ Control Approach = Operational Control​
 
Aggregation Logic 
OPU-level Aggregation (per Year) 
●​ Scope 1 and Scope 2 values are combined.​
 
●​ Aggregation is performed before any visual calculation.​
 

Portfolio-level Aggregation 
Total Energy Consumption (Portfolio, Year) = Σ Total Energy Consumption (OPU, Year) 
 
Units 
●​ Base unit: GJ/year​
 
●​ Display unit: Million GJ/year​
 
●​ Conversion: Million GJ = GJ / 1,000,000 
 Breakdown by Energy Category – Data Logic (Lower Chart) 
Data Source 
●​ Use the same Energy Consumption dataset as Section X.1.​
 
Energy Category Mapping 
Source Value 
Energy Category 
Stationary Combustion 
Stationary Combustion 
Electricity Import 
Electricity Import 
Internal Energy Recovery 
Internal Energy Recovery 
Renewable Energy 
Renewable Energy 
 
Aggregation Logic 
Absolute Value per Category 

Energy (Category, Year)= Σ Energy Consumption WHERE Source ∈ Category 
Percentage Breakdown 
Energy Percentage (Category, Year)= Energy (Category, Year) / Total Energy Consumption (Year) 
●​ Percentage is calculated after absolute aggregation.​
 
●​ No rounding is applied before division. 
Section 2: Energy Intensity Forecast - Refer other Intensity Forecast 
Special Case: MMHE 
B.2 Filter Logic 
●​ Scenario selection applies to:​
 
○​ Energy consumption values​
 
○​ Energy intensity values​
 
●​ Hierarchy filters apply:​
 
○​ Business Unit (BU)​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Year range fixed to:​
 
○​ YEP 2025​
 
○​ 2026–2030 
B.3 Groupings 
●​ Energy Consumption:​
 
○​ Grouped by:​
 
■​ Asset / OPU​
 

■​ Energy type​
 
●​ Energy Intensity:​
 
○​ Grouped by:​
 
■​ Gas Processing​
 
■​ Utilities​
 
■​ Shipping​
 
■​ MMHE 
C. Visualization Requirements 
C.1 Layout 
●​ Layout must strictly follow the  executive PowerPoint:​
 
○​ Left panel:​
 
■​ Energy Consumption Forecast (Operational Control)​
 
■​ Energy breakdown by category​
 
○​ Right panel:​
 
■​ Energy Intensity Forecast (Operational Control)​
 
○​ Bottom:​
 
■​ Existing Operation energy consumption summary​
 
■​ Energy intensity summary table​
 
●​ Chart types, colours, legends, axes, and annotations must remain unchanged.​
 
C.2 Filter 
●​ Filters available:​
 
○​ Scenario​
 

○​ Business Unit (BU)​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Filters refresh all charts and tables simultaneously. 
C.3 Tooltips 
●​ Energy Consumption bars / lines​
 
○​ Asset / category​
 
○​ Year​
 
○​ Energy Consumption amount (Mil GJ per year)​
 
●​ Energy Intensity lines​
 
○​ Category (Gas Processing / Utilities / Shipping / MMHE)​
 
○​ Year​
 
○​ Amount:​
 
■​ GJ / tonne​
 
■​ GJ / MWh​
 
■​ GJ / Mil t-nm​
 
■​ GJ / thousands manhours​
. 
 
Story S-07-10. NZCE Pathway: GHG Emission (Equity Share) 
A. Description 
Displays the NZCE Pathway for G&M Business Sector, illustrating the long-term GHG Emission 
(Equity Share) trajectory from historical years through 2030, 2035, 2040, and 2050, highlighting the role 

of sustainability efficiency improvements and flagship projects in bridging the gap towards NZCE 
targets. 
 
B. Functional Requirements 
B.1 Data Logic 
Refer s07.02 & s07.03 for data logic rules.​
 
B.2 Filter Logic 
●​ Scenario selection applies to the NZCE pathway values.​
 
●​ Year selection is fixed to the displayed timeline.​
 
B.3 Groupings 
●​ Emissions grouped by:​
 
○​ OPUs​
 
○​ Growth vs Existing vs NOJV​
 
●​ Milestone groupings:​
 
○​ 2030​
 
○​ 2035​
 
○​ 2040​
 
○​ 2050​
 
 

C. Visualization Requirements 
C.1 Layout 
●​ Layout must strictly replicate the the ProjectH executive PowerPoint:​
 
○​ Single stacked bar chart across the full width​
 
○​ Overlay reduction and total ES lines​
 
○​ Visual milestone markers for 2030 / 2035 / 2040 / 2050​
 
○​ Annotations for achieved reduction and carbon offset​
 
●​ Colours, legend order, axis scale, labels, and annotations must remain unchanged.​
 
C.2 Filter 
●​ Filters available:​
 
○​ Scenario​
 
●​ Filters refresh the entire pathway view simultaneously.​
 
C.3 Tooltips 
●​ Hovering on stacked bars displays:​
 
○​ OPUS name​
 
○​ Year​
 
○​ GHG Emission amount (Million tCO2e)​
 
●​ Hovering on lines/markers displays:​
 
○​ Line type (Total ES / Upon Reduction)​
 
○​ Target year (2030 / 2035 / 2050)​
 
○​ Emission amount (Million tCO2e)​
 

D. Acceptance Criteria 
●​ NZCE Pathway dashboard matches the executive slide exactly in structure and presentation.​
 
●​ All stacked components and reduction lines display correctly across the full timeline.​
 
●​ Target milestones (2030, 2035, 2040, 2050) are clearly visible and correctly positioned.​
 
●​ Dashboard can be used directly for executive and governance reporting without manual 
adjustment. 
 
Story S-07-11 – NZCE 2050 Traffic Lights (Equity Share) 
A. Description 
Displays the NZCE 2050 Traffic Light status for Gas & Maritime Business, illustrating progress against 
GHG reduction targets for milestone years 2030, 2035, and 2050, using a colour-coded traffic light 
approach to indicate achievement status under the Equity Share (ES) approach. 
 
B. Functional Requirements 
B.1 Data Logic 
●​ NZCE Traffic Light Status​
 
○​ Assessment approach:​
 
■​ Equity Share (ES)​
 
○​ Reference year:​
 
■​ 2019 (for Scope 1 and Scope 2 emission reduction)​
 
●​ Milestone years displayed:​
 
○​ 2030​
 
○​ 2035​
 

○​ 2050​
 
●​ Business segments evaluated:​
 
○​ Gas & Maritime Business​
 
○​ LNG Assets (LNGA)​
 
○​ Gas & Power (G&P)​
 
○​ Maritime​
 
●​ Displayed indicators:​
 
○​ % Target GHG Reduction (Updated)​
 
○​ % Forecasted GHG Reduction​
 
○​ Forecasted GHG Reduction Contribution​
 
○​ GHG Emission (Post Reduction) – where shown​
 
○​ Carbon Offset for Hard to Abate (2050 only)​
 
●​ Traffic light colour logic (as displayed):​
 
○​ Green: Target achieved​
 
○​ Amber: Within tolerance of target​
 
○​ Red: More than tolerance below target​
 
B.2 Filter Logic 
●​ Scenario selection applies to traffic light status.​
 
●​ Hierarchy filters apply:​
 
○​ Business Unit (BU)​
 
○​ Group OPU​
 

○​ OPU​
 
●​ Year selection is fixed to:​
 
○​ 2030​
 
○​ 2035​
 
○​ 2050​
 
B.3 Groupings 
●​ Grouped by:​
 
○​ Business segment​
 
○​ Milestone year (2030 / 2035 / 2050)​
 
C. Visualization Requirements 
C.1 Layout 
●​ Layout must strictly follow the executive PowerPoint:​
 
○​ Three vertical columns representing:​
 
■​ 2030​
 
■​ 2035​
 
■​ 2050​
 
○​ Rows representing:​
 
■​ Gas & Maritime Business​
 
■​ LNG Assets (LNGA)​
 
■​ Gas & Power (G&P)​
 
■​ Maritime​
 

○​ Traffic light icon displayed per cell​
 
●​ Colours, labels, text placement, and icons must remain unchanged.​
 
 
C.2 Filter 
●​ Filters available:​
 
○​ Scenario​
 
○​ Business Unit (BU)​
 
○​ Group OPU​
 
○​ OPU​
 
●​ Filters update the traffic light status consistently.​
 
 
C.3 Tooltips 
●​ Hovering on a traffic light displays:​
 
○​ Business segment​
 
○​ Milestone year​
 
○​ Traffic light status (Green / Amber / Red)​
 
○​ % Forecasted GHG Reduction 
 
Story S-07-12. Upstream Feedgas and LNG Production Profile (LNGA) 
A. Description 
Displays the Upstream Feedgas and LNG Production Profile for LNGA, serving as the primary and 
authoritative reference for projecting LNGA’s GHG emissions across the 2026–2030 planning cycle, 
based on P4R assumptions. 

B. Functional Requirements 
B.1 Data Logic 
This section serves as the primary and authoritative reference for Feedgas Intake and LNG Production 
assumptions used in projecting LNGA GHG emissions across the 2026–2030 planning cycle. 
Business Scope: LNGA only​
 Control Approach: Operational Control​
 Time Range: 2025 (YEP baseline) + Scenario years 
Data Source  
●​ Data is sourced exclusively from LNGA Business Units (BU = LNGA).​
 
●​ Data is split into Feedgas and LNG Production based on the Parameter field.​
 
Feedgas Intake (mmscfd) 
Data Selection Rule 
Feedgas data includes all records where: 
Parameter = "Feedgas Intake"​
 
Aggregation Logic 
For each OPU and Year: 
Feedgas Intake (OPU, Year) = Σ Feedgas Intake values 
 
●​ Unit remains mmscfd​
 
●​ No unit conversion is applied​
 
●​ No normalization or scaling is performed​
 
LNG Production (MMT) 
Data Selection Rule 

LNG Production includes all records where: 
Parameter ∈ ("Production","Production (LNG)")​
 
Aggregation Logic 
For each OPU and Year: 
LNG Production (OPU, Year) = Σ Production values 
●​ Unit remains MMT​
 
●​ No conversion to tonnes or energy equivalent​
 
●​ Aggregation is performed before visualization 
B.2 Filter Logic 
●​ Scenario selection applies to feedgas and LNG production values.​
 
●​ Year Range Filter (5-Year sequences)​
 
B.3 Groupings 
●​ Feedgas:​
 
○​ Grouped by OPU​
 
●​ LNG Production:​
 
○​ Grouped by OPU​
 
C. Visualisation Requirements 
C.1 Layout 
●​ Layout must strictly follow the  executive PowerPoint:​
 
○​ Left panel:​
 
■​ Feedgas stacked area chart​
 

■​ Feedgas summary table​
 
○​ Right panel:​
 
■​ LNG Production stacked area chart​
 
■​ LNG Production summary table​
 
●​ Chart types, colour scheme, legend order, axes, and labels must remain unchanged.​
 
C.2 Filter 
Year Range Filter (5-Year sequences)​
 
C.3 Tooltips 
●​ Feedgas chart​
 
○​ OPU​
 
○​ Year​
 
○​ Feedgas amount (mmscfd)​
 
●​ LNG Production chart​
 
○​ OPU​
 
○​ Year​
 
○​ LNG Production amount (MMT) 
 
Story S-07-13. Kerteh Feedgas and Salesgas Production Profile (G&P) 
A. Description 
Displays the Kerteh Feedgas and Salesgas Production Profile, serving as the primary and 
authoritative reference for projecting PGB’s GHG emissions across the 5-year sequences planning 
cycle, based on P4R assumptions. 

B. Functional Requirements 
B.1 Data Logic 
Refer Data logic from s07.01 
B.3 Groupings 
●​ Feedgas:​
 
○​ Single profile grouping (Kerteh Feedgas)​
 
●​ Salesgas:​
 
○​ Single profile grouping (Salesgas Production)​
 
 
C. Visualization Requirements 
C.1 Layout 
●​ Layout must strictly follow the executive PowerPoint:​
 
○​ Left panel:​
 
■​ Kerteh Feedgas area chart​
 
■​ Feedgas summary table​
 
○​ Right panel:​
 
■​ Salesgas Production area chart​
 
■​ Salesgas summary table​
 
●​ Chart types, colour scheme, legend order, axes, and labels must remain unchanged.​
 
C.2 Filter 
●​ Filters available:​
 

○​ Scenario​
 
○​ Year​
 
●​ Filters refresh both charts and tables simultaneously.​
 
C.3 Tooltips 
●​ Kerteh Feedgas chart​
 
○​ Year​
 
○​ Feedgas amount (mmscfd)​
 
●​ Salesgas Production chart​
 
○​ Year​
 
○​ Salesgas Production amount (mmscfd) 
Story S-07-14. NOJV Production Profile (G&P) 
A. Description 
Displays the NOJV Production and Utilities Profile, serving as the primary and authoritative 
reference for projecting G&P’s GHG emissions across the 5-Year sequences planning cycle, based on 
P4R assumptions. 
B. Functional Requirements 
B.1 Data Logic 
Refer Data logic from s07.01​
 
B.2 Filter Logic 
●​ Scenario selection applies to production and utilities values.​
 
●​ Hierarchy filters apply:​
 
○​ Business Unit (BU)​
 

○​ Group OPU​
 
○​ OPU​
 
●​ Year selection is fixed to the displayed range.​
 
B.3 Groupings 
●​ Production:​
 
○​ Grouped by OPU​
 
●​ Utilities:​
 
○​ Grouped by OPU​
 
C. Visualization Requirements 
C.1 Layout 
●​ Layout must strictly follow the executive PowerPoint:​
 
○​ Left panel:​
 
■​ NOJV Production area chart​
 
■​ Production summary table​
 
○​ Right panel:​
 
■​ NOJV Utilities area chart​
 
■​ Utilities summary table​
 
●​ Chart types, colour scheme, legend order, axes, and labels must remain unchanged.​
 
C.2 Filter 
●​ Filters available:​
 

○​ Scenario​
​
 
●​ Filters refresh both charts and tables simultaneously.​
 
C.3 Tooltips 
●​ NOJV Production chart​
 
○​ OPU​
 
○​ Year​
 
○​ Production amount (tonne/year)​
 
●​ NOJV Utilities chart​
 
○​ OPU​
 
○​ Year​
 
○​ Utilities amount (MWh/year) 
3.8 BR-08 – Data Quality & Compliance  
●​ FS-05.x 
3.9 BR-09 – Change Rationale Capture  
●​ FS-05.x 
3.10 BR-10 – Notifications for Errors & Data Changes  
●​ FS-05.x 
3.11 BR-11 – Emissions Reduction Recommendations   
●​ FS-05.x 
5. NON-FUNCTIONAL REQUIREMENTS 

5.1 Performance 
5.2 Security & Access Control 
5.3 Scalability 
5.4 Availability 
5.5 Usability 
5.6 Audit & Logging 
 
6. ASSUMPTION & CONSTRAINT 
6.1 Assumptions 
6.2 Constraints 
 
7. CONCLUSION 
 
 
 
8. APPENDENCIES 
8.1 Glossary 
8.2 Sample UI Screens / Wireframes 
8.3 Data Model Summary 
 
 

 
 
 
