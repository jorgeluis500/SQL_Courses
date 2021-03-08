-- Section 5 - Analyzing website performance

USE mavenfuzzyfactory;

-- Video 38. Finding the bounce rate. Example
-- Steps:
-- 1) Find the landing pages in each session, which are the first pages. MIN website_ID by website session
-- 2) Bring the page URL to those first pages. We will have only sessions and their landing (first) pages
-- 3) Out of the landing page table just created, Count pageviews for each session, to identify bounces
-- 4) Summarize total sessions and bounces

-- Exploration
SELECT * FROM website_sessions; -- WHERE -- created_at BETWEEN '2014-01-01' AND '2014-02-01'


-- Step 1
-- 1) Find the landing pages in each session, which are the first pages. MIN website_ID by website session

CREATE TEMPORARY TABLE first_pageview
		SELECT 
			website_session_id,
			MIN(website_pageview_id) AS min_page
		FROM website_pageviews
		WHERE created_at BETWEEN '2014-01-01' AND '2014-02-01'
		GROUP BY website_session_id
        ORDER BY 1
;
-- Step 2 Step 2. Bring the page URL to those first pages. We will have only sessions and their landing (first) pages

CREATE TEMPORARY TABLE session_landing_page
SELECT 
	first_pageview.website_session_id,
	wpv2.pageview_url AS landing_page
FROM first_pageview 
LEFT JOIN website_pageviews wpv2
	ON first_pageview.min_page = wpv2.website_pageview_id
WHERE created_at BETWEEN '2014-01-01' AND '2014-02-01'
ORDER BY 
	first_pageview.website_session_id
;

-- Step 3. Next, out of the landing page table we just created, we will create a table that count of pageviews per session, and then filter to 1 pageview to get bounced sessions only

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
	session_landing_page.website_session_id,
	session_landing_page.landing_page,
	COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM session_landing_page
LEFT JOIN website_pageviews
	ON session_landing_page.website_session_id = website_pageviews.website_session_id
GROUP BY
	session_landing_page.website_session_id,
	session_landing_page.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id)  = 1
;

-- Step 4. Join the landing sessions with the bounced sessions only

SELECT
	session_landing_page.landing_page,
	session_landing_page.website_session_id,
	bounced_sessions_only.website_session_id AS bounced_website_session_id
FROM session_landing_page
LEFT JOIN bounced_sessions_only
	ON session_landing_page.website_session_id = bounced_sessions_only.website_session_id
ORDER BY 
	session_landing_page.website_session_id
;
    
-- 4b Finally, we turn the previous query into a group of sessions, bounced sessions and get the rate

SELECT 
	session_landing_page.landing_page,
	COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT session_landing_page.website_session_id) AS sessions,
	COUNT(DISTINCT bounced_sessions_only.website_session_id) / COUNT(DISTINCT session_landing_page.website_session_id) AS bounce_rate
FROM session_landing_page
LEFT JOIN bounced_sessions_only
	ON session_landing_page.website_session_id = bounced_sessions_only.website_session_id
GROUP BY 
	session_landing_page.landing_page
;


-- Alternative solution
-- Before applying this method, we must be sure that there are no duplicates in the data

-- Step 1. Creat a ranked table of the sessions and the total number of pageviews per session

CREATE TEMPORARY TABLE ranked_table AS
SELECT
	*,
	row_number() OVER(PARTITION BY website_session_id ORDER BY website_session_id, created_at) AS rank_per_session,
	COUNT(website_session_id) OVER(PARTITION BY website_session_id ORDER BY website_session_id) AS pageviews_per_session
FROM website_pageviews
WHERE created_at BETWEEN '2014-01-01' AND '2014-02-01'
ORDER BY website_session_id
;

-- Step 2. Now we filter the first page only and define bounce and not bounced

CREATE TEMPORARY TABLE bounce_or_not AS
SELECT
	website_session_id,
    pageview_url,
	pageviews_per_session,
	rank_per_session,
    CASE WHEN pageviews_per_session = 1 THEN 1 ELSE 0 END AS bounced_session, 
    CASE WHEN pageviews_per_session = 1 THEN 0 ELSE 1 END AS not_bounced_session
FROM ranked_table
WHERE rank_per_session = 1
;

-- Step 3. Group the previous query by url and calculate the metrics

SELECT
	pageview_url,
	SUM(bounced_session) AS bounced_sessions, 
    SUM(not_bounced_session) AS not_bounced_sessions,
	COUNT(pageviews_per_session) AS total_sessions,
    	SUM(bounced_session) / COUNT(pageviews_per_session) AS bounce_rate
FROM bounce_or_not
GROUP BY pageview_url
ORDER BY pageview_url
;