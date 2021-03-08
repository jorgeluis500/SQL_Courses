-- WINDOWS FUNCTIONS
-- Section 3
-- Quiz

USE animal_shelter;

-- Question 1

SELECT MIN(admission_date) OVER (ORDER BY name ASC GROUPS BETWEEN UNBOUNDED PRECEDING and 1 PRECEDING)
FROM animals;

--A: The earliest admission date of all animals whose names have a dictionary sort order that is lower than the current animal's name.


-- Question 2

SELECT MIN(admission_date) OVER (ORDER BY name ASC ROWS BETWEEN UNBOUNDED PRECEDING and 1 PRECEDING)
FROM animals;

-- A: The earliest admission date of all animals whose names have a dictionary sort order that is lower than the current animal's name. 
-- Animals with the same name will be sorted arbitrarily.

-- Question 3

SELECT MIN(admission_date) OVER (PARTITION BY species ORDER BY birth_date DESC)
FROM animals;

-- A: The earliest admission date of all animals of the same species as the current animal, and whose birth date is larger than or equal to the current animal's birth date.