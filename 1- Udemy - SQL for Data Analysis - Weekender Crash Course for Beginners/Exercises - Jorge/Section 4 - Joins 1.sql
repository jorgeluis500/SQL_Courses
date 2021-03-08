-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 4
-- Joins 1

-- Customers with more than 30 rentals

SELECT
    r.customer_id,
    count(r.rental_id),
    MAX(r.rental_date)
FROM rental r
GROUP BY
    r.customer_id
HAVING
    count(r.rental_id) >=30
    ;


-- Active customers with phone number

SELECT
  c.*,
  a.phone
FROM
  customer c
  JOIN address a ON c.address_id = a.address_id
WHERE
  c.active = 1
GROUP BY
  1
  ;