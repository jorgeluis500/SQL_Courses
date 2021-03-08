-- SECTION 10 
-- USER ANALYSIS

USE mavenfuzzyfactory;

-- Analyze new and repeat conversion rates
-- Assignment
-- Video 98 and 99
-- Slide 174

/*
comparison of conversion rates and revenue per session for repeat sessions vs new sessions.
Let’s continue using data from 2014, year to date.
*/

SELECT
*
FROM website_sessions
WHERE 
	created_at >= '2014-01-01'
 	AND created_at <= '2014-11-08'
;

SELECT
*
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE 
	ws.created_at >= '2014-01-01'
 	AND ws.created_at <= '2014-11-08'
;

SELECT
	is_repeat_session,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
	COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate,
	SUM(price_usd) / COUNT(DISTINCT ws.website_session_id) as rev_per_session
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE 
	ws.created_at >= '2014-01-01'
 	AND ws.created_at <= '2014-11-08'
GROUP BY
	is_repeat_session
;
