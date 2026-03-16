# Domain Research: Interactive Write-Backs & Data Entry in BI Platforms

**Date:** 2026-03-09
**Topic:** Real-time Scenario Creation (Editable Grids + Write-back APIs) within Apache Superset.

## 1. Problem Definition & Target User

**Problem:** Modern BI platforms, particularly open-source ones like Apache Superset, are fundamentally designed as read-only Online Analytical Processing (OLAP) tools. However, corporate finance, operational planners, and executives frequently need to run "What-If" scenarios (e.g., modifying equity shares, forecasting growth). Currently, these users operate in Excel, leading to fragmented, disjointed data outside the governed BI layer.
**Target User:** Business Analysts, Planners, and System Administrators who need governed environments to input specific scenario parameters and immediately see updated visual models.

## 2. Competitive Landscape & Prior Art

We must understand how competitors solve the "Write-back" problem within BI tools.

1. **Tableau + "Write-Back" Extensions**
   - **Features:** Tableau natively lacks write-back, but relies heavily on a booming ecosystem of premium third-party extensions (e.g., specifically named "Write-Back" by KETL or Xpand IT). These embedded web components allow users to edit data on a dashboard, sending it securely via API to SQL endpoints.
   - **Takeaway:** Providing a dedicated, secure API layer alongside the visualization is the industry standard for enterprise BI.

2. **Microsoft Power BI + Power Apps Embedding**
   - **Features:** Power BI solves this elegantly by natively letting users embed a custom Power App directly into a report canvas. Users input data in the app (e.g., marking a record "Approved"), the app writes directly to the Dataverse or SQL, and the report is refreshed.
   - **Takeaway:** Using a custom UI component integrated into the dashboard (like our proposed Superset React Plugin) is a proven, highly adopted UX pattern for scenarios and approvals.

3. **Apache Superset (Community Attempts)**
   - **Features:** Occasionally, open-source teams attempt to embed AG Grid plugins with editing enabled (`editable: true`). However, without an official `/api/writeback` backend route, they rely on hacky workarounds or entirely external applications (like we originally planned with Option A).
   - **Takeaway:** Superset has no native first-class capability for write-back. Any solution requires custom Flask APIs and a custom `@superset-ui` plugin wrapper to parse the edits.

## 3. Known User Pain Points (Risks for our Option C Architecture)

1. **The "Full Refresh" Delay:** BI tools heavily cache data (Redis). When a user changes an editable cell (e.g., "MLNG 2020: 90"), saving to the database is fast, but pushing that new SQL data back to the chart usually requires busting the cache and waiting for a full `POST /api/v1/chart/data` SQL query to execute, which disrupts the "real-time" immediate feel.
   - *Mitigation for our Spec:* The React plugin must proactively update its *local* state (updating the chart instantly in JS) *before* waiting on the backend database transaction to complete.
2. **Authorization Context Loss:** If the write-back is done in an iframe or an external web app, tracking the active Superset user session is complex and prone to CORS errors or Guest Token expirations.
   - *Mitigation for our Spec:* This validates our decision to build a **Native Plugin**. Superset's `SupersetClient` JS library automatically attaches the correct Session Cookies and CSRF headers when we POST to the Flask blueprint.
3. **Data Integrity Failures:** Invalid data entry inside a BI chart can corrupt downstream tables used by other users.
   - *Mitigation for our Spec:* We must use a dedicated, isolated `equity_share` table for the scenario planning instead of overwriting master fact tables.

## 4. Output Summary (Feed into Implementation Plan)

- Building the UI **directly inside Superset as a Native Plugin** (Option C from `/brainstorm`) aligns perfectly with how Microsoft solves this with Power Apps.
- The most crucial piece of our implementation will be the **Flask Writeback API Blueprint**, as Superset has no native concept of accepting raw JSON patches for user data.
- The UI *must* be capable of local, optimistic updates in React so the chart immediately moves when an input changes, rather than waiting for a full Superset SQL cache invalidation cycle.
