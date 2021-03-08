-- Section 5 - Analyzing website performance

USE mavenfuzzyfactory;

-- Assignment. Videos 39 and 40
-- Bounce rate for traffic landing in the homepage. Date of the request: '2012-06-14'

-- Procces
-- Step 1. Get the first page per session, aka, the MIN per session
-- Step 2. Bring the page URL to those first pages. We will have only sessions and their (first) landing pages
-- Step 3. Next, out of the landing page table we just created, we will create a table that count of pageviews per session, and then filter to 1 pageview to get bounced sessions only
-- Step 4. Finally, we get the sessions and their landing pages (ses_landing pages) and the bounced sessions together. Then we get the metrics. 

-- Exploration
-- General and records
SELECT 
*
FROM website_pageviews
WHERE created_at < '2012-06-14'
;
-- 22,198 records

-- How many uniquie sessions do we have?
SELECT 
COUNT(DISTINCT website_session_id) AS unique_sessions
FROM website_pageviews
WHERE created_at < '2012-06-14'
;
-- 11,044 unique sessions

-- Step 1. Get the first page per session, aka, the MIN per session

CREATE TEMPORARY TABLE first_page_per_session
SELECT 
	website_session_id,
	MIN(website_pageview_id) as min_page
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY
	website_session_id
 ORDER BY 1
 ;
-- Test
SELECT * FROM first_page_per_session;

-- Step 2. Bring the page URL to those first pages. We will have only sessions and their (first) landing pages

DROP TEMPORARY TABLE ses_landing_page;
CREATE TEMPORARY TABLE ses_landing_page
SELECT 
	fpps.website_session_id,
	wpv.pageview_url AS landing_page
FROM first_page_per_session fpps
	LEFT JOIN website_pageviews wpv
		ON wpv.website_pageview_id = fpps.min_page
WHERE wpv.created_at < '2012-06-14'
;
-- Test
SELECT * FROM ses_landing_page;

-- Step 3. Next, out of the landing page table we just created, we will create a table that count of pageviews per session, 
-- and then filter to 1 pageview to get bounced sessions only
-- We do that by bringing the website_pageviews, count them and filter only those sessions having 1 pageview

CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	slp.website_session_id,
	slp.landing_page,
    COUNT(DISTINCT wpv.website_pageview_id) AS count_of_pages_viewed
FROM ses_landing_page slp
LEFT JOIN website_pageviews wpv
	ON slp.website_session_id = wpv.website_session_id
GROUP BY
	slp.website_session_id,
	slp.landing_page
HAVING 
	COUNT(DISTINCT wpv.website_pageview_id) = 1
;
-- Test
SELECT * FROM bounced_sessions;

-- Step 4. Finally, we get the sessions and their landing pages URL (ses_landing pages) and the bounced sessions together. Then we get the metrics. 

SELECT 
	slp.landing_page,
	bs.website_session_id AS bounced_sessions_id,
    slp.website_session_id AS total_sessions_id
FROM ses_landing_page slp
LEFT JOIN bounced_sessions bs
	ON slp.website_session_id = bs.website_session_id
;

SELECT 
	slp.landing_page,
	COUNT(DISTINCT bs.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT slp.website_session_id) AS total_sessions,
	COUNT(DISTINCT bs.website_session_id) / COUNT(DISTINCT slp.website_session_id) AS bouned_rate
FROM ses_landing_page slp
LEFT JOIN bounced_sessions bs
	ON slp.website_session_id = bs.website_session_id
GROUP BY
	slp.landing_page
; 

-- Alternative method

-- Step 1
	-- Rank the pageviews ascending and descending
	-- Ascending will tell you which is the landing page. pv_rank_asc = 1
	-- Descending will tell you if the session is bounced, meaning it had only one view. pv_rank_desc = 1

CREATE TEMPORARY TABLE pageviews_ranked
SELECT 
	*,
	ROW_NUMBER() OVER (PARTITION BY website_session_id ORDER BY website_session_id, created_at) AS pv_rank_asc,
	ROW_NUMBER() OVER (PARTITION BY website_session_id ORDER BY website_session_id, created_at DESC) AS pv_rank_desc
FROM website_pageviews
WHERE created_at < '2012-06-14'
ORDER BY
	website_session_id, 
    created_at
;
-- Test
SELECT * FROM pageviews_ranked;

-- Step 2
	-- Based on the previous query and rankings, we will create landing pages (pv_rank_asc = 1) and bounced sessions (pv_rank_desc = 1)
	-- This step is included for clarity, to better understand the process

CREATE TEMPORARY TABLE sessions_and_bounces
SELECT 
	website_session_id,
	pageview_url,
	pv_rank_asc,
	pv_rank_desc,
	CASE WHEN pv_rank_desc =1 THEN website_session_id END AS bounced_session_id
FROM pageviews_ranked
WHERE pv_rank_asc = 1
ORDER BY website_session_id
;
-- Test
SELECT * FROM sessions_and_bounces;

-- Step 3
	-- Use the previous query to get aggregate the fields and get the metrics

SELECT 
	pageview_url,
	COUNT(DISTINCT bounced_session_id) AS bounced_sessions,
    COUNT(DISTINCT website_session_id) AS all_sessions,
   	COUNT(DISTINCT bounced_session_id) / COUNT(DISTINCT website_session_id) AS bounce_rate
FROM sessions_and_bounces
GROUP BY pageview_url
;

-- Steps 2 and 3 of the previous method could be created in one query to get the final result, like this

SELECT 
	pageview_url,
    COUNT(DISTINCT CASE WHEN pv_rank_desc =1 THEN website_session_id END) AS bounced_sessions, 
	COUNT(DISTINCT website_session_id) AS all_sessions,
    COUNT(DISTINCT CASE WHEN pv_rank_desc =1 THEN website_session_id END) / COUNT(DISTINCT website_session_id) AS bounce_rate
FROM pageviews_ranked
WHERE pv_rank_asc = 1
GROUP BY pageview_url