# Production Deployment Guide - Scenario Planning Dashboard

**Date:** 2026-03-16
**Status:** Deployment Ready
**Environment:** PostgreSQL + Superset

---

## Overview

This document describes the complete production deployment setup for the Scenario Planning Dashboard, including database schema, configuration, and deployment procedures.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Production Environment                    │
├─────────────────────────────────────────────────────────────┤
│  Superset Application                                        │
│  ├─ Frontend (React + TypeScript)                         │
│  ├─ Backend (Flask + SQLAlchemy)                           │
│  └─ Custom Plugin: plugin-chart-scenario                   │
├─────────────────────────────────────────────────────────────┤
│  PostgreSQL Database                                         │
│  ├─ Metadata Tables (Superset core)                       │
│  ├─ Scenario Tables (Custom business data)               │
│  └─ Indexes for performance                                │
└─────────────────────────────────────────────────────────────┘
```

## Database Schema

### Core Tables

#### 1. `gold_scenario_equity_share`
Baseline scenario data for equity share calculations.

```sql
CREATE TABLE gold_scenario_equity_share (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bu VARCHAR(128),                 -- Business Unit
    opu VARCHAR(128),                -- Operational Unit
    year INTEGER,                    -- Year
    value NUMERIC,                   -- Emission value
    scenario_name VARCHAR(255),      -- Scenario identifier
    scenario_id VARCHAR(255),          -- Unique scenario ID
    user_email VARCHAR(255),         -- User who created/modified
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    file_path VARCHAR(500)             -- Source file reference
);
```

#### 2. `scenario_metadata`
Tracks scenario creation and metadata.

```sql
CREATE TABLE scenario_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_id VARCHAR(255) UNIQUE NOT NULL,
    scenario_name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    is_draft BOOLEAN DEFAULT TRUE
);
```

#### 3. `silver_emission_by_sources`
Core emission data with hierarchical filtering support.

```sql
CREATE TABLE silver_emission_by_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bu VARCHAR(128),                 -- Business Unit (filter level 1)
    opu VARCHAR(128),                -- Operational Unit (filter level 2)
    scope VARCHAR(128),              -- Emission Scope (filter level 3)
    source VARCHAR(128),             -- Emission Source (filter level 4)
    year INTEGER,
    value NUMERIC,
    type VARCHAR(64),                -- e.g., "operational_control"
    scenario_id VARCHAR(255),
    user_email VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 4. `silver_scenario_equity_share`
OPU-level equity share emissions.

```sql
CREATE TABLE silver_scenario_equity_share (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bu VARCHAR(128),
    opu VARCHAR(128),
    year INTEGER,
    value NUMERIC,
    scenario_name VARCHAR(255),
    scenario_id VARCHAR(255),
    user_email VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    file_path VARCHAR(500)
);
```

#### 5. `silver_scenario_growth_config`
Growth configuration data for scenarios.

```sql
CREATE TABLE silver_scenario_growth_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bu VARCHAR(128),
    opu VARCHAR(128),
    year INTEGER,
    value NUMERIC,
    scenario_name VARCHAR(255),
    scenario_id VARCHAR(255),
    user_email VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    file_path VARCHAR(500)
);
```

#### 6. `silver_scenario_opu_config`
OPU-level configuration data.

```sql
CREATE TABLE silver_scenario_opu_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bu VARCHAR(128),
    opu VARCHAR(128),
    year INTEGER,
    value NUMERIC,
    scenario_name VARCHAR(255),
    scenario_id VARCHAR(255),
    user_email VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    file_path VARCHAR(500)
);
```

### Performance Indexes

```sql
-- Hierarchical filtering index (critical for BU -> OPU -> Scope -> Source)
CREATE INDEX idx_emission_hierarchy ON silver_emission_by_sources (bu, opu, scope, source);

-- Scenario lookup index
CREATE INDEX idx_emission_scenario ON silver_emission_by_sources (scenario_id);

-- Scenario metadata lookup
CREATE INDEX idx_scenario_metadata_id ON scenario_metadata (scenario_id);
```

## Configuration Files

### Production Configuration (`superset_config.py`)

```python
# Database Configuration
SUPERSET_DB_HOST = os.environ.get("SUPERSET_DB_HOST", "localhost")
SUPERSET_DB_PORT = os.environ.get("SUPERSET_DB_PORT", "5432")
SUPERSET_DB_USER = os.environ.get("SUPERSET_DB_USER", "superset")
SUPERSET_DB_PASS = os.environ.get("SUPERSET_DB_PASS", "superset")
SUPERSET_DB_NAME = os.environ.get("SUPERSET_DB_NAME", "superset")

SQLALCHEMY_DATABASE_URI = f"postgresql+psycopg2://{_DATABASE_USER}:{_DATABASE_PASS}@{_DATABASE_HOST}:{_DATABASE_PORT}/{_DATABASE_NAME}"
```

### Required Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SUPERSET_SECRET_KEY` | **Yes** | None | Generate with `openssl rand -base64 42` |
| `SUPERSET_DB_HOST` | No | `localhost` | PostgreSQL host |
| `SUPERSET_DB_PORT` | No | `5432` | PostgreSQL port |
| `SUPERSET_DB_USER` | No | `superset` | PostgreSQL username |
| `SUPERSET_DB_PASS` | No | `superset` | PostgreSQL password |
| `SUPERSET_DB_NAME` | No | `superset` | PostgreSQL database name |

## Deployment Scripts

### Automated Deployment

**Script:** `deploy-to-production.sh`

```bash
./deploy-to-production.sh <production-host>
```

**What it does:**
1. Creates production database and tables
2. Sets up environment variables
3. Configures Superset for production
4. Provides restart instructions

### Manual SQL Migration

**Script:** `docs/migrations/2026-03-16-production-setup.sql`

```bash
PGPASSWORD=superset psql -h <host> -p 5432 -U superset -d superset -f docs/migrations/2026-03-16-production-setup.sql
```

## Pre-Deployment Checklist

- [ ] PostgreSQL server is running and accessible
- [ ] `SUPERSET_SECRET_KEY` environment variable is set
- [ ] Database credentials are configured
- [ ] Superset application is stopped
- [ ] Backup of existing data (if migrating)

## Post-Deployment Verification

1. **Test database connection:**
   ```bash
   PGPASSWORD=superset psql -h <host> -U superset -d superset -c "\dt"
   ```

2. **Verify tables exist:**
   ```sql
   SELECT table_name FROM information_schema.tables
   WHERE table_schema = 'public'
   AND table_name LIKE '%scenario%' OR table_name LIKE '%emission%';
   ```

3. **Test Superset connection:**
   - Start Superset
   - Navigate to dashboard
   - Verify data loads correctly

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `FATAL: SUPERSET_SECRET_KEY not set` | Run `export SUPERSET_SECRET_KEY=$(openssl rand -base64 42)` |
| `psql: connection refused` | Verify PostgreSQL is running and port is correct |
| `relation already exists` | Tables already created - safe to ignore |
| Superset can't connect to DB | Check `SUPERSET_*` environment variables |

## Support

- **Migration Script:** `docs/migrations/2026-03-16-production-setup.sql`
- **Deployment Script:** `deploy-to-production.sh`
- **Technical Spec:** `docs/specs/2026-03-16-writeback-e2e-tests.md`

---

**Deployment Status:** ✅ Ready for Production
