---
name: sql-optimization
description: SQL query optimization, execution plan analysis, indexing strategies, and performance tuning for PostgreSQL, Snowflake, BigQuery, and other analytical databases
---

# SQL Optimization Skill

Query performance tuning, index design, execution plan analysis, and database optimization patterns.

## When to Use

- Slow queries (>1 second for OLTP, >30 seconds for analytics)
- High database CPU or I/O usage
- Designing indexes for new tables
- Analyzing execution plans (EXPLAIN)
- Optimizing JOIN operations
- Reducing table scans
- Implementing query caching strategies
- Partitioning large tables
- Troubleshooting N+1 query problems

## Quick Reference

### Performance Targets

| Query Type | Target Latency | Notes |
|------------|----------------|-------|
| OLTP (row lookups) | < 10ms | Index required |
| Simple aggregations | < 100ms | Use indexes |
| Complex analytics | < 5s | Materialized views |
| Batch ETL | < 30s per batch | Optimize for throughput |

### Index Cheat Sheet

| Query Pattern | Index Type | Example |
|--------------|------------|---------|
| `WHERE col = value` | B-tree (default) | `CREATE INDEX idx ON t (col)` |
| `WHERE a = x AND b = y` | Composite | `CREATE INDEX idx ON t (a, b)` |
| `WHERE jsonb @> '{}'` | GIN | `CREATE INDEX idx ON t USING gin (col)` |
| `WHERE tsv @@ query` | Full-text | `CREATE INDEX idx ON t USING gin (tsv)` |
| Time-series ranges | BRIN | `CREATE INDEX idx ON t USING brin (ts)` |

### Common Anti-Patterns

```sql
-- BAD: OFFSET pagination (O(n) scan)
SELECT * FROM products ORDER BY id LIMIT 20 OFFSET 199980;

-- GOOD: Cursor-based (O(1) lookup)
SELECT * FROM products WHERE id > 199980 ORDER BY id LIMIT 20;
```

```sql
-- BAD: Function on indexed column (can't use index)
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- GOOD: Functional index or store lowercase
CREATE INDEX idx ON users (LOWER(email));
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';
```

```sql
-- BAD: SELECT * (reads unnecessary columns)
SELECT * FROM orders WHERE user_id = 123;

-- GOOD: Select only needed columns
SELECT id, total, created_at FROM orders WHERE user_id = 123;
```

## Execution Plan Analysis (EXPLAIN)

### PostgreSQL

```sql
-- Basic execution plan
EXPLAIN SELECT * FROM orders WHERE user_id = 123;

-- With actual timing and row counts
EXPLAIN ANALYZE 
SELECT o.id, u.name, o.total
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE o.created_at > '2024-01-01';
```

#### Reading EXPLAIN Output

```
Nested Loop (cost=0.85..16.88 rows=1 width=68) (actual time=0.123..0.456 rows=5 loops=1)
 -> Index Scan using orders_user_id_idx on orders o
 Index Cond: (user_id = 123)
 Filter: (created_at > '2024-01-01')
 Rows Removed by Filter: 10
 -> Index Scan using users_pkey on users u
 Index Cond: (id = o.user_id)

Planning Time: 0.234 ms
Execution Time: 0.567 ms
```

**Key Metrics:**
- **cost**: Estimated cost (startup..total)
- **rows**: Estimated row count
- **actual time**: Real execution time (ms)
- **Index Scan**: Good (uses index)
- **Seq Scan**: Warning (full table scan)
- **Nested Loop**: Join algorithm
- **Planning Time**: Query optimization time
- **Execution Time**: Actual runtime

### Snowflake

```sql
-- Query profile (run query first, then check web UI)
SELECT * FROM orders WHERE user_id = 123;

-- View query history
SELECT query_id, query_text, execution_time
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE execution_time > 10000 -- 10 seconds
ORDER BY execution_time DESC
LIMIT 10;
```

### BigQuery

```sql
-- Dry run to estimate bytes scanned
SELECT *
FROM `project.dataset.orders`
WHERE user_id = 123;
-- Check "Bytes processed" in console

-- View query execution details
SELECT *
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE creation_time > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
ORDER BY total_bytes_processed DESC;
```

## Index Design Patterns

### Composite Index Order

**Rule**: Equality columns first, then range columns

```sql
-- GOOD: Supports WHERE status = 'active' AND created_at > '2024-01-01'
CREATE INDEX idx ON orders (status, created_at);

-- BAD: Can only use created_at part of index
CREATE INDEX idx ON orders (created_at, status);
```

### Covering Index (Include Columns)

Avoid table lookups:

```sql
-- PostgreSQL
CREATE INDEX idx ON users (email) INCLUDE (name, created_at);

-- Query can use index-only scan (no table access)
SELECT email, name, created_at
FROM users
WHERE email = 'user@example.com';
```

### Partial Index

Smaller, faster indexes for filtered queries:

```sql
-- Only index active users
CREATE INDEX idx ON users (email) WHERE deleted_at IS NULL;

-- Index for recent orders only
CREATE INDEX idx ON orders (created_at) 
WHERE created_at > CURRENT_DATE - INTERVAL '30 days';
```

### Unique Constraints as Indexes

```sql
-- Creates implicit index
ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE (email);

-- Equivalent to:
CREATE UNIQUE INDEX users_email_idx ON users (email);
```

## Query Optimization Patterns

### JOIN Optimization

```sql
-- GOOD: Index foreign keys
CREATE INDEX idx_orders_user_id ON orders (user_id);
CREATE INDEX idx_order_items_order_id ON order_items (order_id);

-- GOOD: JOIN on indexed columns
SELECT o.id, u.name, COUNT(oi.id) as item_count
FROM orders o
JOIN users u ON o.user_id = u.id
LEFT JOIN order_items oi ON oi.order_id = o.id
WHERE o.created_at > '2024-01-01'
GROUP BY o.id, u.name;
```

### Avoiding N+1 Queries

```sql
-- BAD: N+1 (1 query + N queries for each user)
-- Application code:
for user in users:
 orders = db.query("SELECT * FROM orders WHERE user_id = ?", user.id)

-- GOOD: Single query with JOIN
SELECT u.id, u.name, o.id as order_id, o.total
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.active = true;
```

### Batch Operations

```sql
-- BAD: Individual inserts (1000 round trips)
INSERT INTO events (user_id, action) VALUES (1, 'click');
INSERT INTO events (user_id, action) VALUES (2, 'view');
-- ...repeat 998 more times

-- GOOD: Batch insert (1 round trip)
INSERT INTO events (user_id, action) VALUES
 (1, 'click'),
 (2, 'view'),
 (3, 'click'),
 -- ...
 (1000, 'purchase');

-- BEST: COPY for large datasets (PostgreSQL)
COPY events FROM '/path/to/data.csv' WITH (FORMAT csv, HEADER true);
```

### Aggregation Optimization

```sql
-- BAD: Subquery in SELECT (runs for each row)
SELECT 
 user_id,
 (SELECT COUNT(*) FROM orders WHERE orders.user_id = users.id) as order_count
FROM users;

-- GOOD: JOIN with aggregation
SELECT 
 u.user_id,
 COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.user_id;
```

## Partitioning Strategies

### Time-Based Partitioning (PostgreSQL)

```sql
-- Create partitioned table
CREATE TABLE events (
 id BIGINT GENERATED ALWAYS AS IDENTITY,
 user_id BIGINT NOT NULL,
 event_time TIMESTAMPTZ NOT NULL,
 event_data JSONB
) PARTITION BY RANGE (event_time);

-- Create monthly partitions
CREATE TABLE events_2024_01 PARTITION OF events
 FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE events_2024_02 PARTITION OF events
 FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Index each partition
CREATE INDEX ON events_2024_01 (user_id, event_time);
CREATE INDEX ON events_2024_02 (user_id, event_time);

-- Drop old partitions instantly
DROP TABLE events_2023_01; -- Instant vs DELETE (hours)
```

### Partitioning in Snowflake

```sql
-- Cluster key (like partitioning)
CREATE TABLE events (
 id NUMBER,
 user_id NUMBER,
 event_time TIMESTAMP_NTZ,
 event_data VARIANT
)
CLUSTER BY (DATE_TRUNC('day', event_time), user_id);

-- Automatic clustering maintenance
ALTER TABLE events RESUME RECLUSTER;
```

### Partitioning in BigQuery

```sql
-- Partition by date column
CREATE TABLE `project.dataset.events`
PARTITION BY DATE(event_time)
CLUSTER BY user_id, event_type
AS
SELECT * FROM source_table;

-- Query with partition filter (cheaper)
SELECT *
FROM `project.dataset.events`
WHERE DATE(event_time) = '2024-01-15' -- Uses partition pruning
 AND user_id = 123;
```

## Materialized Views

Pre-compute expensive aggregations:

### PostgreSQL

```sql
-- Create materialized view
CREATE MATERIALIZED VIEW daily_metrics AS
SELECT 
 DATE_TRUNC('day', created_at) as date,
 COUNT(*) as order_count,
 SUM(total) as total_revenue,
 AVG(total) as avg_order_value
FROM orders
GROUP BY DATE_TRUNC('day', created_at);

-- Create index on materialized view
CREATE INDEX ON daily_metrics (date);

-- Refresh (blocking)
REFRESH MATERIALIZED VIEW daily_metrics;

-- Refresh concurrently (non-blocking, requires unique index)
CREATE UNIQUE INDEX ON daily_metrics (date);
REFRESH MATERIALIZED VIEW CONCURRENTLY daily_metrics;
```

### Snowflake

```sql
-- Dynamic table (auto-refreshing materialized view)
CREATE DYNAMIC TABLE daily_metrics
 TARGET_LAG = '1 hour'
 WAREHOUSE = compute_wh
AS
SELECT 
 DATE_TRUNC('day', created_at) as date,
 COUNT(*) as order_count,
 SUM(total) as total_revenue
FROM orders
GROUP BY DATE_TRUNC('day', created_at);
```

## Database-Specific Optimizations

### PostgreSQL

```sql
-- Analyze table statistics (after bulk loads)
ANALYZE orders;

-- Vacuum to reclaim space and update stats
VACUUM ANALYZE orders;

-- Check bloat
SELECT 
 schemaname,
 tablename,
 pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
 n_dead_tup
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;

-- Configure connection pooling
ALTER SYSTEM SET max_connections = 100;
ALTER SYSTEM SET shared_buffers = '4GB';
ALTER SYSTEM SET effective_cache_size = '12GB';
ALTER SYSTEM SET work_mem = '16MB';
SELECT pg_reload_conf();
```

### Snowflake

```sql
-- Enable result caching
ALTER SESSION SET USE_CACHED_RESULT = TRUE;

-- Optimize warehouse size
ALTER WAREHOUSE compute_wh SET WAREHOUSE_SIZE = 'LARGE';

-- Partition pruning (automatic with cluster keys)
-- Query only scans relevant micro-partitions

-- Search optimization service
ALTER TABLE events ADD SEARCH OPTIMIZATION ON EQUALITY(user_id);
```

### BigQuery

```sql
-- Partition and cluster tables
CREATE TABLE `project.dataset.events`
PARTITION BY DATE(event_time)
CLUSTER BY user_id, event_type
AS SELECT * FROM source;

-- Avoid SELECT * (scans all columns)
SELECT id, user_id, event_time -- Only needed columns
FROM `project.dataset.events`;

-- Use approximate aggregations
SELECT APPROX_COUNT_DISTINCT(user_id) as unique_users
FROM `project.dataset.events`;

-- Cache query results (automatic for 24 hours)
-- Re-running same query uses cache
```

## Monitoring and Diagnostics

### Slow Query Log (PostgreSQL)

```sql
-- Enable slow query logging
ALTER SYSTEM SET log_min_duration_statement = 1000; -- 1 second
SELECT pg_reload_conf();

-- Find slow queries
SELECT 
 query,
 mean_exec_time,
 calls,
 total_exec_time
FROM pg_stat_statements
WHERE mean_exec_time > 1000
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### Index Usage Stats

```sql
-- Find unused indexes (PostgreSQL)
SELECT 
 schemaname,
 tablename,
 indexname,
 idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
 AND indexrelname NOT LIKE '%_pkey'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Find missing indexes on foreign keys
SELECT 
 conrelid::regclass as table_name,
 a.attname as column_name
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
WHERE c.contype = 'f'
 AND NOT EXISTS (
 SELECT 1 FROM pg_index i
 WHERE i.indrelid = c.conrelid 
 AND a.attnum = ANY(i.indkey)
 );
```

## Best Practices

### Development Workflow

1. **Profile first**: Use EXPLAIN ANALYZE before optimizing
2. **Index strategically**: Don't over-index (write performance cost)
3. **Test with real data**: Small datasets hide problems
4. **Monitor production**: Set up slow query alerts
5. **Version indexes**: Include version in index names for safe rollback

### Index Naming Convention

```sql
-- Pattern: idx_{table}_{columns}_{type}
CREATE INDEX idx_orders_user_id_created_at_btree ON orders (user_id, created_at);
CREATE INDEX idx_users_email_partial ON users (email) WHERE deleted_at IS NULL;
CREATE INDEX idx_events_data_gin ON events USING gin (event_data);
```

### Query Optimization Checklist

- [ ] Indexes on WHERE columns
- [ ] Indexes on JOIN columns
- [ ] Composite index order (equality → range)
- [ ] No functions on indexed columns
- [ ] SELECT only needed columns
- [ ] LIMIT results when possible
- [ ] Use EXPLAIN ANALYZE
- [ ] Avoid N+1 queries
- [ ] Batch operations (INSERT/UPDATE)
- [ ] Consider partitioning for large tables (>100M rows)

## Related Skills

- `dbt` - Analytics engineering and transformations
- `data-quality` - Validation and monitoring
- `databases` - PostgreSQL/Snowflake administration
- `postgres-patterns` - PostgreSQL-specific optimizations

## References

- [Use The Index, Luke](https://use-the-index-luke.com/) - SQL indexing guide
- [PostgreSQL Performance](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Snowflake Query Optimization](https://docs.snowflake.com/en/user-guide/query-optimization)
- [BigQuery Best Practices](https://cloud.google.com/bigquery/docs/best-practices-performance-overview)
- [Database Indexing Explained](https://www.postgresql.org/docs/current/indexes.html)
