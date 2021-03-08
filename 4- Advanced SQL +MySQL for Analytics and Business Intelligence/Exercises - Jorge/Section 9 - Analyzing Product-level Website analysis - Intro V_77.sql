-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Analyzing Product-level Website analysis
-- Video 77
-- Slide 138  

SELECT 
DISTINCT pageview_url
FROM website_pageviews
WHERE created_at BETWEEN '2013-02-01' AND '2013-03-01' -- Arbitrary
;

SELECT 
	wp.pageview_url, 
	COUNT(DISTINCT wp.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id)  / COUNT(DISTINCT wp.website_session_id) AS conv_rate
FROM website_pageviews wp
	LEFT JOIN orders o
		ON wp.website_session_id = o.website_session_id
WHERE wp.created_at BETWEEN '2013-02-01' AND '2013-03-01' -- Arbitrary
AND wp.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear' )
GROUP BY
	wp.pageview_url
;
