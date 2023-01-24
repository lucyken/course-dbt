{{
  config(
    materialized='table'
  )
}}

{% set event_types = ["checkout", "package_shipped", "add_to_cart", "page_view"] %}

with stg_events as (
    select * from {{ ref('stg_events') }}
)

select
    session_id,
    {% for event_type in event_types %}
    sum(case when stg_events.event_type = event_type then 1 else 0 end) as {{event_type}}_count,
    {% endfor %}
    min(event_created_at_utc) as session_start_date, 
    max(event_created_at_utc) as session_end_date 
from stg_events 
group by 1 