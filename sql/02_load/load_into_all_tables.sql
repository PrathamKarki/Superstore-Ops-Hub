-- Loading the csv file  data into our staging table

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


-- Load data from stg_superstore to customers table
-- customer master table
MERGE INTO customers c 
USING(
SELECT s.customer_id, s.customer_name, s.segment, s.country, s.city, s.state_province, s.postal_code, s.region 
from STG_SUPERSTORE s 
where s.row_id = (
    SELECT MAX(s2.row_id)
    from STG_SUPERSTORE s2 
    where s2.CUSTOMER_ID = s.customer_id
)
)s
on (c.customer_id = s.customer_id)
WHEN MATCHED THEN 
UPDATE SET 
    c.customer_name = s.customer_name,
    c.segment = s.segment, 
    c.country = s.country, 
    c.city = s.city, 
    c.state_province = s.state_province, 
    c.postal_code = s.postal_code, 
    c.region = s.region 
WHEN NOT MATCHED THEN 
INSERT (customer_id, customer_name, segment, country, city, state_province, postal_code, region)
VALUES(s.customer_id, s.customer_name, s.segment, s.country, s.city, s.state_province, s.postal_code, s.region);


-- load the products table from the stg_superstore table
-- merge
MERGE INTO Products p 
USING(
    SELECT s.product_id, s.product_name, s.category, s.sub_category
    FROM STG_SUPERSTORE s
    WHERE s.row_id = (
        SELECT max(s1.row_id)
        from STG_SUPERSTORE s1
        where s1.product_id = s.product_id
    )
)s
ON (p.product_id = s.product_id)
WHEN MATCHED THEN 
UPDATE SET 
   p.product_name = s.product_name,
   p.category = s.category, 
   p.sub_category = s.sub_category 
WHEN NOT MATCHED THEN 
INSERT (product_id, product_name, category, sub_category)
VALUES(s.product_id, s.product_name, s.category, s.sub_category);


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



-- load the inventory table from the products table 
INSERT INTO inventory(product_id, qty_on_hand)
SELECT product_id, 100 
from products;
