-- analysis 1: Sales and profit by category

select p.category, sum(oi.sales) as total_sales, sum(oi.profit) as total_profit
from products p
INNER JOIN  order_items oi
ON p.product_id = oi.product_id 
group by p.category
order by total_sales desc, total_profit desc;
