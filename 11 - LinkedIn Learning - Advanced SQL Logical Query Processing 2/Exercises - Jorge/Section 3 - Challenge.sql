-- ADVANCED SQL - LOGICAL QUERY PROCESSING 2
-- Section 3 - Challenge



--Last challenge is to write a query that returns a statistical report of vaccinations.
--The report should include the total number of vaccinations for several dimensions:
--🢂 Annual
--🢂 Per species
--🢂 For each species per year
--🢂 By each staff member
--🢂 By each staff member per species
--And to make it interesting, let’s throw in the latest vaccination year for each of these groups

-- Using Grouping sets


SELECT * FROM vaccinations;

-- SOLUTION IN POSTGRES
-- First part. Assemble the groups
-- We must always use the primary keys. In the persons case it's the email field

SELECT 
	COALESCE (CAST (DATE_PART('year', vaccination_time) AS VARCHAR(8) ), 'All Years') AS Year,
	COALESCE(Species, 'All Species') AS Species,
	COALESCE(email, 'All Staff') AS Email,
	COUNT(*) AS number_of_vaccinations 
FROM vaccinations v
GROUP BY 
GROUPING SETS
	(
	DATE_PART('year', vaccination_time),
	(DATE_PART('year', vaccination_time), Species), -- Composite group
	Species,
	(species, email), -- Composite group
	email,
	() -- Group for ALL
	)
ORDER BY 
	DATE_PART('year', vaccination_time), 
	Species,
	email
;

-- Postgres.Second part. 
-- Add the persons name by joining the persons table (It should be done at the beginning of the problem, though)
-- The grouping still need to be at the email level, which is the primary key
-- To get the first and last name, we must use dummy aggregations and a case to check when the aggregation by email is 0
-- We need to add the Max year as a aggregation and it will be handed by the grouping

SELECT 
	COALESCE (CAST (DATE_PART('year', v.vaccination_time) AS VARCHAR(8) ), 'All Years') AS Year,
	COALESCE(v.Species, 'All Species') AS Species,
	COALESCE(v.email, 'All Staff') AS Email,
	CASE WHEN GROUPING (v.Email) = 0 THEN MAX(p.first_name) ELSE '' END AS first_name, -- Dummy aggregate with a CASE to test the grouping not the row itself
	CASE WHEN GROUPING (v.Email) = 0 THEN MAX(p.last_name) ELSE '' END AS last_name, -- Dummy aggregate with a CASE to test the grouping not the row itself
	COUNT(*) AS number_of_vaccinations,
	MAX(DATE_PART('year', v.vaccination_time)) AS Max_year
FROM vaccinations v
INNER JOIN Persons p ON v.email = p.email
GROUP BY 
GROUPING SETS
	(
	DATE_PART('year', v.vaccination_time),
	(DATE_PART('year', v.vaccination_time), v.Species), -- Composite group
	v.Species,
	(v.species, v.email), -- Composite group
	v.email,
	()
	)
ORDER BY 
	DATE_PART('year', v.vaccination_time), 
	v.Species,
	v.email
;


-- SOLUTION IN SQL SERVER
-- We need to use YEAR( instead of DATE_PART('year',

-- First part. Assemble the groups
-- We must always use the primary keys. In the persons case it's the email field

SELECT 
	COALESCE (CAST (YEAR( vaccination_time) AS VARCHAR(8) ), 'All Years') AS Year,
	COALESCE(Species, 'All Species') AS Species,
	COALESCE(email, 'All Staff') AS Email,
	COUNT(*) AS number_of_vaccinations 
FROM vaccinations v
GROUP BY 
GROUPING SETS
	(
	YEAR( vaccination_time),
	(YEAR( vaccination_time), Species), -- Composite group
	Species,
	(species, email), -- Composite group
	email,
	() -- Group for ALL
	)
ORDER BY 
	YEAR( vaccination_time) DESC, -- The sorting must be different in SQL Server
	Species,
	email
;

-- SQL Server. Second part. 
-- Add the persons name by joining the persons table (It should be done at the beginning of the problem, though)
-- The grouping still need to be at the email level, which is the primary key
-- To get the first and last name, we must use dummy aggregations and a case to check when the aggregation by email is 0
-- We need to add the Max year as a aggregation and it will be handed by the grouping

SELECT 
	COALESCE (CAST (YEAR( v.vaccination_time) AS VARCHAR(8) ), 'All Years') AS Year,
	COALESCE(v.Species, 'All Species') AS Species,
	COALESCE(v.email, 'All Staff') AS Email,
	CASE WHEN GROUPING(v.Email) = 0 THEN MAX(p.First_Name) ELSE '' END AS First_Name, -- Dummy aggregate with a CASE to test the grouping not the row itself
	CASE WHEN GROUPING(v.Email) = 0 THEN MAX(p.Last_Name) ELSE '' END AS Last_Name, -- Dummy aggregate with a CASE to test the grouping not the row itself
	COUNT(*) AS number_of_vaccinations,
	MAX(YEAR( v.vaccination_time)) AS Max_year
FROM vaccinations v
INNER JOIN Persons p ON v.Email = p.Email
GROUP BY 
GROUPING SETS
	(
	YEAR( v.vaccination_time),
	(YEAR( v.vaccination_time), v.Species), 
	v.Species,
	(v.species, v.email), 
	v.email,
	()
	)
ORDER BY 
	YEAR( v.vaccination_time) DESC, 
	v.Species,
	v.email
;
