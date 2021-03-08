-- Bid oiptimization trends

USE mavenfuzzyfactory;

-- Video 25
-- Grouping with dates functions. Presentation tip

SELECT
	YEAR(created_at) AS year_of_created_at,
	WEEK(created_at) AS week_of_created_at,
	MIN(DATE(created_at)) AS week_start, -- presentation tip
	COUNT(DISTINCT website_session_id) as sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000 -- arbitrary
GROUP BY 1,2
;

-- Pivoting

SELECT
	primary_product_id,
	COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS count_single_item_orders,
	COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS count_two_item_orders,
	COUNT(DISTINCT order_id) AS orders
FROM orders
WHERE order_id BETWEEN 31000 and 32000
GROUP BY
primary_product_id
;

-- Traffic source trending

SELECT
	-- YEAR(created_at),
	-- WEEK(created_at), they are not part of the results but we are grouping by them
	MIN(DATE(created_at)) AS week_start,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at <'2012-05-10'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
	YEAR(created_at),
	WEEK(created_at)
;

-- Conversion rates sesions to orders by device

SELECT 
	ws.device_type,
   	COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS session_to_order_convert_rt
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE 
	ws.created_at < '2012-05-11'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	ws.device_type
;

-- Additional insight. See the trend by week and device

SELECT 
	-- YEAR(ws.created_at),
	-- WEEK(ws.created_at), they are not part of the results but we are grouping by them
    ws.device_type,
   	MIN(DATE(ws.created_at)) AS week_start,
	COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS session_to_order_convert_rt
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE 
	ws.created_at < '2012-05-11'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	ws.device_type,
   	YEAR(ws.created_at),
	WEEK(ws.created_at)
ORDER BY 
	ws.device_type,
   	YEAR(ws.created_at),
	WEEK(ws.created_at)
;

-- Videos 30 and 31
-- Gsearch device level trends

SELECT
-- 	WEEK(created_at) AS wk,
	MIN(DATE(created_at)) as week_start_date,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS 'dtop_sessions',
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS 'mob_sessions'
FROM website_sessions
WHERE 
	created_at BETWEEN '2012-04-15' AND '2012-06-09'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY
WEEK(created_at)
;