-- PostgreSQL Schema for Scenario Metadata
-- Target: superset database (local Docker)
-- Purpose: Track scenario lifecycle (draft, pending_approval, approved, rejected)

-- Ensure pgcrypto extension for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Scenario metadata table
CREATE TABLE IF NOT EXISTS scenario_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_name TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'draft',
    created_by TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    submitted_at TIMESTAMPTZ,
    approved_by TEXT,
    approved_at TIMESTAMPTZ,
    CHECK (status IN ('draft', 'pending_approval', 'approved', 'rejected'))
);

-- Unique constraint on scenario name
CREATE UNIQUE INDEX IF NOT EXISTS idx_scenario_metadata_name
ON scenario_metadata(scenario_name);

-- Index for status queries (common filter)
CREATE INDEX IF NOT EXISTS idx_scenario_metadata_status
ON scenario_metadata(status);

-- Index for user's scenarios
CREATE INDEX IF NOT EXISTS idx_scenario_metadata_created_by
ON scenario_metadata(created_by);

-- Index for approval workflow queries
CREATE INDEX IF NOT EXISTS idx_scenario_metadata_submitted_at
ON scenario_metadata(submitted_at) WHERE submitted_at IS NOT NULL;