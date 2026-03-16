-- Seed data for silver_scenario_growth_config
-- Using ON CONFLICT to avoid duplicate key errors if run multiple times

INSERT INTO silver_scenario_growth_config 
    (scenario_name, bu, project, fid_year, capacity_mtpa, capex_billion, status, user_email)
VALUES 
    ('existing_assets', 'LNGA', 'LNGC2', 2026, 4.5, 3.2, 'On Track', 'admin@example.com'),
    ('existing_assets', 'LNGA', 'Suriname F2', 2027, 2.8, 1.5, 'Delayed', 'admin@example.com'),
    ('existing_assets', 'LNGA', 'Lake Charles', 2025, 12.5, 10.0, 'On Track', 'admin@example.com'),
    ('existing_assets', 'G&P', 'Calathea', 2028, 5.0, 4.1, 'On Track', 'admin@example.com'),
    ('existing_assets', 'G&P', 'Asters', 2029, 3.5, 2.0, 'Delayed', 'admin@example.com')
ON CONFLICT (scenario_name, project, user_email) 
DO UPDATE SET 
    fid_year = EXCLUDED.fid_year,
    capacity_mtpa = EXCLUDED.capacity_mtpa,
    capex_billion = EXCLUDED.capex_billion,
    status = EXCLUDED.status,
    updated_at = now();
