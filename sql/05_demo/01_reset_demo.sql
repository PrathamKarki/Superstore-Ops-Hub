-- reset sql

DELETE FROM order_items;
DELETE FROM returns;
DELETE FROM orders;

DELETE FROM inventory;
DELETE FROM products;
DELETE FROM customers;

-- staging table 
DELETE FROM stg_superstore;

commit;