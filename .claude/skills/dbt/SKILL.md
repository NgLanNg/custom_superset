---
name: dbt
description: dbt (data build tool) patterns for analytics engineering, including models, tests, documentation, incremental strategies, snapshots, and macros
---

# dbt Analytics Engineering Skill

Comprehensive patterns for building, testing, and documenting data transformations with dbt.

## When to Use

- Building dbt models (SQL transformations)
- Creating or modifying dbt tests (data quality checks)
- Setting up incremental models or snapshots
- Writing dbt macros or using Jinja templating
- Generating or updating dbt documentation
- Configuring dbt materializations (table, view, incremental, ephemeral)
- Implementing dbt project structure and best practices
- Debugging dbt compilation or execution issues

## Quick Reference

### dbt Commands

```bash
# Development workflow
dbt debug # Test database connection
dbt deps # Install package dependencies
dbt compile # Compile SQL without running
dbt run # Execute models
dbt test # Run data tests
dbt build # Run + test in DAG order

# Selective execution
dbt run --select model_name # Single model
dbt run --select +model_name # Model + upstream
dbt run --select model_name+ # Model + downstream
dbt run --select tag:daily # Tagged models
dbt run --select path:marts/finance/** # Path-based

# Development
dbt show --select model_name # Preview model results
dbt compile --select model # Check compiled SQL
dbt docs generate # Generate documentation
dbt docs serve # Serve docs locally
```

### Model Materializations

| Type | Use Case | Example |
|------|----------|---------|
| `view` | Default, lightweight aggregations | Staging models |
| `table` | Heavy transformations, frequent queries | Mart models |
| `incremental` | Large datasets, append-only or merge | Event logs, fact tables |
| `ephemeral` | CTEs, reusable logic (no database object) | Intermediate steps |

### dbt Project Structure

```
my_dbt_project/
├── dbt_project.yml # Project configuration
├── profiles.yml # Database connections (local)
├── packages.yml # Dependencies
│
├── models/
│ ├── staging/ # Source transformations
│ │ ├── _staging.yml # Source configs
│ │ └── stg_customers.sql
│ ├── intermediate/ # Business logic building blocks
│ │ └── int_order_items.sql
│ └── marts/ # Final analytics tables
│ ├── finance/
│ │ ├── _finance.yml
│ │ └── fct_orders.sql
│ └── marketing/
│
├── tests/ # Custom SQL tests
│ └── assert_positive_total.sql
│
├── macros/ # Reusable SQL functions
│ └── cents_to_dollars.sql
│
├── seeds/ # CSV reference data
│ └── country_codes.csv
│
├── snapshots/ # Type-2 SCD tracking
│ └── orders_snapshot.sql
│
└── analyses/ # Ad-hoc queries
 └── monthly_revenue.sql
```

## Model Patterns

### Staging Models

Clean and standardize source data:

```sql
-- models/staging/stg_customers.sql
{{ config(materialized='view') }}

with source as (
 select * from {{ source('raw', 'customers') }}
),

renamed as (
 select
 id as customer_id,
 {{ dbt.safe_cast("created_at", api.Column.translate_type("timestamp")) }} as created_at,
 lower(trim(email)) as email,
 first_name,
 last_name
 
 from source
)

select * from renamed
```

### Intermediate Models

Business logic transformations:

```sql
-- models/intermediate/int_order_items.sql
{{ config(materialized='ephemeral') }}

with orders as (
 select * from {{ ref('stg_orders') }}
),

order_items as (
 select * from {{ ref('stg_order_items') }}
),

joined as (
 select
 order_items.order_item_id,
 orders.order_id,
 orders.customer_id,
 order_items.product_id,
 order_items.quantity,
 order_items.unit_price,
 order_items.quantity * order_items.unit_price as item_total
 
 from order_items
 inner join orders using (order_id)
)

select * from joined
```

### Mart Models (Fact Tables)

Final analytics-ready tables:

```sql
-- models/marts/finance/fct_orders.sql
{{ config(
 materialized='table',
 tags=['daily', 'finance']
) }}

with order_items as (
 select * from {{ ref('int_order_items') }}
),

aggregated as (
 select
 order_id,
 customer_id,
 count(*) as item_count,
 sum(item_total) as order_total,
 max(created_at) as order_date
 
 from order_items
 group by 1, 2
)

select * from aggregated
```

## Incremental Models

For large datasets that grow over time:

### Append Strategy

```sql
-- models/events/fct_page_views.sql
{{ config(
 materialized='incremental',
 unique_key='event_id',
 on_schema_change='append_new_columns'
) }}

select
 event_id,
 user_id,
 page_url,
 event_time
 
from {{ source('raw', 'events') }}

{% if is_incremental() %}
 -- Only process new events
 where event_time > (select max(event_time) from {{ this }})
{% endif %}
```

### Merge/Upsert Strategy

```sql
-- models/fct_daily_metrics.sql
{{ config(
 materialized='incremental',
 unique_key='date',
 incremental_strategy='merge'
) }}

with daily_stats as (
 select
 date_trunc('day', created_at) as date,
 count(distinct user_id) as active_users,
 sum(revenue) as total_revenue
 
 from {{ ref('fct_orders') }}
 
 {% if is_incremental() %}
 where created_at >= (select max(date) from {{ this }})
 {% endif %}
 
 group by 1
)

select * from daily_stats
```

### Delete+Insert Strategy

```sql
{{ config(
 materialized='incremental',
 unique_key='date',
 incremental_strategy='delete+insert'
) }}

-- Efficient for partitioned tables (BigQuery, Snowflake)
-- Deletes full partitions and inserts new data
```

## Testing Patterns

### Schema Tests (YAML)

```yaml
# models/marts/finance/_finance.yml
version: 2

models:
 - name: fct_orders
 description: "Order fact table with aggregated metrics"
 columns:
 - name: order_id
 description: "Unique order identifier"
 tests:
 - unique
 - not_null
 
 - name: customer_id
 tests:
 - not_null
 - relationships:
 to: ref('dim_customers')
 field: customer_id
 
 - name: order_total
 description: "Total order amount in cents"
 tests:
 - not_null
 - dbt_expectations.expect_column_values_to_be_between:
 min_value: 0
 max_value: 1000000
 
 - name: order_date
 tests:
 - not_null
```

### Custom SQL Tests

```sql
-- tests/assert_order_total_equals_sum_items.sql
-- Returns records that fail the test

select
 order_id,
 order_total,
 sum_item_total
 
from (
 select
 o.order_id,
 o.order_total,
 sum(oi.item_total) as sum_item_total
 
 from {{ ref('fct_orders') }} o
 left join {{ ref('int_order_items') }} oi using (order_id)
 group by 1, 2
)

where order_total != sum_item_total
```

### Generic Tests (Reusable)

```sql
-- macros/tests/test_valid_email.sql
{% test valid_email(model, column_name) %}

select {{ column_name }}
from {{ model }}
where {{ column_name }} is not null
 and {{ column_name }} not like '%_@_%.__%'

{% endtest %}
```

Usage:
```yaml
columns:
 - name: email
 tests:
 - valid_email
```

## Snapshots (Type-2 SCD)

Track historical changes:

```sql
-- snapshots/orders_snapshot.sql
{% snapshot orders_snapshot %}

{{
 config(
 target_schema='snapshots',
 unique_key='order_id',
 strategy='timestamp',
 updated_at='updated_at',
 )
}}

select * from {{ source('raw', 'orders') }}

{% endsnapshot %}
```

Alternative check strategy:

```sql
{% snapshot customers_snapshot %}

{{
 config(
 target_schema='snapshots',
 unique_key='customer_id',
 strategy='check',
 check_cols=['email', 'status'],
 )
}}

select * from {{ ref('stg_customers') }}

{% endsnapshot %}
```

Run with:
```bash
dbt snapshot
```

## Macros and Jinja

### Custom Macros

```sql
-- macros/cents_to_dollars.sql
{% macro cents_to_dollars(column_name) %}
 ({{ column_name }} / 100.0)::numeric(10,2)
{% endmacro %}
```

Usage:
```sql
select
 order_id,
 {{ cents_to_dollars('order_total') }} as order_total_usd
from {{ ref('fct_orders') }}
```

### Jinja Control Flow

```sql
select
 order_id,
 {% if var('include_tax', false) %}
 order_total * 1.08 as order_total_with_tax,
 {% endif %}
 order_date
from {{ ref('fct_orders') }}
```

### Dynamic Column Pivot

```sql
{% set payment_methods = ['credit_card', 'debit_card', 'paypal'] %}

select
 date,
 {% for method in payment_methods %}
 sum(case when payment_method = '{{ method }}' then amount else 0 end) as {{ method }}_total
 {{- "," if not loop.last }}
 {% endfor %}
from {{ ref('fct_payments') }}
group by date
```

## Documentation

### Model Documentation

```yaml
# models/_models.yml
version: 2

models:
 - name: fct_orders
 description: |
 # Order Fact Table
 
 This table contains one row per order with aggregated metrics.
 Updated daily at 2 AM UTC.
 
 **Grain**: One row per order
 
 **Refresh**: Daily incremental
 
 columns:
 - name: order_id
 description: "{{ doc('order_id') }}"
```

### Doc Blocks

```markdown
<!-- models/docs.md -->
{% docs order_id %}
Unique identifier for each order. Generated by the payment system.
Format: `ORD-{timestamp}-{random}`
{% enddocs %}
```

### Generate Docs

```bash
dbt docs generate
dbt docs serve --port 8080
```

## Sources

Define external tables:

```yaml
# models/staging/_sources.yml
version: 2

sources:
 - name: raw
 description: "Raw Postgres tables"
 database: analytics
 schema: raw_data
 
 tables:
 - name: customers
 description: "Raw customer data from CRM"
 freshness:
 warn_after: {count: 12, period: hour}
 error_after: {count: 24, period: hour}
 loaded_at_field: _loaded_at
 
 columns:
 - name: id
 tests:
 - unique
 - not_null
```

Check freshness:
```bash
dbt source freshness
```

## Configuration Patterns

### dbt_project.yml

```yaml
name: 'my_analytics'
version: '1.0.0'
config-version: 2

profile: 'default'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
 - "target"
 - "dbt_packages"

models:
 my_analytics:
 # Staging models
 staging:
 +materialized: view
 +tags: ['staging']
 
 # Intermediate models
 intermediate:
 +materialized: ephemeral
 
 # Marts
 marts:
 +materialized: table
 +tags: ['production']
 
 finance:
 +schema: finance
 +tags: ['finance', 'pii']
 
 marketing:
 +schema: marketing

vars:
 start_date: '2024-01-01'
 
on-run-end:
 - "{{ grant_select_on_schemas(schemas, 'analytics_role') }}"
```

### profiles.yml (Local)

```yaml
default:
 outputs:
 dev:
 type: postgres
 host: localhost
 port: 5432
 user: "{{ env_var('DBT_USER') }}"
 password: "{{ env_var('DBT_PASSWORD') }}"
 dbname: analytics
 schema: dev_{{ env_var('USER') }}
 threads: 4
 
 prod:
 type: snowflake
 account: abc123.us-east-1
 user: "{{ env_var('SNOWFLAKE_USER') }}"
 password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
 role: TRANSFORMER
 database: ANALYTICS
 warehouse: TRANSFORMING
 schema: PUBLIC
 threads: 8
 
 target: dev
```

## Best Practices

### Naming Conventions

- **Staging**: `stg_{source}_{entity}.sql`
- **Intermediate**: `int_{entity}_{verb}.sql`
- **Fact**: `fct_{entity}.sql`
- **Dimension**: `dim_{entity}.sql`

### Model Organization

1. **Staging**: 1:1 with source tables, minimal transformations
2. **Intermediate**: Reusable business logic, ephemeral
3. **Marts**: Final tables for BI tools

### Performance Tips

- Use incremental models for large datasets (>10M rows)
- Set appropriate `unique_key` for merge strategies
- Use `ephemeral` for intermediate CTEs
- Leverage `{{ ref() }}` for automatic dependency management
- Tag models for selective execution

### Testing Strategy

- **Schema tests**: Primary keys, foreign keys, value ranges
- **Custom SQL tests**: Business logic validation
- **dbt-expectations**: Extended test suite
- Test critical models daily, comprehensive tests weekly

## Debugging

### Common Issues

```sql
-- Check compiled SQL
dbt compile --select model_name

-- View model preview
dbt show --select model_name --limit 100

-- Debug connection
dbt debug

-- Verbose logging
dbt run --select model_name --log-level debug

-- Parse-only (no execution)
dbt parse
```

### Incremental Model Issues

```sql
-- Force full refresh
dbt run --select model_name --full-refresh

-- Check incremental logic
{% if is_incremental() %}
 {{ log("Running incrementally", info=true) }}
{% else %}
 {{ log("Running full refresh", info=true) }}
{% endif %}
```

## Related Skills

- `sql-optimization` - Query performance and indexing
- `data-quality` - Validation and monitoring
- `databases` - PostgreSQL/Snowflake patterns
- `backend-development` - API integration for dbt Cloud

## References

- [dbt Documentation](https://docs.getdbt.com/)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [dbt Discourse Community](https://discourse.getdbt.com/)
- [dbt Utils Package](https://github.com/dbt-labs/dbt-utils)
- [dbt Expectations](https://github.com/calogica/dbt-expectations)
