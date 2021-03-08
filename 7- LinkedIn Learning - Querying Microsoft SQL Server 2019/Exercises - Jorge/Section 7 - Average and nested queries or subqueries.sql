-- SELECT ORDERS THAT ARE ABOVE AVERAGE VALUES
-- Using nested queries

USE AdventureWorks2019;

-- Exploration

SELECT 
*
FROM Sales.SalesOrderDetail
;

-- STEP 1
-- Each line represent a product in the order. So we calculate the total amount by order

SELECT 
	SalesOrderID
	, SUM(LineTotal) As OrderTotal
FROM Sales.SalesOrderDetail
GROUP BY 
	SalesOrderID
;

-- STEP 2
-- We use a version of that query to then extract the average order value from it

SELECT
AVG(MyValues) as Average_Value
FROM (
	SELECT 
		SUM(LineTotal) As MyValues
	FROM Sales.SalesOrderDetail
	GROUP BY SalesOrderID
	) AS ResultsTable
	;

-- STEP 3
-- We use the query filtering the grouped order by the previous query, the one that returned the average order value

SELECT 
	SalesOrderID
	, SUM(LineTotal) As OrderTotal
FROM Sales.SalesOrderDetail
GROUP BY 
	SalesOrderID
HAVING SUM(LineTotal) > 
	(	SELECT -- 2) This is the one that calculates the average
		AVG(MyValues) as Average_Value
		FROM ( -- 1) This is the one that calculates all the values
				SELECT 
					SUM(LineTotal) As MyValues
				FROM Sales.SalesOrderDetail
				GROUP BY SalesOrderID
			) AS ResultsTable
	)
;
