{{
  config(
    materialized='view'
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

order_items as (
    select * from {{ ref('stg_order_items') }}
),

dim_order as (
    select 
        order_items.order_item_id,
        order_items.product_id,
        order_items.order_item_quantity,
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
        promos.promo_name,
        promos.promo_discount
    from order_items 
    left join orders on orders.order_id = order_items.order_id
    left join order_address on orders.address_id = order_address.address_id
    left join promos on promos.promo_id = orders.promo_id
)

select * from dim_order