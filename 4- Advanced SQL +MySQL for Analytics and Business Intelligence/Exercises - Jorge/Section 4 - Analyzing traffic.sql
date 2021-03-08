-- Section 4 - Traffic Sources
-- Analyzing top traffic sources

SELECT 
	ws.utm_content,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS session_to_order_convert_rt
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE 
	ws.website_session_id between 1000 and 2000
GROUP BY ws.utm_content
ORDER BY COUNT(DISTINCT ws.website_session_id) DESC	
;

-- -- Analyzing top traffic sources - assingment

SELECT 
	utm_source,
	utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions 
WHERE created_at < '2012-04-12'
GROUP BY 
	utm_source,
	utm_campaign,
    http_referer
ORDER BY 
COUNT(DISTINCT website_session_id) DESC	
;

-- Conversion rate (CVR) from session to order. Needed at least 4%

SELECT 
	COUNT(DISTINCT o.order_id) AS Number_of_orders,
	COUNT(DISTINCT ws.website_session_id) AS Number_of_sessions,
	COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS Session_to_orders_conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-04-14'
	AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'

;