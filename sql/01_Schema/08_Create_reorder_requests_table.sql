-- creating the reorder_requests table 

create table reorder_requests(
    request_id NUMBER(10) NOT NULL, 
    product_id VARCHAR2(30) NOT NULL, 
    reorder_qty NUMBER(10) NOT NULL, 
    priority VARCHAR2(10) NOT NULL, 
    status VARCHAR2(12) DEFAULT 'OPEN' NOT NULL, 
    requested_at  TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL, 
    CONSTRAINT pk_reorder_request PRIMARY KEY (request_id),
    CONSTRAINT fk_reorder_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT chk_reorder_qty CHECK (reorder_qty > 0),
    CONSTRAINT chk_reorder_priority CHECK (priority IN ('Normal', 'URGENT')),
    CONSTRAINT ck_reorder_status CHECK (status IN ('OPEN', 'FULFILLED', 'CANCELLED'))

);


-- verifying that table got created 
select * from reorder_requests;