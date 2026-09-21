-- checking if every staging points to exisitng order
SELECT count(*) as missing_orders
from STG_SUPERSTORE s 
where not exists(
    select 1 
    from orders o 
    where o.order_id = s.order_id
);

--checking if staging product points to existing product_id

SELECT count(*) as missing_orders
from STG_SUPERSTORE s 
where not exists(
    select 1 
    from products p
    where p.product_id = s.product_id
);

--checking for invalid quantity and discount
select count(*) as invalid_amount
from stg_superstore 
where quantity <=0  OR discount < 0  OR discount > 1;


-- load the data from stg_superstore to order_items master table
MERGE INTO order_items o
USING(
select s.row_id, s.order_id, s.product_id, s.quantity, s.sales, s.discount, s.profit
from stg_superstore s
)s
ON  (o.row_id = s.row_id)
WHEN MATCHED THEN 
UPDATE SET
    o.order_id = s.order_id, 
    o.product_id = s.product_id, 
    o.quantity = s.quantity, 
    o.sales = s.sales,
    o.discount = s.discount,
    o.profit = s.profit
WHEN NOT MATCHED THEN 
    INSERT(row_id, order_id, product_id, quantity, sales, discount, profit)
    VALUES(s.row_id, s.order_id, s.product_id, s.quantity, s.sales, s.discount, s.profit);


-- checking if the data got loaded into order_items master table

select count(*) as order_item_count
from order_items;