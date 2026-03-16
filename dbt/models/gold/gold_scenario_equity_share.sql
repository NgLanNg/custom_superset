WITH ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY scenario_name, opu, year
      ORDER BY updated_at DESC
    ) AS rn
  FROM {{ ref('stg_scenario_equity_share') }}
)
SELECT
  id,
  scenario_name,
  bu,
  opu,
  year,
  equity_pct,
  user_email,
  updated_at
FROM ranked
WHERE rn = 1
