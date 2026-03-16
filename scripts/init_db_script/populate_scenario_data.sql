INSERT INTO silver_scenario_equity_share (scenario_name, bu, opu, year, value, scenario_id, user_email) VALUES
-- MLNG
('existing_assets', 'LNGA', 'MLNG', 2020, 70, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'MLNG', 2021, 70, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'MLNG', 2022, 70, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'MLNG', 2023, 70, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'MLNG', 2024, 70, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'MLNG', 2025, 75, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'MLNG', 2026, 75, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'MLNG', 2027, 80, '', 'admin@example.com'),

-- LNGC2
('existing_assets', 'LNGA', 'LNGC2', 2020, 30, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC2', 2021, 30, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC2', 2022, 30, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC2', 2023, 30, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC2', 2024, 30, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC2', 2025, 40, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC2', 2026, 40, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC2', 2027, 40, '', 'admin@example.com'),

-- LNGC3
('existing_assets', 'LNGA', 'LNGC3', 2020, 10, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC3', 2021, 10, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC3', 2022, 10, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC3', 2023, 10, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC3', 2024, 15, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC3', 2025, 15, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC3', 2026, 20, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'LNGC3', 2027, 25, '', 'admin@example.com'),

-- ALNG
('existing_assets', 'LNGA', 'ALNG', 2020, 50, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'ALNG', 2021, 50, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'ALNG', 2022, 55, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'ALNG', 2023, 60, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'ALNG', 2024, 60, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'ALNG', 2025, 65, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'ALNG', 2026, 65, '', 'admin@example.com'),
('existing_assets', 'LNGA', 'ALNG', 2027, 70, '', 'admin@example.com')
ON CONFLICT(scenario_name, opu, year, scenario_id, user_email)
DO UPDATE SET value = excluded.value;
