-- checking whether customer_id appears multiple times in stg_table
SELECT customer_id, count(*) as row_count
from stg_superstore 
group by customer_id 
having count(*) > 1 
order by row_count desc;


-- checking wheather same customer_id is confliciting other customer_information such as name, segment, city
select customer_id, 
    COUNT(distinct customer_name) AS NAMES,
    COUNT(distinct segment) AS SEGMENTS,
    COUNT(distinct city) AS CITIES,
    COUNT(distinct state_province) AS STATES,
    COUNT(distinct region) AS REGIONS
FROM stg_superstore 
group by customer_id 
HAVING COUNT ( distinct CUSTOMER_NAME )> 1 
or count( distinct segment) > 1
or count( distinct city) > 1
or count (distinct state_province ) > 1
or count (distinct region ) > 1;

-- selecting one record per customer_id 
SELECT customer_id, row_id, customer_name, city, state_province, region
from stg_superstore s 
WHERE row_id = (
    select max(s2.row_id)
    from stg_superstore s2 
    where s2.customer_id = s.customer_id
);


-- Load data from stg_superstore to customers table
-- customer master table

MERGE INTO customers c 
USING(
SELECT s.customer_id, s.customer_name, s.segment, s.country, s.city, s.state_province, s.postal_code, s.region 
from STG_SUPERSTORE s 
where s.row_id = (
    SELECT MAX(s2.row_id)
    from STG_SUPERSTORE s2 
    where s2.CUSTOMER_ID = s.customer_id
)
)s
on (c.customer_id = s.customer_id)
WHEN MATCHED THEN 
UPDATE SET 
    c.customer_name = s.customer_name,
    c.segment = s.segment, 
    c.country = s.country, 
    c.city = s.city, 
    c.state_province = s.state_province, 
    c.postal_code = s.postal_code, 
    c.region = s.region 
WHEN NOT MATCHED THEN 
INSERT (customer_id, customer_name, segment, country, city, state_province, postal_code, region)
VALUES(s.customer_id, s.customer_name, s.segment, s.country, s.city, s.state_province, s.postal_code, s.region);



-- verifying the customer load 
select count(*) as customer_count 
from customers;


select * 
from customers 
order by customer_id;




