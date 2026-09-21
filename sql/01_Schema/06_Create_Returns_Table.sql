-- Creating the returns table

CREATE TABLE returns(
    order_id VARCHAR2(20) NOT NULL, 
    returned_flag VARCHAR2(5) DEFAULT 'Yes' NOT NULL, 
    CONSTRAINT pk_returns PRIMARY KEY(order_id),
    CONSTRAINT fk_returns_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT chk_returns_flag CHECK (returned_flag IN('Yes', 'No'))
);