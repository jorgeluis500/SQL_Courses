--WINDOWS FUNCTIONS
--Section 4
--Aggregate window functions

--Return an animal'species, name, checkup time, heart rate and Boolean columns that is TRUE only for animals which all of their heart rate measurementes
-- were either equal to or above the average rate for their species

-- It can be solved by subqueries, derived tables or window funtions

-- Exploration
/*
SELECT * FROM routine_checkups rc ORDER BY species ASC, checkup_time ASC;
*/

-- METHOD 1 -- Using a join

WITH avg_hr AS (
-- This calculates the AVG heart rate by species
		SELECT
			species,
			ROUND(AVG(heart_rate),2) AS Rounded_AVG_hr_species, -- to get rouned results
			CAST( AVG(heart_rate) AS DECIMAL (5,2) ) AS Cast_AVG_hr_species -- We can also use CAST
		FROM
			routine_checkups rc
		GROUP BY
			species 
			)
-- SELECT * FROM avg_hr ; -- Test
SELECT
	rc.species,
	rc."name",
	rc.checkup_time,
	rc.heart_rate,
	ahr.Cast_AVG_hr_species, -- just for comparison purposes
	ahr.Rounded_AVG_hr_species,
	CASE
		WHEN rc.heart_rate >= ahr.Rounded_AVG_hr_species THEN TRUE
		ELSE FALSE
	END AS higher_than_average 
FROM
	routine_checkups rc
INNER JOIN avg_hr ahr
	-- The join brings the table with the avg hr per species
 ON
	rc.species = ahr.species
WHERE 
	CASE
		WHEN rc.heart_rate >= ahr.Rounded_AVG_hr_species THEN TRUE
		ELSE FALSE
	END = TRUE
ORDER BY
	rc.species ASC,
	rc.checkup_time ASC
;

-- METHOD 2 -- Using Window funtion. 
-- a. All the animals, with the higher_than average_indicator. This one seems to be more expensive than the previous one

SELECT
	rc.species,
	rc."name",
	rc.checkup_time,
	rc.heart_rate,
	AVG(rc.heart_rate) OVER (PARTITION BY species) AS AVG_hr_species, -- the avg alone might show misleading results
	ROUND(AVG(rc.heart_rate) OVER (PARTITION BY species),2) AS Rounded_AVG_hr_species, -- with the rounded one the visual is more accurate
	CAST( AVG(rc.heart_rate) OVER (PARTITION BY species) AS DECIMAL (5,2) ) AS Cast_AVG_hr_species, -- We can also use CAST
	CASE
		WHEN rc.heart_rate >= ROUND(AVG(rc.heart_rate) OVER (PARTITION BY species),2) THEN TRUE
		ELSE FALSE
	END AS higher_than_average
--	EVERY ( rc.heart_rate 
--			>= AVG(rc.heart_rate) 
--				OVER (PARTITION BY rc.species) 
--			) 
--	OVER (PARTITION BY rc.species, name) AS boolean_2 -- The name field is added so the partition is kept to each animal
-- This would be the way to do it with the EVERY window function. However, although ANSI SQl supports nested window functions from 2016, no database has yet implemented it
-- Therefore, it returns the error: window function calls cannot be nested
FROM
	routine_checkups rc
ORDER BY
	rc.species ASC,
	rc.checkup_time ASC
;


-- b. Clean query with window function and filtering only animals whose heart rate is higher than the average for it's species
-- Two CTE need to be used

WITH all_values 
AS (
	SELECT	rc.species,
			rc."name",
			rc.checkup_time,
			rc.heart_rate,
			CAST( AVG(rc.heart_rate) OVER (PARTITION BY species) AS DECIMAL (5,2) ) AS AVG_hr_species,
			CASE
				WHEN rc.heart_rate >= CAST( AVG(rc.heart_rate) OVER (PARTITION BY species) AS DECIMAL (5,2) ) THEN TRUE
				ELSE FALSE
			END AS higher_than_average
	FROM 	routine_checkups rc
	ORDER BY 	rc.species ASC,
				rc.checkup_time ASC
	)
--SELECT * FROM all_values ; -- Test

-- The EVERY function needs to be defined in the second CTE to count all that are consistently above average
, Consistently_above_average 
AS 
(
SELECT 	*,
		EVERY(higher_than_average = TRUE) OVER (PARTITION BY species,name) AS all_consistently_above
FROM 	all_values 
)
--SELECT * FROM Consistently_above_average; -- Test

SELECT	*
FROM	Consistently_above_average
WHERE	all_consistently_above = TRUE;






