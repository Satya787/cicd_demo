select
    product,
    count(*) as total_orders,
    sum(amount) as total_revenue
from {{ ref('stg_orders') }}
group by product