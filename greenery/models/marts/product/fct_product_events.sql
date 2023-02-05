{{
  config(
    materialized='view'
  )
}}

{% set actions = ["add_to_cart", "page_view"] %}

with products as (
    select * from {{ ref('stg_products')}}
),

product_events as (
    select * from {{ ref('stg_events') }}
    where product_id is not null
), 

product_order_by_day as (
    select 
    product_id, 
    date_trunc(day, date(order_created_at_utc)) as product_order_created_day, 
    count(distinct order_id) as product_order_count
    from {{ ref('fct_order_items')}}
    group by 1,2
),

product_event_by_day as (
    select
        product_id, 
        date_trunc(day, date(event_created_at_utc)) as event_created_day
        {% for action in actions %}
        , sum(case when product_events.event_type = '{{action}}' then 1 else 0 end) as {{action}}_count
        {% endfor %}
    from product_events 
    group by 1,2
)

select 
    product_event_by_day.product_id, 
    products.product_name,
    product_event_by_day.event_created_day, 
    {% for action in actions %}
    {{action}}_count,
    {% endfor %}
    product_order_count
from product_event_by_day
left join product_order_by_day on product_order_by_day.product_order_created_day = product_event_by_day.event_created_day
    and product_order_by_day.product_id = product_event_by_day.product_id
left join products on products.product_id = product_event_by_day.product_id

