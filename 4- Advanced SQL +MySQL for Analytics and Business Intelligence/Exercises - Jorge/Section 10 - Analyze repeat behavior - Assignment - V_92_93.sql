-- SECTION 10 
-- USER ANALYSIS

USE mavenfuzzyfactory;

-- Analyze repeat behavior
-- Assignment
-- Video 92 and 93
-- Slide 165

-- We’ve been thinking about customer value based solely on their first session conversion and revenue. But if customers
-- have repeat sessions, they may be more valuable than we thought. If that’s the case, we might be able to spend a bit more to acquire them.

-- Could you please pull data on how many of our website visitors come back for another session? 2014 to date is good.

-- Key technical points
-- The user's first session must have been in the specified period of time
-- And the session itself must have been created in the same period of time

-- Exploration

SELECT
* 
FROM website_sessions
WHERE 
	created_at >= '2014-01-01'
 	AND created_at <= '2014-11-01'
-- AND 
-- user_id = 172067
; 

-- Step 1
-- Sessions per users
-- The WHERE clasue filters the data at the beginning.

SELECT
	user_id,
	COUNT(website_session_id) as sessions 
FROM website_sessions
WHERE 
	created_at >= '2014-01-01'
	AND created_at <= '2014-11-01'
GROUP BY
	user_id
HAVING MIN(is_repeat_session) = 0 
-- This step is very important. It ensures only users id with their first visit on 2014 are counted 
-- after the creation date filter in the WHERE has been applied

ORDER BY 2 DESC
;


SELECT 
	repeat_sessions,
	COUNT(user_id) as users
FROM (
	SELECT
		user_id,
		SUM(is_repeat_session) as repeat_sessions 
	FROM website_sessions
WHERE 
	created_at >= '2014-01-01'
	AND created_at < '2014-11-01'
GROUP BY
		user_id
HAVING MIN(is_repeat_session) = 0 -- This step is very important. It ensures only users id with their first visit on 2014 are counted
	-- ORDER BY 2 DESC
	) AS sessions_per_user
GROUP BY
	repeat_sessions
ORDER BY
	repeat_sessions
;

-- VIDEO SOLUTION (much faster in terms of performance)

-- STEP 1. Identify the relevant new sessions
-- STEP 2. With those users, get the subsequent sessions
-- STEP 3. Analyze the data at the user level (how many sessions did each user have?)
-- STEP 4. Aggregate the user_level analysis to generate your behavioral analysis


CREATE TEMPORARY TABLE  sessions_w_repeats
SELECT
	ns.user_id,
	ns.website_session_id AS new_session_id,
	ws.website_session_id AS repeat_session_id
FROM (
	-- This section gives me the users with new sessions in 2014
    SELECT 
		user_id,
		website_session_id
	FROM website_sessions
	WHERE 
		created_at >= '2014-01-01'
		AND created_at < '2014-11-01'
		AND is_repeat_session = 0
	) AS ns -- new_sessions 
LEFT JOIN website_sessions ws -- Then I join to get the subsequent sessions for those users
	ON ns.user_id = ws.user_id
    AND ws.website_session_id > ns.website_session_id -- This condition gives me the sessions that are  not the new ones. It is redundant with the next
    AND ws.is_repeat_session = 1 -- Redundant with the previous contidion
    AND created_at >= '2014-01-01'
	AND created_at < '2014-11-01'
;
-- Test
SELECT *,
COUNT(repeat_session_id) OVER( PARTITION BY user_id) AS repeat_sessions
FROM sessions_w_repeats;


SELECT 
	repeat_sessions,
	COUNT(DISTINCT user_id) as users
FROM (
	SELECT
		user_id,
		COUNT(DISTINCT new_session_id) as new_sessions,
		COUNT(DISTINCT repeat_session_id) AS repeat_sessions
	FROM sessions_w_repeats
	GROUP BY
		user_id
) AS user_level
GROUP BY
repeat_sessions
;