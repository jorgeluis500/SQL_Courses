-- ADVANCED SQL - LOGICAL QUERY PROCESSING 2
-- Section 2 - Lateral joins

--Show the animails with the 3 most recent vaccines

-- WITH POSTGRESQL

SELECT 
	a."name",
	a.species,
	a.primary_color,
	a.breed,
	Last_vaccinations.*
FROM animals a
CROSS JOIN LATERAL --  Lateral processing invokes the sub query for each row of the animal's table and accumulates the result. 
	(
	SELECT 
		v.vaccine, 
		v.vaccination_time 
 	FROM vaccinations v
 	WHERE v.name = a."name"
 		AND a.species = v.species 
 	ORDER BY vaccination_time DESC -- This is the only time where the ORDER BY is allowed in derived tables
 	LIMIT 3 OFFSET 0
 	) AS Last_vaccinations
;

-- If we want to include animal that were never vaccinated, we mus use a lEFT Lateral join. The reservation clause must 

SELECT 
	a."name",
	a.species,
	a.primary_color,
	a.breed,
	Last_vaccinations.*
FROM animals a
LEFT OUTER JOIN LATERAL --  
	(
	SELECT 
		v.vaccine, 
		v.vaccination_time 
 	FROM vaccinations v
 	WHERE v.name = a."name"
 		AND a.species = v.species 
 	ORDER BY vaccination_time DESC
 	LIMIT 3 OFFSET 0
 	) AS Last_vaccinations
ON TRUE 
--The derived table is evaluated for each animal row. 
--And the correlation predicate is what determines which rows will qualify. 
--In a sense, the correlation is the qualification. 
--To overcome this syntax challenge, we need to use a bullion true expression as the join qualification predicate. 
;


--WITH SQL SERVER
-- Microsoft uses its own sintaxis, CROSS APPLY and OUTER APPLY

SELECT 
	a."name",
	a.species,
	a.primary_color,
	a.breed,
	Last_vaccinations.*
FROM animals a
CROSS APPLY -- CROSS JOIN LATERAL  is replaced by CROSS APPLY
	(
	SELECT 
		v.vaccine, 
		v.vaccination_time 
 	FROM vaccinations v
 	WHERE v.name = a."name"
 		AND a.species = v.species 
 	ORDER BY vaccination_time DESC
 	OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY 
 	) AS Last_vaccinations
;

-- Including animals that were never vaccinated

SELECT 
	a."name",
	a.species,
	a.primary_color,
	a.breed,
	Last_vaccinations.*
FROM animals a
OUTER APPLY -- The LEFT OUTER JOIN LATERAL is replaced by OUTER APPLY
	(
	SELECT TOP 3 -- Used instead of  OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY just to test
		v.vaccine, 
		v.vaccination_time 
 	FROM vaccinations v
 	WHERE v.name = a."name"
 		AND a.species = v.species 
 	ORDER BY vaccination_time DESC
-- 	OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY
 	) AS Last_vaccinations
--ON TRUE -- In SQl Server this is not needes becasue it is not allowed 
;
