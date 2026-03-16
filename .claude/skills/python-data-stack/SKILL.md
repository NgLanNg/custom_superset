---
name: python-data-stack
description: Python data workflows with pandas/polars/pyarrow/duckdb for analytics, quick pipelines, and validation. Use for dataframe transforms, local prototyping, ad-hoc pipelines, or wiring Python operators in Airflow/Dagster.
---

# Python Data Stack

## When to Use
- Ad-hoc transforms, profiling, or prototyping before formalizing in dbt/warehouse
- Python operators in Airflow/Dagster for lightweight data prep
- Converting between CSV/Parquet/Arrow, joining local + warehouse data, or experimenting with DuckDB/Polars

## Environment and Tooling
- Create virtualenv/poetry to pin deps; prefer `python -m pip install ...` and lock versions.
- Core libs: pandas, polars, pyarrow, duckdb, sqlalchemy; validation: pandera or great_expectations; testing: pytest.
- Prefer Parquet/Arrow over CSV for schema and speed; set dtype explicitly to avoid implicit casts.

## Quick Patterns

### pandas essentials
```python
import pandas as pd
df = pd.read_parquet("data.parquet")
df["order_date"] = pd.to_datetime(df["order_date"], utc=True)
df = df.assign(net=lambda d: d["gross"] - d["discount"])
# Chunked CSV read to cap memory
iter_df = pd.read_csv("events.csv", chunksize=200_000, dtype={"user_id": "int64"})
```

### polars (fast, lazy, zero-copy)
```python
import polars as pl
scan = pl.scan_parquet("s3://bucket/events/*.parquet")
result = (
 scan
 .filter(pl.col("event_date") >= pl.date(2025, 1, 1))
 .group_by("user_id")
 .agg(pl.col("amount").sum().alias("spend"))
)
df = result.collect() # or .collect(streaming=True) for larger-than-RAM
# Sink directly to disk without materializing in RAM
result.sink_parquet("output.parquet")
```

### Zero-copy interoperability via Arrow
```python
import polars as pl
import duckdb
# Load in Polars, hand to DuckDB zero-copy via Arrow
df_pl = pl.scan_parquet("data.parquet").collect()
rel = duckdb.sql("SELECT * FROM df_pl WHERE value > 100")
arrow_tbl = rel.to_arrow_table()
final_df = pl.from_arrow(arrow_tbl) # back to Polars
```

### duckdb for SQL over files
```python
import duckdb
con = duckdb.connect()
con.execute("SET enable_progress_bar=true")
df = con.execute(
	"""
	SELECT user_id, sum(amount) AS spend
	FROM read_parquet('s3://bucket/events/*.parquet')
	WHERE event_date >= '2025-01-01'
	GROUP BY 1
	"""
).df()
```

### Parquet partitioning and predicate pushdown
```python
# Write Hive-style partitioned dataset
df.write_parquet(
	"dataset/",
	partition_by=["year", "month"],
	use_pyarrow=True
)
# Scan with predicate pushdown (reads only necessary files)
q = pl.scan_parquet("dataset/") \
	.filter(pl.col("year") == 2023) \
	.select(["id", "value"])
print(q.explain()) # verify FILTER pushed to scan
```

### DuckDB ASOF joins for time-series
```python
import pandas as pd
import duckdb
trades = pd.DataFrame(...)
quotes = pd.DataFrame(...)
# Find previous quote for every trade efficiently
result = duckdb.sql("""
SELECT t.time, t.symbol, t.price, q.bid, q.ask
FROM trades t
ASOF JOIN quotes q
 ON t.symbol = q.symbol
 AND t.time >= q.time
""").df()
```

### IO and connectors
- Use SQLAlchemy URLs for warehouses; fetch in chunks to avoid OOM.
- When writing, prefer Parquet with `compression='zstd'`; validate schema before writing.

## Performance and Memory
- Favor vectorized ops over `DataFrame.apply`; in pandas use `.map`/`.str`/`.dt` accessors.
- Use categoricals for low-cardinality strings; drop unused columns early.
- For large joins, push work to duckdb/polars or the warehouse; avoid full in-memory joins when data is large.
- Profile with `%timeit` or built-in timers; watch memory via `df.memory_usage(deep=True)`.

## Validation and Testing
- Add fast checks: `df.isna().mean()` for null rates, `df.duplicated(subset=[...]).sum()` for key dupes.
- Use pandera or Great Expectations for schema validation before write.
- Keep small sample fixtures for pytest; seed randomness for reproducibility.

### Unit testing transformation logic
```python
from polars.testing import assert_frame_equal
import pytest

def clean_data(df):
	return df.with_columns(pl.col("name").str.to_uppercase())

def test_clean_data():
	input_df = pl.DataFrame({"name": ["alice"]})
	expected_df = pl.DataFrame({"name": ["ALICE"]})
	result_df = clean_data(input_df)
	assert_frame_equal(result_df, expected_df)
```

### Unit testing transformation logic
```python
from polars.testing import assert_frame_equal
import pytest

def clean_data(df):
 return df.with_columns(pl.col("name").str.to_uppercase())

def test_clean_data():
 input_df = pl.DataFrame({"name": ["alice"]})
 expected_df = pl.DataFrame({"name": ["ALICE"]})
 result_df = clean_data(input_df)
 assert_frame_equal(result_df, expected_df)
```

## Packaging for Pipelines
- Wrap transforms as functions accepting paths/URLs and emitting Parquet; keep pure and idempotent.
- For Airflow, keep operators thin; move heavy logic to modules; avoid large XComs (write to file/S3 instead).
- Log row counts and simple stats; return metadata (path, rows_written) for downstream tasks.

## Related Skills
- dbt (production models), data-quality (tests), sql-optimization (query tuning), etl-pipelines (orchestration), data-modeling (grain and schema decisions).
