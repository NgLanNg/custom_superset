# Data Quality Checklist (Great Expectations)

Practical checklist for building Great Expectations suites and dbt tests.

## Data Quality Dimensions

| Dimension | Definition | dbt Test | GE Expectation |
|-----------|-----------|----------|----------------|
| **Completeness** | No nulls in critical columns | `not_null` | `expect_column_values_to_not_be_null` |
| **Uniqueness** | No duplicate keys | `unique` | `expect_column_values_to_be_unique` |
| **Validity** | Values conform to format (email, date, int) | `accepted_values` | `expect_column_values_to_match_regex` |
| **Consistency** | Data type consistency across sources | N/A | `expect_column_values_to_be_of_type` |
| **Accuracy** | Values match business rules (age > 0) | `dbt_utils.expression_is_true` | `expect_column_values_to_be_between` |
| **Timeliness** | Data loaded within SLA | `source_freshness` | `expect_table_row_count_to_equal_other_table` |
| **Referential Integrity** | FK exists in parent | `relationships` | `expect_column_pair_values_A_to_be_in_B` |

## dbt Test Manifest

```yaml
# models/staging/stg_customers.yml
version: 2
models:
 - name: stg_customers
 description: Raw customer data with basic validation
 columns:
 - name: customer_id
 description: Primary key
 tests:
 - unique
 - not_null
 - name: email
 tests:
 - not_null
 - dbt_utils.expression_is_true:
 expression: "email LIKE '%@%.%'"
 - name: age
 tests:
 - dbt_utils.expression_is_true:
 expression: "age >= 0 AND age <= 150"
```

## Great Expectations Suite Template

```python
# conf/expectations/customers_suite.json
{
 "expectation_suite_name": "customers_suite",
 "expectations": [
 {
 "expectation_type": "expect_table_columns_to_match_set",
 "kwargs": {
 "column_set": ["customer_id", "email", "age", "created_at"]
 }
 },
 {
 "expectation_type": "expect_column_values_to_not_be_null",
 "kwargs": {"column": "customer_id"}
 },
 {
 "expectation_type": "expect_column_values_to_be_unique",
 "kwargs": {"column": "customer_id"}
 },
 {
 "expectation_type": "expect_column_values_to_match_regex",
 "kwargs": {
 "column": "email",
 "regex": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
 }
 }
 ]
}
```

## Freshness SLA Definition

```yaml
sources:
 - name: raw_stripe
 tables:
 - name: payments
 freshness:
 warn_after: {count: 4, period: hour}
 error_after: {count: 6, period: hour}
 loaded_at_field: ingested_at
```

## Data Contract (Schema + SLA)

```yaml
contracts:
 - name: fct_orders
 owner: analytics-team
 sla:
 freshness: 4 hours
 completeness: 99.9%
 schema:
 order_id:
 type: int
 not_null: true
 unique: true
 customer_id:
 type: int
 not_null: true
 references: dim_customers.customer_id
 amount:
 type: decimal
 constraints:
 - "> 0"
```

## Anomaly Detection Baseline

```sql
-- Set baseline for rate-of-change detection
WITH daily_counts AS (
 SELECT
 DATE_TRUNC('day', created_at) as event_date,
 COUNT(*) as daily_count,
 STDDEV(daily_count) OVER (
 ORDER BY DATE_TRUNC('day', created_at)
 ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
 ) as rolling_std
 FROM orders
 WHERE created_at >= CURRENT_DATE - 60
 GROUP BY 1
)
SELECT
 event_date,
 daily_count,
 rolling_std,
 CASE
 WHEN ABS(daily_count - LAG(daily_count) OVER (ORDER BY event_date))
 > 3 * rolling_std THEN 'ANOMALY'
 ELSE 'OK'
 END as status
FROM daily_counts
ORDER BY event_date DESC;
```
