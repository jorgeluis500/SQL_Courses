-- SECTION 7
-- ANALYZING CHANNEL PORTFOLIOS

USE mavenfuzzyfactory;

-- Analyzing direct traffic - Assignment
-- Videos 64 and 65

-- pull organic search, direct type in, and paid brand search sessions by month, and show those sessions as a % of paid search nonbrand

-- Exploration

SELECT DISTINCT
	utm_source,
	utm_campaign,
	http_referer
FROM website_sessions
WHERE created_at <= '2012-12-23'
ORDER BY 1;

-- From the concepts
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

-- Then 

SELECT 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END) AS brand
FROM website_sessions
WHERE created_at <= '2012-12-23'
;

-- ... and using the same principle, create the rest of the measures and group by year and month
-- (the process in the video is slightly different but produces the same result)

SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS paid_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END) AS paid_brand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct,
	COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand
FROM website_sessions
WHERE created_at <= '2012-12-23'
GROUP BY
	YEAR(created_at),
	MONTH(created_at)
;
