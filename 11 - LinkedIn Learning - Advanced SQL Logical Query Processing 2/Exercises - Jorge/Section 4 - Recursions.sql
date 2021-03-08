-- ADVANCED SQL - LOGICAL QUERY PROCESSING 2
-- Section 4 - Recursions


--In PostgreSQL we can generate series like using a unique function:

SELECT CAST(day AS Date) AS day -- day is at the same type, the data type and the name of the date (I think)

FROM GENERATE_SERIES(	'2019-01-01':: date, -- Start::Type
						'2019-12-31',		 -- End						
						'1 day'				 -- Interval
					) AS days_of_2019(day)
ORDER BY day ASC
;

--In SQL Server we use recursion:

WITH days_of_2019 (day) AS -- The (day) is the Data Type
(	SELECT	CAST ('20190101'AS DATE)
	
	UNION ALL
	
	SELECT DATEADD(DAY,1,day) -- The arguments are: DATEADD (datepart , number , date ). In this case the date is named 'day'. Might be confusing to read
	FROM days_of_2019
	WHERE day < CAST ('20191231'AS DATE)
)
SELECT 
	* 
FROM days_of_2019
ORDER BY day ASC
OPTION (MAXRECURSION 365) -- This is added to go beyond the default otion of 100 iterations in SQL server
;

-- In Postgres we can also use recursion

WITH RECURSIVE days_of_2019 (day) AS -- We use RECURSIVE here and no 'AS'. The (day) is the Data Type
(	SELECT	CAST ('20190101'AS DATE)
	
	UNION ALL
	
	SELECT CAST(day + INTERVAL '1 day' AS DATE) -- We add 1 day to each day
	FROM days_of_2019
	WHERE day < CAST ('20191231'AS DATE)
)
SELECT 
	* 
FROM days_of_2019
ORDER BY day ASC
;

-- This query will return the Fibonacci series in a sneaky way, 2 elements at a time which allows for easier recursion.

WITH RECURSIVE f (m, n)
AS
(        SELECT         0, 1
        UNION ALL
        SELECT  m + n, m + n + n
        FROM         f
        WHERE         m + n + n <= 1000
)
SELECT  * FROM f;