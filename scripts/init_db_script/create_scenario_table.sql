-- PostgreSQL Schema for Scenario MVP
-- Target: superset database (local Docker)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS silver_scenario_equity_share (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_name TEXT NOT NULL,
    bu TEXT NOT NULL,
    opu TEXT NOT NULL,
    year INTEGER NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    scenario_id TEXT DEFAULT '',
    user_email TEXT DEFAULT '',
    updated_at TIMESTAMPTZ DEFAULT now(),
    file_path TEXT,
    UNIQUE(scenario_name, opu, year, scenario_id, user_email)
);

CREATE INDEX IF NOT EXISTS idx_scenario_equity_lookup
ON silver_scenario_equity_share(scenario_name, bu, opu);
