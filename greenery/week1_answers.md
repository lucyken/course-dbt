

# Week 1 answers 

- How many users do we have?

``` sql
select count(distinct user_id) from stg_users 
```

Answer: 130

- On average, how many orders do we receive per hour?

```sql
with orders_per_hour as 
(
    select 
        date_trunc('hour', order_created_at_utc) as created_at_hour, 
        count(*) as order_count 
    from stg_orders 
    group by 1 
)

select avg(order_count) as avg_orders_per_hour from orders_per_hour
```

Answer: 7.520833

- On average, how long does an order take from being placed to being delivered?

```sql
with delivery_speed as 
(
    select 
        order_id,
        datediff('days', order_created_at_utc, order_actual_delivery_date_utc ) as delivery_days
    from stg_orders 
)

select round(avg(delivery_days),1) as avg_delivery_days from delivery_speed
```

Answer: 3.9 days 

- How many users have only made one purchase? Two purchases? Three+ purchases?

```sql
with user_orders_lifetime as (
    select 
        user_id, 
        count(*) lifetime_order_count
    from stg_orders
    group by 1 
)

select 
    case lifetime_order_count
        when 1 then '1 Purchases'
        when 2 then '2 Purchases'
        else '3+ Purchases' 
        end as customer_order_bins,
    count(user_id)
from user_orders_lifetime
group by 1
```

Answers: 
3+ Purchases, 71 
1 Purchases,  25
2 Purchases,  28


- On average, how many unique sessions do we have per hour?

```sql
-- select * from stg_events

with events_per_hour as (
    select
        date_trunc('hour', event_created_at_utc) as event_hour,
        count(distinct session_id) as unique_session_count
    from stg_events
    group by 1
)

select avg(unique_session_count) as sessions_per_hour from events_per_hour
```

Answers: 16.327586
