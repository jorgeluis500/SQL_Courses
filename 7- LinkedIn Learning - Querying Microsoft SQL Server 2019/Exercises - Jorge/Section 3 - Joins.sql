-- Tables separateley
SELECT 
	BusinessEntityID
	, FirstName	
	, LastName	
FROM Person.Person
;

SELECT 
	BusinessEntityID
	, PhoneNumber
FROM Person.PersonPhone
;

-- INNER JOIN

SELECT 
	Person.BusinessEntityID
	, Person.FirstName	
	, Person.LastName
	, PersonPhone.PhoneNumber
FROM Person.Person 
	INNER JOIN Person.PersonPhone 
		 ON Person.BusinessEntityID = PersonPhone.BusinessEntityID
;

-- LEFT JOIN

SELECT 
	Person.BusinessEntityID
	, Person.PersonType
	, Person.FirstName
	, Person.LastName
	, Employee.JobTitle
FROM Person.Person
	LEFT JOIN HumanResources.Employee
		ON Person.BusinessEntityID = Employee.BusinessEntityID
;
-- CROSS JOIN

-- 1
SELECT 
	Department.Name AS DepartmentName
FROM HumanResources.Department 

;
-- 2
SELECT 
	AddressType.Name AS AddressName
FROM Person.AddressType
;

-- 3 Actual Cross join
SELECT 
	Department.Name AS DepartmentName, 
	AddressType.Name AS AddressName
FROM HumanResources.Department 
	CROSS JOIN Person.AddressType
;
