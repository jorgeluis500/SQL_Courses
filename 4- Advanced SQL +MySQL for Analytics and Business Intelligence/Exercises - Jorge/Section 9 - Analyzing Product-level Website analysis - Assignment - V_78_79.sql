-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Analyzing Product-level Website analysis
-- Assignment
-- Video 78 and 79
-- Slide 140

-- Sessions which hit the /products page and see where they are next
-- Clickthrough rates from /products since the new product launch on January 06, 2013, by product and compare to the 3 months leading up to the launch as a baseline

-- My solution
-- STEP 1. -- Select sessions with product pages only
-- STEP 2. -- Join those sessions back to the websessions_pageviews
-- STEP 3. -- Build the metrics
-- STEP 4. -- Create the aggregations in the final query

-- The process in the video is different but the results are the same in this case. 
-- Check it to see a new condition in the JOIN clasuse. The solution in the video is bulletproof for more advanced cases

-- After getting the product pages, join back to pageviews on session ID and pageview_id but for the pageview_id on the pageviews site, GREATER than those on the sessions side
-- This way we will have only pageviews that came after the products page


SELECT 
*
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'
ORDER BY 
	website_session_id, 
	website_pageview_id
;

-- STEP 1
-- Select sessions with product pages only

-- DROP TEMPORARY TABLE sessions_w_product_page;
CREATE TEMPORARY TABLE sessions_w_product_page
SELECT 
	website_session_id AS session_id_with_product_page, 
	website_pageview_id AS pageview_id_product_page, 
    created_at AS product_page_hit_at,
	pageview_url AS product_page_url,
    CASE WHEN created_at < '2013-01-06' THEN 'Pre_product_2' ELSE 'Post_product_2' END AS time_period
FROM website_pageviews
WHERE 
	created_at BETWEEN '2012-10-06' AND '2013-04-06'
	AND pageview_url ='/products'
ORDER BY 
	website_session_id, 
	website_pageview_id
;
-- Test
SELECT * FROM sessions_w_product_page;
SELECT 
	time_period,
	COUNT(DISTINCT session_id_with_product_page) AS unique_sessions,
	COUNT(*) 
 FROM sessions_w_product_page GROUP BY time_period;

-- STEP 2
-- Join those sessions back to the websessions_pageviews

-- Test
SELECT 
	*,
	CONCAT(product_page_url, ' --> ',pageview_url) AS product_path
FROM sessions_w_product_page spp
	LEFT JOIN website_pageviews wp
		ON spp.session_id_with_product_page = wp.website_session_id
WHERE pageview_URL IN ('/products','/the-original-mr-fuzzy', '/the-forever-love-bear')
;

-- Test2
SELECT 
	time_period,
	CONCAT(product_page_url, ' --> ',pageview_url) AS product_path,
	COUNT(DISTINCT wp.website_session_id) AS sessions
FROM sessions_w_product_page spp
	LEFT JOIN website_pageviews wp
		ON spp.session_id_with_product_page = wp.website_session_id
WHERE pageview_URL IN ('/products','/the-original-mr-fuzzy', '/the-forever-love-bear')
GROUP BY 1,2
ORDER BY 1,2
;

-- STEP 3 
-- Build the metrics

-- Test a to check the metrics
SELECT 
	*,
	-- COUNT(DISTINCT wp.website_session_id) AS sessions,
	CASE WHEN pageview_url <> '/products' THEN website_session_id ELSE NULL END AS w_next_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END AS to_mr_fuzzy,
	CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END AS to_lovebear
FROM sessions_w_product_page spp
	LEFT JOIN website_pageviews wp
		ON spp.session_id_with_product_page = wp.website_session_id
WHERE pageview_URL IN ('/products','/the-original-mr-fuzzy', '/the-forever-love-bear')
;

-- STEP 4. 
-- Create the aggregations in the final query

SELECT 
	time_period,
	COUNT(DISTINCT wp.website_session_id) AS sessions,
	
    COUNT(DISTINCT CASE WHEN pageview_url <> '/products' THEN website_session_id ELSE NULL END) AS w_next_page,
	COUNT(DISTINCT CASE WHEN pageview_url <> '/products' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT wp.website_session_id) AS pct_to_next_page,
    
    COUNT(DISTINCT CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mr_fuzzy,
	COUNT(DISTINCT CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT wp.website_session_id) AS pct_to_mrfuzzy,
    
    COUNT(DISTINCT CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT wp.website_session_id) AS pct_to_lovebear
    
FROM sessions_w_product_page spp
	LEFT JOIN website_pageviews wp
		ON spp.session_id_with_product_page = wp.website_session_id
WHERE 
	pageview_URL IN ('/products','/the-original-mr-fuzzy', '/the-forever-love-bear')
GROUP BY
	time_period
ORDER BY
	time_period DESC
;