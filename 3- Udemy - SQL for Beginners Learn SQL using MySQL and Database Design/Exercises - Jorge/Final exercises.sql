-- Challenges

-- 1. Select films over two hours long

SELECT 
	*
FROM films
WHERE length_min >120;

-- 2. Which film had the most screenings in Oct 2017

SELECT 
	f.name as Film,
    COUNT(*) AS Number_of_screenings
FROM screenings s
	LEFT JOIN films f
		ON s.film_id = f.id
GROUP BY
	film_id
ORDER BY
	COUNT(*) DESC
LIMIT 1
;

-- 3. How many bookings did Jigsaw had in Oct 2017

SELECT * FROM bookings;
SELECT * FROM screenings;

-- This is wrong
SELECT 
	f.id,
	f.name,
	COUNT(b.id) AS Number_of_screenings
FROM bookings b
	LEFT JOIN screenings s
		ON b.screening_id = s.id
	LEFT JOIN films f
		ON s.film_id = f.id
WHERE
	f.name = 'Jigsaw'
;

-- Right solution with subquery

SELECT
COUNT(b.id) AS number_of_bookings
FROM bookings b
LEFT JOIN screenings s
	ON b.screening_id = s.id
WHERE s.film_id = (
					SELECT
						id
					FROM films
					WHERE name = 'Jigsaw'
					)
;

-- Right solution with bridge table - easire to read

SELECT
	f.name,
	COUNT(b.id) AS number_of_bookings
FROM bookings b
INNER JOIN screenings s
	ON b.screening_id = s.id
INNER JOIN films f
	ON s.film_id = f.id
WHERE f.name = 'Jigsaw'
GROUP BY
	f.name;


-- 4. Which 5 customers did the most bookings in Oct 2017?

SELECT * FROM bookings;
SELECT * FROM customers;

SELECT
	-- b.customer_id,
    c.first_name,
    c.last_name,
	COUNT(b.id) AS Number_of_bookings
FROM bookings b
	LEFT JOIN customers c
		ON b.customer_id = c.id
GROUP BY
	b.customer_id, -- by grouping by customer_id, we are iginv the dataset the desired granularity. However, IMO is't good practice to group by all fields involved
	c.first_name,
    c.last_name
ORDER BY
	COUNT(b.id) DESC
LIMIT 5
;

-- 5. Which film was most shown in the Chaplin room in October 2017

SELECT * FROM screenings
ORDER BY 
room_id;

SELECT 
    s.room_id,
    r.name,
    s.film_id,
    f.name,
    COUNT(s.id) AS Number_of_screenings
FROM
    screenings s
INNER JOIN rooms r
	ON s.room_id = r.id 
INNER JOIN films f
	ON s.film_id = f.id
WHERE 
	r.name = 'Chaplin'
GROUP BY
    s.room_id,
    s.film_id
ORDER BY
	COUNT(s.id) DESC
LIMIT 1
;

-- 6. How many of the customers made a bookings in 2017?

-- Exploration
SELECT * FROM bookings;
SELECT * FROM customers;

-- Solution 1 (wrong): only customers that didn't book

SELECT
	COUNT( DISTINCT it.All_Customers) AS Number_of_Customers
FROM (
	SELECT 
		c.id AS All_Customers,
		b.customer_id AS Booking_customers
	FROM
		customers c
	LEFT JOIN bookings b
		ON b.customer_id = c.id
) AS it
WHERE it.Booking_customers IS NULL
;

-- Solution 2. Customers than booked and all customers

SELECT
	CASE WHEN it.Booking_customers IS NULL THEN 'No_booking' ELSE 'Booking' END AS Customer_action,
	COUNT( DISTINCT it.All_Customers) AS Number_of_Customers
FROM (
	SELECT 
		c.id AS All_Customers,
		b.customer_id AS Booking_customers
	FROM
		customers c
	LEFT JOIN bookings b
		ON b.customer_id = c.id
) AS it
GROUP BY
	CASE WHEN it.Booking_customers IS NULL THEN 'No_booking' ELSE 'Booking' END ;
    
-- Another solution, only for the customers that booked

SELECT 
	COUNT(id) AS Customers_that_booked
FROM customers 
WHERE id IN 
	(SELECT customer_id FROM bookings);

-- Or simply...
    
SELECT 
	COUNT(DISTINCT customer_id) AS customers_that_booked 
FROM bookings;
