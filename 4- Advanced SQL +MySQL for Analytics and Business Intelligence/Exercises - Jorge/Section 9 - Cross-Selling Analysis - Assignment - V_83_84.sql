-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Cross-Selling and Analysis
-- Asigment
-- Videos 83 and 84
-- Slide 148

-- On September 25th (2013) we started giving customers the option to add a 2nd product while on the /cart page.

-- Compare the month before vs the month after the change
-- I’d like to see CTR (Clickthrough) from the /cart page, Avg Products per Order, AOV (Average order value), and overall revenue per /cart page view.

-- STEP 1 -- Select sessions with cart sessions
-- STEP 2 -- Join the cart sessions with all the pageviews table on website session and the pageviews higher than the cart pageview number
-- STEP 3 -- Next, give me the page that came after cart. Get the min page per session from the previous query
-- STEP 4 -- Join orders table to the cart and afer table
-- Step 5 -- Build the metrics, addding all the fields and then eliminating those that are not needed

-- Tables exploration

SELECT 
	*
FROM orders
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
;

SELECT 
	*
FROM order_items
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
;

SELECT 
	*
FROM website_sessions
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
;

SELECT 
	*
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
-- AND website_pageview_id =
;

-- STEP 1
-- Select sessions with cart sessions

-- DROP TEMPORARY TABLE cart_sessions;
CREATE TEMPORARY TABLE cart_sessions
SELECT 
	website_session_id, 
    website_pageview_id, 
    pageview_url, 
    CASE WHEN created_at < '2013-09-25' THEN 'A_Pre_Cros_Sell' ELSE 'B_Post_Cros_Sell' END AS time_period
FROM website_pageviews
WHERE 
	created_at BETWEEN '2013-08-25' AND '2013-10-25'
	AND pageview_url = '/cart'
ORDER BY 	
    website_session_id, 
    website_pageview_id
;
-- Test
SELECT * FROM cart_sessions;

-- STEP 2
-- Join the cart sessions with all the pageviews table on website session
-- and the pageviews higher than the cart pageview number

-- Test 
SELECT 
*
FROM cart_sessions cs
	LEFT JOIN website_pageviews wp
		ON cs.website_session_id = wp.website_session_id
		AND wp.website_pageview_id > cs.website_pageview_id
;

-- STEP 3
-- Next, give me the page that came after cart. 
-- Get the min page per session from the previous query

-- DROP TEMPORARY TABLE cart_and_after;
CREATE TEMPORARY TABLE cart_and_after
SELECT 
	cs.website_session_id, 
	cs.website_pageview_id, 
	cs.pageview_url, 
	cs.time_period, 
	MIN(wp.website_pageview_id) AS after_cart
	-- created_at, 
	-- website_session_id, 
	-- wp.pageview_url
FROM cart_sessions cs
	LEFT JOIN website_pageviews wp
		ON cs.website_session_id = wp.website_session_id
			AND wp.website_pageview_id > cs.website_pageview_id
GROUP BY
	cs.website_session_id, 
	cs.website_pageview_id, 
	cs.pageview_url, 
	cs.time_period 
ORDER BY
	cs.website_session_id
;
-- Test
SELECT * FROM cart_and_after;

-- STEP 3a. Checking
-- Bring the pageview_url to be sure that the page that the page we got with the MIN (the one that comes after cart) is shipping, 

SELECT caa.website_session_id,
       caa.website_pageview_id,
       caa.pageview_url,
       caa.time_period,
       caa.after_cart,
       wp.pageview_url
FROM cart_and_after caa
    LEFT JOIN website_pageviews wp
        ON caa.after_cart = wp.website_pageview_id
;
-- STEP 4. 
-- Join orders table to the cart and afer table

-- Test
SELECT 
*
FROM cart_and_after caa
	LEFT JOIN orders o
		ON caa.website_session_id = o.website_session_id
;

-- Step 5. 
-- Build the metrics, addding all the fields and then eliminating those that are not needed

SELECT 
    caa.time_period,
    COUNT(DISTINCT caa.website_session_id) AS cart_sessions,
    -- caa.website_pageview_id,
    -- caa.pageview_url,
    COUNT(DISTINCT caa.after_cart) AS clickthrough,
    COUNT(DISTINCT caa.after_cart) / COUNT(DISTINCT caa.website_session_id) AS cart_ctr,
    /* o.order_id,
    o.created_at,
    o.website_session_id,
    o.user_id,
    o.primary_product_id,*/
    AVG(o.items_purchased) AS products_per_order,
    AVG(o.price_usd) AS AOV,
    SUM(o.price_usd) / COUNT(DISTINCT caa.website_session_id) AS rev_per_cart_sesssion
    -- o.cogs_usd
FROM
    cart_and_after caa
        LEFT JOIN
    orders o ON caa.website_session_id = o.website_session_id
GROUP BY
    caa.time_period
;