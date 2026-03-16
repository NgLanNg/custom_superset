# Design Decision: Scenario UI as a Custom Superset Plugin (Option C)

**Date**: 2026-03-09
**Topic**: Where the Scenario UI should live.
**Selected Approach**: Option C (Custom Superset Visualization Plugin)

## 1. Context & Problem Statement

We need to determine the architectural home for the highly-customized, interactive "Scenario Creation" UI which includes data grids (for write-backs) and live-updating charts. Originally scoped as a standalone HTML page embedding Superset iframes, the user explicitly requested to build it *inside* Superset as a native plugin (Option C).

## 2. Selected Approach: Custom Chart Plugin

Instead of fighting iframes and external Guest Token authentication, we will build a custom `@superset-ui` chart plugin (e.g., `plugin-chart-scenario-manager`).

This plugin will render the interactive React grid and the live chart inside a single Superset dashboard pane.

### Trade-offs Accepted

- **Pros:**
  - **Native Auth:** No need for complex Guest Token proxies or external Flask apps. Write-backs hit the Superset backend securely via native session tokens.
  - **Cohesive UX:** It lives inside the main Superset application, benefiting from Superset's native RBAC (Role-Based Access Control).
  - **Maintainability:** Custom plugins are loosely coupled enough that they don't block core Superset framework upgrades as badly as modifying core files.
- **Cons:**
  - **Layout Constraints:** We are constrained to the borders of a Superset dashboard slice. We cannot easily build full-screen proprietary navbars or sidebars outside of what the Superset dashboard builder provides.
  - **Build Complexity:** Requires writing React and TypeScript under the strict `@superset-ui` build pipeline.

## 3. Implementation Blueprint (To carry into `/spec`)

1. **Scaffold Plugin:** Use Superset's generator to scaffold `@superset-ui/plugin-chart-scenario-manager` in `superset-frontend/plugins/`.
2. **React Migration:** Port the existing HTML/CSS/JS from `scenario-ui.html` into modern React functional components inside the plugin. Use Ant Design (native to Superset) to replace custom CSS styles where possible to match Superset themes.
3. **Data Binding:** The plugin will accept baseline data via Superset's standard query pipeline (FormData).
4. **Write-Back Endpoint:** We still need the backend Flask `scenario_writeback.py` blueprint, but now the React plugin will call it natively using Superset's pre-configured `SupersetClient.post({})` utility, automatically handling CSRF and Session auth.
