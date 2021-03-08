-- WINDOWS FUNCTIONS
-- PARTITION and ORDER BY

-- We are going to bring the number of animals for each species

/*
Using a sub-query solution requires introducing a correlation between the parent query and the sub-query so that the count is limited only to animals of the same species. 
This requires unique aliases to distinguish between the two instances of the table, A1 and a1.

This is a ver expensive query becasue the correlated query is executed for each row. Cost 340 
*/

SELECT
	a1.species,
	a1.name,
	a1.primary_color,
	a1.admission_date,
	( SELECT COUNT(*) FROM animals a2 WHERE a1.species = a2.species ) AS number_of_species_animals
FROM
	animals a1
ORDER BY
	a1.species,
	a1.admission_date 
	;

-- The second option is to use a join to another query. A non-correlated sub-query
-- This one is much better (Cost 10.55)


SELECT
	a1.species,
	a1.name,
	a1.primary_color,
	a1.admission_date,
	ca.number_of_species_animals
FROM
	animals a1
INNER JOIN (
	SELECT
		species,
		COUNT(*) AS number_of_species_animals
	FROM
		animals a
	GROUP BY
		species
		) AS ca 
	ON ca.species = a1.species
ORDER BY
	a1.species,
	a1.admission_date
;

-- The window function is a little more expensive at 11.4

SELECT
	species,
	name,
	primary_color,
	admission_date,
	COUNT(*) OVER (PARTITION BY species) AS number_of_species_animals
FROM
	animals
ORDER BY
	species,
	admission_date
;

SELECT MIN(admission_date) FILTER(species) OVER ()
FROM animals;