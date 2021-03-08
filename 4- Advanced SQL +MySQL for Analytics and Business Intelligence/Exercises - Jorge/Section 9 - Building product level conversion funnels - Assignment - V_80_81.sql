-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Building product level conversion funnels
-- Assignment
-- Video 80 and 81
-- Slide 143

-- look at our two products since January 6th and analyze the conversion funnels from each product page to conversion.
-- produce a comparison between the two conversion funnels, for all website traffic.

-- STEP 1. -- Finding the initial pages we need, Mr Fuzzy and Love bear
-- STEP 2. -- Joining it back to pageviews for pagevies that occured after the products
-- STEP 3. -- Test the conditions with the previous query
-- STEP 4a. -- Create the aggregations
-- STEP 4b. -- Conversion rates

-- Test
SELECT 
*
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
AND website_session_id = '63516'
;

-- STEP 1
-- Finding the initial pages we need, Mr Fuzzy and Love bear

-- DROP TEMPORARY TABLE product_pageviews;
CREATE TEMPORARY TABLE product_pageviews
SELECT 
	website_pageview_id, 
    created_at, 
    website_session_id, 
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 'mr_fuzzy' ELSE 'love_bear' END AS pageview_url
FROM website_pageviews
WHERE 
	created_at BETWEEN '2013-01-06' AND '2013-04-10'
	AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
-- ORDER BY 
	-- website_session_id,
	-- website_pageview_id
;
-- Test
SELECT * FROM product_pageviews;
    
    
-- STEP 2
-- Joining it back to pageviews for pagevies that occured after the products

SELECT 
*
-- DISTINCT wp.pageview_url -- This test allows us to see which pages come after the product pages
FROM product_pageviews pp
	LEFT JOIN website_pageviews wp
		ON pp.website_session_id = wp.website_session_id
        AND wp.website_pageview_id > pp.website_pageview_id
ORDER BY 
	pp.website_session_id,
	pp.website_pageview_id
    
;

-- STEP 3
-- Test the conditions with the previous query

SELECT *,
	pp.pageview_url AS product_seen ,
--  	COUNT(DISTINCT pp.website_session_id) as sessions,
	CASE WHEN wp.pageview_url = '/cart' THEN pp.website_session_id ELSE NULL END AS to_cart,
    CASE WHEN wp.pageview_url = '/shipping' THEN pp.website_session_id ELSE NULL END AS to_shippping,
    CASE WHEN wp.pageview_url = '/billing-2' THEN pp.website_session_id ELSE NULL END AS to_billing,
    CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN pp.website_session_id ELSE NULL END AS to_thankyou
FROM product_pageviews pp
	LEFT JOIN website_pageviews wp
		ON pp.website_session_id = wp.website_session_id
        AND wp.website_pageview_id > pp.website_pageview_id
-- GROUP BY 
	-- pp.website_pageview_id
;

-- STEP 4a 
-- Create the aggregations

SELECT
	pp.pageview_url AS product_seen ,
 	COUNT(DISTINCT pp.website_session_id) as sessions,
	COUNT(DISTINCT CASE WHEN wp.pageview_url = '/cart' THEN pp.website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/shipping' THEN pp.website_session_id ELSE NULL END) AS to_shippping,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/billing-2' THEN pp.website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN pp.website_session_id ELSE NULL END) AS to_thankyou
FROM product_pageviews pp
	LEFT JOIN website_pageviews wp
		ON pp.website_session_id = wp.website_session_id
        AND wp.website_pageview_id > pp.website_pageview_id
GROUP BY 
	pp.pageview_url 
;

-- Test
SELECT 
	COUNT(DISTINCT website_session_id) AS sessions
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
--  AND pageview_url = '/thank-you-for-your-order'
AND pageview_url = '/billing-2'
;

-- STEP 4b
-- Conversion rates

SELECT
	pp.pageview_url AS product_seen,
--  	COUNT(DISTINCT pp.website_session_id) as sessions,
	COUNT(DISTINCT CASE WHEN wp.pageview_url = '/cart' THEN pp.website_session_id ELSE NULL END) / COUNT(DISTINCT pp.website_session_id) AS product_page_click_rt,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/shipping' THEN pp.website_session_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN wp.pageview_url = '/cart' THEN pp.website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/billing-2' THEN pp.website_session_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN wp.pageview_url = '/shipping' THEN pp.website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN pp.website_session_id ELSE NULL END) 
    / COUNT(DISTINCT CASE WHEN wp.pageview_url = '/billing-2' THEN pp.website_session_id ELSE NULL END) AS billing_click_rt
FROM product_pageviews pp
	LEFT JOIN website_pageviews wp
		ON pp.website_session_id = wp.website_session_id
        AND wp.website_pageview_id > pp.website_pageview_id
GROUP BY 
	pp.pageview_url 
;
