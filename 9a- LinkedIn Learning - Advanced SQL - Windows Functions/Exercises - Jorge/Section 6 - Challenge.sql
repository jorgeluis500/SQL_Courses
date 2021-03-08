-- WINDOW FUNCTIONS
-- Section 6
-- Challenge

/*
Write a query that returns the top 5 most improved quarters in terms of the number of adoptions, both per species, and overall.
Improvement means the increase in number of adoptions compared to the previous calendar quarter.
The first quarter in which animals were adopted for each species and for all species, does not constitute an improvement from zero, and should be treated as no improvement.
In case there are quarters that are tied in terms of adoption improvement, return the most recent ones.

Hint: Quarters can be identified by their first day.

Expected results sorted by species ASC, adoption_difference_from_previous_quarter DESC and quarter_start ASC:
---------------------------------------------------------------------------------------------------------------------
|	species			|	year	|	quarter	|	adoption_difference_from_previous_quarter	|	quarterly_adoptions	|
|-------------------|-----------|-----------|-----------------------------------------------|-----------------------|
|	All species		|	2019	|		3	|										7		|				11		|
|	All species		|	2018	|		2	|										4		|				8		|
|	All species		|	2019	|		4	|										3		|				14		|
|	All species		|	2017	|		3	|										2		|				3		|
|	All species		|	2018	|		1	|										2		|				4		|
|	Cat				|	2019	|		4	|										4		|				6		|
|	Cat				|	2018	|		3	|										2		|				3		|
|	Cat				|	2019	|		2	|										2		|				2		|
|	Cat				|	2018	|		1	|										1		|				2		|
|	Cat				|	2019	|		3	|										0		|				2		|
|	Dog				|	2019	|		3	|										7		|				8		|
|	Dog				|	2018	|		2	|										4		|				6		|
|	Dog				|	2017	|		3	|										2		|				2		|
|	Dog				|	2018	|		1	|										2		|				2		|
|	Dog				|	2019	|		1	|										1		|				4		|
|	Rabbit			|	2019	|		1	|										2		|				2		|
|	Rabbit			|	2017	|		4	|										1		|				1		|
|	Rabbit			|	2018	|		2	|										1		|				1		|
|	Rabbit			|	2019	|		4	|										1		|				2		|
|	Rabbit			|	2019	|		3	|										0		|				1		|
---------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
------------------------ Extra challenge: !BUG HUNT! -------------------------------
-- Check the alternative solution at the bottom of the solution file for details. --
------------------------------------------------------------------------------------
*/

-- Exploration

SELECT 
	species,
	name,
	adoption_date,
	DATE( DATE_TRUNC('quarter', adoption_date) ) AS adoption_quarter,
	date_part('year', adoption_date) as yr,
	date_part('quarter', adoption_date) as qtr 
FROM adoptions a2 
ORDER BY
	date_part('year', adoption_date),
	date_part('quarter', adoption_date) ASC
;

-- STEP 1
-- Count the addoption by quarter for all species

SELECT 
	DATE( DATE_TRUNC('quarter', adoption_date) ) AS adoption_quarter,
	date_part('year', adoption_date) as yr, -- Should not be used for calculations but useful for debugging
	date_part('quarter', adoption_date) as qtr, -- Should not be used for calculations but useful for debugging
	COUNT(*) As number_of_adoptions
FROM adoptions a2 
GROUP BY
	DATE( DATE_TRUNC('quarter', adoption_date) ),
	date_part('year', adoption_date),
	date_part('quarter', adoption_date)
ORDER BY
	DATE( DATE_TRUNC('quarter', adoption_date) )  ASC
;

-- STEP 2
-- Do the same for each species and union it with all species

WITH all_in_union AS (
		SELECT 
			species, 
			DATE( DATE_TRUNC('quarter', adoption_date) ) AS adoption_quarter,
			date_part('year', adoption_date) as yr, -- Should not be used for calculations but useful for debugging
			date_part('quarter', adoption_date) as qtr, -- Should not be used for calculations but useful for debugging
			COUNT(*) As number_of_adoptions
		FROM adoptions a2 
		GROUP BY
			species, 
			DATE( DATE_TRUNC('quarter', adoption_date) ),
			date_part('year', adoption_date),
			date_part('quarter', adoption_date)
		--ORDER BY
		--	species, 
		--	date_part('year', adoption_date),
		--	date_part('quarter', adoption_date) ASC
		
		UNION 
		
		SELECT 
			'All species' AS species, 
			DATE( DATE_TRUNC('quarter', adoption_date) ) AS adoption_quarter,
			date_part('year', adoption_date) as yr, -- Should not be used for calculations but useful for debugging
			date_part('quarter', adoption_date) as qtr, -- Should not be used for calculations but useful for debugging
			COUNT(*) As number_of_adoptions
		FROM adoptions a2 
		GROUP BY
			DATE( DATE_TRUNC('quarter', adoption_date) ),
			date_part('year', adoption_date),
			date_part('quarter', adoption_date)
		--ORDER BY
		--	species, 
		--	date_part('year', adoption_date),
		--	date_part('quarter', adoption_date) ASC
	)
--SELECT * FROM all_in_union ORDER BY species, adoption_quarter ;

-- STEP 3
-- Calculate the adoptions in previous quarter and the diference with the curent one

, calculations AS (
		SELECT 
			*,
			COALESCE (FIRST_VALUE (number_of_adoptions) OVER w, 0) AS adoption_previous_quarter, -- Wrapped in COALESCE to put 0 instead of NULLS
			(number_of_adoptions - COALESCE (FIRST_VALUE (number_of_adoptions) OVER w, 0))  AS adoption_difference_from_previous_quarter
		FROM  all_in_union
		WINDOW w AS 
					(
					PARTITION BY species
					ORDER BY adoption_quarter ASC
					RANGE BETWEEN 
					'3 month' PRECEDING -- This scans the whole 3-month period
					AND
					'3 month' PRECEDING 
					)
		
--		ORDER BY 
--			species,
--			adoption_quarter 
	)
-- Test
-- SELECT * FROM calculations;
	
	
-- STEP 4
-- Get a ranking to filter by later

-- THE FIRST QUARTER FOR EACH SPECIES IS BEING RANKED. IT SHOULD BE LEFT OUT OF THE CALCULATION

, ranked_differences AS (
		SELECT 
			*,
			RANK () OVER (
								PARTITION BY species 
								ORDER BY adoption_difference_from_previous_quarter DESC, adoption_quarter DESC
								) AS ranked_diff
		FROM calculations
		ORDER BY
			species,
			adoption_difference_from_previous_quarter DESC

		)
-- Test
--SELECT * FROM  ranked_differences WHERE species = 'Cat';		
		
SELECT 
	species,
--	adoption_quarter
	date_part('year', adoption_quarter) as year,
	date_part('quarter', adoption_quarter) as quarter,
	adoption_difference_from_previous_quarter,
	number_of_adoptions,
	ranked_diff
FROM ranked_differences 
WHERE ranked_diff <=5 
ORDER BY
	species ASC,
	adoption_difference_from_previous_quarter DESC,
	adoption_quarter ASC
;

-- THE FIRST QUARTER FOR EACH SPECIES IS BEING RANKED. IT SHOULD BE LEFT OUT OF THE CALCULATION