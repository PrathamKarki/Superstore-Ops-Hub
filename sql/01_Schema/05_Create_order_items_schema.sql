-- Creating the order_items table 

CREATE TABLE order_items(
    row_id NUMBER(10) NOT NULL, 
    order_id VARCHAR2(20) NOT NULL, 
    product_id VARCHAR2(30) NOT NULL, 
    quantity NUMBER(8) NOT NULL, 
    sales NUMBER(12, 4) NOT NULL, 
    discount NUMBER(5,2) DEFAULT 0 NOT NULL, 
    profit NUMBER(12, 4),
    stock_applied_flag CHAR(1) DEFAULT 'N' NOT NULL, 
    CONSTRAINT pk_order_items PRIMARY KEY(row_id),
    CONSTRAINT fk_items_order FOREIGN KEY(order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_items_product FOREIGN KEY(product_id) REFERENCES products(product_id),
    CONSTRAINT chk_items_quantity CHECK(quantity > 0),
    CONSTRAINT chk_items_discount CHECK(discount >= 0 AND discount <=1),
    CONSTRAINT chk_items_stock_flag CHECK(stock_applied_flag IN ('Y', 'N'))
);