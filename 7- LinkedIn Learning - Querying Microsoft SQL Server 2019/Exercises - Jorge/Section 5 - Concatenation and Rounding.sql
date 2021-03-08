-- Concatenation

-- There is a function to concatenate with a separator, CONCAT_WS. It's smarter than the original CONCAT. 
-- It "knows" when to add the separator. In the following example, if there is a NULL middle name, the separator is added only once 

SELECT 
	FirstName,
	LastName,
	CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS FullName,
	CONCAT_WS(' ', FirstName,  MiddleName, LastName) AS FullName2
FROM Person.Person;


-- Round with mathematical functions

SELECT 
	BusinessEntityID
	, SalesYTD
	, ROUND(SalesYTD,2) AS Round2
	, ROUND(SalesYTD,-2) AS RoundHundred -- Rounds to the hundreds
	, CEILING(SalesYTD) AS RoundCeiling
	, FLOOR(SalesYTD) AS RoundFloor
FROM Sales.SalesPerson;