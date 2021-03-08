-- SECTION 8
-- ANALYZING SEASONALITY AND BUSINESS PATTERNS

USE mavenfuzzyfactory;

-- Analyzing seasonality and business patterns
-- Videos 66

-- Basically date functions

SELECT 
	website_session_id,
	created_at,
    YEAR(created_at) AS yr,
    QUARTER(created_at) AS qtr,
    MONTH(created_at) AS mo,
    MONTHNAME(created_at) AS month_name,
    YEARWEEK(created_at) AS year_week,
    WEEKOFYEAR(created_at) AS week_of_year,
    DAYOFYEAR(created_at) AS day_of_year,
    DAY(created_at) AS `day`,
    DAYOFMONTH(created_at) AS day_of_month,
    WEEKDAY(created_at) AS day_of_week, -- From 0 to 6. 0 is Monday
    DAYOFWEEK(created_at) AS day_of_week_2, -- From 1 to 7. 1 is Sunday
    DAYNAME(created_at) AS day_name,
	MAX(DAYOFYEAR(created_at)) OVER () MAX_day_of_year, -- Could be useful
  	HOUR(created_at) AS hr,
    MINUTE(created_at) AS min
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000 
;