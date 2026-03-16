# Technical Design: Native Scenario Plugin & Write-back API

**Date:** 2026-03-09
**Topic:** Data Models, API Contracts, and System Structure for the Scenario Plugin.

## 1. Context

We are implementing the Scenario Creation UI directly inside Apache Superset as a custom `@superset-ui` chart plugin. This allows for seamless authentication (native user sessions) and optimistic interactive chart updates. The primary technical requirement is that data entered into the grid cells must be persisted back to the database, skipping the traditional read-only OLAP workflow of Superset.

## 2. Data Design

We are adding a domain-specific table to store user inputs for the scenarios. We will store this in the primary Superset metadata database (SQLite/Postgres) since this is a custom extension of the platform.

### Table: `scenario_equity_share`

This table records the specific value input by a user for a given asset in a given year.

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | Integer / UUID | Primary Key | Autoincrementing unique ID. |
| `scenario_name` | String(100) | Not Null | E.g., "existing_assets" or "growth_projects". |
| `business_unit` | String(50) | Not Null | E.g., 'LNGA', 'G&P'. |
| `asset` | String(100) | Not Null | The GPU or Project name (e.g., 'MLNG', 'LNGC2'). |
| `year` | Integer | Not Null | Financial year (e.g., 2020). |
| `value` | Float | Not Null | Equity percentage (0-100). |
| `updated_at` | DateTime | default `now()` | Timestamp of the last edit. |
| `updated_by` | Integer (FK) | references `ab_user.id` | The Superset User ID making the edit. |

**Indexes & Constraints:**

- Unique Constraint: `(scenario_name, asset, year)` - Ensures we `UPSERT` on cell edits rather than duplicate.
- Index: `(scenario_name, asset)` - Fast lookups for populating the React grids.

## 3. API Design

We need a bespoke Flask endpoint to receive cell edits natively from the React plugin.

### Endpoint: `POST /api/v1/scenario/writeback`

**Flow:** Custom Blueprint inside Superset Backend.
**Authentication:** Relies on Superset's standard `@expose` and `@protect()` decorators (requires the user to be logged in to Superset). CSRF protection is enforced natively.

**Request Payload:**

```json
{
  "scenario_name": "existing_assets",
  "business_unit": "LNGA",
  "asset": "MLNG",
  "year": 2020,
  "value": 90.0
}
```

**Response Payload (Success - 200 OK):**

```json
{
  "status": "success",
  "data": {
    "scenario_name": "existing_assets",
    "asset": "MLNG",
    "year": 2020,
    "value": 90.0,
    "updated_at": "2026-03-09T15:00:00Z"
  }
}
```

**Response Payload (Error - 400 Bad Request):**

```json
{
  "status": "error",
  "message": "Value must be between 0 and 100."
}
```

## 4. Integration Points

### 4.1 Frontend to Backend (The Plugin)

Inside the custom React Plugin `plugin-chart-scenario`:

- We do **not** use `fetch()`. We use Superset's strict HTTP client to handle CSRF tokens and redirects automatically.

```typescript
import { SupersetClient } from '@superset-ui/core';

// Inside onCellInput event:
SupersetClient.post({
  endpoint: '/api/v1/scenario/writeback',
  jsonPayload: payload
}).then(...)
```

### 4.2 Backend to Database (The API)

Inside `superset/views/scenario_writeback.py`:

- We use the global Superset `db` object (`from superset import db`) and its active SQLAlchemy session.
- We perform an **UPSERT** (On Conflict Update).

### 4.3 UI to Chart (Optimistic Rendering)

Inside the React component:

- The `onCellInput` event must immediately call `setGridData(...)` and recalculate the `chartData` average arrays.
- It updates the Echarts/Chart.js instance synchronously so the user sees the chart point move instantly, while the `SupersetClient.post` network request resolves in the background.

## 5. Design Decisions log

- **Why a custom table in the metadata DB instead of a separate Snowflake/Postgres instance?**
  *Trade-off:* Modifying the metadata DB mixes analytical data with application config. However, for MVP, creating a standalone external API with a separate DB adds huge CORS, infrastructure, and authentication complexity. The `superset.db` is already actively connected.
- **Why REST instead of GraphQL?**
  *Trade-off:* Superset's main `api/v1` architecture uses Flask-AppBuilder REST controllers. Sticking to REST keeps our custom code idiomatically aligned with the rest of Superset.
- **Why optimistic UI updates?**
  *Trade-off:* If the `SupersetClient.post` fails, the local React UI will be out of sync. We accept this risk because forcing the user to wait 300ms for a network round trip on every keystroke ruins the "spreadsheet" experience. If the POST fails, we will throw an Ant Design `Toast.error` and optionally revert the local state.
