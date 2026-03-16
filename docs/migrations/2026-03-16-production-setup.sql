-- Migration Script: Production Database Setup for Scenario Dashboard
-- Date: 2026-03-16
-- Description: Create PostgreSQL database and tables for production deployment

-- Connect to PostgreSQL
\c superset

BEGIN;

-- =====================================
-- 1. Create 'superset' database if it doesn't exist
-- =====================================
SELECT 'CREATE DATABASE superset'
WHERE NOT EXISTS (SELECT datname FROM pg_database WHERE datname = 'superset');
$cmd$

-- =====================================
-- 2. Grant all privileges
-- =====================================
GRANT ALL PRIVILEGES ON DATABASE superset TO superset;

COMMIT;

-- Connect to superset database
\c superset
\set VERBOSITY

BEGIN;

-- =====================================
-- 3. Create required tables
-- =====================================

-- gold_scenario_equity_share (scenario creation baseline data)
CREATE TABLE IF NOT EXISTS gold_scenario_equity_share (
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

-- scenario_metadata (for tracking created scenarios)
CREATE TABLE IF NOT EXISTS scenario_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_id VARCHAR(255) UNIQUE NOT NULL,
    scenario_name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),
    is_draft BOOLEAN DEFAULT TRUE
);

-- silver_emission_by_sources
CREATE TABLE IF NOT EXISTS silver_emission_by_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bu VARCHAR(128),
    opu VARCHAR(128),
    scope VARCHAR(128),
    source VARCHAR(128),
    year INTEGER,
    value NUMERIC,
    type VARCHAR(64),
    scenario_id VARCHAR(255),
    user_email VARCHAR(255),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- silver_scenario_equity_share (for OPU-level emissions data)
CREATE TABLE IF NOT EXISTS silver_scenario_equity_share (
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

-- silver_scenario_growth_config
CREATE TABLE IF NOT EXISTS silver_scenario_growth_config (
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

-- silver_scenario_opu_config
CREATE TABLE IF NOT EXISTS silver_scenario_opu_config (
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

-- =====================================
-- 4. Create indexes for performance
-- =====================================

-- Indexes for hierarchical filtering (BU -> OPU -> Scope -> Source)
CREATE INDEX IF NOT EXISTS idx_emission_hierarchy ON silver_emission_by_sources (bu, opu, scope, source);
CREATE INDEX IF NOT EXISTS idx_emission_scenario ON silver_emission_by_sources (scenario_id);

-- Indexes for scenario_id lookups
CREATE INDEX IF NOT EXISTS idx_scenario_metadata_id ON scenario_metadata (scenario_id);

COMMIT;

-- =====================================
-- 5. Seed initial test data
-- =====================================

-- Create admin user if not exists (for tests)
DO $$
BEGIN
    INSERT INTO ab_user (username, first_name, last_name, email, roles)
    SELECT 'admin', 'Admin', 'Admin', 'admin@test.com', '["Admin"]'
    WHERE NOT EXISTS (SELECT id FROM ab_user WHERE username = 'admin');
END;
$$

-- Seed base emission data (LNGA - LNGA Operations)
INSERT INTO gold_scenario_equity_share (bu, opu, year, value)
SELECT 'LNGA', 'LNGA', 2024, 100.0
WHERE NOT EXISTS (
    SELECT 1 FROM gold_scenario_equity_share WHERE bu = 'LNGA' AND opu = 'LNGA' AND year = 2024
);

INSERT INTO gold_scenario_equity_share (bu, opu, year, value)
SELECT 'LNGA', 'LNGA', 2025, 120.0
WHERE NOT EXISTS (
    SELECT 1 FROM gold_scenario_equity_share WHERE bu = 'LNGA' AND opu = 'LNGA' AND year = 2025
);

-- =====================================
-- 6. Verification output
-- =====================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'PRODUCTION DATABASE SETUP COMPLETE';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Database: superset';
    RAISE NOTICE '';
    RAISE NOTICE 'Tables created:';
    RAISE NOTICE '  - gold_scenario_equity_share';
    RAISE NOTICE '  - scenario_metadata';
    RAISE NOTICE '  - silver_emission_by_sources';
    RAISE NOTICE '  - silver_scenario_equity_share';
    RAISE NOTICE '  - silver_scenario_growth_config';
    RAISE NOTICE '  - silver_scenario_opu_config';
    RAISE NOTICE '';
    RAISE NOTICE 'Admin user created: admin/admin';
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Verify database connection:';
    RAISE NOTICE '   psql -h localhost -U superset -d superset';
    RAISE NOTICE '2. Verify tables:';
    RAISE NOTICE '   psql -h localhost -U superset -d superset -c "\dt"';
END;
$$