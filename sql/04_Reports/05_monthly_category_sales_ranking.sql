-- Analysis 5: Monthly Category Sales Ranking

WITH monthly_category_sales AS (
    SELECT
        TRUNC(o.order_date, 'MM') AS month,
        p.category,
        SUM(oi.sales) AS total_sales
    FROM orders o
    INNER JOIN order_items oi
        ON o.order_id = oi.order_id
    INNER JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        TRUNC(o.order_date, 'MM'),
        p.category
)
SELECT
    TO_CHAR(month, 'Mon YYYY') AS month,
    category,
    total_sales,
    RANK() OVER (
        PARTITION BY month
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM monthly_category_sales
ORDER BY
    month,
    sales_rank;