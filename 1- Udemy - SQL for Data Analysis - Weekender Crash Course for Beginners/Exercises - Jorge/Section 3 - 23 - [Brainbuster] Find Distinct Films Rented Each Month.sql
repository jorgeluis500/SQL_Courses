-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 3
-- 23 - [Brainbuster] Find Distinct Films Rented Each Month


-- Rentals per month, Unique customer per month and a avg rentals per customer per month

-- adding Unique titles per month

SELECT
  LEFT(r.rental_date, 7) as Rental_month,
  COUNT(r.rental_id) as Rentals_per_month,
  COUNT(distinct r.customer_id) as Unique_customers,
  COUNT(r.rental_id) / COUNT(distinct r.customer_id) as Avg_rentals_per_customer,
  COUNT(distinct i.film_id) as Unique_titles,
  COUNT(r.rental_id) / COUNT(distinct i.film_id) as Rentals_per_title
FROM
  rental r,
  inventory i,
  film f
WHERE
  r.inventory_id = i.inventory_id
  AND i.film_id = f.film_id
GROUP BY
  LEFT(r.rental_date, 7)
  ;