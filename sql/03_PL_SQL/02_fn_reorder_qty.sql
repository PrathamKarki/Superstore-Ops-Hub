-- calculate how many units should be reorders 
-- USING function fn_reorder_qty

CREATE OR REPLACE FUNCTION fn_reorder_qty (
p_qty_on_hand NUMBER
)
RETURN NUMBER 
IS
v_reorder_qty NUMBER;
BEGIN 
    v_reorder_qty := 100 - p_qty_on_hand;
    RETURN v_reorder_qty;
END;
/

