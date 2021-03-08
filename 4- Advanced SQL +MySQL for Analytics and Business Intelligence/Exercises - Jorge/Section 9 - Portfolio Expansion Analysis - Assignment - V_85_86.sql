-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Portfolio Expansion Analysis
-- Asigment
-- Videos 85 and 86
-- Slide 152

-- On December 12th 2013, we launched a third product targeting the birthday gift market (Birthday Bear).
-- Could you please run a pre-post analysis comparing the month before vs. the month after, 
-- in terms of session-to-order conversion rate, AOV, products per order, and revenue per session?

SELECT 
*
FROM website_pageviews
WHERE created_at BETWEEN '2013-11-12' AND '2014-01-14'
;

SELECT 
*
FROM website_sessions
WHERE created_at BETWEEN '2013-11-12' AND '2014-01-14'
;

-- Solution. Use the pageviews left-joined to orders and calculate the metrics

SELECT 
    CASE 
    WHEN ws.created_at < '2013-12-12' THEN 'A_Pre_Cros_Sell' 
    WHEN ws.created_at >= '2013-12-12' THEN 'B_Post_Cros_Sell' 
    ELSE 'Check logic' END AS time_period,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate,
    AVG(o.price_usd) AS AOV, -- (Average order value)
    SUM(o.items_purchased) AS products_sold,
    SUM(o.items_purchased) / COUNT(DISTINCT o.order_id) as products_per_order,
    SUM(o.price_usd) AS Total_revenue,
    SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '2013-11-12' AND '2014-01-14'
GROUP BY
    CASE 
    WHEN ws.created_at < '2013-12-12' THEN 'A_Pre_Cros_Sell' 
    WHEN ws.created_at >= '2013-12-12' THEN 'B_Post_Cros_Sell' 
    ELSE 'Check logic' END