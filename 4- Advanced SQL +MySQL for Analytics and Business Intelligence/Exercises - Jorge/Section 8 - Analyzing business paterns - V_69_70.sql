-- SECTION 8
-- ANALYZING SEASONALITY AND BUSINESS PATTERNS

USE mavenfuzzyfactory;

-- Analyzing Business Patterns - Assignment
-- Videos 69 and 70
-- Slide 125

-- Average website session volume, by hour of day and by day week, so that we can staff appropriately?
-- Avoid the holiday time period and use a date range of Sep 15 - Nov 15, 2013.
SELECT 
*
FROM 
website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15';

-- ALL THIS IS WRONG
-- Step 1
-- Test. Calculate the number of weekdays in the period

SELECT 
	WEEKDAY(created_at) AS wkday,
--  HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS sessions, 
	COUNT(DISTINCT DATE(created_at) ) AS unique_weekdays, -- THIS IS THE LINE THAT CALCULATE THE NUMBER OF WEEKDAYS!
	COUNT(DISTINCT website_session_id) / COUNT(DISTINCT DATE(created_at) ) AS avg_website_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY
	WEEKDAY(created_at)
	-- HOUR(created_at)
;

-- Step 2. Pivot the values and group by hour
-- Test

SELECT 
	WEEKDAY(created_at) AS wkday,
	HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS sessions, 
	COUNT(DISTINCT DATE(created_at) ) AS unique_weekdays,
	COUNT(DISTINCT website_session_id) / COUNT(DISTINCT DATE(created_at) ) AS avg_website_sessions,
    COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 0 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT DATE(created_at)) AS mon,
    COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT DATE(created_at)) AS tue
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY
WEEKDAY(created_at),
HOUR(created_at)
;

-- Final query

-- This is wrong

SELECT 
	HOUR(created_at) as hr,
    COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 0 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT DATE(created_at)) AS mon,
    COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT DATE(created_at)) AS tue,
    COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 2 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT DATE(created_at)) AS wed,
    COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 3 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT DATE(created_at)) AS thu,
    COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 4 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT DATE(created_at)) AS fri,
    COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 5 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT DATE(created_at)) AS sat,
    COUNT(DISTINCT CASE WHEN WEEKDAY(created_at) = 6 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT DATE(created_at)) AS sun
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY
 HOUR(created_at)
;


-- Solution in the video
-- 1. Create the sessions grouped by weekday and hour (make it a subquery)
-- 2. Take the average per hour
-- 3 Pivot the days

SELECT
	-- 2. Here we take the average per hour
	hr,
	AVG(sessions) AS avg_sessions
FROM (
	-- 1. here we create the sessions grouped by weekday and hour
	SELECT 
		DATE(created_at) AS created_date,
		WEEKDAY(created_at) AS wkday,
		HOUR(created_at) AS hr,
		COUNT(DISTINCT website_session_id) AS sessions
	FROM website_sessions
	WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
	GROUP BY
		DATE(created_at),
		WEEKDAY(created_at),
		HOUR(created_at)
	) AS daily_hourly_sessions
GROUP BY 
	hr
;

-- 3. Pivot the days in the previous query

SELECT
	-- 2. Here we take the average per hour
	hr,
	    -- 3 And pivot the days
    ROUND(AVG(CASE WHEN wkday = 0 THEN sessions ELSE NULL END),1) AS mon,
    ROUND(AVG(CASE WHEN wkday = 1 THEN sessions ELSE NULL END),1) AS tue,
    ROUND(AVG(CASE WHEN wkday = 2 THEN sessions ELSE NULL END),1) AS wed,
    ROUND(AVG(CASE WHEN wkday = 3 THEN sessions ELSE NULL END),1) AS thu,
    ROUND(AVG(CASE WHEN wkday = 4 THEN sessions ELSE NULL END),1) AS fri,
    ROUND(AVG(CASE WHEN wkday = 5 THEN sessions ELSE NULL END),1) AS sat,
    ROUND(AVG(CASE WHEN wkday = 6 THEN sessions ELSE NULL END),1) AS sun
FROM (
	-- 1. here we create the sessions grouped by weekday and hour
	SELECT 
		DATE(created_at) AS created_date,
		WEEKDAY(created_at) AS wkday,
		HOUR(created_at) AS hr,
		COUNT(DISTINCT website_session_id) AS sessions
	FROM website_sessions
	WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
	GROUP BY
		DATE(created_at),
		WEEKDAY(created_at),
		HOUR(created_at)
	) AS daily_hourly_sessions
GROUP BY 
	hr
;
