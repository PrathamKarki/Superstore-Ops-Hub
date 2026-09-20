-- Load the orders table from the stg_superstore using merge

MERGE INTO orders o 
USING(
SELECT s.order_id, s.row_id, s.order_date, s.ship_date, s.ship_mode, s.customer_id 
from stg_superstore s
where s.row_id = (
    select max(s1.row_id)
    from stg_superstore s1
    where s1.order_id = s.order_id
) 
)s
ON (o.order_id = s.order_id)

WHEN MATCHED THEN 
UPDATE SET
    o.order_date = s.order_date, 
    o.ship_date = s.ship_date, 
    o.ship_mode = s.ship_mode,
    o.customer_id = s.customer_id

WHEN NOT MATCHED THEN
INSERT (order_id, order_date, ship_date, ship_mode, customer_id)
VALUES(s.order_id, s.order_date, s.ship_date, s.ship_mode, s.customer_id);

