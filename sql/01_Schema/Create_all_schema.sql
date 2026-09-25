-- creating schema for stg_superstore
CREATE TABLE stg_superstore(
    LOAD_BATCH_ID NUMBER(10) DEFAULT 1 NOT NULL, 
    ROW_ID NUMBER(10) NOT NULL,
    
    ORDER_ID VARCHAR2(20) NOT NULL,
    ORDER_DATE DATE NOT NULL,
    SHIP_DATE DATE,
    SHIP_MODE VARCHAR2(30),

    CUSTOMER_ID VARCHAR2(20) NOT NULL,
    CUSTOMER_NAME VARCHAR2(80) NOT NULL,
    SEGMENT VARCHAR2(30),

    COUNTRY VARCHAR2(50),
    CITY VARCHAR2(50),
    STATE_PROVINCE VARCHAR2(50),
    POSTAL_CODE VARCHAR2(20),
    REGION VARCHAR2(20),

    PRODUCT_ID VARCHAR2(30) NOT NULL,
    CATEGORY VARCHAR2(30),
    SUB_CATEGORY VARCHAR2(30),
    PRODUCT_NAME VARCHAR2(200) NOT NULL,

    SALES NUMBER(12, 4) NOT NULL, 
    QUANTITY NUMBER(8) NOT NULL, 
    DISCOUNT NUMBER(5, 2), 
    PROFIT NUMBER(12, 4), 
    RETURNED VARCHAR2(5),
    LOADED_AT TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,

    CONSTRAINT pk_stg_superstore PRIMARY KEY (LOAD_BATCH_ID, ROW_ID),
    CONSTRAINT chk_stg_quantity CHECK (QUANTITY > 0),
    CONSTRAINT chk_stg_discount CHECK (DISCOUNT IS NULL OR (DISCOUNT >=0 AND DISCOUNT <=1))
);


-- Creating of master table 
-- customers
CREATE TABLE CUSTOMERS(
    CUSTOMER_ID VARCHAR2(20) NOT NULL, 
    CUSTOMER_NAME VARCHAR2(80) NOT NULL, 
    SEGMENT VARCHAR2(30) NOT NULL, 
    COUNTRY VARCHAR2(50),
    CITY VARCHAR2(50),
    STATE_PROVINCE VARCHAR2(50),
    POSTAL_CODE VARCHAR2(20),
    REGION VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_customer_id PRIMARY KEY(CUSTOMER_ID),
    CONSTRAINT chk_cus_segment CHECK (segment IN ('Consumer', 'Corporate', 'Home Office'))
);

-- products
CREATE TABLE products(
    PRODUCT_ID VARCHAR2(30) NOT NULL, 
    PRODUCT_NAME VARCHAR2(200) NOT NULL,
    CATEGORY VARCHAR2(30) NOT NULL, 
    SUB_CATEGORY VARCHAR2(30) NOT NULL, 
    CONSTRAINT pk_products_id PRIMARY KEY (PRODUCT_ID)
);

-- orders
create table orders(
    order_id VARCHAR2(20) NOT NULL, 
    order_date DATE NOT NULL, 
    ship_date DATE,
    ship_mode VARCHAR2(30) NOT NULL, 
    customer_id VARCHAR2(20) NOT NULL, 
    CONSTRAINT pk_orders_id PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_cus_id FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT chk_orders_ship_mode CHECK(ship_mode IN ('First Class', 'Second Class', 'Standard Class', 'Same Day'))
);

-- Creating for order_items table 

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


-- Creating the returns table
CREATE TABLE returns(
    order_id VARCHAR2(20) NOT NULL, 
    returned_flag VARCHAR2(5) DEFAULT 'Yes' NOT NULL, 
    CONSTRAINT pk_returns PRIMARY KEY(order_id),
    CONSTRAINT fk_returns_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT chk_returns_flag CHECK (returned_flag IN('Yes', 'No'))
);


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

