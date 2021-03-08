-- ADVANCED SQL - LOGICAL QUERY PROCESSING 2
-- Section 1 - Challenge

-- Show which breeds were never adopted

-- NULL breeds need to be considered carefully
-- There are NULL Dogs and NULL cats so species need to be added to
-- Answer: The only breed that was never adopter was the Turkish Angora cat
-- Try using the other techniques first to see if they work, before Set operators:  OUTER JOIN, NOT EXISTS and NOT IN


-- Exploration
SELECT * FROM adoptions;
SELECT * FROM animals;

SELECT * 
FROM animals a1 
	LEFT JOIN adoptions a2 ON  a1."name"  = a2."name"  AND a1.species = a2.species
--WHERE a2.adoption_date IS NULL
;



-- LEFT JOIN My solution
-- No solution

-- First try

SELECT 
	a1.species,
--	a1."name" ,
	a1.breed,
	COUNT(a2.adopter_email) AS number_of_adoptions
FROM animals a1 
LEFT JOIN adoptions a2 ON  a1."name"  = a2."name"  AND a1.species = a2.species
GROUP BY
	a1.species,
--	a1."name" ,
	a1.breed
ORDER BY 
	a1.species,
--	a1."name" ,
	a1.breed
;

-- Second try
SELECT DISTINCT -- needed becasue if the same animal is adopted and returned in the future, it will appear twice
--	*
	a1.species,
	a1.breed
--	a1."name" 
FROM animals a1
LEFT JOIN adoptions a2 ON a1."name"  = a2."name"  AND a1.species = a2.species
WHERE a2.adopter_email IS NULL AND a1.breed IS NOT NULL
ORDER BY 
	a1.species 
--	a1."name"
;


--NOT EXISTS. My solution
--No solution

SELECT
	species,
	breed
FROM
	animals a1
WHERE NOT EXISTS	(
					SELECT NULL -- Again, anything can be put here since we are correlating the subquery with the parent one
					FROM adoptions a2 
					WHERE a1."name"  = a2."name"  AND a1.species = a2.species
					)
;


-- WITH IN
-- This works

SELECT DISTINCT 
--	*
		species,
		breed 
FROM 	animals a
WHERE 	(Species, breed) NOT IN
	(
		SELECT 
					a1.species, a1.breed
		FROM 		animals a1
		INNER JOIN 	adoptions a2 ON a1."name"  = a2."name"  AND a1.species = a2.species
		WHERE 		a1.breed IS NOT NULL -- If this is not included, we get an empty set
	)	
;

		
-- With Set operators

SELECT species, breed FROM animals -- This results in all the animals

EXCEPT -- DISTINCT -- This is by default

SELECT a1.species, a1.breed -- This query results in all the animals that were adopted 
FROM animals a1 
	INNER JOIN adoptions a2 
	ON  a1."name"  = a2."name"  AND a1.species = a2.species

-- Since we are choosing only two columns, we are eliminating everything except the ones that ar not in the second set
	