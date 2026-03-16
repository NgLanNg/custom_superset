---
type: project-context
date: 2026-03-10
author: Antigravity
project: Custom Superset — Scenario Creation Dashboard
stepsCompleted: [1, 2, 3, 4]
inputDocuments: [docs/system/project-overview.md]
---

# Project Context: Custom Superset

## 1. Technology Stack

- **Backend**: Python 3.11, Flask 2.x, Flask-AppBuilder (RBAC), SQLAlchemy 2.x
- **Frontend**: Node.js v24, React 17 (TypeScript), Webpack 5, `@superset-ui` core architecture
- **Database**: SQLite (MVP at `~/.superset/superset.db`); PostgreSQL RDS planned for production
- **Charting**: ECharts 5 (tree-shaken), AG Grid (`ag-grid-react`)
- **Styling**: Emotion (`@emotion/styled`), Ant Design 5
- **Testing**: Jest + React Testing Library (unit), Playwright (E2E), pytest (backend)

## 2. Implementation Patterns

- **Monorepo Structure**: `superset/` (Python backend) and `superset-frontend/` (React/TypeScript monorepo with Lerna)
- **Feature Flags**: Controlled via `FEATURE_FLAGS` dict in `superset_config.py` (`EMBEDDED_SUPERSET`, `AG_GRID_TABLE_ENABLED`, `DASHBOARD_RBAC`)
- **Plugin Architecture**: Chart visualizations registered as `@superset-ui/plugin-*` packages in `MainPreset.ts`
- **Write-back Pattern**: Custom Flask Blueprint (`ScenarioWritebackView`) registered via `FLASK_APP_MUTATOR`; frontend uses `SupersetClient.post()` with optimistic UI
- **Config Override**: All customizations in `superset_config.py` (project root, symlinked into `superset/`); core `config.py` is never mutated

## 3. Custom Extensions

| Extension | Location | Purpose |
|-----------|----------|---------|
| Scenario Write-back API | `superset/superset/views/scenario_writeback.py` | POST `/api/v1/scenario/writeback` for cell edits |
| Scenario Chart Plugin | `superset-frontend/plugins/plugin-chart-scenario/` | Editable equity-share grid + live ECharts chart |
| Config Override | `superset_config.py` | Feature flags, CORS, blueprint registration, auth |
| DB Schema | `scripts/init_db_script/create_scenario_table.sql` | `silver_scenario_equity_share` DDL |
| Seed Data | `scripts/init_db_script/populate_scenario_data.sql` | 4 OPUs x 8 years baseline |

## 4. Strict Implementation Rules

> [!CRITICAL]
> These rules must be adhered to by all automated agents working on this project.

1. **Embedding**: Use `EMBEDDED_SUPERSET` configuration + Guest Tokens + `@superset-ui/embedded-sdk`. Never hack CSS to hide navbars.
2. **Editable Grids**: Use `plugin-chart-ag-grid-table` or custom chart plugins (like `plugin-chart-scenario`) for editable interfaces.
3. **Configuration**: ALL environment variables and Superset config extensions reside in `superset_config.py`. Never mutate core `config.py`.
4. **Primary Keys**: UUID for all new tables.
5. **Auth**: Use `@has_access_api` for protected endpoints. No CSRF exemptions or custom tokens.
6. **TypeScript**: No `any` types in new code. Use proper interfaces from `types.ts`.
7. **Pre-commit**: `pre-commit run --all-files` required before any push.

## 5. Current State

- **Phase**: MVP Complete (SQLite)
- **All tasks T1-T8**: Done (DB schema, Flask API, plugin scaffold, React component, registration, write-back wiring)
- **Code review**: All Critical/High issues resolved
- **Remaining**: PostgreSQL migration, dbt Gold model, Tableau integration, OPU tab implementation
- **Full documentation**: `docs/system/project-overview.md`
