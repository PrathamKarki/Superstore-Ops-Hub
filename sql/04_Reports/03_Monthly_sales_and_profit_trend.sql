-- Analysis #3 Monthly sales and profit

WITH monthly_data as (
  select trunc(o.order_date, 'MM') as month, 
           sum(oi.sales) as total_sales, 
           sum(oi.profit) as total_profit
    from orders o 
    INNER JOIN order_items oi 
    on o.order_id = oi.order_id
    group by trunc(o.order_date, 'MM')
    order by month
) 
SELECT month, total_sales, total_profit
from monthly_data 
order by month;