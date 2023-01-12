{{
  config(
    materialized='table'
  )
}}

with source as (
  select * from {{ source('postgres', 'events') }}
), 

renamed as (
  select 
    event_id as event_id, 
    session_id as session_id, 
    user_id as user_id, 
    page_url as event_page_url, 
    created_at::timestamp_ntz as event_created_at_utc, 
    event_type, 
    order_id as order_id, 
    product_id as product_id
  from source
)

select * from renamed