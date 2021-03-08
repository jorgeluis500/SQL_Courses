-- WINDOW FUNCTIONS
-- Section 5
-- ROW_NUMBER and NTILE

-- We need to write a query to show the top three and only three animals of each species who had the most checkups, 
-- including species for which we have less than three animals.

-- Exploration
SELECT
	species,
	name,
	COUNT(*) As number_of_checkups
FROM routine_checkups rc 
GROUP BY
	species,
	name
ORDER BY 
	species,
	COUNT(*) DESC
;

-- STEP 1
-- The previous query dones not consider all the species so we need to use the species table to include those with 0 checkups
-- We need to have all the species, so they have 0 checkups. 
-- For that we use the reference.species table to bring them all and left join it with the routine_checkups table on species

SELECT
	s.species,
	rc."name",
--	COUNT(*) AS number_of_checkups -- this doesn't make sense since for sepecies without checkups, it returns 1
	COUNT(rc.checkup_time) AS number_of_checkups, -- By using this, we make sure that species that are not there yet, have 0 checkups
	ROW_NUMBER() OVER (PARTITION BY s.species ORDER BY COUNT(rc.checkup_time) DESC) AS checkup_ranking
FROM
	reference.species s
LEFT JOIN routine_checkups rc ON
	s.species = rc.species
GROUP BY
	s.species,
	rc."name"
ORDER BY
	s.species,
	COUNT(*) DESC
;

-- STEP 2
-- We turn the previous query into a CTE and then select *	filtering the rank

WITH ranked_checkups AS (
		SELECT
			s.species,
			rc."name",
			COUNT(rc.checkup_time) AS number_of_checkups,
			ROW_NUMBER() OVER (PARTITION BY s.species ORDER BY COUNT(rc.checkup_time) DESC) AS checkup_ranking
		FROM
			reference.species s
		LEFT JOIN routine_checkups rc ON
			s.species = rc.species
		GROUP BY
			s.species,
			rc."name"
	) -- SELECT * FROM ranked_checkups -- Test

SELECT
	*
FROM ranked_checkups
WHERE 
	checkup_ranking <=3
;


