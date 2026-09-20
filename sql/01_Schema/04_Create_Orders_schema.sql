-- Creating the orders master table 

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

