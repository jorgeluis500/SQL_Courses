-- Aggregations exercise

USE cinema_booking_system;

SELECT * FROM bookings;

-- How many bookings did customer id 10 make in October 2017?
SELECT 
	customer_id,
	count(ID) 
FROM bookings
WHERE 
	customer_id=10
;

-- Count the number of screenings for Blade Runner 2049 in October 2017
SELECT 
	f.name,
	COUNT(s.id) as Number_of_screenings
FROM screenings s
	LEFT JOIN films f
		ON s.film_id = f.id
WHERE f.name = 'Blade Runner 2049'
;

-- Count the number of unique cusrtomer who made a booking for October 2017
SELECT 
	COUNT(DISTINCT b.customer_id)
FROM bookings b
	LEFT JOIN screenings s
		ON b.screening_id = s.id
WHERE s.start_time BETWEEN '2017-10-01' AND '2017-10-31'
;
-- In fact, the join was unnecessary since all the bookings were made in October 2017
	
    SELECT * FROM screenings;
    
    -- Grouping
    
SELECT 
	customer_id, 
	screening_id,
	COUNT(id) 
FROM bookings
WHERE customer_id = 10
GROUP BY     
	customer_id,
    screening_id
    ;
    
    -- Excercise 2
    -- Part A. Select customer id and count the number of reserved seats grouped by customer for Oct 2017
SELECT 
	customer_id,
	COUNT(rs.id) AS Reserved_seats
FROM customers c
	INNER JOIN bookings b
		ON c.id = b.customer_id
	INNER JOIN reserved_seat rs
		ON b.id = rs.booking_id
GROUP BY
	customer_id
ORDER BY
	customer_id
;

-- Part B. Select the film name and count the number of screeenings for each filem that is over 2 hours long

SELECT
	f.name, 
	f.length_min,
    COUNT(s.id) AS Number_of_screenings
FROM films f
	LEFT JOIN screenings s
		ON f.id = s.film_id
WHERE 
	length_min > 120
GROUP BY
	f.name, 
	f.length_min
;
    