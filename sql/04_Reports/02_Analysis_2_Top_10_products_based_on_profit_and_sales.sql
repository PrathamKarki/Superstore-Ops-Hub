-- Top 10 products based on profit and sales

select p.product_id, p.product_name, sum(oi.sales) as total_sales, sum(oi.profit) as total_profit
from products p
INNER JOIN order_items oi
ON p.product_id = oi.product_id 
group by p.product_id, p.product_name
order by total_sales desc, total_profit desc
fetch first 10 rows only;
