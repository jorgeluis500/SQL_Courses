-- SECTION 7
-- ANALYZING CHANNEL PORTFOLIOS

USE mavenfuzzyfactory;

-- Cross-Channel Bid optimization - Assignment
-- Videos 59 and 60 

-- pull nonbrand conversion rates from session to order for gsearch and bsearch, and slice the data by device type?
-- Analyze data from August 22 to September 18

SELECT 
	ws.device_type,
    ws.utm_source,
    COUNT(DISTINCT ws.website_session_id ) AS sessions,
    COUNT(DISTINCT o.order_id ) AS orders,
    COUNT(DISTINCT o.order_id ) / COUNT(DISTINCT ws.website_session_id ) AS conv_rate
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
WHERE 
	ws.created_at >= '2012-08-22' AND
    ws.created_at <= '2012-09-18' AND -- the video uses Sep 19th
	ws.utm_source IN ('gsearch', 'bsearch') AND
    ws.utm_campaign = 'nonbrand'
GROUP BY 
	ws.device_type,
	ws.utm_source
;