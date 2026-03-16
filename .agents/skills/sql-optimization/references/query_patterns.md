# SQL Query Optimization Patterns

Real-world query optimization patterns for common bottlenecks.

## Index Design Checklist

**When to index:**
- High-cardinality columns (customer_id, user_id, event_date)
- Columns in WHERE, JOIN, GROUP BY
- Large tables (>100M rows)

**When NOT to index:**
- Low cardinality (<100 distinct values)
- Small tables (<10k rows)
- Write-heavy tables (OLTP with heavy inserts)

## Composite Index Examples

```sql
-- Orders table: frequent queries on status, order_date, customer_id
CREATE INDEX idx_orders_status_date_customer 
ON orders (status, order_date DESC, customer_id);

-- Covering index (includes amount for SELECT without table scan)
CREATE INDEX idx_orders_covering 
ON orders (order_date DESC, customer_id) 
INCLUDE (amount, currency);
```

## Query Pattern Benchmarks

**N+1 Anti-pattern:**
```sql
-- BAD: Loop via application
SELECT customer_id FROM customers; -- 1000 rows
-- App loops: SELECT * FROM orders WHERE customer_id = ? (1000 queries)

-- GOOD: Single join
SELECT c.customer_id, COUNT(o.order_id) as order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;
```

**Batch operations:**
```sql
-- Prefer batch over row-by-row
INSERT INTO archive_orders 
SELECT * FROM orders 
WHERE created_at < CURRENT_DATE - INTERVAL 365 DAY;
-- vs INSERT 1 row at a time (1000x slower)
```

## Execution Plan Analysis (EXPLAIN ANALYZE)

```sql
-- PostgreSQL
EXPLAIN ANALYZE
SELECT o.order_id, c.name, sum(oi.quantity)
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.created_at >= '2025-01-01'
GROUP BY 1, 2;

-- Look for:
-- - Seq Scan (full table) on large tables → add index
-- - Hash Join cost > Nested Loop → consider partition or index
-- - Sort/Aggregate taking >50% of cost → add ORDER BY to index
```

## Partitioning Strategy

```sql
-- PostgreSQL Range Partition
CREATE TABLE orders_partitioned (
 order_id BIGINT,
 created_at DATE,
 ...
) PARTITION BY RANGE (YEAR(created_at), MONTH(created_at));

CREATE TABLE orders_2025_01 PARTITION OF orders_partitioned
 FOR VALUES FROM (2025, 1) TO (2025, 2);

-- BigQuery Clustering
CREATE TABLE orders_clustered (
 order_id INT,
 customer_id INT,
 created_at DATE,
 amount DECIMAL
)
CLUSTER BY customer_id, created_at;
```

## Query Rewrite Examples

**Slow: Correlated subquery**
```sql
SELECT order_id, customer_id,
 (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.order_id) as item_count
FROM orders o;
```

**Fast: Window function**
```sql
SELECT order_id, customer_id,
 COUNT(*) OVER (PARTITION BY order_id) as item_count
FROM orders o
JOIN order_items oi USING (order_id);
```
