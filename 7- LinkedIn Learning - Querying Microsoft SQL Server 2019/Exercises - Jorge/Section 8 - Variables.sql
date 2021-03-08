-- VARIABLES

DECLARE @MyFirstVariable INT;

SET @MyFirstVariable = 5;

SELECT 
@MyFirstVariable AS MyValue
, @MyFirstVariable *5 AS Multiplication
, @MyFirstVariable + 10 AS Addition
;

-- Another one

DECLARE @VarColor VARCHAR(20) = 'Red' -- The value can be set in the declaration

SELECT 
	ProductNumber
	, Color
	, ListPrice
FROM Production.Product
WHERE Color = @VarColor
;