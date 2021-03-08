-- ADVANCED SQL - LOGICAL QUERY PROCESSING 2
-- Section 1 - Subqueries

-- PROBLEM 1
-- Show adoption rows including fees
-- MAX fee ever paid
-- Discount from MAX in percent

-- My solution

-- It is a non-correlated subquery, calculated from the same adoption table
SELECT 
	*,
	(SELECT MAX(adoption_fee) FROM adoptions a3) AS Max_fee,
	((SELECT MAX(adoption_fee) FROM adoptions a3) - adoption_fee) *100.0 / (SELECT MAX(adoption_fee) FROM adoptions a3)  AS Discount_percent
FROM adoptions a2 
;

-- PROBLEM 2
--Include the MAX fee per species instead of overall

--Test the max fee per species standalone
SELECT 
	species, 
	MAX(adoption_fee) AS Max_fee_per_species
FROM	adoptions
GROUP BY 
	species 
;

-- Using a correlated query
-- We must provide distinct aliases to differentiate the table in each case

SELECT 	*,
		(SELECT MAX(adoption_fee)
		FROM adoptions a2
		WHERE a2.species = a3.species) AS Max_fee_per_species -- Instead of filtering individually (if it could be done), we use the a3.species to get the pax for each one
FROM adoptions a3 ;


-- PROBLEM 3
--Show all attributes of people that adopted at least one animal

-- Test tables
SELECT * FROM persons;
SELECT * FROM adoptions;


-- First way
-- With an INNER JOIN between the persons and adoptions table

SELECT 
		DISTINCT p2.* -- Adding the DISTINCT operator guarantees that the adopters' emails will appear only once 
FROM 	persons p2 
INNER JOIN 	adoptions a2 ON p2.email = a2.adopter_email 
ORDER BY 
	p2.email
;

-- Second way

SELECT 
	* 
FROM persons p2 
WHERE email IN (SELECT adopter_email FROM adoptions a2 )
ORDER BY email 
;


-- Third way
-- Using EXISTS
-- Exists is typically used in the where clause, and is followed by a correlated subquery. 
-- It is evaluated for each row and the rows for which the sub query we turns at least one row will evaluate to true. 
-- Nothing prevents us from using a non-correlated subquery in exists, but it doesn't make much sense, since, if we do that, all rows will either evaluate to true or false.

SELECT 
	* 
FROM persons p2 
WHERE EXISTS (SELECT NULL -- You can put anything here sice the important thing is the predicate as a whole
		     FROM adoptions a2 
		     WHERE p2.email = a2.adopter_email) 
;

