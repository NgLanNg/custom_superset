-- PostgreSQL Schema for OPU Configuration MVP
-- Target: superset database (local Docker)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS silver_scenario_opu_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_name TEXT NOT NULL,
    opu TEXT NOT NULL,
    bu TEXT NOT NULL,
    type TEXT NOT NULL, -- 'existing' or 'growth'
    base_equity_pct DOUBLE PRECISION,
    region TEXT,
    active BOOLEAN DEFAULT true,
    user_email TEXT DEFAULT '',
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(scenario_name, opu, user_email)
);
