-- WINDOW FUNCTIONS
-- Section 6
-- Offset Window Functions


SELECT
	species,
	"name",
	checkup_time,
	weight, 
	LAG(weight) OVER(
					PARTITION BY species, name
					ORDER BY checkup_time ASC) AS weight_previous_checkup,
					-- Interesting e important: When you specidy the partition, the order by does not need to specify the same fields opf the partitio again, just the checkup time for each partition
	(weight - LAG(weight) OVER(
					PARTITION BY species, name
					ORDER BY checkup_time ASC)) AS weight_variation
FROM routine_checkups rc 
--We should do nothing about the resulting nulls, at least not at a database level

;

SELECT
	species,
	"name",
	checkup_time,
	weight, 
	FIRST_VALUE (weight) OVER(
					PARTITION BY species, name
					ORDER BY checkup_time ASC
					RANGE BETWEEN	'3 months' PRECEDING
									AND
									'1 day' PRECEDING) AS weight_previous_checkup
FROM routine_checkups rc 
WHERE name = 'Ivy'
ORDER BY 
	species,
	name,
	checkup_time ASC
