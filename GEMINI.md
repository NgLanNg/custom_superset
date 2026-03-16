# GEMINI.md - Project Context & Mandates

## Project: Custom Superset — Scenario Creation Dashboard

This project is a heavily customized version of Apache Superset, tailored for a "Scenario Creation Dashboard". It involves custom chart plugins for editable grids and write-back capabilities to a database.

## Technical Stack
- **Backend**: Python 3.11, Flask 2.x, Flask-AppBuilder (RBAC), SQLAlchemy 2.x
- **Frontend**: Node.js v24, React 17 (TypeScript), Webpack 5, `@superset-ui` core architecture
- **Database**: SQLite (Development) / PostgreSQL (Production)
- **Charting**: ECharts 5, AG Grid (`ag-grid-react`)
- **Styling**: Emotion, Ant Design 5

## Architectural Mapping
- **Monorepo Structure**: 
  - `superset/`: Python backend.
  - `superset-frontend/`: React/TypeScript monorepo.
- **Configuration**: `superset_config.py` in the root directory contains all custom configurations and feature flags.
- **Plugin System**: Custom visualizations are in `superset-frontend/plugins/`.
- **Write-back API**: Located in `superset/superset/views/scenario_writeback.py`.

## Foundational Mandates
1. **Configuration**: ALL environment variables and Superset config extensions MUST reside in `superset_config.py`. Never mutate core `config.py`.
2. **Embedding**: Use `EMBEDDED_SUPERSET` configuration + Guest Tokens + `@superset-ui/embedded-sdk`.
3. **Editable Grids**: Use `plugin-chart-ag-grid-table` or custom chart plugins (like `plugin-chart-scenario`) for editable interfaces.
4. **Database**: Use UUID for all new tables. Primary keys should be robust.
5. **Security**: Use `@has_access_api` for protected endpoints. Maintain strict RBAC.
6. **Code Quality**: 
   - **TypeScript**: No `any` types. Use proper interfaces.
   - **Python**: Follow existing Superset patterns and Flask-AppBuilder conventions.
7. **Verification**: `pre-commit run --all-files` is required before proposing changes.

## Context Efficiency
- Refer to `.geminiignore` for excluded patterns.
- Keep context lean by focusing on the specific monorepo component being modified.
