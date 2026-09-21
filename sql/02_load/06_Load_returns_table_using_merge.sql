-- Checking that the orders acutally exisit in our orders table

SELECT count(distinct s.order_id) as missing_return_orders
from stg_superstore s 
where s.returned = 'Yes'
AND NOT EXISTS(
      SELECT 1
      FROM orders o
      WHERE o.order_id = s.order_id
);


-- Load the returns data into the returned data from the stg_superstore table 
MERGE INTO returns r 
USING (
    select DISTINCT s.order_id
    from stg_superstore s 
    where s.returned = 'Yes'
)s 
ON  (r.order_id = s.order_id) 
WHEN MATCHED THEN 
UPDATE SET 
    r.returned_flag = 'Yes'
WHEN NOT MATCHED THEN 
INSERT(order_id, returned_flag)
VALUES(s.order_id, 'Yes'); 


-- confirming the total count of the returns table 

select count(*) as retuns_count 
from returns;