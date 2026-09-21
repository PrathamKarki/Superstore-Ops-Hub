-- Creating the inventory table

CREATE table inventory(
    product_id VARCHAR2(30) NOT NULL, 
    qty_on_hand NUMBER(10) NOT NULL, 
    reorder_point NUMBER(10) DEFAULT 50 NOT NULL, 
    last_updated TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL, 
    constraint pk_inventory PRIMARY KEY(product_id),
    constraint fk_inventory FOREIGN KEY(product_id) REFERENCES products(product_id),
    constraint  chk_inventory_quantity CHECK(qty_on_hand >= 0),
    constraint chk_inventory_reorder CHECK(reorder_point > 0)
);
