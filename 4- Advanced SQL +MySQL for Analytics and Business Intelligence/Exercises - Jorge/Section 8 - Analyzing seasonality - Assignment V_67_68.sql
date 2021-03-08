-- SECTION 8
-- ANALYZING SEASONALITY AND BUSINESS PATTERNS

USE mavenfuzzyfactory;

-- Analyzing seasonality - Assignment
-- Videos 67 and 68

-- Take a look at 2012’s monthly and weekly volume patterns, to see if we can find any seasonal trends 
-- Pull session volume and order volume,

-- Query 1

SELECT
	YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) as mo,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2013-01-01'
GROUP BY 1,2
;

-- Query 1

SELECT
-- 	YEARWEEK(ws.created_at) AS yr,
    MIN(DATE(ws.created_at)) as week_start_date,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at <= '2013-01-02'
GROUP BY
	YEARWEEK(ws.created_at)
;