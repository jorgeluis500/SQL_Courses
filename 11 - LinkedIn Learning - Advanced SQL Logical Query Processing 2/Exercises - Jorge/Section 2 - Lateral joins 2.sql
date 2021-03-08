-- ADVANCED SQL - LOGICAL QUERY PROCESSING 2
-- Section 2 - Lateral joins

-- Top N per group challenge

-- Show animals with their most recent vaccinations


--This works but is inefficient. It's a correlated subquery that returns one value and one column per row of the parent query

SELECT 
	a.Species,
	a.Name,
	a.Breed,
	a.Primary_Color,
	(	SELECT v.vaccine -- only one field
		FROM Vaccinations v 
		WHERE a.Name = v.Name AND a.Species = v.Species 
		ORDER BY v.vaccination_time DESC -- gives me the most recent first
		OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY  -- leaves me the most recent only
	) AS lv -- Last_vaccine
FROM Animals a
;

-- It doesn't work is we need the 3 most recent
-- Neither does it returns another field, apart from vaccine
-- So we use another approach, a LATERAL join

-- In PostgreSQL:

SELECT 
	a.Species,
	a.Name,
	a.Breed,
	a.Primary_Color,
	lv.*
FROM Animals a
CROSS JOIN LATERAL
	(	SELECT v.Vaccine, v.Vaccination_Time 
		FROM Vaccinations v 
		WHERE a.Name = v.Name AND a.Species = v.Species 
		ORDER BY v.vaccination_time DESC -- gives me the most recent first
		OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY  -- leaves me the three most recent only
	) AS lv -- Last_vaccine
;

--In SQL Server
-- We only change the CROSS LATERAL JOIN for CROSS APPLY

SELECT 
	a.Species,
	a.Name,
	a.Breed,
	a.Primary_Color,
	lv.*
FROM Animals a
CROSS APPLY -- This is the only change made
	(	SELECT v.Vaccine, v.Vaccination_Time 
		FROM Vaccinations v 
		WHERE a.Name = v.Name AND a.Species = v.Species 
		ORDER BY v.vaccination_time DESC 
		OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY 
	) AS lv -- Last_vaccine
;

-- With a CROSS JOIN the animals that have not been vaccinated, don't appear. 
-- To see them, we use an OUTER join
-- Unlike normal joins, there's no logical qualification predicate here. 
-- The derive table is evaluated for each animal row. 
-- And the correlation predicate is what determines which rows will qualify. 
-- In a sense, the correlation is the qualification. 
-- To overcome this syntax challenge, we need to use a bullion true expression as the join qualification predicate. 

-- In PostgreSQL:

SELECT 
	a.Species,
	a.Name,
	a.Breed,
	a.Primary_Color,
	lv.*
FROM Animals a
LEFT OUTER JOIN LATERAL -- We change this, compared with the previous query
	(	SELECT v.Vaccine, v.Vaccination_Time
		FROM Vaccinations v 
		WHERE a.Name = v.Name AND a.Species = v.Species 
		ORDER BY v.vaccination_time DESC 
		OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY  
	) AS lv -- Last_vaccine
ON TRUE -- And we add this, compared to the previous query
;

--In SQL Server

SELECT 
	a.Species,
	a.Name,
	a.Breed,
	a.Primary_Color,
	lv.*
FROM Animals a
OUTER APPLY -- Instead of LEFT OUTER JOIN LATERAL in the previous query
	(	SELECT v.Vaccine, v.Vaccination_Time
		FROM Vaccinations v 
		WHERE a.Name = v.Name AND a.Species = v.Species 
		ORDER BY v.vaccination_time DESC 
		OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY  
	) AS lv -- Last_vaccine
--The ON TRUE predicate is not needed nor allowed in SQL Server
;





