-- SECTION 7
-- ANALYZING CHANNEL PORTFOLIOS

USE mavenfuzzyfactory;

-- Channel portfolio optimization
-- Video 54

-- How to get conversion rates (done before, just to practice)

SELECT 
	ws.utm_content,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
	COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE ws.created_at between '2014-01-01' AND '2014-02-01' -- Arbitrary
GROUP BY
	ws.utm_content
ORDER BY
	sessions DESC 
;
