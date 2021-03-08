-- ADVANCED SQL - LOGICAL QUERY PROCESSING 2
-- Section 3 - Grouping sets

--In SQL Server (In PostgreSQl it would be using DATE_PART

--If we need to present year-month, results, yeraly results and total resutls, we coud do something like this

SELECT 		YEAR(adoption_date) AS year, MONTH(adoption_date) AS Month, COUNT(*) as monthly_adoptions
FROM 		adoptions a2
GROUP BY 	YEAR(adoption_date), MONTH(adoption_date) 

UNION ALL

SELECT 		YEAR(adoption_date) AS year, COUNT(*) as annual_adoptions
FROM 		adoptions a2
GROUP BY 	YEAR(adoption_date)

UNION ALL

SELECT 		COUNT(*) as total_adoptions
FROM 		adoptions a2
GROUP BY 	() -- This is the standar form when we group by nothing, gives the total result

-- but, since the UNION doesn't work because we do't have the same number of columns
;

-- We can't add strings as months and year en the second and third queries because the data tupes are not the same
-- But we can add NULLs, since they don't have any data type

SELECT 		YEAR(adoption_date) AS year, MONTH(adoption_date) AS Month, COUNT(*) as monthly_adoptions
FROM 		adoptions a2
GROUP BY 	YEAR(adoption_date), MONTH(adoption_date) 

UNION ALL

SELECT 		YEAR(adoption_date) AS year, NULL AS Month, COUNT(*) as annual_adoptions
FROM 		adoptions a2
GROUP BY 	YEAR(adoption_date)

UNION ALL

SELECT 		NULL AS year, NULL AS Month, COUNT(*) as total_adoptions
FROM 		adoptions a2
GROUP BY 	() 
;

-- We can also use a WITH clause to deal with it
-- We wrap the firs query in a WITH clasue and use it three times with unions

WITH Aggregated_options AS 
(
SELECT 		YEAR(adoption_date) AS year, MONTH(adoption_date) AS Month, COUNT(*) as Adoptions -- Name_changed to better reflect the metric
FROM 		adoptions a2
GROUP BY 	YEAR(adoption_date), MONTH(adoption_date) 
)

SELECT * 
FROM Aggregated_options

UNION ALL

SELECT 		Year, NULL, COUNT(*) 
FROM 		Aggregated_options
GROUP BY 	Year

UNION ALL

SELECT 		NULL, NULL, COUNT(*)
FROM Aggregated_options
GROUP BY ()

;

-- However, this approach is neither efficient, nor scalable nor convenient. The queries can become long

-- In this case, we could use the grouping sets


SELECT 		YEAR(adoption_date) AS year, 
			MONTH(adoption_date) AS Month, 
			COUNT(*) as Adoptions

FROM 		adoptions a2

GROUP BY 	GROUPING SETS ((  YEAR(adoption_date), MONTH(adoption_date)  )) -- Two group of parenthesis
--- We need to add two groups of parenthesis so the whole combination year-months is treated as a single group		
;

-- If we use only a single group of parenthesis, each year and month are treated a single groups and then "unioned" in a single query

SELECT 		YEAR(adoption_date) AS year, 
			MONTH(adoption_date) AS Month, 
			COUNT(*) as Adoptions

FROM 		adoptions a2

GROUP BY 	GROUPING SETS (  YEAR(adoption_date), MONTH(adoption_date)  ) -- Two group of parenthesis, the internal to define the group, the externat to list each group, in this case, only one
;

-- Therefore, to get our year-month, yearly and total results, we need to inldude each field or combination of fields inside the GROUPING SETS operator, separated by commas

SELECT 		YEAR(adoption_date) AS Year, 
			MONTH(adoption_date) AS Month, 
			COUNT(*) as Adoptions

FROM 		adoptions a2

GROUP BY 	GROUPING SETS 	(
							( YEAR(adoption_date), MONTH(adoption_date)), 	-- First group  
							YEAR(adoption_date), 							-- Second group
							()												-- Third group
							)

ORDER BY Year, Month
;

-- Grouping sets are not limited to related or hierarchichal expressions

SELECT 		YEAR(adoption_date) AS Year, 
			Adopter_Email, 						-- Different field
			COUNT(*) AS Adoptions

FROM 		adoptions a2

GROUP BY 	GROUPING SETS 	(
							YEAR(adoption_date), 							
							Adopter_Email		-- Different field
						)
;

-- Another example. Count the number of animals grouped by Species, Breed and overall:

SELECT 
	Species,
	Breed,
	COUNT(*) AS number_of_animals
FROM Animals a2
GROUP BY
GROUPING SETS (	Species, Breed, () )
ORDER BY 
	Species, 
	Breed

-- This query, unfortunately, gives os two NULL lines, one for the overal results (correctly) and one for All the NULLS in the species	
	;

-- The way to overcome this, is by adding a COALESCE for the species and a CASE and a GROUPING expression for the breed, like this

SELECT 
	COALESCE(Species,'All') AS Species,
	Breed,
	COUNT(*) AS number_of_animals
FROM Animals a2
GROUP BY
GROUPING SETS (	Species, Breed, () )
ORDER BY 
	Species, 
	Breed


