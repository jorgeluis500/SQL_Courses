-- SELECT MAX VALUE FROM A TABLE

USE AdventureWorks2019;

-- Method 1:

SELECT 
	BusinessEntityID
	, SalesYTD
	, (SELECT MAX(SalesYTD) FROM Sales.SalesPerson) AS HighestSalesYTD
FROM Sales. SalesPerson
ORDER BY SalesYTD DESC
;

-- Method 2

SELECT 
	*
FROM Sales. SalesPerson
WHERE SalesYTD= (SELECT MAX(SalesYTD) FROM Sales.SalesPerson) 
ORDER BY SalesYTD DESC

-- Method 3

SELECT 
	BusinessEntityID
	, SalesYTD
	, MAX(SalesYTD) OVER () AS HighestSalesYTD
FROM Sales. SalesPerson
ORDER BY SalesYTD DESC
