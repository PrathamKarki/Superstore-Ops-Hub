-- loading from our csv to stg_superstore

INSERT INTO STG_SUPERSTORE(
LOAD_BATCH_ID, ROW_ID,
ORDER_ID, ORDER_DATE, SHIP_DATE, SHIP_MODE, 
CUSTOMER_ID, CUSTOMER_NAME, SEGMENT, 
COUNTRY, CITY, STATE_PROVINCE, POSTAL_CODE, REGION,
PRODUCT_ID, CATEGORY, SUB_CATEGORY, PRODUCT_NAME,
SALES, QUANTITY, DISCOUNT, PROFIT, RETURNED

)
SELECT LOAD_BATCH_ID, ROW_ID,
ORDER_ID, ORDER_DATE, SHIP_DATE, SHIP_MODE, 
CUSTOMER_ID, CUSTOMER_NAME, SEGMENT, 
COUNTRY, CITY, STATE_PROVINCE, POSTAL_CODE, REGION,
PRODUCT_ID, CATEGORY, SUB_CATEGORY, PRODUCT_NAME,
SALES, QUANTITY, DISCOUNT, PROFIT, RETURNED
FROM STG_SUPERSTORE_2K;


COMMIT;



-- verifying that stg_superstore got data inserted
select count(*) as staging_rows
from stg_superstore;


-- running our pl/sql procedure to load into our master table: customer, proudcts, order, order_items, returns;
EXEC prc_merge_sales;



-- verifying that the master table got data inserted
SELECT COUNT(*) from customers;
SELECT COUNT(*) from products;
SELECT COUNT(*) from orders;
SELECT COUNT(*) from order_items;
SELECT COUNT(*) from returns;


-- seeding data into inventory
INSERT INTO inventory(product_id, qty_on_hand)
SELECT product_id, 100
from products;

commit;

--verifying the data got inserted into inventory_rows
select count(*) as inventory_rows
from inventory;




-- checking inventory before applying sales
SELECT product_id, qty_on_hand, reorder_point
FROM inventory
ORDER BY product_id 
FETCH FIRST 10 rows only;


-- checking for unprocessed sales, here n means sale has not been yet affected inventory
SELECT row_id, product_id, quantity, stock_applied_flag
from order_items 
where stock_applied_flag = 'N'
order by row_id 
fetch first 10 rows only;


-- executing the inventory procedure 
exec prc_apply_stock;



-- checking inventory after applying sales
select product_id, qty_on_hand, reorder_point 
from inventory 
order by product_id 
fetch first 10 rows only;



-- verifying sales were marked as applied 
select row_id, product_id, quantity, stock_applied_flag 
from order_items 
where stock_applied_flag = 'Y'
order by row_id 
fetch first 10 rows only;
