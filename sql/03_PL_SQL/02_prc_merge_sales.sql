/* prc merge sales to load data from staging table to our master tables */
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



EXEC prc_merge_sales;