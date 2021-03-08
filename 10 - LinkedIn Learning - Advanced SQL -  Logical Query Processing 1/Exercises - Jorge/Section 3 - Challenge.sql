--LOGICAL QUERY ORDER PROCESSING 1
--Section 4 
-- Challenge

-- Write a query to report the number of vaccinations each animal has received
-- Include animals that have never been vaccinated
-- Exclude rabbits, rabies vaccines, and animal that were last vaccinated on or after October first, 2019

-- The report should show animal name, species, primary color, breed and the number of vacinations
-- Use the correct logicvl join types and force order if needed. Use the correct logical group by expressions

-- Exploration and tests

USE Animal_Shelter;

SELECT 
	* 
FROM vaccinations v2 
;

SELECT 
	* 
FROM animals a2 
LEFT OUTER JOIN 	vaccinations v ON a2.species = v.species AND a2."name" = v."name"
--WHERE a2.species = 'Rabbit' AND a2.name= 'Humphrey'
ORDER BY a2.species, v.name
;

-- MY SOLUTION

SELECT 
			a.species,
			a.name,	
			a.primary_color,
			a.breed,
			COUNT(v.vaccination_time) AS Number_of_vaccinations,
			MAX(v.vaccination_time) AS last_vaccination_date

FROM 		animals a 
LEFT JOIN 	vaccinations v ON a.species = v.species AND a."name" = v."name" 

WHERE 		(v.vaccine <> 'Rabies' OR v.vaccine IS NULL)  -- v.vaccine IS DISTINCT FROM 'Rabies' -- In PostgreSQL this form is more elegant 

GROUP BY 	a.name,	
			a.species,
			a.primary_color,
			a.breed 

HAVING 		(MAX(v.vaccination_time) <= '2019-10-01' OR MAX(v.vaccination_time) IS NULL)
		AND a.species <>'Rabbit' -- This works here becasue the GROUP BY clause leaves this partition but it should be be moved to the WHERE clause
		
ORDER BY 	COUNT (vaccination_time) ASC, species, name

;

--The previous query si correct but there is a better way to get the results
-- The species clause that is in teh HAVING can be moved to the WHERE clause, to be procesed first


SELECT 
			a.species,
			a.name,	
			a.primary_color,
			a.breed,
			COUNT(v.vaccination_time) AS Number_of_vaccinations,
			MAX(v.vaccination_time) AS last_vaccination_date

FROM 		animals a 
LEFT JOIN 	vaccinations v ON a.species = v.species AND a."name" = v."name" 

WHERE 		(v.vaccine <> 'Rabies' OR v.vaccine IS NULL)  -- v.vaccine IS DISTINCT FROM 'Rabies' -- In PostgreSQL this form is more elegant 
		AND a.species <>'Rabbit'

GROUP BY 	a.name,	
			a.species,
			a.primary_color,
			a.breed 

HAVING 		(MAX(v.vaccination_time) <= '2019-10-01' OR MAX(v.vaccination_time) IS NULL)
				
ORDER BY 	COUNT (vaccination_time) ASC, species, name