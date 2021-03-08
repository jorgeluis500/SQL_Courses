-- ADVANCED SQL - LOGICAL QUERY PROCESSING 2
-- Section 1 - Set Operators


-- Find animals that were not adopted

-- My solution

-- With a Set operator
-- This is the best option. Efficient and readable
SELECT species, "name" FROM animals
EXCEPT DISTINCT
SELECT species, "name" FROM adoptions;


--Other solutions

-- With a join
SELECT DISTINCT -- needed becasue if the same animal is adopted and returned in the future, it will appear twice
--	*
	a1.species, 
	a1."name" 
FROM animals a1
LEFT JOIN adoptions a2 ON a1."name"  = a2."name"  AND a1.species = a2.species
WHERE a2.adopter_email IS NULL
ORDER BY 
	a1.species, 
	a1."name";
	
-- With NOT EXISTS
-- Select name, species, from animals where NOT EXIST. 
--Select something, from adoptions, where name equals name and species equals species. 
--Here we don't need DISTINCT. Duplicates are not possible as the sub query will be evaluated only once per animal. 
--So each animal can only be returned either once or not at all.

SELECT
	species,
	"name"
FROM
	animals a1
WHERE NOT EXISTS	(
					SELECT * -- Again, anything can be put here since we are correlating the subquery with the parent one
					FROM adoptions a2 
					WHERE a1."name"  = a2."name"  AND a1.species = a2.species
					)
;


