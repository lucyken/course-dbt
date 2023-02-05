{{
  config(
    materialized='table'
  )
}}

with users as (
    select * from {{ ref("dim_users") }}
), 

fact_orders as (
    select * from {{ ref("fct_orders") }}
)

select 
    users.user_id, 
    users.cohort_month as customer_cohort_month,
    users.billing_address_country as customer_country,
    datediff(month, date(order_created_at_utc), users.first_order_date) as months_since_order_date, 
    sum(fact_orders.order_cost) as order_value,
    count(distinct fact_orders.order_id) as order_count
from fact_orders 
left join users on users.user_id = fact_orders.user_id
group by 1,2,3,4
