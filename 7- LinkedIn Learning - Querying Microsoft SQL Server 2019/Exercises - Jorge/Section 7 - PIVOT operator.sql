-- PIVOT data


-- Exploration

SELECT 
	ProductLine
	, ListPrice
FROM Production.Product
WHERE ProductLine IS NOT NULL
;

-- Select the average list price

SELECT 
	ProductLine
	, AVG(ListPrice) AS AverageProce
FROM Production.Product
WHERE ProductLine IS NOT NULL
GROUP BY
	ProductLine;


-- Now we build a new query to pivot results from a query very similar to the first one
-- The IN operator assures only the selected values are used and the NULLs are not included

SELECT 
	M
	, R
	, S
	, T
FROM (
	SELECT 
		ProductLine
		, ListPrice
	FROM Production.Product ) AS SourceData
PIVOT (AVG(ListPrice) FOR ProductLine IN (M, R, S, T)) AS PivotTable
;

-- Wen can even add names to the metrics

SELECT 
	'Average List Price' AS 'Product Line'
	, M
	, R
	, S
	, T
FROM (
	SELECT 
		ProductLine
		, ListPrice
	FROM Production.Product ) AS SourceData
PIVOT (AVG(ListPrice) FOR ProductLine IN (M, R, S, T)) AS PivotTable
;

-- Performance-wise, it behaves similar to the COUNT CASE method
