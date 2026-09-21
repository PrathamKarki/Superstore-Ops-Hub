-- load the inventory table from the products table 
INSERT INTO inventory(product_id, qty_on_hand)
SELECT product_id, 100 
from products;


-- verifying the inventory table got data inserted 
select * from inventory 
fetch first 5 rows only;


select count(*) as total_in_inventory
from inventory;