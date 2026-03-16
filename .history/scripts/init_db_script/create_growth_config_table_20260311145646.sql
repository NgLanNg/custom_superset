-- PostgreSQL Schema for Growth Configuration MVP
-- Target: superset database (local Docker)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS silver_scenario_growth_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_name TEXT NOT NULL,
    bu TEXT NOT NULL,
    project TEXT NOT NULL,
    fid_year INTEGER,
    capacity_mtpa DOUBLE PRECISION,
    capex_billion DOUBLE PRECISION,
    status TEXT DEFAULT 'On Track',
    user_email TEXT DEFAULT '',
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(scenario_name, project, user_email)
);
