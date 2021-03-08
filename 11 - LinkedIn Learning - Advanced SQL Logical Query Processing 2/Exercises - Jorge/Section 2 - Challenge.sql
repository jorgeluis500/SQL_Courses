-- ADVANCED SQL - LOGICAL QUERY PROCESSING 2
-- Section 2 - Challenge

-- Test
SELECT 
	* 
FROM animals a2
WHERE breed IS NOT NULL
ORDER BY breed
;

--Part a.
-- We need a self join on species and breed all possible commbinations
--This give us a cartesian join with all the rows that matches the predicate but repeated

SELECT 
	a1.species, 
	a1.breed,
	a1.name,
	a1.gender,
	a2.name,
	a2.gender
FROM animals a1
INNER JOIN animals a2
	ON  a1.breed  = a2.breed  --  The A1.Breed = A2.Breed predicate caused all animals with a null breed to evaluate to unknown. And in this case, it's a desirable effect.
--	AND a1.breed IS NOT NULL -- This line could be added for clarity
	AND a1.species = a2.species 
ORDER BY a1.species, a1.breed
;

-- Part b
-- We need to differentitate the genders. Match onlye female with male.

SELECT 
	a1.species, 
	a1.breed,
	a1.name,
	a1.gender,
	a2.name,
	a2.gender
FROM animals a1
INNER JOIN animals a2
	ON  a1.breed  = a2.breed  
	AND a1.species = a2.species 
	AND a1.gender <> a2.gender -- This does the trick. However, we get 2 lines by pair
ORDER BY species, breed
;

-- Part 3. 
-- Instead of having two lines per pair, we need one. Introducing an inequelity will do the job

SELECT 
	a1.species, 
	a1.breed,
	a1.name,
	a1.gender,
	a2.name,
	a2.gender
FROM animals a1
INNER JOIN animals a2
	ON  a1.breed  = a2.breed  
	AND a1.species = a2.species 
	AND a1.gender > a2.gender -- This is the key part. If we put <> (different than), we get the correct results. By using the inequality we get one line
ORDER BY species, breed

-- A word of caution. If you decide to use this shortcut for strings, make sure your collations use dictionary sort order and that the string casing is consistent. 
-- If you use a binary sort order or a case sensitive collation, a non-capital 'f' will have a higher sort order than a capital 'M', which is going to fail this query
;



-- Part 4
-- We will also use the names as genders, knowing the gender in advance by executing the query with the inequality in the previous query

SELECT 
	a1.species, 
	a1.breed,
	a1.name AS male,
--	a1.gender,
	a2.name AS female
--	a2.gender
FROM animals a1
INNER JOIN animals a2
	ON  a1.breed  = a2.breed  
	AND a1.species = a2.species 
	AND a1.gender > a2.gender -- This is the key part. If we put <> (different than), we get the correct results. By using the inequality we get one line
ORDER BY species, breed
;
