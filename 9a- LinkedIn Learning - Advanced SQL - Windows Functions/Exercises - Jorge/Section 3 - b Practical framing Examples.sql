-- WINDOWS FUNCTIONS
-- Framing examples

--We are going to count the number of animals we have each time an animal is admitted, for each species

SELECT
	a1.species,
	a1.name,
	a1.primary_color,
	a1.admission_date,
	( 	SELECT 
			COUNT(*) 
		FROM animals a2 
		WHERE a1.species = a2.species 
		AND
		a2.admission_date < a1.admission_date 
		) AS up_to_previous_day_animal_species
FROM
	animals a1
ORDER BY
	a1.species,
	a1.admission_date 
	;
	
-- Using windows functions, we aggregate a frame

SELECT
	species,
	name,
	primary_color,
	admission_date,
	COUNT(*) 
	OVER (	PARTITION BY 	species
			ORDER BY 		admission_date ASC
			ROWS BETWEEN 	UNBOUNDED PRECEDING 
							AND
							-- CURRENT ROW -- If we use CURRENT ROW, the result is offset by 1 because the current row is counted in the computation
							1 PRECEDING -- This option tells query not to use the current rown but the previous one so the count stops at the preceding row
			) AS number_of_species_animals
FROM
	animals
ORDER BY
	species,
	admission_date 
;

-- However, this previous query doesn't behave as expected
-- On '2017-08-01' we added two dogs. They are not counted correctly. To follow the case let's limit the queries to dogs only

-- Let's examine with the usual way, this timne working with a CTE

WITH filtered_animals AS (
	SELECT * 
	FROM animals
	WHERE 
		species = 'Dog'
		AND admission_date > '2017-08-01'
	)
SELECT
	fa.species,
	fa.name,
	fa.primary_color,
	fa.admission_date,
	( 	SELECT 
		COUNT(*) 
		FROM filtered_animals AS fa2
		WHERE fa.species = fa2.species 
		AND
		fa2.admission_date < fa.admission_date 
	) AS up_to_previous_day_animal_species
FROM filtered_animals AS fa
ORDER BY 
	fa.species, fa.admission_date
;
-- This query shows that when the dog Ranger was admitted to the shelter, there was already 2 dogs before, -


-- Now with the window function
--What we need instead of a ROW frame is a RANGE frame. And since we are going to do that, we need to change the data type. 

SELECT
	species,
	name,
	primary_color,
	admission_date,
	COUNT(*) 
	OVER (	PARTITION BY 	species
			ORDER BY 		admission_date ASC
			RANGE BETWEEN 	UNBOUNDED PRECEDING -- Here instead of ROWS we need to specify the range in days
							AND
							'1 day' PRECEDING -- Here we change the 1 (INT used for ROWS), for '1 day' since the data type is a date
							-- This option then tells the query not to use the current DAY but the previous one so the count stops at the preceding DAY 
			) AS number_of_species_animals
FROM
	animals
WHERE 
	species = 'Dog'
	AND admission_date > '2017-08-01'
ORDER BY
	species,
	admission_date 
;

-- This query is not only clearer to read but also 10x faster that the one with the subquery and the CTE