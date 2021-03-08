-- FINAL PROJECT
-- Videos 100, 101 and 102
-- Slide 177

USE mavenfuzzyfactory;

-- Question 1

SELECT 
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
    -- COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
-- WHERE YEAR(ws.created_at) < 2015 -- optional since 2015 Q1 is incomplete
GROUP BY
1,2

;


-- Question 2

SELECT 
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conv_rate,
	SUM(price_usd) / COUNT(DISTINCT o.order_id) AS revenue_per_order,
    SUM(price_usd) / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM
    website_sessions ws
        LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
-- WHERE YEAR(ws.created_at) < 2015 -- optional since 2015 Q1 is incomplete
GROUP BY
1,2
;

-- Question 3

-- Exploration

SELECT 
	ROW_NUMBER() over() as index_no, 
	utm_content, utm_campaign, http_referer 
FROM (
	SELECT DISTINCT
	utm_content, utm_campaign, http_referer
	FROM website_sessions
	) AS combinations
;

-- Step 1. Create the classifications

SELECT 
	*,
    CASE 
		WHEN http_referer IS NULL THEN 'direct_type_in' 
		WHEN http_referer IS NOT NULL AND utm_campaign IS NULL THEN 'organic_search'
        WHEN http_referer IS NOT NULL AND utm_campaign = 'brand' THEN 'overall_paid_brand'
		WHEN http_referer = 'https://www.gsearch.com' AND utm_campaign = 'nonbrand' THEN 'gsearch_nonbrand'
        WHEN http_referer = 'https://www.bsearch.com' AND utm_campaign = 'nonbrand' THEN 'bsearch_nonbrand'
        WHEN http_referer IS NOT NULL AND utm_content LIKE '%_ad_%' THEN 'brand_search_overall'
		ELSE 'other_check' END AS traffic_type
    -- YEAR(o.created_at) AS yr,
    -- QUARTER(o.created_at) AS qtr,
   --  COUNT(DISTINCT o.order_id) AS orders
FROM orders o
LEFT JOIN website_sessions ws
	ON o.website_session_id = ws.website_session_id
-- GROUP BY 1 
;

-- Step 2. Create the aggregated metrics

SELECT 
	YEAR(o.created_at) AS yr,
	QUARTER(o.created_at) AS qtr,    
	COUNT( DISTINCT CASE WHEN http_referer = 'https://www.gsearch.com' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS'gsearch_nonbrand',
    COUNT( DISTINCT CASE WHEN http_referer = 'https://www.bsearch.com' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS'bsearch_nonbrand',
	COUNT( DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS 'brand_search_orders',
    COUNT( DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_campaign IS NULL THEN o.order_id ELSE NULL END) AS'organic_search',
    COUNT( DISTINCT CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END) AS'direct_type_in'
FROM orders o
LEFT JOIN website_sessions ws
	ON o.website_session_id = ws.website_session_id
GROUP BY 1,2
ORDER BY 1,2
; 

-- Question 4

-- Test

SELECT 
	YEAR(ws.created_at) AS yr,
	QUARTER(ws.created_at) AS qtr,    
	COUNT( DISTINCT CASE WHEN http_referer = 'https://www.gsearch.com' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS gsearch_orders,  
	COUNT( DISTINCT CASE WHEN http_referer = 'https://www.gsearch.com' AND utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS 'gsearch_sessions',
    
    COUNT( DISTINCT CASE WHEN http_referer = 'https://www.bsearch.com' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS'bsearch_nonbrand_orders',
	COUNT( DISTINCT CASE WHEN http_referer = 'https://www.bsearch.com' AND utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS'bsearch_nonbrand_sessions',
    
    COUNT( DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS 'brand_search_orders',
    COUNT( DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS 'brand_search_sessions',
    
    COUNT( DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_campaign IS NULL THEN o.order_id ELSE NULL END) AS'organic_search_orders',
    COUNT( DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_campaign IS NULL THEN ws.website_session_id ELSE NULL END) AS'organic_search_sessions',
    
    COUNT( DISTINCT CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END) AS'direct_type_in_orders',
	COUNT( DISTINCT CASE WHEN http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS'direct_type_in_sessions',

	COUNT(DISTINCT ws.website_session_id) AS sessions
FROM website_sessions ws
LEFT JOIN orders o
	ON o.website_session_id = ws.website_session_id
GROUP BY 1,2
ORDER BY 1,2
;

-- Metrics
SELECT 
	YEAR(ws.created_at) AS yr,
	QUARTER(ws.created_at) AS qtr,    
	COUNT( DISTINCT CASE WHEN http_referer = 'https://www.gsearch.com' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) /  
	COUNT( DISTINCT CASE WHEN http_referer = 'https://www.gsearch.com' AND utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS 'gsearch_conv_rate',
    
    COUNT( DISTINCT CASE WHEN http_referer = 'https://www.bsearch.com' AND utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) /
	COUNT( DISTINCT CASE WHEN http_referer = 'https://www.bsearch.com' AND utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS'bsearch_nonbrand_conv_rate',
    
    COUNT( DISTINCT CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END) /
    COUNT( DISTINCT CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS 'brand_search_conv_rate',
    
    COUNT( DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_campaign IS NULL THEN o.order_id ELSE NULL END) /
    COUNT( DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_campaign IS NULL THEN ws.website_session_id ELSE NULL END) AS'organic_conv_rate',
    
    COUNT( DISTINCT CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END) /
	COUNT( DISTINCT CASE WHEN http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS'direct_type_in_conv_rate',

	COUNT(DISTINCT ws.website_session_id) AS sessions
FROM website_sessions ws
LEFT JOIN orders o
	ON o.website_session_id = ws.website_session_id
GROUP BY 1,2
ORDER BY 1,2
;

-- Question 5

-- TEST

SELECT 
    oi.order_item_id,
    oi.created_at,
    oi.order_id,
    oi.product_id,
    oi.is_primary_item,
    oi.price_usd,
    oi.cogs_usd,
    p.product_name,
    oi.price_usd - oi.cogs_usd AS margin
FROM
    order_items oi
        LEFT JOIN
    products p ON oi.product_id = p.product_id
;
-- Not used

-- My solution

SELECT 
	YEAR(created_at) AS yr,
	MONTH(created_at) AS mo,
	SUM(CASE WHEN product_id = 1 THEN price_usd ELSE 0 END) AS mrfuzzy_revenue,
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE 0 END) - SUM(CASE WHEN product_id = 1 THEN cogs_usd ELSE 0 END) AS mrfuzzy_margin,

    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE 0 END) AS lovebear_revenue,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE 0 END) - SUM(CASE WHEN product_id = 2 THEN cogs_usd ELSE 0 END) AS lovebear_margin,


    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE 0 END) AS birthdaypanda_revenue,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE 0 END) - SUM(CASE WHEN product_id = 3 THEN cogs_usd ELSE 0 END) AS birthdaypanda_margin,

    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE 0 END) AS hudsonbear_revenue,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE 0 END) - SUM(CASE WHEN product_id = 4 THEN cogs_usd ELSE 0 END) AS hudsonbear_margin,	

    SUM(price_usd) AS total_revenue,
--     COUNT(DISTINCT order_id) as total_orders, -- Not asked
-- 	COUNT(product_id) as total_units, -- Not asked
	SUM(price_usd-cogs_usd) AS total_margin
FROM order_items
GROUP BY 1,2
ORDER BY 1,2
;

-- A more effecive solution, less code

SELECT 
	YEAR(created_at) AS yr,
	MONTH(created_at) AS mo,
	SUM(CASE WHEN product_id = 1 THEN price_usd ELSE 0 END) AS mrfuzzy_revenue,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE 0 END) AS mrfuzzy_margin,

    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE 0 END) AS lovebear_revenue,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE 0 END) AS lovebear_margin,


    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE 0 END) AS birthdaypanda_revenue,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE 0 END) AS birthdaypanda_margin,

    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE 0 END) AS hudsonbear_revenue,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE 0 END) AS hudsonbear_margin,	

    SUM(price_usd) AS total_revenue,
	SUM(price_usd-cogs_usd) AS total_margin
FROM order_items
GROUP BY 1,2
ORDER BY 1,2
;

-- Question 6

-- The questoin can be answered wby creating th /product pages, joinning  it back to paeviews and orders and calculating the rates. 2 queries in total. I used a longer method to be sure

SELECT * FROM website_pageviews ;

-- PART A
-- STEP 1 get the / product page pageview, sessions and urls
-- STEP 2. Bring the rest of the pages below the /product page
-- Step 3. Bring the next page to a temporary table
-- Step 4. Calculate the clickthrough rates
-- PART B
-- Step 1. Use the first created temporary table (/product page) to join with the orders and get the rate
-- Step 2. Calculate the conversion rates

-- DROP TEMPORARY TABLE product_pages;
CREATE TEMPORARY TABLE product_pages
SELECT 
    pageview_url AS product_page,
    created_at As product_page_seen_at,
    website_session_id,
    website_pageview_id
FROM
    website_pageviews
WHERE
    pageview_url = '/products'
ORDER BY
    website_session_id,
    website_pageview_id
;
-- test
SELECT * FROM  product_pages;

-- STEP 2. Bring the rest of the pages

-- Test
SELECT * FROM  website_pageviews
WHERE website_session_id = 6;


SELECT 
    pp.product_page,
    pp.product_page_seen_at,
    pp.website_session_id,
--     pp.website_pageview_id,
    wp.website_pageview_id,
    wp.created_at,
    wp.website_session_id,
    wp.pageview_url
FROM
    product_pages pp
        LEFT JOIN
    website_pageviews wp ON pp.website_session_id = wp.website_session_id
        AND wp.website_pageview_id > pp.website_pageview_id
;

-- Step 3. Bring the next page to a temporary table

-- DROP TEMPORARY TABLE product_pages_w_next;
CREATE TEMPORARY TABLE product_pages_w_next
SELECT 
    pp.product_page,
	DATE(pp.product_page_seen_at) AS product_page_seen_at,
    pp.website_session_id,
    pp.website_pageview_id As pp_pageview,
    MIN(wp.website_pageview_id) AS next_website_pageview_id
FROM
    product_pages pp
        LEFT JOIN
    website_pageviews wp ON pp.website_session_id = wp.website_session_id
        AND wp.website_pageview_id > pp.website_pageview_id
GROUP BY 1,2,3,4
;
-- Test
SELECT * FROM  product_pages_w_next;

-- Step 4 calcualte the rates

SELECT 
	YEAR(product_page_seen_at) As yr,
   	MONTH(product_page_seen_at) As mo,
    COUNT(DISTINCT pp_pageview) As product_pages_seen,
    COUNT(DISTINCT next_website_pageview_id) AS next_pages_seen,
    COUNT(DISTINCT next_website_pageview_id) / COUNT(DISTINCT pp_pageview) AS product_page_clickthrough_rate
FROM
    product_pages_w_next
GROUP BY
1,2
;

-- PART B
-- Use the first created temporary table (/product page) to join with the orders and get the rate

-- Test
SELECT 
*
FROM product_pages pp
	LEFT JOIN orders o 
		ON pp.website_session_id = o.website_session_id
;

SELECT 
	YEAR(pp.product_page_seen_at) AS yr,
   	MONTH(pp.product_page_seen_at) AS mo,
    COUNT(DISTINCT pp.website_session_id) AS product_pages_seen,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT pp.website_session_id) AS order_conv_rate
FROM product_pages pp
	LEFT JOIN orders o 
		ON pp.website_session_id = o.website_session_id
GROUP BY
1,2
;


-- Question 7

-- Step 1 compbine the orders and order items table

SELECT 
	o.order_id,
    o.primary_product_id,
    oi.product_id,
	oi.is_primary_item
FROM orders o
LEFT JOIN order_items oi
	ON o.order_id = oi.order_id
WHERE o.created_at>= '2014-12-05' 
;

-- Step 2 
-- Bringing cross-sell products only

SELECT 
	o.order_id,
    o.primary_product_id,
    oi.product_id ,
    oi.is_primary_item
FROM orders o
LEFT JOIN order_items oi
	ON o.order_id = oi.order_id
    AND oi.is_primary_item = 0 -- Bring only cross-sell products
WHERE o.created_at>= '2014-12-05'
;

-- Step 3
-- Count the orders by product and cross-sell product

SELECT 
    o.primary_product_id,
	oi.product_id as x_sell_products,
   	COUNT(DISTINCT o.order_id) as orders
FROM orders o
LEFT JOIN order_items oi
	ON o.order_id = oi.order_id
    AND oi.is_primary_item = 0 -- Bring only cross-sell products. This condition can also be included in the where
WHERE o.created_at>= '2014-12-05'
GROUP BY 1,2
;
-- Step 4
-- Pivot the results to see them better

SELECT 
    o.primary_product_id,
	COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN o.order_id ELSE NULL END) AS x_sell_product_1,
   	COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN o.order_id ELSE NULL END) AS x_sell_product_2,
    COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN o.order_id ELSE NULL END) AS x_sell_product_3,
       COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN o.order_id ELSE NULL END) AS x_sell_product_4,
-- rates
    COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS x_sell_product_1_rt,
   	COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS x_sell_product_2_rt,
    COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS x_sell_product_3_rt,
    COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN o.order_id ELSE NULL END) / COUNT(DISTINCT o.order_id) AS x_sell_product_4_rt
FROM orders o
LEFT JOIN order_items oi
	ON o.order_id = oi.order_id
    AND oi.is_primary_item = 0 -- Bring only cross-sell products. This condition can also be included in the where
WHERE o.created_at>= '2014-12-05'
GROUP BY 1
;

-- Question 8
