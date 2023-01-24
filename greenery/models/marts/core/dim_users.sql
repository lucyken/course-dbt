{{
  config(
    materialized='table'
  )
}}

with users as (
    select * from {{ ref('stg_users') }}
), 

addresses as (
  select * from {{ ref('stg_addresses')}}
), 

user_orders as (
  select 
    user_id, 
    date(min(order_created_at_utc)) as first_order_date,
    count(distinct order_id) total_order_count, 
    sum(order_cost) as customer_lifetime_value
    from {{ ref('stg_orders')}}
    group by 1 
), 

users_with_address_info as (
select 
    users.user_id,
    users.user_first_name, 
    users.user_last_name, 
    users.user_email,
    users.user_phone_number, 
    users.user_created_at_utc,
    users.user_updated_at_utc,
    addresses.address_line_1 as billing_address_line_1,
    addresses.address_zipcode as billing_address_zipcode,
    addresses.address_country as billing_address_country, 
    user_orders.first_order_date, 
    date_trunc(month, date(user_orders.first_order_date)) as cohort_month,
    user_orders.total_order_count, 
    user_orders.customer_lifetime_value
from users
left join addresses on addresses.address_id = users.address_id
left join user_orders on user_orders.user_id = users.user_id 
)

select * from users_with_address_info
