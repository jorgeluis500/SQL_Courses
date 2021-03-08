-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 3
-- 20 - [Brainbuster] Finding Your Active Users - Last Rental Time by Customer


-- 1. Max rental date per customer and total number of rentals

SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  MAX(r.rental_date) as Max_rental_date,
  COUNT(r.rental_id) as Number_of_rentals
FROM
  rental r,
  customer c
WHERE
  r.customer_id = c.customer_id
GROUP BY
  c.customer_id
;

-- 2. Revenue per month

SELECT
  SUM(p.amount) as Revenue,
  LEFT(p.payment_date,7) as Revenue_month
FROM
  payment p
GROUP BY
  LEFT(p.payment_date,7)
;