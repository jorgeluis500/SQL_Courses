-- Section 5 - Analyzing website performance
-- Building Conversion funnels
-- Video 45

USE mavenfuzzyfactory;

-- BUSINESS CONTEXT
	-- We want to build a mini conversion funnel, from lander 2 to cart
    -- We weant to know how many people reached each step, and also dropoff rates
    -- For simplicity, we will look at /lander-2 traffic only
    -- For simplicity, we're looking at customer whol liked Mr Fuzzy only
    
    -- Process
-- STEP 1: select all pageviews for relevant sessions
-- STEP 2: identify each relevant pageview as the specific funnel step (with flags)
-- STEP 3: create a sesion level conversion view
-- STEP 4 aggregate the data to assess funnel performance
    
    
-- STEP 1: select all pageviews for relevant sessions

-- Step 1a: the relevant sessions
SELECT 
	website_session_id
FROM website_sessions
WHERE 
	created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe for demo purposes
;

-- Step 1b: the relevant sessions with the pageviews
SELECT 
	ws.website_session_id,
    wp.website_pageview_id,
    wp.pageview_url
FROM website_sessions ws
LEFT JOIN website_pageviews wp
	ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe for demo purposes
    AND pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	ws.website_session_id,
    wp.website_pageview_id
;    
-- STEP 2: identify each relevant pageview as the specific funnel step (with flags)

-- Step 2a.
-- Copy the previous query but create the flags this time

SELECT 
	ws.website_session_id,
    wp.website_pageview_id,
    wp.pageview_url,
    CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page, -- new
    CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page, -- new
    CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page -- new
FROM website_sessions ws
LEFT JOIN website_pageviews wp
	ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe for demo purposes
    AND pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	ws.website_session_id,
    wp.website_pageview_id
;

-- After this step, the final query can be constructed using SUMs. That query is at the bottom of the exercise. The following ones are from the video

-- STEP 3
-- Step 3a
-- Turn the previous query into a subquery and get the MAX of each flag, grouping only by website_session_id.
-- This MAX will indicate if the page made it in the session, which now are one by line.

SELECT
	website_session_id,
	MAX(product_page) AS product_made_it,
	MAX(mr_fuzzy_page) AS mr_fuzzy_made_it,
	MAX(cart_page) AS cart_made_it
FROM( 

SELECT 
	ws.website_session_id,
    wp.website_pageview_id,
    wp.pageview_url,
    CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page, -- new
    CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page, -- new
    CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page -- new
FROM website_sessions ws
LEFT JOIN website_pageviews wp
	ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe for demo purposes
    AND pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	ws.website_session_id,
    wp.website_pageview_id
) as pageview_level

GROUP BY
	website_session_id
;

-- Step 3b
-- Next, we turn that into a temporary table to, later, create the aggregations

-- DROP TEMPORARY TABLE session_level_made_it_flags;
CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT
	website_session_id,
	MAX(product_page) AS product_made_it,
	MAX(mr_fuzzy_page) AS mr_fuzzy_made_it,
	MAX(cart_page) AS cart_made_it
FROM( 

SELECT 
	ws.website_session_id,
    wp.website_pageview_id,
    wp.pageview_url,
    CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page, -- new
    CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page, -- new
    CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page -- new
FROM website_sessions ws
LEFT JOIN website_pageviews wp
	ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe for demo purposes
    AND pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
ORDER BY
	ws.website_session_id,
    wp.website_pageview_id
) as pageview_level

GROUP BY
	website_session_id
;
-- Test
SELECT * FROM session_level_made_it_flags;

-- STEP 4
-- Step 4a: Wrap the prevoius query in aggregations to have the funnel

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS lander_clickedthrough,
	COUNT(DISTINCT CASE WHEN mr_fuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS product_page_clickedthrough,
	COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS mr_fuzzy_page_clickedthrough
FROM session_level_made_it_flags
;

-- Step 4a: Create percentages from one stage to the other

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS lander_clickthrough_rate,
	COUNT(DISTINCT CASE WHEN mr_fuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS product_clickedthrough_rate,
	COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN mr_fuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mr_fuzzy_clickedthrough_rate
FROM session_level_made_it_flags
;

-- The end
-- ------------------------------------------------------------
-- Quicker method
-- After creating the flags in step 2, the query can be finalized by counting the sessions and wraping the CASEs in SUms:

SELECT 
	COUNT( DISTINCT ws.website_session_id) AS lander_page,
    -- wp.website_pageview_id,
    -- wp.pageview_url,
    SUM(CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) AS product_page, 
    SUM(CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mr_fuzzy_page, 
    SUM(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_page 
FROM website_sessions ws
LEFT JOIN website_pageviews wp
	ON ws.website_session_id = wp.website_session_id
WHERE 
	ws.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe for demo purposes
    AND wp.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')
;
