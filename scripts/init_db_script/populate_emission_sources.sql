-- Seed data for silver_emission_by_sources
-- Baseline scenario data for existing OPUs (LNGA, G&P)
-- Years 2019-2030, Scope 1 + Scope 2, key emission sources

INSERT INTO silver_emission_by_sources (bu, opu, scope, source, year, value, type, scenario_id, user_email)
VALUES
-- LNGA / MLNG / Scope 1
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2019, 1250.5, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2020, 1230.0, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2021, 1210.3, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2022, 1195.8, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2023, 1180.2, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2024, 1165.7, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2025, 1150.0, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2026, 1135.4, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2027, 1120.9, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2028, 1106.3, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2029, 1091.8, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Combustion', 2030, 1077.2, 'operational_control', 'base', ''),

('LNGA', 'MLNG', 'Scope 1', 'Venting', 2019, 320.1, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2020, 315.4, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2021, 310.7, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2022, 306.0, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2023, 301.3, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2024, 296.6, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2025, 291.9, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2026, 287.2, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2027, 282.5, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2028, 277.8, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2029, 273.1, 'operational_control', 'base', ''),
('LNGA', 'MLNG', 'Scope 1', 'Venting', 2030, 268.4, 'operational_control', 'base', ''),

-- LNGA / PFLNG 1 / Scope 1
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2019, 450.2, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2020, 442.5, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2021, 434.8, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2022, 427.1, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2023, 419.4, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2024, 411.7, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2025, 404.0, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2026, 396.3, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2027, 388.6, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2028, 380.9, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2029, 373.2, 'operational_control', 'base', ''),
('LNGA', 'PFLNG 1', 'Scope 1', 'Combustion', 2030, 365.5, 'operational_control', 'base', ''),

-- G&P / SARAWAK GAS / Scope 1
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2019, 890.6, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2020, 875.3, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2021, 860.0, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2022, 844.7, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2023, 829.4, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2024, 814.1, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2025, 798.8, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2026, 783.5, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2027, 768.2, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2028, 752.9, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2029, 737.6, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Combustion', 2030, 722.3, 'operational_control', 'base', ''),

('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2019, 150.3, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2020, 147.8, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2021, 145.3, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2022, 142.8, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2023, 140.3, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2024, 137.8, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2025, 135.3, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2026, 132.8, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2027, 130.3, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2028, 127.8, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2029, 125.3, 'operational_control', 'base', ''),
('G&P', 'SARAWAK GAS', 'Scope 1', 'Fugitive', 2030, 122.8, 'operational_control', 'base', ''),

-- MISC / PETRONAS GAS / Scope 2
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2019, 210.4, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2020, 205.9, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2021, 201.4, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2022, 196.9, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2023, 192.4, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2024, 187.9, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2025, 183.4, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2026, 178.9, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2027, 174.4, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2028, 169.9, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2029, 165.4, 'operational_control', 'base', ''),
('MISC', 'PETRONAS GAS', 'Scope 2', 'Electricity', 2030, 160.9, 'operational_control', 'base', '')

ON CONFLICT (bu, opu, scope, source, year, scenario_id, user_email) DO NOTHING;
