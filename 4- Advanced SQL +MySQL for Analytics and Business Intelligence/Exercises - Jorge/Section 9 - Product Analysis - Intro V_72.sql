-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Analyzing Product Sales and Product Launches
-- Intro. 
-- Slide 130, Video 72


SELECT 
*
FROM orders
WHERE order_id BETWEEN 10000 and 11000;

SELECT 
	primary_product_id, 
	COUNT(*) AS orders,
	COUNT(DISTINCT order_id) AS orders2,
	COUNT(DISTINCT website_session_id) as sessions,
	COUNT(DISTINCT user_id) as users, 
	SUM(price_usd) AS revenue, 
	SUM(price_usd - cogs_usd) AS margin,
    AVG(price_usd) AS AOV -- Average Order Value
FROM orders
WHERE order_id BETWEEN 10000 and 11000
GROUP BY
	primary_product_id
;

