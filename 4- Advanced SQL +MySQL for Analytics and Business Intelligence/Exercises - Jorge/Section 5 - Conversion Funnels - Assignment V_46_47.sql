-- Section 5 - Analyzing website performance
-- Building Conversion funnels
-- Videos 46 and 47

USE mavenfuzzyfactory;

-- ASSIGNMENT
-- build us a full conversion funnel, analyzing how many customers make it to each step?
-- Start with /lander-1 and build the funnel all the way to our thank you page. Please use data since August 5th and gsearch (and nonbrand?)
-- Date of the request: '2012-09-05'

-- STEP 1
-- Step 1a: Explore the sessions

SELECT *
FROM website_sessions
WHERE created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
;

-- Step 1 b: make sure lander-1 is the only landing page on that period

SELECT 
    wp.pageview_url,
    COUNT(*)
FROM website_pageviews wp
LEFT JOIN website_sessions ws
	ON  wp.website_session_id = ws.website_session_id
WHERE ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
GROUP BY
    wp.pageview_url;

-- It is. Had it not been the case (for example if the exercise hadn't mentioned the gsearch condition), the sessions with /home would have been to be excluded
-- This table eliminate the seesions that began with /home

/*
-- DROP TEMPORARY TABLE sessions_no_home;
CREATE TEMPORARY TABLE sessions_no_home
SELECT
	website_session_id
FROM(
		SELECT 
			website_session_id,
			MAX(CASE WHEN pageview_url =  '/home' THEN 1 ELSE 0 END) AS session_w_home
		FROM website_pageviews
		WHERE created_at BETWEEN '2012-08-05' AND '2012-09-05'
		GROUP BY
		website_session_id
		) AS sesions_w_home_flagged
WHERE session_w_home = 0
ORDER BY
	website_session_id
;
-- Test
SELECT * FROM sessions_no_home;

-- and then , we could have continued, using the new sessions_no_home table (which exclude sessions with /home) instead of the original sessions table
-- BUT BEWARE, the created_at field should come from the sessions table, to be really accurate
*/

-- STEP 2
-- bring the pageviews

SELECT 
	ws.website_session_id,
	wp.created_at,
	wp.pageview_url
FROM website_sessions ws
LEFT JOIN website_pageviews wp
	ON ws.website_session_id = wp.website_session_id
WHERE ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
;

-- STEP 2: 
-- Step 2a: out of the previous query, create the individual stages with the flags

SELECT 
	ws.website_session_id,
	wp.created_at,
	wp.pageview_url,
	CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions ws
LEFT JOIN website_pageviews wp
	ON ws.website_session_id = wp.website_session_id
WHERE ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
ORDER BY
	ws.website_session_id,
	ws.created_at
;

-- Step 2b
-- Turn the previous query into a subquery, get the MAX for each metric and group by website_session_id

-- DROP TEMPORARY TABLE unique_sessions_and_metrics;
CREATE TEMPORARY TABLE unique_sessions_and_metrics
SELECT
	website_session_id,
	MAX(product_page) AS made_it_to_product,
    MAX(mrfuzzy_page) AS made_it_to_mrfuzzy,
    MAX(cart_page) AS made_it_to_cart,
    MAX(shipping_page) AS made_it_to_shipping,
    MAX(billing_page) AS made_it_to_billing,
    MAX(thankyou_page) AS made_it_to_thankyou
FROM (
		SELECT 
			ws.website_session_id,
			wp.created_at,
			wp.pageview_url,
			CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
			CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
			CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
			CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
			CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
			CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
		FROM website_sessions ws
		LEFT JOIN website_pageviews wp
			ON ws.website_session_id = wp.website_session_id
		WHERE ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
			AND ws.utm_source = 'gsearch'
			AND ws.utm_campaign = 'nonbrand'
		ORDER BY
			ws.website_session_id,
			ws.created_at
) AS stages_and_flags
GROUP BY
	website_session_id
;
-- Test
SELECT * FROM unique_sessions_and_metrics;

-- STEP 4
-- Finally, create the aggregations out of the temporary query

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions, 
	COUNT(DISTINCT CASE WHEN made_it_to_product = 1 THEN website_session_id ELSE NULL END) AS lander_clickthrough, 
	COUNT(DISTINCT CASE WHEN made_it_to_mrfuzzy = 1 THEN website_session_id ELSE NULL END) AS product_clickthrough,
	COUNT(DISTINCT CASE WHEN made_it_to_cart = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_clickthrough,
	COUNT(DISTINCT CASE WHEN made_it_to_shipping = 1 THEN website_session_id ELSE NULL END) AS cart__clickthrough,
	COUNT(DISTINCT CASE WHEN made_it_to_billing = 1 THEN website_session_id ELSE NULL END) AS shipping_clickthrough,
	COUNT(DISTINCT CASE WHEN made_it_to_thankyou = 1 THEN website_session_id ELSE NULL END) AS billing_clickthrough
FROM unique_sessions_and_metrics
;

-- Step 4b would be to create the rates

-- ------------------------------

-- STEP 3 (quick method)
-- Step 3a: Out of the previous query, create the agggregations, this time with the quick method

SELECT 
	COUNT(DISTINCT ws.website_session_id) AS sessions,
-- 	wp.created_at,
-- 	wp.pageview_url,
	SUM(CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) AS lander_clickthrough,
    SUM(CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS product_clickthrough,
    SUM(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) AS mrfuzzy_clickthrough,
    SUM(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) AS cart__clickthrough,
    SUM(CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END) AS shipping_clickthrough,
    SUM(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS billing_clickthrough
FROM website_sessions ws
LEFT JOIN website_pageviews wp
	ON ws.website_session_id = wp.website_session_id
WHERE ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
;
-- Step 3b: and the rates (quick method)

SELECT 
	COUNT(DISTINCT ws.website_session_id) AS sessions,
-- 	wp.created_at,
-- 	wp.pageview_url,
	SUM(CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) / COUNT(DISTINCT ws.website_session_id) AS product_clickthrough_rate,
    SUM(CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) / SUM(CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) AS mrfuzzy_clickthrough_rate,
    SUM(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) / SUM(CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS cart_clickthrough_rate,
    SUM(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) / SUM(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) AS shipping_clickthrough_rate,
    SUM(CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END) / SUM(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) AS billing_clickthrough_rate,
    SUM(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) / SUM(CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END) AS thankyou_clickthrough_rate
FROM website_sessions ws
LEFT JOIN website_pageviews wp
	ON ws.website_session_id = wp.website_session_id
WHERE ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
;
