
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


-- Creating procedure PRC_APPLY_STOCK to update inventory 
-- explicit cursor
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

--executing the procedure
EXEC PRC_APPLY_STOCK;



-- check the inventory after applying the stock 
SELECT product_id,
       qty_on_hand,
       reorder_point
FROM inventory
ORDER BY product_id
FETCH FIRST 10 ROWS ONLY;


-- check wheather sales were marked as applied
SELECT product_id,
       qty_on_hand,
       reorder_point
FROM inventory
ORDER BY product_id
FETCH FIRST 10 ROWS ONLY;