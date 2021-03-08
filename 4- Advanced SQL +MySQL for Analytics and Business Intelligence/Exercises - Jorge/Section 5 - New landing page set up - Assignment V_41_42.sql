-- Section 5 - Analyzing website performance

USE mavenfuzzyfactory;

-- Assignemnt. Videos 41 and 42
-- New landing page set up: /lander-1. Traffic 50/50. Analyze bounce rate and compare it with home page, only for dates where the new page went live. 
-- Sessions for gsearch nonbrand traffic only
-- Date of the request: '2012-07-28'

-- EXPLORATION
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
-- One important detail is that we need to use the exact moment where the the new landing page goes live, 
-- so, ideally we should use the min pageview_id for our lower limit in subsequent queries. I used the whole datetime returned in the this query. 
-- The result is almost identical but beter to have more precision with the pageview

-- Step b
-- How many sessions are there in the period?

SELECT 
*
FROM website_sessions
WHERE 
created_at BETWEEN '2012-06-19 01:35:54' AND '2012-07-28' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand';
-- Answer 4,574

-- Step c
-- Check the number or records in website_pageviews for the period

SELECT 
*
FROM website_pageviews
WHERE created_at BETWEEN '2012-06-19 01:35:54' AND '2012-07-28';
-- Answer 11,492

-- -- Step d. How many records are we going to be working with? page views joined with sessions for the period and specific source and campaign

SELECT 
	COUNT(DISTINCT wp.website_pageview_id) AS unique_pageviews -- website_pageview_id is already unique but the DISTINCT is used just in case
FROM website_pageviews wp
LEFT JOIN website_sessions ws
	 ON wp.website_session_id = ws.website_session_id 
WHERE wp.created_at BETWEEN '2012-06-19 01:35:54' AND '2012-07-28'
AND ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand'
;
-- Answer: 9,658

-- Step e
-- How many unique sessions are there when the join is made? 
SELECT 
	COUNT(DISTINCT wp.website_session_id) AS unique_sessions
FROM website_pageviews wp
LEFT JOIN website_sessions ws
	 ON wp.website_session_id = ws.website_session_id 
WHERE wp.created_at BETWEEN '2012-06-19 01:35:54' AND '2012-07-28'
AND ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand'
;
-- Answer: 4,574

-- ANALYSIS 
-- Step 1 Get new minimum pageview for each session

-- DROP TEMPORARY TABLE first_page_per_s;
CREATE TEMPORARY TABLE first_page_per_s
SELECT 
	wp.website_session_id,
	MIN(wp.website_pageview_id) as first_page_id
FROM website_pageviews wp
	LEFT JOIN website_sessions ws
		ON wp.website_session_id = ws.website_session_id
WHERE 
	wp.created_at BETWEEN '2012-06-19 01:35:54' AND '2012-07-28'
	AND ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
GROUP BY
	wp.website_session_id
;
-- Test
SELECT * FROM first_page_per_s;

-- Step 2
-- Step 2. Bring the page URL to those first pages. We will have only sessions and their (first) landing pages

-- DROP TEMPORARY TABLE landing_pages;
CREATE TEMPORARY TABLE landing_pages
SELECT 
	fpps.website_session_id,
	wpv.pageview_url
FROM first_page_per_s fpps
LEFT JOIN website_pageviews wpv
    ON fpps.first_page_id = wpv.website_pageview_id
;
-- Test
SELECT * FROM landing_pages;

-- Step 3. Next, out of the landing page table we just created, we will bring the website_pageviews, count them and filter only those sessions having 1 pageview, 
-- 		   and then filter to 1 pageview to get bounced sessions only

-- DROP TEMPORARY TABLE bounce_sessions;
CREATE TEMPORARY TABLE bounce_sessions
SELECT 
	lp.website_session_id,
    lp.pageview_url,
    COUNT(DISTINCT wp.website_pageview_id) AS bounced_sessions
FROM landing_pages lp
LEFT JOIN website_pageviews wp
	ON lp.website_session_id = wp.website_session_id 
GROUP BY
	lp.pageview_url,
    lp.website_session_id
HAVING 
	COUNT(DISTINCT wp.website_pageview_id) = 1
    ;
-- Test
SELECT * FROM bounce_sessions;

-- Step 4. Finally, we get the sessions and their landing pages URL (landing pages) and the bounced sessions together. Then we get the metrics. 

SELECT 
	lp.pageview_url,
	lp.website_session_id,
	bs.website_session_id AS bounced_website_session_id
FROM landing_pages lp
LEFT JOIN bounce_sessions bs
	ON lp.website_session_id = bs.website_session_id
ORDER BY 
lp.website_session_id
;

SELECT 
	lp.pageview_url,
	COUNT(DISTINCT lp.website_session_id) AS all_sessions,
	COUNT(DISTINCT bs.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bs.website_session_id)  / COUNT(DISTINCT lp.website_session_id) AS bounced_rate
FROM landing_pages lp
LEFT JOIN bounce_sessions bs
	ON lp.website_session_id = bs.website_session_id
GROUP BY
	lp.pageview_url
;
-- -------------------------------------------------------------------------------------------------------------

-- Alternative method

-- Step 1
	-- Rank the pageviews ascending and descending
	-- Ascending will tell you which is the landing page. pv_rank_asc = 1
	-- Descending will tell you if the session is bounced, meaning it had only one view. pv_rank_desc = 1

-- DROP TEMPORARY TABLE ranked_pageviews;
CREATE TEMPORARY TABLE ranked_pageviews
SELECT 
	wp.website_session_id,
    wp.website_pageview_id,
    wp.created_at,
    wp.pageview_url,
    ROW_NUMBER() OVER (partition by wp.website_session_id ORDER BY wp.website_session_id, wp.created_at) AS page_rank_asc,
	ROW_NUMBER() OVER (partition by wp.website_session_id ORDER BY wp.website_session_id, wp.created_at DESC) AS page_rank_desc
FROM website_pageviews wp
LEFT JOIN website_sessions ws
	 ON wp.website_session_id = ws.website_session_id 
WHERE 
	wp.created_at BETWEEN '2012-06-19 01:35:54' AND '2012-07-28'
	AND ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
ORDER BY
	wp.website_session_id,
	wp.website_pageview_id
;
-- Test
SELECT * FROM ranked_pageviews;

-- Step 2
	-- Based on the previous query and rankings, we will create landing pages (pv_rank_asc = 1) and bounced sessions (pv_rank_desc = 1)
	-- This step is included for clarity, to better understand the process

SELECT 
	*,
	CASE WHEN page_rank_desc != 1 THEN website_session_id END AS not_bounced_session,
	CASE WHEN page_rank_desc = 1 THEN website_session_id END AS bounced_session
FROM ranked_pageviews
WHERE page_rank_asc = 1;

-- Step 3
	-- Use the previous query to get aggregate the fields and get the metrics
	-- Or, like in this case, use the first query to get the results
    
SELECT 
	pageview_url,
	COUNT(DISTINCT website_session_id) AS all_sessions,
	COUNT(DISTINCT CASE WHEN page_rank_desc = 1 THEN website_session_id END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN page_rank_desc = 1 THEN website_session_id END) / COUNT(DISTINCT website_session_id) AS bounce_rate
FROM ranked_pageviews
WHERE page_rank_asc = 1
GROUP BY
	pageview_url;

