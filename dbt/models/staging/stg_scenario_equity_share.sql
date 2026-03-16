SELECT
  id,
  scenario_name,
  bu,
  opu,
  year,
  value::NUMERIC(5,2) AS equity_pct,
  scenario_id,
  user_email,
  updated_at,
  file_path
FROM {{ source('superset', 'silver_scenario_equity_share') }}
