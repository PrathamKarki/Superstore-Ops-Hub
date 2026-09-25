/* 1. prc merge sales to load data from staging table to our master tables */
CREATE OR REPLACE PROCEDURE prc_merge_sales
IS
BEGIN
    /* load customers */
    MERGE INTO customers c
    USING (
        SELECT
            s.customer_id,
            s.customer_name,
            s.segment,
            s.country,
            s.city,
            s.state_province,
            s.postal_code,
            s.region
        FROM stg_superstore s
        WHERE s.row_id = (
            SELECT MAX(s2.row_id)
            FROM stg_superstore s2
            WHERE s2.customer_id = s.customer_id
        )
    ) s
    ON (c.customer_id = s.customer_id)

    WHEN MATCHED THEN
        UPDATE SET
            c.customer_name  = s.customer_name,
            c.segment        = s.segment,
            c.country        = s.country,
            c.city           = s.city,
            c.state_province = s.state_province,
            c.postal_code    = s.postal_code,
            c.region         = s.region

    WHEN NOT MATCHED THEN
        INSERT (
            customer_id,
            customer_name,
            segment,
            country,
            city,
            state_province,
            postal_code,
            region
        )
        VALUES (
            s.customer_id,
            s.customer_name,
            s.segment,
            s.country,
            s.city,
            s.state_province,
            s.postal_code,
            s.region
        );

   /* load products */

    MERGE INTO products p
    USING (
        SELECT
            s.product_id,
            s.product_name,
            s.category,
            s.sub_category
        FROM stg_superstore s
        WHERE s.row_id = (
            SELECT MAX(s1.row_id)
            FROM stg_superstore s1
            WHERE s1.product_id = s.product_id
        )
    ) s
    ON (p.product_id = s.product_id)

    WHEN MATCHED THEN
        UPDATE SET
            p.product_name = s.product_name,
            p.category     = s.category,
            p.sub_category = s.sub_category

    WHEN NOT MATCHED THEN
        INSERT (
            product_id,
            product_name,
            category,
            sub_category
        )
        VALUES (
            s.product_id,
            s.product_name,
            s.category,
            s.sub_category
        );

    /* load orders */
    MERGE INTO orders o
    USING (
        SELECT
            s.order_id,
            s.order_date,
            s.ship_date,
            s.ship_mode,
            s.customer_id
        FROM stg_superstore s
        WHERE s.row_id = (
            SELECT MAX(s1.row_id)
            FROM stg_superstore s1
            WHERE s1.order_id = s.order_id
        )
    ) s
    ON (o.order_id = s.order_id)

    WHEN MATCHED THEN
        UPDATE SET
            o.order_date  = s.order_date,
            o.ship_date   = s.ship_date,
            o.ship_mode   = s.ship_mode,
            o.customer_id = s.customer_id

    WHEN NOT MATCHED THEN
        INSERT (
            order_id,
            order_date,
            ship_date,
            ship_mode,
            customer_id
        )
        VALUES (
            s.order_id,
            s.order_date,
            s.ship_date,
            s.ship_mode,
            s.customer_id
        );

    /* load order_items */
    MERGE INTO order_items o
    USING (
        SELECT
            s.row_id,
            s.order_id,
            s.product_id,
            s.quantity,
            s.sales,
            s.discount,
            s.profit
        FROM stg_superstore s
    ) s
    ON (o.row_id = s.row_id)

    WHEN MATCHED THEN
        UPDATE SET
            o.order_id  = s.order_id,
            o.product_id = s.product_id,
            o.quantity  = s.quantity,
            o.sales     = s.sales,
            o.discount  = s.discount,
            o.profit    = s.profit

    WHEN NOT MATCHED THEN
        INSERT (
            row_id,
            order_id,
            product_id,
            quantity,
            sales,
            discount,
            profit
        )
        VALUES (
            s.row_id,
            s.order_id,
            s.product_id,
            s.quantity,
            s.sales,
            s.discount,
            s.profit
        );


    /* load returns */
    MERGE INTO returns r
    USING (
        SELECT DISTINCT
            s.order_id
        FROM stg_superstore s
        WHERE s.returned = 'Yes'
    ) s
    ON (r.order_id = s.order_id)

    WHEN MATCHED THEN
        UPDATE SET
            r.returned_flag = 'Yes'

    WHEN NOT MATCHED THEN
        INSERT (
            order_id,
            returned_flag
        )
        VALUES (
            s.order_id,
            'Yes'
        );
    COMMIT;

END;
/





-- 2. PRC_APPLY_STOCK
-- Creating procedure PRC_APPLY_STOCK to update inventory 
CREATE OR REPLACE PROCEDURE prc_apply_stock
IS  
 v_on_hand NUMBER;
CURSOR c_sales IS
    SELECT product_id, sum(quantity) as total_sold
    from order_items 
    where stock_applied_flag = 'N'
    group by product_id 
    order by product_id;
BEGIN
 FOR rec IN c_sales LOOP

    BEGIN

     select qty_on_hand INTO v_on_hand
     from inventory
     where product_id = rec.product_id;
    
    EXCEPTION 
     WHEN  NO_DATA_FOUND THEN 
        RAISE_APPLICATION_ERROR(-20002, 'Product_id not found' || rec.product_id);
    END;

    IF v_on_hand < rec.total_sold THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient stock for' || rec.product_id);
    ELSE
     -- updating the inventory
     UPDATE inventory 
     SET qty_on_hand = qty_on_hand - rec.total_sold
     where product_id = rec.product_id;

     UPDATE order_items
     SET stock_applied_flag = 'Y'
     WHERE product_id = rec.product_id AND stock_applied_flag = 'N';
     
END IF;
END LOOP;

COMMIT;

END;
/





-- inspecting the inventory for first 10 product with their starting stock
SELECT product_id,
       qty_on_hand,
       reorder_point
FROM inventory
ORDER BY product_id
FETCH FIRST 10 ROWS ONLY;

-- checking the sales that have not been applied where 'N' means sale has not affected inventory
SELECT row_id,
       product_id,
       quantity,
       stock_applied_flag
FROM order_items
WHERE stock_applied_flag = 'N'
ORDER BY row_id
FETCH FIRST 10 ROWS ONLY;




-- check the inventory after applying the stock 
SELECT product_id,
       qty_on_hand,
       reorder_point
FROM inventory
ORDER BY product_id
FETCH FIRST 10 ROWS ONLY;


-- check wheather sales were marked as applied
SELECT row_id,
       product_id,
       quantity,
       stock_applied_flag
FROM order_items
WHERE stock_applied_flag = 'Y'
ORDER BY row_id
FETCH FIRST 10 ROWS ONLY;


SELECT product_id,
       qty_on_hand,
       reorder_point
FROM inventory
ORDER BY product_id
FETCH FIRST 10 ROWS ONLY;







EXEC prc_merge_sales;
EXEC PRC_APPLY_STOCK;