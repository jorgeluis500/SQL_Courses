-- WINDOW FUNCTIONS
-- Section 5
-- RANK and DENSE_RANK


WITH All_ranks AS (
		SELECT
			s.species,
			rc."name",
			COUNT(rc.checkup_time) AS number_of_checkups,
			ROW_NUMBER() OVER w AS row_number,
			RANK() OVER w AS rank,
			DENSE_RANK () OVER w AS rank_dense
		FROM
			reference.species s
		LEFT JOIN routine_checkups rc ON
			s.species = rc.species
		GROUP BY
			s.species,
			rc."name"
		WINDOW w AS (PARTITION BY s.species ORDER BY COUNT(rc.checkup_time) DESC) -- Use of WINDOWS clause for the OVER clause and avoid repetition
	) -- SELECT * FROM All_ranks -- Test

SELECT
	*
FROM All_ranks
--WHERE 
--	row_number <=3 -- Test with RANK and DENSE_RANK