/* ====================================
	Quality Checks in Gold Layer 
====================================*/

select distinct gender from gold.dim_customers;

select * from gold.dim_products;

select * from gold.fact_sales;

--FACT CHeck
--Foreign Key Integrity(Dimensions)

select fs.order_number,c.customer_key,p.product_key,c.first_name,p.product_name
from gold.fact_sales as fs JOIN gold.dim_customers c
on fs.customer_key = c.customer_key
JOIN gold.dim_products p
on fs.product_key = p.product_key
where c.customer_key is null or p.product_key is null;
