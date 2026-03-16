# dbt Test Templates

Common dbt test patterns for models, staging, and incremental transforms.

## Schema Tests (YAML)

```yaml
models:
 - name: fct_orders
 columns:
 - name: order_id
 tests:
 - unique
 - not_null
 - name: customer_id
 tests:
 - not_null
 - relationships:
 to: ref('dim_customers')
 field: customer_id
 - name: status
 tests:
 - accepted_values:
 values: ['pending', 'shipped', 'delivered', 'cancelled']
 - name: total_amount
 tests:
 - not_null
 - dbt_utils.expression_is_true:
 expression: ">= 0"
```

## Custom SQL Tests

```sql
-- tests/assert_fct_orders_no_duplicates.sql
select order_id, count(*) as cnt
from {{ ref('fct_orders') }}
group by order_id
having count(*) > 1
```

## Generic Tests

```sql
-- macros/test_no_future_dates.sql
{% test no_future_dates(model, column_name) %}
select *
from {{ model }}
where {{ column_name }} > current_date
{% endtest %}
```

## Freshness Tests

```yaml
sources:
 - name: raw_orders
 tables:
 - name: orders
 freshness:
 warn_after: {count: 24, period: hour}
 error_after: {count: 48, period: hour}
 loaded_at_field: created_at
```

## SCD2 Validation

```sql
-- tests/assert_dim_customers_scd2_valid.sql
select customer_sk, sum(case when is_current = true then 1 else 0 end) as current_count
from {{ ref('dim_customers') }}
group by customer_sk
having current_count != 1
```

## Incremental Tests

```sql
-- tests/assert_fct_orders_incremental_no_gaps.sql
-- Check for missing dates in incremental load
with expected_dates as (
 select date_trunc('day', event_at::date)::date as order_date
 from {{ ref('fct_orders') }}
),
actual_dates as (
 select distinct date_trunc('day', event_at::date)::date as order_date
 from {{ ref('fct_orders') }}
)
select e.order_date
from expected_dates e
left join actual_dates a on e.order_date = a.order_date
where a.order_date is null
```
