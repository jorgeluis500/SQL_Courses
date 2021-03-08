-- Subqueries

USE cinema_booking_system;

-- Non-correlated queries in the WHERE
-- The subquery can be run as a standalone query
SELECT
	id, 
    start_time
FROM screenings
WHERE 
film_id IN (
		SELECT id from films
		WHERE length_min > 120)
;



SELECT
email
FROM customers
WHERE id IN (
	SELECT customer_id FROM bookings
    WHERE screening_id = 1
    )
  ;
  
  -- Non-correlated queries in the FROM

SELECT * FROM reserved_seat;

SELECT 
	AVG(No_seats),
	MAX(No_seats)
FROM
	(
    SELECT 
		booking_id, 
		COUNT(seat_id) AS No_seats
	FROM reserved_seat
	GROUP BY
		booking_id
	) AS b
;

-- Correlated subqueries
-- The subquery can't run without the outer query

SELECT * FROM bookings;
SELECT * FROM reserved_seat;

SELECT
	screening_id,
    customer_id
FROM bookings
ORDER BY
	screening_id
;
    
SELECT
	screening_id,
    customer_id,
    (SELECT
		COUNT(seat_id)
	FROM reserved_seat
    WHERE 
		booking_id = b.id)
FROM bookings b
ORDER BY
	screening_id
;

-- Exercises

-- 1. Select the name and length from al films with a length greater than the average film length

SELECT
	name,
    length_min
FROM films
WHERE length_min > (
	SELECT 
		AVG(length_min)
	FROM films)
ORDER BY name
;

-- 2. Select the maximum number and the minimum number of screenings for a particular film

SELECT * FROM screenings
;

SELECT
	MAX(ns.Number_of_screenings) AS Max_screenings,
    MIN(ns.Number_of_screenings) AS Min_screenings
FROM
(
	SELECT 
		film_id,
		COUNT(id) AS Number_of_screenings
	FROM screenings
	GROUP BY
		film_id
	ORDER BY
		COUNT(id) DESC
) AS ns
;
-- 3. Select each film name and the number of screenings for that film

SELECT
f.name,
(	
	SELECT COUNT(id) FROM screenings
	WHERE film_id = f.id
) AS Number_of_screenings
FROM films f
ORDER BY
	Number_of_screenings DESC
;

-- Number 3 without the subquery. Using an inner join instead

SELECT 
    f.name, 
    COUNT(s.id) AS Number_of_screenings
FROM screenings s
	LEFT JOIN films f 
		ON s.film_id = f.id
GROUP BY 
	f.name
ORDER BY 
	COUNT(id) DESC
;

