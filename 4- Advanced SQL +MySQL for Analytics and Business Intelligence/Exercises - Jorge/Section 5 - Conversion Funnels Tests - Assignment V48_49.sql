-- Section 5 - Analyzing website performance
-- Analyzing Conversion funnels tests
-- Videos 48 and 49
-- Slide 90

USE mavenfuzzyfactory;

-- ASSIGNMENT
-- see whether /billing-2 is doing any better than the original /billing page
-- what % of sessions on those pages end up placing an order. For all traffic, not just for our search visitors
-- Date of the request. '2012-11-10'

-- Step 1
-- Find out when the billing_2 page had it's first activity

SELECT 
	pageview_url,
	MIN(website_pageview_id) AS first_pv_id,
	MIN(created_at) AS first_created_at
FROM website_pageviews
WHERE pageview_url = '/billing-2'
GROUP BY pageview_url
ORDER BY website_pageview_id
;
-- Answer: 53550

-- first we will see the relevant pages

SELECT 
*
FROM website_pageviews
WHERE website_pageview_id >= 53550 -- first pageview_id where the test was live
AND created_at <= '2012-11-10' -- time of assignment
AND pageview_url IN ('/billing', '/billing-2')
ORDER BY website_pageview_id
;

-- Then we will combine them with orders
SELECT * FROM orders;

SELECT 
	wp.website_session_id,
	wp.pageview_url AS billing_version_seen,
	o.order_id
FROM website_pageviews wp
LEFT JOIN orders o
	ON wp.website_session_id = o.website_session_id
WHERE wp.website_pageview_id >= 53550 -- first pageview_id where the test was live
AND wp.created_at <= '2012-11-10' -- time of assignment
AND wp.pageview_url IN ('/billing', '/billing-2')
ORDER BY website_pageview_id
;

-- Long method
-- And finally we turn it into a subquery, count the distinct id to create the aggregatrions and group by version seen

SELECT 
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS billing_to_order_rate
FROM (
    SELECT 
        wp.website_session_id,
		wp.pageview_url AS billing_version_seen,
		o.order_id
    FROM
        website_pageviews wp
    LEFT JOIN orders o 
		ON wp.website_session_id = o.website_session_id
    WHERE
        wp.website_pageview_id >= 53550
        AND wp.created_at <= '2012-11-10'
        AND wp.pageview_url IN ('/billing' , '/billing-2')
    ORDER BY website_pageview_id
) AS billing_sessions_w_orders
GROUP BY
	billing_version_seen
;

-- ---------------------------------------------

-- Shorter method

SELECT 
	wp.pageview_url AS billing_version_seen,
	COUNT(wp.website_session_id) AS sessions,
	COUNT(o.order_id) AS orders,
	COUNT(o.order_id) / COUNT(wp.website_session_id) AS billing_to_order_rate
FROM website_pageviews wp
LEFT JOIN orders o
	ON wp.website_session_id = o.website_session_id
WHERE wp.website_pageview_id >= 53550 -- first pageview_id where the test was live
AND wp.created_at <= '2012-11-10' -- time of assignment
AND wp.pageview_url IN ('/billing', '/billing-2')
GROUP BY wp.pageview_url
ORDER BY wp.pageview_url
;