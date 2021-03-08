-- SECTION 10 
-- USER ANALYSIS

USE mavenfuzzyfactory;

-- Analyze time to repeat
-- Assignment
-- Video 96 and 97
-- Slide 171

-- Exploration

SELECT DISTINCT
*
FROM website_sessions
WHERE 
	created_at >= '2014-01-01'
 	AND created_at <= '2014-11-05'
;


SELECT DISTINCT
utm_source, utm_content, utm_campaign, http_referer
FROM website_sessions
WHERE 
	created_at >= '2014-01-01'
 	AND created_at <= '2014-11-05'
;

SELECT 
	utm_source, 
    utm_campaign, 
    http_referer,
	COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE 
	created_at >= '2014-01-01'
 	AND created_at <= '2014-11-05'
GROUP BY 1,2,3
ORDER BY 5 DESC
;


SELECT 
	*,
    CASE 
		WHEN http_referer IS NULL THEN 'direct_type_in' 
		WHEN http_referer IS NOT NULL AND utm_campaign IS NULL THEN 'organic_search'
        WHEN http_referer IS NOT NULL AND utm_campaign = 'brand' THEN 'paid_brand'
		WHEN http_referer IS NOT NULL AND utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN http_referer IS NOT NULL AND utm_source = 'socialbook' THEN 'paid_social'
		ELSE 'other_check' END AS traffic_type,
    CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END AS new_sessions,
    CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END AS repeat_sessions
FROM website_sessions
WHERE 
	created_at >= '2014-01-01'
 	AND created_at <= '2014-11-05'
;


SELECT 
    CASE 
		WHEN http_referer IS NULL THEN 'direct_type_in' 
		WHEN http_referer IS NOT NULL AND utm_campaign IS NULL THEN 'organic_search'
        WHEN http_referer IS NOT NULL AND utm_campaign = 'brand' THEN 'paid_brand'
		WHEN http_referer IS NOT NULL AND utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN http_referer IS NOT NULL AND utm_source = 'socialbook' THEN 'paid_social'
		ELSE 'other_check' END AS traffic_type,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE 
	created_at >= '2014-01-01'
 	AND created_at <= '2014-11-05'
GROUP BY
	traffic_type
ORDER BY 3 DESC
;