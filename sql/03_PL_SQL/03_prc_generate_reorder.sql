
-- prc_generate_reorder procedure to find product below their reorder poitn and create reorder request

CREATE OR REPLACE PROCEDURE prc_generate_reorder
IS v_open NUMBER;
   v_priority VARCHAR2(10);
   v_qty NUMBER;
CURSOR c_low_stock IS
    select product_id, qty_on_hand, reorder_point 
    from inventory 
    where qty_on_hand <= reorder_point 
    order by qty_on_hand, product_id;
BEGIN
FOR rec IN c_low_stock LOOP
        -- later:
        -- check wheather an open request already exist
        SELECT count(*) INTO v_open 
        from reorder_requests
        where product_id = rec.product_id AND status = 'OPEN';

        IF v_open > 0  THEN 
            null;
        ELSE
            IF rec.qty_on_hand <= rec.reorder_point / 2 THEN
                v_priority := 'URGENT';
            ELSE
                v_priority := 'Normal';
            END IF;

             v_qty := fn_reorder_qty(rec.qty_on_hand);

             INSERT INTO reorder_requests(request_id, product_id, reorder_qty, priority, status, requested_at)
             VALUES(seq_reorder_request.NEXTVAL, rec.product_id, v_qty, v_priority, 'OPEN', SYSTIMESTAMP);

        END IF;

    END LOOP;

COMMIT;

END;
/


