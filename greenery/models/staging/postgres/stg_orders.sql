{{
  config(
    materialized='table'
  )
}}

with source as (
  select * from {{ source('postgres', 'orders') }}
), 

renamed as (
  select
  order_id, 
  user_id, 
  md5(promo_id) as promo_id,
  address_id, 
  created_at::timestamp_ntz as order_created_at_utc, 
  order_cost, 
  shipping_cost as order_shipping_cost,
  order_total as order_total_cost,
  tracking_id as order_shipment_tracking_id, 
  shipping_service as order_shipment_service_name, 
  estimated_delivery_at::timestamp_ntz as order_estimated_delivery_date_utc,
  delivered_at::timestamp_ntz as order_actual_delivery_date_utc, 
  status as order_status
  from source
)

select * from renamed