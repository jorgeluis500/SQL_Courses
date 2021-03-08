--WINDOWS FUNCTIONS
--Section 4
--Combining grouped and aggregate window functions


SELECT
	species,
	count(*) AS count_group,
	count(*) OVER () AS count_window
FROM animals a2 
GROUP BY
	species 

	-- This query evaluates the grouping first and the windows function later. Therefore the windows function counts the number of already aggregated groups
	-- and not the total rows, as it might be expected
;

SELECT
	species,
	count(*) AS count_group,
	count(a2.name) OVER () AS count_window
FROM animals a2 
GROUP BY
	species 
-- This one returns an error since the name is not in the groups and COUNT function is not an aggregate one
--Name is not a group by expression and it is not contained in an aggregate function. 
--The window aggregate COUNT doesn't have access to the individual rows within each group 
--and for name to make sense in this context, it must return a single value per group
;

-- If I want to count the number of Non-NULL names, I should wrap the COUNT in a SUM becasue it's a group aggregate function

SELECT
	species,
	COUNT(*) AS count_group,
	SUM(COUNT(a2.name)) OVER () AS all_non_null_names_window
FROM animals a2 
GROUP BY
	species 
;

/*
We need to create a query to report monthly adoption fees revenue. 
The query needs to show every month and every year with adoptions, the total monthly adoption fees 
and the percent of this month's revenue from the total annual revenue for the same year. 
*/

-- STEP 1
-- Show the metrics without the percentages yet

SELECT
	DATE_PART('year',adoption_date) AS yr,
	DATE_PART('month',adoption_date) AS mo,
	SUM(adoption_fee) as monthly_revenue
FROM
	adoptions a2
GROUP BY 
	DATE_PART('year',adoption_date),
	DATE_PART('month',adoption_date)
ORDER BY 
	DATE_PART('year',adoption_date),
	DATE_PART('month',adoption_date)
	
	
-- To get the percentages per year we will use a window function directly

SELECT
	DATE_PART('year',adoption_date) AS yr,
	DATE_PART('month',adoption_date) AS mo,
	SUM(adoption_fee) as monthly_revenue,
	ROUND(SUM(adoption_fee) *100
		/ SUM( SUM(adoption_fee) ) 	-- In the denominator of this expression, the first SUM function is an WINDOW aggregate one and the second is an GROUP aggregate one!
		OVER (PARTITION BY DATE_PART('year',adoption_date)), 2) AS annual_percent
FROM
	adoptions a2
GROUP BY 
	DATE_PART('year',adoption_date),
	DATE_PART('month',adoption_date)
ORDER BY 
	DATE_PART('year',adoption_date),
	DATE_PART('month',adoption_date)
;

--Since the previous query could be difficult to undertand, we will use a CTE to make it more readable

-- First we calcualte all metrics but not th percentage
WITH metrics AS (
		SELECT
			DATE_PART('year',adoption_date) AS yr,
			DATE_PART('month',adoption_date) AS mo,
			SUM(adoption_fee) as monthly_revenue
		FROM
			adoptions a2
		GROUP BY 
			DATE_PART('year',adoption_date),
			DATE_PART('month',adoption_date)
	)
-- Then we add the percentage calculation with a regular window function. One SUM only in the denominator
SELECT 
	*,
	SUM(m.monthly_revenue) OVER (PARTITION BY m.yr) AS yearly_revenue,
	ROUND( m.monthly_revenue *100 / SUM(m.monthly_revenue) OVER (PARTITION BY m.yr) ,2) AS annual_percent -- One SUM only
FROM metrics m
ORDER BY
	yr,
	mo
;
