-- SECTION 10 
-- USER ANALYSIS

USE mavenfuzzyfactory;

-- Analyze time to repeat
-- Assignment
-- Video 92 and 93
-- Slide 168

/*
We’ve been thinking about customer value based solely on their first session conversion and revenue. But if customers
have repeat sessions, they may be more valuable than we thought. If that’s the case, we might be able to spend a bit more to acquire them.

Could you please pull data on how many of our website visitors come back for another session? 2014 to date is good.
*/


-- The solution in the video is different, it is similar to the previous assignment
-- Exploration

SELECT
* 
FROM website_sessions
WHERE 
	created_at >= '2014-01-01'
 	AND created_at <= '2014-11-01'
-- AND 
-- user_id = 172067
ORDER BY 
	user_id,
    created_at
; 

-- STEP 1
-- I get the second date

CREATE TEMPORARY TABLE sessions_w_next_date
SELECT 
    user_id, 
    created_at, 
    website_session_id, 
    is_repeat_session,
    LEAD (created_at, 1) OVER (PARTITION BY user_id ORDER BY user_id, created_at) AS next_date
FROM
    website_sessions
WHERE
    created_at >= '2014-01-01'
        AND created_at <= '2014-11-01'
ORDER BY user_id , created_at
;
-- Test
SELECT * FROM sessions_w_next_date;

-- STEP 2
-- With the previous query, I then filter to have only the repeat session 0, meaning only the sessions created during the period
-- I also calculate the difference in days between both dates

-- DROP TEMPORARY TABLE days_between_visits;
CREATE TEMPORARY TABLE days_between_visits
SELECT 
    user_id, 
    created_at, 
    next_date,
    DATEDIFF(next_date, created_at) as days_1st_2nd_visit,
    website_session_id, 
    is_repeat_session
FROM
    sessions_w_next_date
WHERE
    is_repeat_session = 0
    -- AND next_date IS NOT NULL -- Step included for presentation and performance. 
ORDER BY user_id , created_at
;
-- Test
SELECT * FROM days_between_visits;

-- STEP 3 calculate the metrics
-- Could have been a query and a sub_query but this is better for clarity

SELECT
	MAX(days_1st_2nd_visit) AS Max_days,
	MIN(days_1st_2nd_visit) AS Min_days,
	AVG(days_1st_2nd_visit) AS Avg_days
FROM days_between_visits