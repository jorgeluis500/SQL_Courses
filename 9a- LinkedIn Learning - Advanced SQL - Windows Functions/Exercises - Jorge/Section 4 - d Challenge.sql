--WINDOWS FUNCTIONS
--Section 4
-- Challenge

-- Write a query that returns all the year in which animals were vaccinated and the number of vaccinations given that year

-- In addition, calculate and return the following two columns:
-- 1. The average number of vaccination given in the previous two calendar years
-- 2. The percent difference between the current year's number of vaccinations and the average of the previous two years


-- Exploration

SELECT
*
FROM vaccinations
;


SELECT
	*,
	DATE_PART('year', vaccination_time) as yr,
	COUNT(*) OVER (PARTITION BY DATE_PART('year', vaccination_time)) AS vac_per_year
FROM vaccinations
ORDER BY
	DATE_PART('year', vaccination_time)
;

-- STEP 1
-- Create the vaccinations per year table
WITH vpy AS (
		SELECT
			CAST (DATE_PART('year', vaccination_time) AS INT) as yr,
			COUNT(*) as vac_per_year
		FROM vaccinations v 
		GROUP BY
			DATE_PART('year', vaccination_time)
		ORDER BY
			DATE_PART('year', vaccination_time)
	), -- SELECT * FROM vpy ;

-- Calculate the two adittional columns in a second CTE

vpy_with_avgs AS(
		SELECT 
			*,
			CAST (
			AVG(vac_per_year) 
			OVER ( 
			ORDER BY yr ASC
				RANGE BETWEEN -- RANGE is necesssary to calculate the average over the years and not the rows. 
				2 PRECEDING 
				AND
				1 PRECEDING 
			) AS DECIMAL (5,2))
			AS avg_last_2_years
		FROM vpy
--		WHERE yr <> 2018 -- When we remove this, the calculation still takes place over the years, so the number changes as it should
	) -- SELECT * FROM  vpy_with_avgs;
SELECT 
	*,
	CAST ((vac_per_year / avg_last_2_years) * 100 AS DECIMAL (5,2)) AS percentage_change
FROM vpy_with_avgs
;

