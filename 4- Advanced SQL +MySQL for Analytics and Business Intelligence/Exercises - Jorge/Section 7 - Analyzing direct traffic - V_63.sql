-- SECTION 7
-- ANALYZING CHANNEL PORTFOLIOS

USE mavenfuzzyfactory;

-- Analyzing direct traffic
-- Videos 63

SELECT distinct
	utm_campaign,
	http_referer
FROM website_sessions
ORDER BY 1;

-- utm_campaign NULL and http_referer NULL is direct_type_in traffic. It's when the customer types is our website or page
-- utm campaign NULL and http_referer NOT NULL is traffic coming from those sites. Not paid. Organic search
-- utm campaign NOT NULL and http_referer NOT NULL is paid traffic 

# utm_campaign	http_referer				Traffic type
-- NULL			NULL						direct_type_in
-- NULL			https://www.gsearch.com		organic (gsearch)
-- NULL			https://www.bsearch.com		organic (bsearch)
-- brand		https://www.gsearch.com		Paid brand (gsearch)
-- brand		https://www.bsearch.com		Paid brand (bsearch)
-- nonbrand		https://www.gsearch.com		Paid nonbrand (gsearch)
-- nonbrand		https://www.bsearch.com		Paid nonbrand (bsearch)


SELECT 
	CASE 
		WHEN http_referer IS NULL THEN 'direct_type_in' 
		WHEN http_referer = 'https://www.gsearch.com' AND utm_campaign IS NULL THEN 'gsearch_organic'
		WHEN http_referer = 'https://www.bsearch.com' AND utm_campaign IS NULL THEN 'bsearch_organic'
		ELSE 'other' END AS traffic_type,
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000 
GROUP BY 1
ORDER BY 2 DESC
;




