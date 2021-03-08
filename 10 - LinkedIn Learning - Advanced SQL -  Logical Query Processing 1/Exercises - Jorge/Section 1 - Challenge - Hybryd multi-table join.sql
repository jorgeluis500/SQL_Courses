-- Advanced SQL - Logical Query Processing 
-- Section 1 Challenge

-- Write a query to report aninmals and their vaccinations
-- Include animals that have not been vaccinated
-- The report should include the animal's sname, species breed and primary color, vaccination time and vaccine name, the staff membner first name, last name and role

-- Use the minumum number of tables required

-- Use the correct logical join types and force join order as needed

-- SOLUTION
-- See the Entity Relationship Diagram

-- Exploration
SELECT * FROM Vaccinations ;

SELECT * FROM Persons ;

SELECT
    a.Name, 
    a.Species,
    a.Primary_Color,
    v.Vaccination_Time,
    v.Vaccine,
    v.Email,
    p.First_Name,
    p.Last_Name,
    sa.Role
FROM Animals AS a
LEFT OUTER JOIN 
    (Vaccinations v
        INNER JOIN 
        (Staff s
            INNER JOIN 
            (Persons p
                INNER JOIN Staff_Assignments sa
                ON  p.email = sa.Email
            )
            ON s.Email = p.Email
        )
        ON v.Email = s.Email
    )
ON a.Name = v.Name AND a.Species = v.Species
;

-- This previous query is a convoluted solution. Its better to write all joins at the same level, then change the Animals to get it as a LEFT join, and the rest goes inside the parenthesis
-- with the predicate for the animals join, outside it

SELECT
    a.Name, 
    a.Species,
    a.Primary_Color,
    v.Vaccination_Time,
    v.Vaccine,
    v.Email,
    p.First_Name,
    p.Last_Name,
    sa.Role
FROM Animals AS a
LEFT OUTER JOIN 
    (
    Vaccinations v -- The predicate for this join is moved outside the parenthesis
    INNER JOIN Staff s
        ON v.Email = s.Email
    INNER JOIN Persons p
        ON s.Email = p.Email
    INNER JOIN Staff_Assignments sa
        ON  p.email = sa.Email
    )
ON a.Name = v.Name AND a.Species = v.Species
;
