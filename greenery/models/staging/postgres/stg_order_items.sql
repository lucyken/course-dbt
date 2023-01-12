{{
  config(
    materialized='table'
  )
}}

with source as (
  select * from {{ source('postgres', 'order_items') }}
), 

renamed as (
  select 
    md5(concat(order_id, product_id)) as order_item_id,
    order_id as order_id,
    product_id as product_id,
    quantity as order_item_quantity
  from source
)

select * from renamed

