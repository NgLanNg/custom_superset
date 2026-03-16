-- Seed data for silver_scenario_opu_config
-- Using ON CONFLICT to avoid duplicate key errors if run multiple times

INSERT INTO silver_scenario_opu_config 
    (scenario_name, opu, bu, type, base_equity_pct, region, active, user_email)
VALUES 
    -- Existing OPUs
    ('existing_assets', 'ALNG', 'LNGA', 'existing', 70.0, 'Asia', true, 'admin@example.com'),
    ('existing_assets', 'MLNG', 'LNGA', 'existing', 65.0, 'Asia', true, 'admin@example.com'),
    ('existing_assets', 'PFLNG 1', 'LNGA', 'existing', 100.0, 'Asia', true, 'admin@example.com'),
    ('existing_assets', 'PFLNG 2', 'LNGA', 'existing', 80.0, 'Asia', true, 'admin@example.com'),
    ('existing_assets', 'Gladstone', 'LNGA', 'existing', 27.5, 'Australia', true, 'admin@example.com'),
    ('existing_assets', 'Egypt LNG', 'LNGA', 'existing', 35.5, 'Africa', true, 'admin@example.com'),
    ('existing_assets', 'Dragon LNG', 'LNGA', 'existing', 50.0, 'Europe', true, 'admin@example.com'),
    ('existing_assets', 'Bintulu', 'G&P', 'existing', 60.0, 'Asia', true, 'admin@example.com'),
    ('existing_assets', 'Sabah', 'G&P', 'existing', 75.0, 'Asia', true, 'admin@example.com'),
    
    -- Growth OPUs
    ('existing_assets', 'LNGC2', 'LNGA', 'growth', 100.0, 'Global', true, 'admin@example.com'),
    ('existing_assets', 'Suriname F2', 'LNGA', 'growth', 50.0, 'South America', true, 'admin@example.com'),
    ('existing_assets', 'Lake Charles', 'LNGA', 'growth', 25.0, 'North America', true, 'admin@example.com'),
    ('existing_assets', 'Calathea', 'G&P', 'growth', 40.0, 'Africa', true, 'admin@example.com'),
    ('existing_assets', 'Asters', 'G&P', 'growth', 30.0, 'Asia', true, 'admin@example.com')
ON CONFLICT (scenario_name, opu, user_email) 
DO UPDATE SET 
    bu = EXCLUDED.bu,
    type = EXCLUDED.type,
    base_equity_pct = EXCLUDED.base_equity_pct,
    region = EXCLUDED.region,
    active = EXCLUDED.active,
    updated_at = now();
