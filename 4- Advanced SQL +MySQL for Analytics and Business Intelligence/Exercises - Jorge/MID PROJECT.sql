-- MID PROJECT
-- Videos 50, 51 and 52
-- Slide 94
-- Date of the request November 27,2012 - '2012-11-27'

USE mavenfuzzyfactory;

-- Question 1
-- Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?

SELECT 
	utm_source,
	YEAR(ws.created_at) AS yr,
	LPAD(MONTH(ws.created_at),2,0) AS mo,
	COUNT(DISTINCT ws.website_session_id) as sessions,
	COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM website_sessions ws
LEFT JOIN orders o
	 ON ws.website_session_id = o.website_session_id
WHERE utm_source = 'gsearch'
AND ws.created_at <= '2012-11-27'
GROUP BY
	utm_source,
	year(ws.created_at),
	LPAD(month(ws.created_at),2,0)
;

-- Question 2
-- Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately. 
-- I am wondering if brand is picking up at all. If so, this is a good story to tell.

-- Option a. We can present it like this, where we see the conversion rate is similar...
SELECT 
	utm_source,
    utm_campaign,
	YEAR(ws.created_at) AS yr,
	LPAD(MONTH(ws.created_at),2,0) AS mo,
	COUNT(DISTINCT ws.website_session_id) as sessions,
	COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM website_sessions ws
LEFT JOIN orders o
	 ON ws.website_session_id = o.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign IN ('nonbrand', 'brand')
AND ws.created_at <= '2012-11-27'
GROUP BY
	utm_source,
    utm_campaign,
	year(ws.created_at),
	LPAD(month(ws.created_at),2,0)
;

-- Option b. we can present it side by side

SELECT 
	utm_source,
	YEAR(ws.created_at) AS yr,
	LPAD(MONTH(ws.created_at),2,0) AS mo,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_orders
FROM website_sessions ws
LEFT JOIN orders o
	 ON ws.website_session_id = o.website_session_id
WHERE utm_source = 'gsearch'
-- AND utm_campaign IN ('nonbrand', 'brand') -- this is optional. The CASE fields take only these into account. The query is faster without this condition, actually
AND ws.created_at <= '2012-11-27'
GROUP BY
	utm_source,
	year(ws.created_at),
	LPAD(month(ws.created_at),2,0)
;

-- Question 3
-- While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? 
-- I want to flex our analytical muscles a little and show the board we really know our traffic sources


-- We can present it in tabular form...
SELECT 
	utm_source,
    ws.utm_campaign,
    ws.device_type,
    YEAR(ws.created_at) AS yr,
	LPAD(MONTH(ws.created_at),2,0) AS mo,
	COUNT(DISTINCT ws.website_session_id) as sessions,
	COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM website_sessions ws
LEFT JOIN orders o
	 ON ws.website_session_id = o.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND ws.created_at <= '2012-11-27'
GROUP BY
	utm_source,
    ws.utm_campaign,
    ws.device_type,
	year(ws.created_at),
	LPAD(month(ws.created_at),2,0)
;

-- or side by side
    
SELECT 
	utm_source,
    utm_campaign,
	YEAR(ws.created_at) AS yr,
	LPAD(MONTH(ws.created_at),2,0) AS mo,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS desktop_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN o.order_id ELSE NULL END) AS desktop_orders,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS mobile_sessions,
	COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN o.order_id ELSE NULL END) AS mobile_orders
FROM website_sessions ws
LEFT JOIN orders o
	 ON ws.website_session_id = o.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND ws.created_at <= '2012-11-27'
GROUP BY
	utm_source,
    utm_campaign,
	year(ws.created_at),
	LPAD(month(ws.created_at),2,0)
;
-- Question 4
-- I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from
-- Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?

SELECT 
	YEAR(created_at) AS yr,
	LPAD(MONTH(created_at),2,0) AS mo,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL THEN website_session_id ELSE NULL END) AS noname_sessions
FROM website_sessions
WHERE created_at <= '2012-11-27'
GROUP BY
	YEAR(created_at),
	LPAD(MONTH(created_at),2,0)
;
-- It's not exaclty like this
-- First we define the channels

SELECT DISTINCT
	utm_source,
	utm_campaign,
	http_referer
FROM website_sessions
WHERE created_at <= '2012-11-27'
ORDER BY
	utm_source
;
-- When utm_source is not null, those are paid sessions (gsearch, bsearch, etc.)
-- When utm_source is null but the http_referer is not null, those are organic search sessions. People use the search engine and then click on a non-paid link
-- When utm_source is null AND the http_referer is null too, it means people came to the website on their on, they typed in the address. Good


SELECT 
	YEAR(created_at) AS yr,
	LPAD(MONTH(created_at),2,0) AS mo,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_paid_sessions,
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
WHERE created_at <= '2012-11-27'
GROUP BY
	YEAR(created_at),
	LPAD(MONTH(created_at),2,0)
;

-- Question 5
-- I’d like to tell the story of our website performance improvements over the course of the first 8 months. Could you pull session to order conversion rates, by month?

SELECT
	YEAR(ws.created_at) as yr,
 	LPAD(MONTH(ws.created_at),2,0) AS mo,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS session_to_order_rate
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE ws.created_at <= '2012-11-27'
GROUP BY
	YEAR(ws.created_at),
 	LPAD(MONTH(ws.created_at),2,0)
    ;

-- Question 6
-- For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR
-- from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)

-- Exploration steps
-- Step a. Find out when the new page stareted receiving pageviews

SELECT 
	pageview_url,
    MIN(website_pageview_id) as first_pageview,
	MIN(created_at) AS first_date
FROM website_pageviews
WHERE pageview_url = '/lander-1'
GROUP BY 
pageview_url
;
-- Answer: '2012-06-19 01:35:54'
-- first_pageview = 23504

-- Analysis. 
-- Step 1. Get min pages per session (and make it a temp table)

-- DROP TEMPORARY TABLE first_page_per_s;
CREATE TEMPORARY TABLE first_page_per_s
SELECT 
	wp.website_session_id,
	MIN(wp.website_pageview_id) as first_page_id
FROM website_pageviews wp
	LEFT JOIN website_sessions ws
		ON wp.website_session_id = ws.website_session_id
WHERE 
	wp.created_at < '2012-07-28' -- prescribed by the asssignment
	AND wp.website_pageview_id >= 23504
    AND ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
GROUP BY
	wp.website_session_id
 ;
-- Test
SELECT * FROM first_page_per_s;

-- Step 2. Bring the url to those pages (and create another temp table)

-- DROP TEMPORARY TABLE first_page_w_url;
CREATE TEMPORARY TABLE first_page_w_url
SELECT 
	fps.website_session_id,
	fps.first_page_id,
	wp.pageview_url
FROM first_page_per_s fps
	LEFT JOIN website_pageviews wp
		ON fps.first_page_id = wp.website_pageview_id
;
-- Test
SELECT * FROM first_page_w_url;

-- Step 3. Join that table with the orders and calculate the conversion rate

SELECT 
	fpu.pageview_url,
	COUNT(DISTINCT fpu.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT fpu.website_session_id) AS sessions_to_order_rate
FROM first_page_w_url fpu
	LEFT JOIN orders o
		ON fpu.website_session_id = o.website_session_id
GROUP BY
	fpu.pageview_url
;
-- from this query, we got that the conversion rates were
# pageview_url	sessions	orders	sessions_to_order_rate
-- /home		0.0319
-- /lander-1	0.0406
-- Difference	0.0087 favourable to lander

-- From here, we find out when was rthe last time /home received a visit. 

SELECT 
	MAX(wp.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions ws
	LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
    AND wp.pageview_url = '/home'
	AND wp.created_at <= '2012-11-27'
;
-- Result: '17145'

-- And from there, we count how many session we have had...

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE 
	utm_source = 'gsearch' 
    AND utm_campaign = 'nonbrand'
    AND website_session_id > 17145
	AND created_at <= '2012-11-27'
;
-- 22972
-- X .0087 incremental conversion = 202 incremental orders since 7/29
-- roughly 4 months, so roughly 50 extra order per month

-- Test
SELECT 
	COUNT(DISTINCT order_id) as orders
FROM orders
WHERE website_session_id > 17145
AND created_at <= '2012-11-27'
;

-- Question 7
-- For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each
-- of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28)

-- STEP 1
-- Select the min page for each session

-- DROP TEMPORARY TABLE first_page_per_session;
CREATE TEMPORARY TABLE first_page_per_session
SELECT 
	wp.website_session_id,
	MIN(wp.website_pageview_id) as first_page_id
FROM website_pageviews wp
	LEFT JOIN website_sessions ws
		ON wp.website_session_id = ws.website_session_id
WHERE 
	wp.created_at BETWEEN '2012-06-19' AND  '2012-07-28'
	AND ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
GROUP BY
	wp.website_session_id
 ;
-- Test
SELECT * FROM first_page_per_session;

-- STEP 2
-- Bring the first page URL 

-- DROP TEMPORARY TABLE first_pages_s;
CREATE TEMPORARY TABLE first_pages_s
SELECT 
	fpps.website_session_id,
	wp.pageview_url AS session_first_page
FROM first_page_per_session fpps
	LEFT JOIN website_pageviews wp
		ON fpps.first_page_id= wp.website_pageview_id
;
-- Test
SELECT * FROM first_pages_s;

-- STEP 3
-- Join first pages with the rest of the pages

SELECT 
	wp.website_session_id, 
	wp.website_pageview_id, 
	fp.session_first_page, 
	wp.pageview_url
FROM website_pageviews wp 
LEFT JOIN first_pages_s fp
	ON fp.website_session_id = wp.website_session_id
LEFT JOIN website_sessions ws
	ON wp.website_session_id = ws.website_session_id
WHERE 
	wp.created_at BETWEEN '2012-06-19' AND  '2012-07-28'
	AND ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
ORDER BY
wp.website_pageview_id
;

-- STEP 4
-- Create the funnel metrics using the previous query

SELECT 
	wp.website_session_id, 
	wp.website_pageview_id, 
	fp.session_first_page, 
	wp.pageview_url,
    CASE WHEN wp.pageview_url ='/products' THEN wp.website_session_id ELSE NULL END AS lander_clickthrough,
    CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN wp.website_session_id ELSE NULL END AS product_clickthrough,
    CASE WHEN wp.pageview_url = '/cart' THEN wp.website_session_id ELSE NULL END AS mrfuzzy_clickthrough,
    CASE WHEN wp.pageview_url = '/shipping' THEN wp.website_session_id ELSE NULL END AS cart_clickthrough,
    CASE WHEN wp.pageview_url = '/billing' THEN wp.website_session_id ELSE NULL END AS shipping_clickthrough,
    CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN wp.website_session_id ELSE NULL END AS billing_clickthrough
FROM website_pageviews wp 
LEFT JOIN first_pages_s fp
	ON fp.website_session_id = wp.website_session_id
LEFT JOIN website_sessions ws
	ON wp.website_session_id = ws.website_session_id
WHERE 
	wp.created_at BETWEEN '2012-06-19' AND  '2012-07-28'
	AND ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
ORDER BY
wp.website_pageview_id
;

-- Agregate the metrics

SELECT 
	fp.session_first_page, 
    COUNT(DISTINCT wp.website_session_id) AS sessions, 
	-- wp.website_pageview_id, 
	-- wp.pageview_url,
    COUNT(DISTINCT CASE WHEN wp.pageview_url ='/products' THEN wp.website_session_id ELSE NULL END) AS lander_clickthrough,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN wp.website_session_id ELSE NULL END) AS product_clickthrough,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/cart' THEN wp.website_session_id ELSE NULL END) AS mrfuzzy_clickthrough,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/shipping' THEN wp.website_session_id ELSE NULL END) AS cart_clickthrough,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/billing' THEN wp.website_session_id ELSE NULL END) AS shipping_clickthrough,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN wp.website_session_id ELSE NULL END) AS billing_clickthrough
FROM website_pageviews wp 
LEFT JOIN first_pages_s fp
	ON fp.website_session_id = wp.website_session_id
LEFT JOIN website_sessions ws
	ON wp.website_session_id = ws.website_session_id
WHERE 
	wp.created_at BETWEEN '2012-06-19' AND  '2012-07-28'
	AND ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
    AND fp.session_first_page <> '/products'
GROUP BY
	fp.session_first_page
;

-- The second part of this is to get the rates, using the previous query

SELECT 
	fp.session_first_page, 
    COUNT(DISTINCT wp.website_session_id) AS sessions, 
	-- wp.website_pageview_id, 
	-- wp.pageview_url,
    COUNT(DISTINCT CASE WHEN wp.pageview_url ='/products' THEN wp.website_session_id ELSE NULL END) / COUNT(DISTINCT wp.website_session_id) AS product_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN wp.website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN wp.pageview_url ='/products' THEN wp.website_session_id ELSE NULL END) AS mrfuzzy_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/cart' THEN wp.website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN wp.website_session_id ELSE NULL END) AS cart_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/shipping' THEN wp.website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN wp.pageview_url = '/cart' THEN wp.website_session_id ELSE NULL END) AS shipping_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/billing' THEN wp.website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN wp.pageview_url = '/shipping' THEN wp.website_session_id ELSE NULL END)AS billing_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN wp.website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN wp.pageview_url = '/billing' THEN wp.website_session_id ELSE NULL END) AS thankyou_clickthrough_rate
FROM website_pageviews wp 
LEFT JOIN first_pages_s fp
	ON fp.website_session_id = wp.website_session_id
LEFT JOIN website_sessions ws
	ON wp.website_session_id = ws.website_session_id
WHERE 
	wp.created_at BETWEEN '2012-06-19' AND  '2012-07-28'
	AND ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
    AND fp.session_first_page <> '/products'
GROUP BY
	fp.session_first_page
;

-- Question 8
-- I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test
-- (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions
-- for the past month to understand monthly impact.

SELECT 
	wp.pageview_url AS billing_version_seen,
	COUNT(wp.website_session_id) AS sessions,
	SUM(o.price_usd) / COUNT(wp.website_session_id) AS revenue_per_billing_page_seen
FROM website_pageviews wp
LEFT JOIN orders o
	ON wp.website_session_id = o.website_session_id
WHERE wp.website_pageview_id >= 53550 -- first pageview_id where the test was live
AND wp.created_at <= '2012-11-10' -- time of assignment
AND wp.pageview_url IN ('/billing', '/billing-2')
GROUP BY wp.pageview_url
ORDER BY wp.pageview_url
;
-- Result
-- Revenue per billing page seen
-- /billing		22.826484
-- /billing-2	31.339297
-- Dif 			8.512813

SELECT 
pageview_url,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_pageviews
WHERE pageview_url IN ('/billing', '/billing-2')
AND created_at BETWEEN '2012-10-27' AND '2012-11-27'
GROUP BY
pageview_url

-- sessions last month
-- /billing		610
-- /billing-2	584

-- The billing 2 page has brought an additional amount of 584 sessions x 8.51 = $4,971
-- The course has a different conclusion, which I disagree with
