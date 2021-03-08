-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Cross-Selling and Product Portfolio Analysis
-- Intro
-- Video 82
-- Slide 146


-- ORDERS TABLE EXPLORATION
-- In the orders table, each line represents an order. Each order is associated to a unique session. Same number of records
-- There might be users with more than one order, so there are less users than records

SELECT 
	COUNT(*) AS records,
	COUNT(DISTINCT order_id) as orders,
	COUNT(DISTINCT website_session_id) as sessions,
    COUNT(DISTINCT user_id) as users
FROM orders 
-- WHERE order_id BETWEEN 10000 AND 11000 -- 
;

-- In each order there is always a primary product (primary_product_id) which can be any product. 
-- If there is only one item purchased, that is the primary product

SELECT 
	*
FROM orders
WHERE order_id BETWEEN 10000 AND 11000 -- Arbitrary
;

-- ORDERS ITEMS TABLE EXPLORATION
-- In the order_items table, each line represents an item in an order. Therefore, there are more records (order items) than orders

SELECT 
	COUNT(*) AS records,
    COUNT(DISTINCT order_item_id) as order_items,
	COUNT(DISTINCT order_id) as orders
FROM order_items
-- WHERE order_id BETWEEN 10000 AND 11000 -- 
;

-- Each product has a field to indicate if the product in the order is the primary product in that order or not
-- Using that field we can see how much cross-sell has been

SELECT 
	*
FROM order_items
WHERE order_id BETWEEN 10000 AND 11000 -- Arbitrary
;
-- Combining the tables

SELECT 
	o.order_id,
    o.primary_product_id,
    oi.product_id,
	oi.is_primary_item
FROM orders o
LEFT JOIN order_items oi
	ON o.order_id = oi.order_id
WHERE o.order_id BETWEEN 10000 AND 11000
;

-- Bringing cross-sell products only

SELECT 
	o.order_id,
    o.primary_product_id,
    oi.product_id ,
    oi.is_primary_item
FROM orders o
LEFT JOIN order_items oi
	ON o.order_id = oi.order_id
    AND oi.is_primary_item = 0 -- Bring only cross-sell products
WHERE o.order_id BETWEEN 10000 AND 11000
;

-- Count the orders by product and cross-sell product

SELECT 
    o.primary_product_id,
	oi.product_id as x_sell_products,
   	COUNT(DISTINCT o.order_id) as orders
FROM orders o
LEFT JOIN order_items oi
	ON o.order_id = oi.order_id
    AND oi.is_primary_item = 0 -- Bring only cross-sell products. This condition can also be included in the where
WHERE o.order_id BETWEEN 10000 AND 11000
GROUP BY 1,2
;

-- Pivot the results to see them better

SELECT 
    o.primary_product_id,
	COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN o.order_id ELSE NULL END) AS x_sell_product_1,
   	COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN o.order_id ELSE NULL END) AS x_sell_product_2,
    COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN o.order_id ELSE NULL END) AS x_sell_product_3,
-- rates
    COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS x_sell_product_1_rt,
   	COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS x_sell_product_2_rt,
    COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS x_sell_product_3_rt
FROM orders o
LEFT JOIN order_items oi
	ON o.order_id = oi.order_id
    AND oi.is_primary_item = 0 -- Bring only cross-sell products. This condition can also be included in the where
WHERE o.order_id BETWEEN 10000 AND 11000
GROUP BY 1