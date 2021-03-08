-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Analyzing Product Launches
-- Assignment
-- Slide 135, Video 75 and 76

-- Launch date '2013-01-06'
-- monthly order volume, overall conversion rates, revenue per session, and a breakdown of sales by
-- product, all for the time period since April 1, 2012 --> '2013-04-01'

-- Exploration

SELECT 
*
FROM website_sessions  ws
	LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '2012-04-01' AND '2013-04-05'
;
-- Analysis

SELECT 
	YEAR(ws.created_at) AS yr,
	MONTH(ws.created_at) AS mo,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
	COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate,
	SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session,
	COUNT(DISTINCT CASE WHEN primary_product_id = 1 THEN o.order_id ELSE NULL END) AS product_one_orders,
	COUNT(DISTINCT CASE WHEN primary_product_id = 2 THEN o.order_id ELSE NULL END) AS product_two_orders
FROM website_sessions  ws
	LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '2012-04-01' AND '2013-04-01'
GROUP BY
	YEAR(ws.created_at),
	MONTH(ws.created_at)
;

