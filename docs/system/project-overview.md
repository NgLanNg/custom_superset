---
type: project-documentation
date: 2026-03-10
author: Antigravity
project: Custom Superset — Scenario Creation Dashboard
version: MVP-1.0 (SQLite)
---

# Project Overview: Custom Superset — Scenario Creation Dashboard

A customized Apache Superset deployment with a write-back Scenario Chart plugin for editing equity-share percentages across LNG assets and growth projects. Cell edits persist to the database in real time and update a live ECharts line chart.

---

## 1. Architecture

```
                        +-------------------------------+
                        |         Browser Client        |
                        |   React + ECharts + Ant Design|
                        +-------+---------------+-------+
                                |               |
                        GET /explore    POST /api/v1/scenario/writeback
                                |               |
                        +-------v---------------v-------+
                        |     Flask (Superset) :8088     |
                        |  BaseSupersetView + FAB Auth   |
                        +-------+---------------+-------+
                                |               |
                        SQLAlchemy          Raw SQL (text)
                                |               |
                        +-------v---------------v-------+
                        |   SQLite (MVP) / PostgreSQL   |
                        |   ~/.superset/superset.db     |
                        |   Table: silver_scenario_...  |
                        +-------------------------------+
```

### Layered Breakdown

| Layer | Technology | Role |
|-------|-----------|------|
| **Presentation** | React 17, TypeScript, ECharts 5, Ant Design 5 | Editable grid, live chart, stat cards |
| **API** | Flask-AppBuilder, Marshmallow | REST endpoints, auth, validation |
| **Business Logic** | `ScenarioWritebackView` (Python) | UPSERT logic, user tracking, input guards |
| **Persistence** | SQLite (MVP) / PostgreSQL (planned) | `silver_scenario_equity_share` table |
| **Plugin System** | `@superset-ui/plugin-chart-scenario` | Registered in `MainPreset.ts` via `VizType.Scenario` |

---

## 2. Project Structure

```
/Users/alan/dashboard/
|
|-- superset_config.py            # Custom Superset config (symlinked into superset/)
|-- start.sh                      # macOS dev launcher (backend :8088 + frontend :9000)
|
|-- scripts/init_db_script/
|   |-- create_scenario_table.sql # DDL for silver_scenario_equity_share
|   `-- populate_scenario_data.sql# Seed data (4 OPUs x 8 years)
|
|-- superset/                     # Apache Superset git clone
|   |-- superset/                 # Python backend
|   |   |-- views/
|   |   |   `-- scenario_writeback.py  # Custom write-back API
|   |   |-- app.py, config.py, models/, commands/, security/, ...
|   |   `-- migrations/           # Alembic
|   |
|   `-- superset-frontend/        # React monorepo
|       |-- plugins/
|       |   `-- plugin-chart-scenario/  # Custom plugin
|       |       `-- src/
|       |           |-- ScenarioChart.tsx      # Main component (486 lines)
|       |           |-- ScenarioChart.styles.ts# Emotion styled components
|       |           |-- types.ts               # TypeScript interfaces
|       |           |-- mockData.ts            # Development seed data
|       |           |-- index.ts               # Package export
|       |           `-- plugin/
|       |               |-- index.ts           # ChartPlugin class
|       |               |-- buildQuery.ts      # Query builder
|       |               |-- controlPanel.ts    # Control panel config
|       |               `-- transformProps.ts   # Raw data -> component props
|       |
|       `-- src/visualizations/presets/
|           `-- MainPreset.ts     # Plugin registration point
|
|-- docs/                         # Project documentation
|-- vault/                        # Session context and task tracking
`-- .agents/, .claude/, .gemini/  # AI framework config (excluded from source)
```

---

## 3. Custom Extensions

### 3.1 Scenario Write-back API

**File:** `superset/superset/views/scenario_writeback.py`

| Endpoint | Method | Auth | Purpose |
|----------|--------|------|---------|
| `/api/v1/scenario/writeback` | POST | `@has_access_api` | Persist cell edits |
| `/api/v1/scenario/health` | GET | None | Health check |

**Request payload:**

```json
{
  "scenario_name": "existing_assets",
  "bu": "LNGA",
  "opu": "MLNG",
  "year": 2025,
  "value": 75,
  "scenario_id": ""
}
```

**Validation rules:**
- `scenario_name`, `bu`, `opu` -- required, non-empty strings, max 128 chars
- `year` -- required integer
- `value` -- required float, range [0, 100]

**Persistence:** SQLite UPSERT via `ON CONFLICT(scenario_name, opu, year, scenario_id, user_email) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at`.

**Registration:** Via `FLASK_APP_MUTATOR` in `superset_config.py` -> `appbuilder.add_view_no_menu(ScenarioWritebackView)`.

---

### 3.2 Scenario Chart Plugin

**Package:** `@superset-ui/plugin-chart-scenario`
**Directory:** `superset-frontend/plugins/plugin-chart-scenario/`

#### Component: `ScenarioChart.tsx`

Three-tab layout:

| Tab | Content | Editable |
|-----|---------|----------|
| **Equity Share Configuration** | Existing assets grid + Growth projects grid + ECharts line chart + Stat cards | Yes |
| **Growth Configuration** | Growth pipeline table (project, FID year, capacity, capex, status) | Read-only (mock) |
| **OPU Configuration** | Placeholder empty state | No |

**Data flow:**
1. Superset runs `buildQuery.ts` -> sends SQL query to backend
2. Backend returns rows from `silver_scenario_equity_share`
3. `transformProps.ts` pivots flat rows into `ExistingAssetRow[]` and `GrowthProjectRow[]`
4. `ScenarioChart.tsx` renders grids; falls back to `mockData.ts` if no real data
5. On cell edit: optimistic UI update -> `SupersetClient.post('/api/v1/scenario/writeback')` -> notification on success/failure

**TypeScript interfaces (types.ts):**

```typescript
interface ExistingAssetRow { bu: string; gpu: string; vals: number[] }
interface GrowthProjectRow { bu: string; project: string; vals: number[] }
interface ScenarioChartProps {
  height: number; width: number;
  existingData: ExistingAssetRow[];
  growthData: GrowthProjectRow[];
  scenarioName?: string;   // sent to write-back API
  bu?: string;             // sent to write-back API
}
```

**Plugin registration (`MainPreset.ts`):**

```typescript
import { ScenarioChartPlugin } from '@superset-ui/plugin-chart-scenario';
new ScenarioChartPlugin().configure({ key: VizType.Scenario })
```

---

### 3.3 Superset Configuration Override

**File:** `superset_config.py` (project root, symlinked into `superset/`)

| Setting | Value | Purpose |
|---------|-------|---------|
| `SECRET_KEY` | `$SUPERSET_SECRET_KEY` (env) | Session signing -- crashes on missing |
| `SQLALCHEMY_DATABASE_URI` | `sqlite:///~/.superset/superset.db` | Metadata + scenario data |
| `ENABLE_CORS` | `True` | Cross-origin for embedded dashboards |
| `CORS_OPTIONS.origins` | `localhost:8088`, `localhost:9000` | Dev-only whitelist |
| `FEATURE_FLAGS.EMBEDDED_SUPERSET` | `True` | Enable guest-token embedding |
| `FEATURE_FLAGS.AG_GRID_TABLE_ENABLED` | `True` | AG Grid editable table |
| `FEATURE_FLAGS.DASHBOARD_RBAC` | `True` | Per-dashboard role access |
| `GUEST_TOKEN_JWT_SECRET` | `$SUPERSET_GUEST_TOKEN_SECRET` (env) | Embedded SDK auth |
| `FLASK_APP_MUTATOR` | Registers `ScenarioWritebackView` | Custom API route injection |

---

## 4. Database Schema

**Table:** `silver_scenario_equity_share`
**Location:** `~/.superset/superset.db` (SQLite MVP)
**DDL:** `scripts/init_db_script/create_scenario_table.sql`

| Column | Type | Constraint |
|--------|------|-----------|
| `id` | TEXT | PRIMARY KEY (UUID) |
| `scenario_name` | TEXT | NOT NULL |
| `bu` | TEXT | NOT NULL |
| `opu` | TEXT | NOT NULL |
| `year` | INTEGER | NOT NULL |
| `value` | REAL | NOT NULL |
| `scenario_id` | TEXT | Nullable |
| `user_email` | TEXT | Nullable |
| `updated_at` | DATETIME | DEFAULT CURRENT_TIMESTAMP |
| `file_path` | TEXT | Nullable (NULL = UI edit, non-NULL = Lambda ingest) |

**Unique constraint:** `(scenario_name, opu, year, scenario_id, user_email)`
**Index:** `idx_scenario_equity_lookup` on `(scenario_name, bu, opu)`

**Seed data** (`populate_scenario_data.sql`):

| OPU | Years | Range |
|-----|-------|-------|
| MLNG | 2020-2027 | 70% -> 80% |
| LNGC2 | 2020-2027 | 30% -> 40% |
| LNGC3 | 2020-2027 | 10% -> 25% |
| ALNG | 2020-2027 | 50% -> 70% |

---

## 5. Data Flow Diagram

```
User edits cell (75%)
        |
        v
ScenarioCell.onBlur()
        |
        v
handleSave('existing', rowIdx, yearIdx, 75)
        |
        +---> setExistingData(prev => ...)   [Optimistic UI]
        |         |
        |         v
        |     ECharts re-renders chart
        |
        +---> SupersetClient.post('/api/v1/scenario/writeback', {
                scenario_name, bu, opu, year, value
              })
                |
                v
        ScenarioWritebackView.writeback()
                |
                +---> Validate payload (required fields, types, ranges)
                +---> Resolve user_email from current_user
                +---> INSERT ... ON CONFLICT DO UPDATE
                +---> Return { status: "success", data: { opu, year, value } }
                        |
                        v
                notification.success("Saved")
```

---

## 6. Technology Stack

### Backend

| Component | Technology |
|-----------|-----------|
| Framework | Flask 2.x + Flask-AppBuilder |
| ORM | SQLAlchemy 2.x |
| Database | SQLite (MVP) / PostgreSQL RDS (production) |
| Auth | Flask-Login, `@has_access_api` decorator, RBAC |
| Async (unused in MVP) | Celery + Redis |
| Migration | Alembic |
| Type checking | MyPy |
| Linting | Ruff, Black |

### Frontend

| Component | Technology |
|-----------|-----------|
| Framework | React 17, TypeScript |
| State | React hooks (`useState`, `useMemo`, `useCallback`) |
| Charts | ECharts 5 (tree-shaken: LineChart, Grid, Legend, Tooltip) |
| UI Components | Ant Design 5 (`Tabs`, `notification`) |
| Styled Components | Emotion (`@emotion/styled`) |
| HTTP Client | `SupersetClient` from `@superset-ui/core` |
| Build | Webpack 5 |
| Package Manager | npm (Lerna monorepo) |
| Testing | Jest + React Testing Library, Playwright (E2E) |

### DevOps

| Component | Technology |
|-----------|-----------|
| Dev startup | `start.sh` (macOS osascript) |
| Backend port | `:8088` (Flask debug server) |
| Frontend port | `:9000` (Webpack dev server) |
| Pre-commit | Black, Prettier, Ruff, MyPy, ESLint |

---

## 7. Security Model

| Concern | Implementation |
|---------|---------------|
| Session signing | `SECRET_KEY` from env var (hard crash on missing) |
| API auth | `@has_access_api` on write-back endpoint (requires logged-in user) |
| CORS | Restricted to `localhost:8088` and `localhost:9000` |
| Input validation | Max 128 chars on text fields; value range [0, 100]; type checks |
| Embedded auth | Guest Token JWT via `@superset-ui/embedded-sdk` |
| User tracking | `user_email` column populated from `current_user` on every write |
| `file_path` column | `NULL` for UI edits, non-NULL for ingestion -- audit trail |
| Error handling | Generic error messages to client; full stack traces in server logs |

---

## 8. Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Architecture | Native `@superset-ui` chart plugin | Avoids iframe overhead; leverages plugin system, auth, and build pipeline |
| MVP database | SQLite (`superset.db`) | Unblocks local development; production will use PostgreSQL RDS |
| Primary key | UUID (`gen_random_uuid()`) | Matches all other Silver-layer tables |
| Write-back auth | `@has_access_api` + `SupersetClient.post()` | Uses Superset's native CSRF handling; no exemptions needed |
| UI update strategy | Optimistic | Local state updates immediately; reverts on API failure |
| Chart library | ECharts (tree-shaken) | Already bundled in Superset; avoids adding Chart.js dependency |
| Styling | Emotion styled-components | Matches Superset plugin conventions |
| Blueprint registration | `FLASK_APP_MUTATOR` | Defers import until app context exists; avoids circular imports |

---

## 9. Running the Project

### Prerequisites

- Python 3.11+ with virtualenv at `superset/.venv/`
- Node.js v24+ with npm
- SQLite 3
- macOS (for `start.sh`; manual startup on other OS)

### Quick Start

```bash
# 1. Set required env vars
export SUPERSET_SECRET_KEY=<your-secret>
export SUPERSET_GUEST_TOKEN_SECRET=<your-jwt-secret>

# 2. Initialize the scenario table
sqlite3 ~/.superset/superset.db < scripts/init_db_script/create_scenario_table.sql
sqlite3 ~/.superset/superset.db < scripts/init_db_script/populate_scenario_data.sql

# 3. Launch (opens two Terminal tabs on macOS)
./start.sh

# Backend: http://localhost:8088
# Frontend: http://localhost:9000
```

### Manual Startup (non-macOS)

```bash
# Terminal 1 — Backend
cd superset
source .venv/bin/activate
export FLASK_APP=superset FLASK_ENV=development SUPERSET_SECRET_KEY=TEST
superset run -p 8088 --with-threads --reload --debugger

# Terminal 2 — Frontend
cd superset/superset-frontend
npm run dev-server
```

### Health Checks

```bash
# Superset
curl http://localhost:8088/health

# Scenario API
curl http://localhost:8088/api/v1/scenario/health
```

---

## 10. File Inventory (Custom Code)

| File | Lines | Purpose |
|------|-------|---------|
| `superset_config.py` | 58 | Superset config override + blueprint registration |
| `start.sh` | 17 | macOS dev launcher |
| `scripts/init_db_script/create_scenario_table.sql` | 20 | DDL |
| `scripts/init_db_script/populate_scenario_data.sql` | 42 | Seed data |
| `superset/superset/views/scenario_writeback.py` | 162 | Write-back API (Flask) |
| `plugins/plugin-chart-scenario/src/ScenarioChart.tsx` | 486 | Main React component |
| `plugins/plugin-chart-scenario/src/ScenarioChart.styles.ts` | 464 | Styled components |
| `plugins/plugin-chart-scenario/src/types.ts` | 69 | TypeScript interfaces |
| `plugins/plugin-chart-scenario/src/mockData.ts` | 42 | Dev mock data |
| `plugins/plugin-chart-scenario/src/index.ts` | 1 | Package export |
| `plugins/plugin-chart-scenario/src/plugin/index.ts` | 33 | ChartPlugin class |
| `plugins/plugin-chart-scenario/src/plugin/buildQuery.ts` | 37 | Query builder |
| `plugins/plugin-chart-scenario/src/plugin/controlPanel.ts` | 50 | Control panel config |
| `plugins/plugin-chart-scenario/src/plugin/transformProps.ts` | 64 | Data transformation |
| **Total custom code** | **~1,545** | |

---

## 11. Production Roadmap

| Phase | Description | Status |
|-------|------------|--------|
| **MVP (SQLite)** | Full write-back loop: grid edit -> API -> SQLite -> chart update | Complete |
| **PostgreSQL migration** | Replace SQLite with `peth_prod.silver_scenario_equity_share` on RDS | Pending |
| **dbt Gold model** | `gold_scenario_equity_share.sql` with `ROW_NUMBER()` deduplication | Pending |
| **Tableau integration** | Connect Tableau to Gold model for downstream reporting | Pending |
| **OPU Configuration tab** | Implement the placeholder third tab with real data | Pending |
| **Growth Configuration** | Replace mock pipeline data with real project tracking | Pending |

---

## 12. Implementation Rules

> These rules are enforced for all agents and contributors.

1. **Config in `superset_config.py`** -- never mutate the core `config.py`
2. **Editable grids via AG Grid or custom plugin** -- not legacy tables
3. **Embedding via `EMBEDDED_SUPERSET` + Guest Tokens** -- not CSS hacks
4. **UUID primary keys** -- all new tables
5. **Pre-commit required** -- `pre-commit run --all-files` before any push
6. **No `any` types** in new TypeScript code
7. **Use `@superset-ui/core`** for UI components, not direct Ant Design imports

## Tableau Connection
To connect Tableau Desktop to the Gold model:
1. Connect to PostgreSQL server on `localhost:5432` (or the production RDS endpoint)
2. Database: `superset`
3. Username and Password as configured.
4. Use the table `public.gold_scenario_equity_share` for the deduplicated scenario reporting data.

---

## 13. Deployment Documentation

| Document | Location | Purpose |
|----------|----------|---------|
| Alibaba Cloud Deployment | `docs/deployment/alibaba-cloud-deployment-guide.md` | Full deployment guide for Alibaba Cloud |
| Docker Reference | `docs/deployment/docker-reference.md` | Dockerfile and docker-compose reference |
| Troubleshooting | `docs/deployment/troubleshooting-guide.md` | Common issues and fixes |
| Alpha Sports Dashboard | `docs/deployment/alpha-sports-dashboard-deployment.md` | Complete deployment guide |

### Quick Start for Alibaba Cloud

```bash
# 1. Prepare server
apt install -y docker.io
curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 2. Create .env
cat > .env << 'EOF'
SUPERSET_POSTGRES_PASSWORD=your_password
SUPERSET_SECRET_KEY=$(openssl rand -base64 42)
SUPERSET_GUEST_TOKEN_SECRET=$(openssl rand -base64 42)
EOF

# 3. Build and start
docker-compose build superset
docker-compose up -d

# 4. Initialize database
docker exec -it superset-base superset db upgrade
docker exec -it superset-base superset init
docker exec -i superset-postgres psql -U superset -d superset -f /app/scripts/init_db_script/create_scenario_table.sql
```

For full details, see `docs/deployment/alibaba-cloud-deployment-guide.md`.
