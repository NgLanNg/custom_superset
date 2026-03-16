-- T51: Create silver_emission_by_sources for Scenario Creation Page
-- Stores GHG emission data by source, grouped by BU, OPU, Scope, Source, Year
-- Includes scenario tracking columns for scenario-based edits

CREATE TABLE IF NOT EXISTS silver_emission_by_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bu TEXT NOT NULL,
    opu TEXT NOT NULL,
    scope TEXT NOT NULL,
    source TEXT NOT NULL,
    year INTEGER NOT NULL,
    value NUMERIC(15, 4) NOT NULL DEFAULT 0,
    type TEXT DEFAULT 'operational_control',
    scenario_id TEXT NOT NULL DEFAULT 'base',
    user_email TEXT NOT NULL DEFAULT '',
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(bu, opu, scope, source, year, scenario_id, user_email)
);

CREATE INDEX IF NOT EXISTS idx_emission_sources_scenario
ON silver_emission_by_sources(scenario_id, user_email);

CREATE INDEX IF NOT EXISTS idx_emission_sources_bu_opu
ON silver_emission_by_sources(bu, opu);

CREATE INDEX IF NOT EXISTS idx_emission_sources_year
ON silver_emission_by_sources(year);
