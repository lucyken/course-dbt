{{
  config(
    materialized='table'
  )
}}

with promos as (
    select * from {{ ref('stg_promos') }}
),

order_address as (
    select * from {{ ref('stg_addresses') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

order_item_quantity as (
    select 
        order_id, 
        sum(order_item_quantity) as order_quantity
    from {{ ref('stg_order_items') }}
    group by 1
),

dim_order as (
    select 
        orders.order_id, 
        orders.user_id, 
        orders.order_created_at_utc, 
        orders.order_cost,
        orders.order_shipping_cost,
        orders.order_total_cost,
        orders.order_shipment_service_name, 
        orders.order_estimated_delivery_date_utc,
        orders.order_actual_delivery_date_utc, 
        order_address.address_country as order_country,
        order_item_quantity.order_quantity as order_quantity,
        promos.promo_name,
        promos.promo_discount
    from orders
    left join order_address on orders.address_id = order_address.address_id
    left join order_item_quantity on order_item_quantity.order_id = orders.order_id
    left join promos on promos.promo_id = orders.promo_id
)

select * from dim_order