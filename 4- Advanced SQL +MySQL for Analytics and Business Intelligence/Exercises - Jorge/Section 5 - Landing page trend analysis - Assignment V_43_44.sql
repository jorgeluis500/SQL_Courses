USE mavenfuzzyfactory;

-- Section 5. Analyzing Website Performance
-- Assignnment. Landing page trend analysis
-- Videos 43 and 44

-- Part A: paid search nonbrand traffic landing on /home and /lander-1, trended weekly since June 1st? 
-- Part B: pull our overall paid search bounce rate trended weekly?
-- Date of the request: '2012-08-31'

-- Exploration

SELECT 
*
FROM website_pageviews;

-- Records and unique sessions in the period
SELECT 
 COUNT(DISTINCT wp.website_session_id) AS unique_sessions,
 COUNT(*) AS pageviews
FROM website_pageviews wp
LEFT JOIN website_sessions ws
	ON wp.website_session_id = ws.website_session_id
WHERE wp.created_at between '2012-06-01'AND '2012-08-31'
AND ws.utm_campaign = 'nonbrand'
;
-- Answer 
-- unique_sessions: 12,217. They would be 12,216 if we leave only the landing pages in the next step
-- pageviews: 26,142. They would be 26,140 if we leave only the landing pages in the next step

-- Analysis
-- Step 1
-- First pageview by session, count of pageviews per session, all with the filtering conditions

-- DROP TEMPORARY TABLE firstpps;
CREATE TEMPORARY TABLE firstpps
SELECT 
	wp.website_session_id,
	MIN(wp.website_pageview_id) AS sessions_first_page,
    COUNT(wp.website_pageview_id) AS count_pageviews
FROM website_pageviews wp
LEFT JOIN website_sessions ws
	ON wp.website_session_id = ws.website_session_id
WHERE wp.created_at between '2012-06-01'AND '2012-08-31'
AND ws.utm_campaign = 'nonbrand'
-- AND wp.pageview_url IN ('/home', '/lander-1') -- as with previous examples, since we are applying an arbitrary cutoff, there was a page (shipping) that did not belong to the landing pages of the website
GROUP BY
wp.website_session_id;

-- Test
SELECT * FROM firstpps;

-- Step 2
-- Bring the pageview_URL (landing page) and the creation date to those pages

-- DROP TEMPORARY TABLE landing_pages2;
CREATE TEMPORARY TABLE landing_pages2
SELECT 
	fp.website_session_id,
	fp.sessions_first_page,
    fp.count_pageviews,
    wp.pageview_url AS landing_page,
    wp.created_at AS session_created_at
FROM firstpps fp
LEFT JOIN website_pageviews wp
	ON  fp.sessions_first_page = wp.website_pageview_id
;
-- Test
SELECT * FROM landing_pages2;

-- Step 3
-- Since we got the number of pageviews in the first query, we can now get the metrics we are being asked

-- Fields formation. To check
SELECT 
	yearweek(session_created_at) AS year_week,
	website_session_id, 
	sessions_first_page, 
	count_pageviews, 
	landing_page, 
	session_created_at,
	CASE WHEN count_pageviews = 1 THEN website_session_id END AS bounced_session_id,
    CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END AS home_sessions_id,
	CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END AS lander_session_id
FROM landing_pages2
WHERE landing_page IN ('/home', '/lander-1')
;

-- Final query, with the aggregations
SELECT 
	-- yearweek(session_created_at) AS year_week,
	MIN(DATE(session_created_at)) as week_start_date,
	COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS bounce_rate,
    COUNT(DISTINCT website_session_id) AS all_sessions, 
	COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions, 
	COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions 
FROM landing_pages2
WHERE landing_page IN ('/home', '/lander-1')
GROUP BY
yearweek(session_created_at)
;
