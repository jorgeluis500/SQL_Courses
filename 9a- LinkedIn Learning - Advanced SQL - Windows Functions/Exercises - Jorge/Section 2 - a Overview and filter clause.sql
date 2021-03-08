-- WINDOWS FUNCTIONS
-- Overview of the OVER and filter clause

-- These two queries are similar in results. However, the cost of the one that uses the window function is about 30% less that the one with the subquery

SELECT
	species,
	name,
	primary_color,
	admission_date, 
	(SELECT COUNT(*) FROM animals WHERE admission_date >= '2017-01-01') AS number_of_animals
FROM
	animals a2
WHERE 
	admission_date >= '2017-01-01'
ORDER BY
	admission_date 
;


SELECT
	species,
	name,
	primary_color,
	admission_date, 
	COUNT(*) OVER () AS number_of_animals
FROM
	animals a2
WHERE admission_date >= '2017-01-01'
ORDER BY
	admission_date 
;
