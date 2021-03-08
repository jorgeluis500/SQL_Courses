-- WINDOW FUNCTIONS
-- Section 5
-- Challenge
/*
Write a query that returns the top 25% of animals per species that had the fewest "temperature exceptions".
Ignore animals that had no routine checkups.
A "temperature exception" is a checkup temperature measurement that is either equal to or exceeds +/- 0.5% from the specie's average.
If two or more animals of the same species have the same number of temperature exceptions, those with the more recent exceptions should be returned.
There is no need to return additional tied animals over the 25% mark.
If the number of animals for a species does not divide by 4 without remainder, you may return 1 more animal, but not less.

Hint: CAST averages to DECIMAL (5, 2).

Expected results sorted by species ASC, number_of_exceptions DESC, latest_exception DESC:
---------------------------------------------------------------------------------
|	species	|	name		|	number_of_exceptions	|	latest_exception	|
|-----------|---------------|---------------------------|-----------------------|
|	Cat		|	Cleo		|					1		|	2019-09-20 09:45:00	|
|	Cat		|	Cosmo		|					0		|				[NULL]	|
|	Cat		|	Kiki		|					0		|				[NULL]	|
|	Cat		|	Penny		|					0		|				[NULL]	|
|	Cat		|	Patches		|					0		|				[NULL]	|
|	Dog		|	Gizmo		|					1		|	2019-10-07 08:51:00	|
|	Dog		|	Riley		|					1		|	2019-07-25 10:48:00	|
|	Dog		|	Mocha		|					1		|	2019-05-14 11:10:00	|
|	Dog		|	Emma		|					1		|	2019-05-07 11:09:00	|
|	Dog		|	Samson		|					1		|	2019-03-27 09:04:00	|
|	Dog		|	Bailey		|					0		|				[NULL]	|
|	Dog		|	Luke		|					0		|				[NULL]	|
|	Dog		|	Benny		|					0		|				[NULL]	|
|	Dog		|	Boomer		|					0		|				[NULL]	|
|	Dog		|	Rusty		|					0		|				[NULL]	|
|	Dog		|	Millie		|					0		|				[NULL]	|
|	Dog		|	Beau		|					0		|				[NULL]	|
|	Rabbit	|	Humphrey	|					1		|	2018-12-19 08:32:00	|
|	Rabbit	|	April		|					0		|				[NULL]	|
---------------------------------------------------------------------------------
*/

-- STEP 1
-- Calculate the average, the variatinons, the percentage variation and define the exceptions
SELECT * FROM  routine_checkups rc ;


WITH main_table AS 
(
		SELECT
			species,
			"name",
			checkup_time,
			temperature,
			CAST( AVG(temperature) OVER w AS DECIMAL (5,2)) AS avg_temp_species,
			CAST(temperature -  AVG(temperature) OVER w AS DECIMAL (5,2)) AS abs_variation,
			(temperature / AVG(temperature) OVER w - 1) * 100 AS percentage_variation,
			CASE 
				WHEN ABS((temperature / AVG(temperature) OVER w - 1) * 100) >= 0.5 
				THEN 1 ELSE 0 
			END AS is_exception
		FROM
			routine_checkups rc 
		WINDOW w AS (PARTITION BY species) 
		ORDER BY 
			species, 
			percentage_variation
	), 

	-- SELECT * FROM main_table -- Test

-- STEP 2
--Calculate the number of exceptions as well as the latest exception date per animal 
-- Here the fields could have been calculated by using window functions too but there is no need to. It would have complicated the query and added one more step
-- Classic aggregations and GROUP BY will do the job
	
exceptions AS (	
		SELECT
			species,
			name,
			SUM(is_exception) AS number_of_exceptions,
			MAX(CASE WHEN is_exception = 1 THEN checkup_time ELSE NULL END) AS latest_exception_date
		FROM main_table 
		GROUP BY
			species,
			name
		ORDER BY 
			species,
			number_of_exceptions
		),
-- Test
-- SELECT * FROM exceptions 
--  WHERE name = 'Cosmo' -- for test purposes

		
-- STEP 3
--Calculate the ntile rank

sections AS (
		SELECT 
			*,
			NTILE (4) OVER (partition by species ORDER BY number_of_exceptions ASC, latest_exception_date DESC) AS sections_rank -- the order by latest exception DESC acts as a tiebreaker
		FROM exceptions 		
		ORDER BY 
			species,
			number_of_exceptions ASC, 
			latest_exception_date DESC
		)

-- STEP 5
-- Sleect only the NTILE 1
SELECT
	*
FROM sections 
WHERE sections_rank = 1
ORDER BY 
	species,
	number_of_exceptions DESC, 
	latest_exception_date DESC
;
