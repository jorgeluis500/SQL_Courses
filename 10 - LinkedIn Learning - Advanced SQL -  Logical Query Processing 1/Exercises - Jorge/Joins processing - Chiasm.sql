-- When you need to join two tables (using for exampel a bridge table), instead of doing the classif LEFT joins everywhere, it's better to use Chiasm
-- This si instead of doing this:

SELECT
*
FROM Animals A
LEFT OUTER JOIN Adoptions AD
    ON A.Name = AD.Name AND A.Species = AD.Species
LEFT OUTER JOIN Persons P
    ON AD.Adopter_Email = P.Email
;
--  ..do this: 


SELECT
*
FROM Animals A
LEFT OUTER JOIN 
        (Adoptions AD
            INNER JOIN Persons P
                ON AD.Adopter_Email = P.Email
        ) 
    ON A.Name = AD.Name AND A.Species = AD.Species   
;

-- The parenthesis are not required but they help with readability
