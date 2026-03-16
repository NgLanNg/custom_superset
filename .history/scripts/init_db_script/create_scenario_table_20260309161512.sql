-- SQLite Schema for Scenario MVP
-- Target: ~/.superset/superset.db

CREATE TABLE IF NOT EXISTS silver_scenario_equity_share (
    id TEXT PRIMARY KEY, -- Will hold UUIDs
    scenario_name TEXT NOT NULL,
    bu TEXT NOT NULL,
    opu TEXT NOT NULL,
    year INTEGER NOT NULL,
    value REAL NOT NULL,
    scenario_id TEXT,
    user_email TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    file_path TEXT,
    UNIQUE(scenario_name, opu, year, scenario_id, user_email)
);

CREATE INDEX IF NOT EXISTS idx_scenario_equity_lookup 
ON silver_scenario_equity_share(scenario_name, bu, opu);
