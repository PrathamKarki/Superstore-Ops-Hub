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






