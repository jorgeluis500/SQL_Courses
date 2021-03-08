-- STRING AND DATE FUNCTIONS

-- String functions

SELECT
	email,
	substring(email, 5)
FROM customers
;

SELECT
	substring(name, -3)
FROM films
;

-- Date function

SELECT DATE('2018-06-05 07:45:32');-- Extracts the date only

SELECT 
    DATE(start_time)
FROM
    screenings

