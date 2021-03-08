-- ADVANCED SQL - LOGICAL QUERY PROCESSING 2
-- Section 2 - Self and Inequality joins

--Show people who adopted 2 animals on the sane day. No less than 2 no more than 2. Same day

SELECT 
	a.adopter_email,
	a.adoption_date,
	a.species AS species_1, 
	a."name" AS name_1, 
	a2.species AS species_2, 
	a2."name" AS name_2 
FROM adoptions a 
	INNER JOIN adoptions a2
	ON a.adopter_email = a2.adopter_email AND a.adoption_date = a2.adoption_date -- This joins the email and dates lines with themselves
	AND a.name <> a2.name -- This get rid of the lines that have the same animals inverted in both lines,
	AND a.name > a2.name -- And this, gets rid of the duplicates, using the dictionary order to do so. It can replace the previous predicate entirely
	-- This works here only becasue there are two animals per day in some cases.
ORDER BY a.adopter_email, a.adoption_date 
;

--To account for: 
	-- Animals with the same name and different species
	-- Animals with the same species and different names
	-- Animals with different species and different names
-- We must use the following query:

SELECT 
	a.adopter_email,
	a.adoption_date,
	a.species AS species_1, 
	a."name" AS name_1, 
	a2.species AS species_2, 
	a2."name" AS name_2 
FROM adoptions a 
	INNER JOIN adoptions a2
	ON a.adopter_email = a2.adopter_email AND a.adoption_date = a2.adoption_date
	AND (	(a.name = a2.name AND a.species > a2.species) 	-- Animals with the same name and different species
		OR 	(a.name > a2.name AND a.species = a2.species) -- Animals with the same species and different names
		OR 	(a.name > a2.name AND a.species <> a2.species) -- Animals with different species and different names
		)
ORDER BY a.adopter_email, a.adoption_date 
