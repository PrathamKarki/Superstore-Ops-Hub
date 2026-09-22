-- analysis: customer segmenetation 

create or replace function fn_customer_tier(
    p_customer_id IN VARCHAR2
)
RETURN VARCHAR2
IS 
    v_lifetime NUMBER;
BEGIN 
    SELECT NVL(sum(oi.sales), 0) into v_lifetime 
    from customers c 
    INNER JOIN orders o 
    ON c.customer_id = o.customer_id 
    INNER JOIN order_items oi 
    ON o.order_id = oi.order_id 
    where c.customer_id = p_customer_id;

    IF v_lifetime >= 3000 THEN 
        RETURN 'Gold';
    
    ELSIF v_lifetime >= 1500 THEN
        RETURN 'Silver';

    ELSE 
        RETURN 'Bronze';
    END IF;

    END fn_customer_tier;
/


-- count of how many customer belong to each tier
SELECT
    fn_customer_tier(c.customer_id) AS customer_tier,
    COUNT(*) AS customer_count
FROM customers c
GROUP BY fn_customer_tier(c.customer_id)
ORDER BY customer_tier;