CREATE OR REPLACE VIEW public.v_scenario_equity_share AS
SELECT
  scenario_name AS "Scenario",
  bu AS "Business Unit",
  opu AS "OPU",
  year AS "Year",
  equity_pct AS "Equity %",
  user_email AS "Last Modified By",
  updated_at AS "Last Modified"
FROM gold_scenario_equity_share;
