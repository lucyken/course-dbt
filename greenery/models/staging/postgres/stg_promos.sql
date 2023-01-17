with source as (
  select * from {{ source('postgres', 'promos') }}
), 

renamed as (
  select 
    md5(promo_id) as promo_id,
    promo_id as promo_name, 
    discount as promo_discount,
    status as promo_status
  from source
)

select * from renamed