-- SECTION 7
-- ANALYZING CHANNEL PORTFOLIOS

USE mavenfuzzyfactory;

-- Channel portfolio optimization - Assignment
-- Videos 55 and 56

-- We launched a second paid search channel, bsearch, around August 22.
-- Pull weekly trended session volume since then and compare to gsearch nonbrand
-- Date of the request '2012-11-29'

-- Step 1
-- Find out the launching date of the new channel

SELECT 
	utm_source,
	MIN(website_session_id) AS bseach_first_session_id,
    MIN(created_at) as bsearch_fisrt_date
FROM website_sessions
WHERE 
	utm_source = 'bsearch' AND
	utm_campaign = 'nonbrand'
GROUP BY
	utm_source
;
-- Results if we do not include nonbrand
-- website_session_id = 1306
-- Date: '2012-03-27 23:54:43'
-- This is too early in time and not consisten with the email

-- When we include nonbrand in the filter, we get this:
-- website_session_id = 20664
-- Date: '2012-08-19 02:43:26'

-- Exploration
SELECT 
	WEEK(created_at) as week_start_date,
	created_at,
	website_session_id,
	utm_source,
	utm_campaign
FROM website_sessions
WHERE 
	website_session_id >= 20664 AND
	created_at <= '2012-11-29' AND
	utm_campaign = 'nonbrand'
;

-- Query
-- In order to match the exercise, I will use the exact date instead of the minimum session id

SELECT 
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT website_session_id ) AS total_sessions,
    COUNT(DISTINCT CASE WHEN utm_source= 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source= 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE 
	-- website_session_id >= 20664 AND
	created_at > '2012-08-22' AND
    created_at < '2012-11-29' AND
	utm_campaign = 'nonbrand'
GROUP BY
	YEARWEEK(created_at)