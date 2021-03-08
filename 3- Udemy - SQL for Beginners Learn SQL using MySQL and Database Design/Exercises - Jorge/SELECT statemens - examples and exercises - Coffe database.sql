USE coffe_store;

SELECT * FROM products;

-- Using WHERE
SELECT * FROM products
WHERE coffe_origin = 'Colombia';

SELECT * FROM products
WHERE price = 3;
-- Works without the decimals 

-- Using WHERE and AND
SELECT * FROM products
WHERE coffe_origin = 'Colombia'
AND price = 3;

-- Using WHERE and OR 
SELECT * FROM products
WHERE coffe_origin = 'Colombia'
OR price = 3;

-- Working with NULL values
SELECT
*
FROM customers
WHERE phone_number IS NULL;

SELECT
*
FROM customers
WHERE phone_number IS NOT NULL;

-- Exercises
-- 1
SELECT
	first_name,
	phone_number
FROM customers
WHERE 	gender = 'F'
	AND last_name = 'Bluth'
   ;
   
-- 2
 SELECT
	name
FROM products
WHERE price > 3
	OR  coffe_origin = 'Sri Lanka'
;
-- 3
 SELECT
	*
FROM customers
WHERE gender = 'M'
	AND phone_number IS NULL
;

SELECT
*
FROM orders
ORDER BY order_time;


USE coffe_store;

SELECT
	name,
	price
FROM products
WHERE 
	coffe_origin IN ('Colombia', 'Indonesia')
ORDER BY
	name;
    
SELECT
	first_name,
	phone_number
FROM customers
WHERE 
	last_name LIKE '%ar%'
    ;
        
SELECT
COUNT(DISTINCT customer_id)
FROM orders
WHERE order_time BETWEEN '2017-02-01' AND '2017-02-28'
;

SELECT 
	DISTINCT last_name
FROM customers
ORDER BY
	last_name
;

SELECT
*
FROM orders    
WHERE 
	order_time BETWEEN '2017-02-01' AND '2017-02-28'
    AND customer_id = 1
ORDER BY 
	order_time
LIMIT 3
;

SELECT
	name,
	price AS retail_price,
	coffe_origin
FROM products
;

-- JOIN exercises
-- 1
SELECT
	o.id AS Order_ID,
	c.phone_number
FROM orders o
	LEFT JOIN customers c
		ON o.customer_id = c.id
WHERE
product_id=4
;

-- 2
SELECT
	p.name AS Product_Name,
	o.order_time AS Order_Time
FROM orders o
	LEFT JOIN products p
		ON o.product_id = p.id
WHERE
	p.name = 'Filter'
	AND o.order_time BETWEEN '2017-01-15' AND '2017-02-17'
;

-- 3
SELECT
	p.name AS Product_Name,
    p.price,
    c.gender,
	o.order_time AS Order_Time
FROM orders o
	LEFT JOIN products p
		ON o.product_id = p.id
	LEFT JOIN customers c
		ON o.customer_id = c.id
WHERE
	c.gender = 'F'
    ;
