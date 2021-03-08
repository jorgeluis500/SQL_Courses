-- We have two tables, Person and Employee

SELECT 
	BusinessEntityID
	, FirstName
	, LastName
FROM Person.Person
;

SELECT 
	BusinessEntityID
	, JobTitle
FROM HumanResources.Employee


-- We want to have the employees only with their titles. We can do that with an inner join

SELECT 
	P.BusinessEntityID
	, P.FirstName
	, P.LastName
	, E.JobTitle
FROM Person.Person P
INNER JOIN HumanResources.Employee E 
	ON P.BusinessEntityID = E.BusinessEntityID
;

-- We can also do that with a correlated subquery
-- To achieve that, we use the first query but we use the second one inside the first one to bring the titles. We need to create a link bewtween the two


SELECT 
	BusinessEntityID
	, FirstName
	, LastName
	, (SELECT JobTitle FROM HumanResources.Employee WHERE BusinessEntityID = MyPeople.BusinessEntityID) AS Employee_Title -- This is the second query with a WHERE clause
FROM Person.Person AS MyPeople -- This one has an alias that is used in the correlated subquery
;
-- This query is equivalent to a LEFT join, so it brings everyone. 
-- To filter is to only the existing values in both tables, we create anothjer filtering condition

SELECT 
	BusinessEntityID
	, FirstName
	, LastName
	, (SELECT JobTitle FROM HumanResources.Employee WHERE BusinessEntityID = MyPeople.BusinessEntityID) AS Employee_Title 
FROM Person.Person AS MyPeople 
WHERE 
	(SELECT JobTitle FROM HumanResources.Employee WHERE BusinessEntityID = MyPeople.BusinessEntityID) IS NOT NULL -- New condition
;

-- ...which can also be expresed like this

SELECT 
	BusinessEntityID
	, FirstName
	, LastName
	, (SELECT JobTitle FROM HumanResources.Employee WHERE BusinessEntityID = MyPeople.BusinessEntityID) AS Employee_Title 
FROM Person.Person AS MyPeople 
WHERE 
	EXISTS (SELECT JobTitle FROM HumanResources.Employee WHERE BusinessEntityID = MyPeople.BusinessEntityID)
;

-- Which one to use in a real case? Test the performance in the real situation