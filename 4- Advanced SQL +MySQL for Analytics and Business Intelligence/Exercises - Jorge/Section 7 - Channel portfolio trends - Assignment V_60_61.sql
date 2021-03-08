-- SECTION 7
-- ANALYZING CHANNEL PORTFOLIOS

USE mavenfuzzyfactory;

-- Channel portfolio trends - Assignment
-- Videos 61 and 62

-- Weekly sessions volume for gsearch and bsearch nonbrand. 
-- Slice by device. From nov4
-- Show bsearch as % of gsearch
-- Date of the request '2012-12-22'

SELECT 
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT website_session_id ) AS total_sessions,
    COUNT(DISTINCT CASE WHEN utm_source= 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS g_dktop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source= 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_dktop_sessions,
	COUNT(DISTINCT CASE WHEN utm_source= 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN utm_source= 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS b_pct_of_g_desktop,
    COUNT(DISTINCT CASE WHEN utm_source= 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS g_mob_sessions,
	COUNT(DISTINCT CASE WHEN utm_source= 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_mob_sessions,
	COUNT(DISTINCT CASE WHEN utm_source= 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN utm_source= 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS b_pct_of_g_mobile
FROM website_sessions
WHERE 
	created_at >= '2012-11-04' AND
    created_at <= '2012-12-22' AND
	utm_campaign = 'nonbrand'
GROUP BY
	YEARWEEK(created_at)