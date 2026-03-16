CREATE TABLE IF NOT EXISTS peth_prod.silver_scenario_equity_share (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_name text        NOT NULL,
  bu            text        NOT NULL,
  opu           text        NOT NULL,
  year          integer     NOT NULL,
  value         numeric     NOT NULL,
  scenario_id   text,
  user_email    text,
  updated_at    timestamptz DEFAULT now(),
  file_path     text,
  CONSTRAINT uq_scenario_opu_year UNIQUE (scenario_name, opu, year, scenario_id, user_email)
);

CREATE INDEX IF NOT EXISTS idx_scenario_equity_lookup
  ON peth_prod.silver_scenario_equity_share (scenario_name, bu, opu);
