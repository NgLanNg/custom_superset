# Scenario Feature Re-alignment Report

**Status:** Technical Debt Identified / Pivot Required
**Last Agent:** Antigravity
**Date:** 2026-03-12

## Blunt Assessment
The project has strayed into building a standalone React application (SPA) disguised as an extension, while the user strictly wants a **Superset Dashboard** experience. 

We successfully fixed the "403 Forbidden" errors on the `/scenario/create/` route, but this was a tactical victory on a strategically flawed path. The user has explicitly rejected the standalone web page approach.

## What Was Done
1.  **Fixed 403 Access:** Unified backend permissions to `Scenario` and added missing `@permission_name` decorators in `opu_config_view.py`, `growth_config_view.py`, and `scenario_writeback.py`.
2.  **Environment Sync:** Required setting `SUPERSET_SECRET_KEY` and running `superset init` to sync permissions to the FAB database.
3.  **UI Verification:** Confirmed that `http://localhost:8088/scenario/create/` is fully functional and talkative with the API. 

## The Problem (The "Real" Work)
The current `ScenarioCreationPage.tsx` is a full-page view registered in `src/views/routes.tsx`. It is **not** a dashboard component. 
There is a `plugin-chart-scenario` in the `plugins/` directory that appears to be the intended vehicle for dashboard integration, but it is currently less featured than the standalone page.

## Realities for the Next Agent
- **Stop building the SPA:** Any further work on `/scenario/create/` is a waste of time.
- **Merge/Migrate:** The logic in `src/scenario/ScenarioCreationPage.tsx` (Save/Submit flows, Metadata handling) needs to be integrated into `plugin-chart-scenario`.
- **Dashboard Context:** The "Scenario Creator" needs to behave as a Chart or a Native Filter inside a standard Superset Dashboard, likely inheriting filters from the dashboard level rather than having its own `FilterPanel`.
- **Acceptance Criteria check:** Review `vault/tasks/delegate-t59-t60-scenario-e2e.md`. It describes the page as a "Scenario Creation Page," which might be why the previous agent went the SPA route. **The user's direct feedback overrules the spec.**

## Files of Interest
- **Backend APIs:** `/superset/superset/views/scenario_writeback.py` (Functional, keep these).
- **SPA (The "Wrong" Way):** `superset/superset-frontend/src/scenario/ScenarioCreationPage.tsx`.
- **Dashboard Target (The "Right" Way):** `superset/superset-frontend/plugins/plugin-chart-scenario/src/ScenarioChart.tsx`.

Proceed by gutting the SPA and beefing up the plugin.


log:

Rethinking Dashboard vs SPA Approach
The user clarified that they wanted a "dashboard," not a standalone web route for scenario creation. I'm now reviewing the original requirements and project specifications to determine how to integrate the scenario creation functionality into a Superset dashboard or if a pivot is necessary to meet this expectation.

Progress Updates
1
Reviewing original requirement and project specs to align with "Dashboard" expectation

Realigning Scenario Feature to Dashboard
I've identified the core components of the Scenario feature: the ScenarioCreationPage and the plugin-chart-scenario. I'm now analyzing their code to understand their differences and determine how to consolidate the creation functionality into a dashboard-friendly chart plugin.

Progress Updates
1
Loading project context and researching Scenario implementation

2
Investigating ScenarioView and identifying the frontend components for the Scenario Creator.

3
Comparing the Scenario Creation Page with the Scenario Chart Plugin to decide on the integration strategy.

report your work back to report md file for other agent, be blunt and reallistic






Reporting Progress and Alignment Issues
I've created 

report.md
 with a blunt assessment of the project's state, highlighting the misalignment between the current SPA implementation and the dashboard requirement. The backend fixes remain valid, but a frontend pivot is necessary.

Files Edited
Progress Updates
1
Creating the report.md file with a blunt assessment of the current state.

2
Updating the walkthrough and notifying the user of the report.

I've created the report.md file in the root of the dashboard. It contains a blunt assessment of the work done and the critical misalignment identified: the current implementation is a standalone web page (SPA), while you've requested a dashboard-based solution.

I've also updated the task and walkthrough to reflect this. You can review the report and let me know if you'd like me to start the pivot by migrating the creation logic into the plugin-chart-scenario so it can be used natively in your dashboards.

Walkthrough of fixing Scenario route access and API permissions. Confirmed that the `/scenario/create/` route and all associated API endpoints (`opu-config`, `growth-config`, `emission-sources`) are now accessible without 403 errors. Unified permission naming to `Scenario` across all relevant views and synchronized the database using `superset init`. Verified the fix with browser-based testing and captured a proof-of-work screenshot.