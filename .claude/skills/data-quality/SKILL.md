---
name: data-quality
description: Data quality validation, monitoring, and testing patterns using dbt tests, Great Expectations, and custom validation rules
---

# Data Quality Skill

Comprehensive data quality validation, testing, and monitoring patterns for analytics pipelines.

## When to Use

- Validating data freshness and completeness
- Implementing data quality checks in pipelines
- Setting up anomaly detection for metrics
- Creating data contracts between teams
- Monitoring schema changes
- Testing referential integrity
- Validating business logic
- Setting up alerting for data quality issues
- Documenting data quality SLAs

## Quick Reference

### Data Quality Dimensions

| Dimension | Description | Example Test |
|-----------|-------------|--------------|
| **Completeness** | No missing values | `NOT NULL`, row count checks |
| **Uniqueness** | No duplicates | `UNIQUE`, `PRIMARY KEY` |
| **Validity** | Values within expected range | `BETWEEN 0 AND 100` |
| **Consistency** | Cross-column logic | Order total = sum(items) |
| **Timeliness** | Data freshness | Updated within 24 hours |
| **Accuracy** | Matches source of truth | Reconciliation checks |

### Test Severity Levels

```yaml
# dbt test configuration
models:
 - name: fct_orders
 tests:
 - row_count:
 severity: error # Pipeline fails
 - freshness:
 severity: warn # Alert but continue
```

## dbt Testing Patterns

### Schema Tests

```yaml
# models/_models.yml
version: 2

models:
 - name: fct_orders
 description: "Order fact table"
 
 # Table-level tests
 tests:
 - dbt_utils.expression_is_true:
 expression: "order_total = sum_item_total"
 
 - dbt_expectations.expect_table_row_count_to_be_between:
 min_value: 1000
 max_value: 1000000
 
 columns:
 - name: order_id
 description: "Unique order identifier"
 tests:
 - unique
 - not_null
 
 - name: user_id
 tests:
 - not_null
 - relationships:
 to: ref('dim_users')
 field: user_id
 
 - name: order_total
 tests:
 - not_null
 - dbt_expectations.expect_column_values_to_be_between:
 min_value: 0
 max_value: 1000000
 config:
 severity: error
 
 - name: order_status
 tests:
 - accepted_values:
 values: ['pending', 'completed', 'cancelled', 'refunded']
 
 - name: created_at
 tests:
 - not_null
 - dbt_expectations.expect_column_values_to_be_of_type:
 column_type: timestamp
```

### Custom SQL Tests

```sql
-- tests/assert_order_total_matches_items.sql
-- Returns rows that fail the test (any rows = test fails)

with order_totals as (
 select
 order_id,
 order_total,
 sum(item_price * quantity) as calculated_total
 from {{ ref('fct_orders') }} o
 left join {{ ref('fct_order_items') }} oi using (order_id)
 group by order_id, order_total
)

select *
from order_totals
where abs(order_total - calculated_total) > 0.01 -- Allow 1 cent rounding
```

```sql
-- tests/assert_no_future_dates.sql
select *
from {{ ref('fct_orders') }}
where created_at > current_timestamp
```

```sql
-- tests/assert_referential_integrity.sql
-- Check for orphaned records
select user_id
from {{ ref('fct_orders') }}
where user_id not in (select user_id from {{ ref('dim_users') }})
```

### dbt-expectations Package

Advanced validation library:

```yaml
# packages.yml
packages:
 - package: calogica/dbt_expectations
 version: 0.10.0
```

```yaml
# models/_models.yml
models:
 - name: fct_orders
 tests:
 # Row count validation
 - dbt_expectations.expect_table_row_count_to_be_between:
 min_value: 1000
 max_value: 100000
 
 # Column count validation
 - dbt_expectations.expect_table_column_count_to_equal:
 value: 10
 
 # Schema validation
 - dbt_expectations.expect_table_columns_to_match_ordered_list:
 column_list: ["order_id", "user_id", "order_total", "created_at"]
 
 columns:
 - name: email
 tests:
 # Email format validation
 - dbt_expectations.expect_column_values_to_match_regex:
 regex: "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
 
 - name: order_total
 tests:
 # Statistical validation
 - dbt_expectations.expect_column_mean_to_be_between:
 min_value: 50
 max_value: 200
 
 - dbt_expectations.expect_column_stdev_to_be_between:
 min_value: 10
 max_value: 100
 
 - name: created_at
 tests:
 # Freshness check
 - dbt_expectations.expect_column_values_to_be_increasing:
 sort_column: order_id
```

### Generic Tests (Reusable)

```sql
-- macros/tests/test_positive_values.sql
{% test positive_values(model, column_name) %}

select {{ column_name }}
from {{ model }}
where {{ column_name }} <= 0

{% endtest %}
```

Usage:
```yaml
columns:
 - name: order_total
 tests:
 - positive_values
```

```sql
-- macros/tests/test_valid_date_range.sql
{% test valid_date_range(model, column_name, start_date, end_date) %}

select {{ column_name }}
from {{ model }}
where {{ column_name }} < '{{ start_date }}'
 or {{ column_name }} > '{{ end_date }}'

{% endtest %}
```

Usage:
```yaml
columns:
 - name: created_at
 tests:
 - valid_date_range:
 start_date: '2020-01-01'
 end_date: '2030-12-31'
```

## Great Expectations Patterns

### Setup

```python
import great_expectations as gx
import great_expectations.expectations as gxe

context = gx.get_context()

# Create Data Source
datasource = context.data_sources.add_postgres(
 name="analytics_db",
 connection_string="postgresql://user:pass@localhost/analytics"
)

# Create Data Asset
data_asset = datasource.add_table_asset(
 name="orders",
 table_name="fct_orders"
)

# Create Batch Definition
batch_definition = data_asset.add_batch_definition_whole_table("batch_def")
batch = batch_definition.get_batch()
```

### Expectation Suite

```python
# Create Expectation Suite
suite = context.suites.add(
 gx.ExpectationSuite(name="orders_quality_checks")
)

# Completeness checks
suite.add_expectation(
 gxe.ExpectColumnValuesToNotBeNull(column="order_id")
)

suite.add_expectation(
 gxe.ExpectColumnValuesToNotBeNull(
 column="user_id",
 mostly=0.95 # Allow 5% nulls
 )
)

# Uniqueness checks
suite.add_expectation(
 gxe.ExpectColumnValuesToBeUnique(column="order_id")
)

# Value range checks
suite.add_expectation(
 gxe.ExpectColumnValuesToBeBetween(
 column="order_total",
 min_value=0,
 max_value=1000000
 )
)

# Categorical checks
suite.add_expectation(
 gxe.ExpectColumnValuesToBeInSet(
 column="status",
 value_set=['pending', 'completed', 'cancelled', 'refunded']
 )
)

# Statistical checks
suite.add_expectation(
 gxe.ExpectColumnMeanToBeBetween(
 column="order_total",
 min_value=50,
 max_value=200
 )
)

# Schema checks
suite.add_expectation(
 gxe.ExpectTableColumnsToMatchOrderedList(
 column_list=["order_id", "user_id", "order_total", "created_at"]
 )
)

# Freshness checks
suite.add_expectation(
 gxe.ExpectColumnMaxToBeBetween(
 column="created_at",
 min_value="2024-01-01",
 max_value=None # No upper bound
 )
)
```

### Validation

```python
# Create Validation Definition
validation_definition = gx.ValidationDefinition(
 name="orders_validation",
 data=batch_definition,
 suite=suite
)

context.validation_definitions.add(validation_definition)

# Run validation
results = batch.validate(suite)

# Check results
print(f"Validation passed: {results.success}")

for result in results.results:
 expectation = result.expectation_config.type
 passed = result.success
 print(f"{expectation}: {'✓' if passed else '✗'}")
```

### Checkpoint (Automation)

```python
from great_expectations.checkpoint import UpdateDataDocsAction

# Create Checkpoint
checkpoint = context.checkpoints.add(
 gx.Checkpoint(
 name="daily_orders_check",
 validation_definitions=[validation_definition],
 actions=[
 UpdateDataDocsAction(name="update_data_docs")
 ]
 )
)

# Run checkpoint
checkpoint_result = checkpoint.run()
```

## Freshness Monitoring

### dbt Source Freshness

```yaml
# models/staging/_sources.yml
version: 2

sources:
 - name: raw_data
 database: production
 schema: public
 
 freshness:
 warn_after: {count: 12, period: hour}
 error_after: {count: 24, period: hour}
 
 tables:
 - name: orders
 description: "Raw orders from production database"
 loaded_at_field: _synced_at
 
 freshness:
 warn_after: {count: 2, period: hour}
 error_after: {count: 6, period: hour}
```

Check freshness:
```bash
dbt source freshness
```

### Custom Freshness Tests

```sql
-- tests/assert_data_is_fresh.sql
with latest_record as (
 select max(created_at) as max_time
 from {{ ref('fct_orders') }}
)

select *
from latest_record
where max_time < current_timestamp - interval '24 hours'
```

## Anomaly Detection

### Statistical Anomaly Detection

```sql
-- tests/assert_order_volume_within_range.sql
-- Detect anomalous daily order counts

with daily_counts as (
 select
 date_trunc('day', created_at) as date,
 count(*) as order_count
 from {{ ref('fct_orders') }}
 where created_at >= current_date - interval '30 days'
 group by 1
),

stats as (
 select
 avg(order_count) as mean_count,
 stddev(order_count) as std_count
 from daily_counts
),

today as (
 select count(*) as today_count
 from {{ ref('fct_orders') }}
 where date_trunc('day', created_at) = current_date
)

select *
from today, stats
where today_count < (mean_count - 3 * std_count) -- More than 3 std devs below mean
 or today_count > (mean_count + 3 * std_count) -- More than 3 std devs above mean
```

### Rate of Change Detection

```sql
-- tests/assert_order_growth_within_bounds.sql
with daily_counts as (
 select
 date_trunc('day', created_at) as date,
 count(*) as order_count
 from {{ ref('fct_orders') }}
 where created_at >= current_date - interval '7 days'
 group by 1
 order by 1
),

growth_rates as (
 select
 date,
 order_count,
 lag(order_count) over (order by date) as prev_count,
 (order_count - lag(order_count) over (order by date))::float 
 / nullif(lag(order_count) over (order by date), 0) as growth_rate
 from daily_counts
)

select *
from growth_rates
where abs(growth_rate) > 0.50 -- Alert if >50% change day-over-day
```

## Data Contracts

Define expectations as contracts between data producers and consumers:

### Contract Definition (YAML)

```yaml
# contracts/orders_contract.yml
version: 1

data_asset: fct_orders

owner: data-engineering@company.com

sla:
 freshness: 6 hours
 completeness: 99.5%
 availability: 99.9%

schema:
 columns:
 - name: order_id
 type: bigint
 nullable: false
 unique: true
 description: "Unique order identifier"
 
 - name: user_id
 type: bigint
 nullable: false
 references: dim_users.user_id
 
 - name: order_total
 type: numeric(10,2)
 nullable: false
 constraints:
 min: 0
 max: 1000000
 
 - name: status
 type: varchar(20)
 nullable: false
 allowed_values: ['pending', 'completed', 'cancelled', 'refunded']
 
 - name: created_at
 type: timestamp
 nullable: false

business_rules:
 - name: total_matches_items
 description: "Order total equals sum of item prices"
 sql: "order_total = (SELECT sum(price * quantity) FROM order_items WHERE order_id = orders.order_id)"
 
 - name: no_future_orders
 description: "No orders in the future"
 sql: "created_at <= current_timestamp"
```

### Automated Contract Validation

```python
# validate_contract.py
import yaml
import great_expectations as gx

def validate_contract(contract_file, batch):
 """Validate data against contract specification"""
 
 with open(contract_file) as f:
 contract = yaml.safe_load(f)
 
 suite = gx.ExpectationSuite(name=f"{contract['data_asset']}_contract")
 
 # Schema validation
 for col in contract['schema']['columns']:
 if not col['nullable']:
 suite.add_expectation(
 gxe.ExpectColumnValuesToNotBeNull(column=col['name'])
 )
 
 if col.get('unique'):
 suite.add_expectation(
 gxe.ExpectColumnValuesToBeUnique(column=col['name'])
 )
 
 if 'allowed_values' in col:
 suite.add_expectation(
 gxe.ExpectColumnValuesToBeInSet(
 column=col['name'],
 value_set=col['allowed_values']
 )
 )
 
 if 'constraints' in col:
 suite.add_expectation(
 gxe.ExpectColumnValuesToBeBetween(
 column=col['name'],
 min_value=col['constraints'].get('min'),
 max_value=col['constraints'].get('max')
 )
 )
 
 # Run validation
 results = batch.validate(suite)
 return results
```

## Monitoring and Alerting

### dbt Cloud Integration

```yaml
# dbt_project.yml
on-run-end:
 - "{{ log_test_results() }}" # Custom macro to log failures
 
 # Send to monitoring system
 - "{{ send_test_failures_to_datadog() }}"
```

```sql
-- macros/monitoring.sql
{% macro log_test_failures() %}
 {% if execute %}
 {% set test_results = run_query("
 SELECT *
 FROM " ~ target.schema ~ ".test_results
 WHERE status = 'fail'
 ") %}
 
 {% if test_results %}
 {{ log("Test failures detected:", info=true) }}
 {{ log(test_results, info=true) }}
 {% endif %}
 {% endif %}
{% endmacro %}
```

### Slack Notifications

```python
# airflow_dag.py
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.providers.slack.operators.slack_webhook import SlackWebhookOperator

def check_dbt_test_results():
 """Parse dbt test results and raise if failures"""
 import json
 
 with open('target/run_results.json') as f:
 results = json.load(f)
 
 failures = [r for r in results['results'] if r['status'] == 'fail']
 
 if failures:
 raise ValueError(f"{len(failures)} tests failed")

with DAG('dbt_pipeline', ...) as dag:
 dbt_test = BashOperator(
 task_id='dbt_test',
 bash_command='dbt test'
 )
 
 check_results = PythonOperator(
 task_id='check_results',
 python_callable=check_dbt_test_results
 )
 
 alert = SlackWebhookOperator(
 task_id='alert_failures',
 webhook_token='{{ var.value.slack_webhook }}',
 message='dbt tests failed! Check logs.',
 trigger_rule='one_failed'
 )
 
 dbt_test >> check_results >> alert
```

## Best Practices

### Test Coverage Strategy

1. **Critical tables**: 100% coverage (all columns tested)
2. **Mart tables**: 80% coverage (key columns + business logic)
3. **Staging tables**: 50% coverage (primary keys + not null)
4. **Intermediate tables**: 20% coverage (spot checks)

### Test Organization

```
tests/
├── generic/ # Reusable test macros
│ ├── test_positive_values.sql
│ └── test_valid_email.sql
├── relationships/ # Foreign key checks
│ ├── orders_user_id.sql
│ └── order_items_order_id.sql
├── business_logic/ # Custom business rules
│ ├── order_total_matches_items.sql
│ └── no_negative_refunds.sql
└── anomaly_detection/ # Statistical checks
 └── order_volume_anomaly.sql
```

### Performance Tips

- Run tests in parallel: `dbt test --threads 8`
- Use `store_failures: true` to save failing rows for debugging
- Schedule expensive tests off-peak
- Use sampling for large tables: `dbt test --select tag:sample`

## Related Skills

- `dbt` - Analytics engineering and transformations
- `sql-optimization` - Query performance
- `databases` - Database administration
- `backend-development` - API integration for monitoring

## References

- [dbt Testing](https://docs.getdbt.com/docs/build/tests)
- [dbt-expectations](https://github.com/calogica/dbt-expectations)
- [Great Expectations](https://docs.greatexpectations.io/)
- [Data Quality Best Practices](https://www.getdbt.com/blog/data-quality-testing)
- [Elementary Data](https://www.elementary-data.com/) - dbt observability
