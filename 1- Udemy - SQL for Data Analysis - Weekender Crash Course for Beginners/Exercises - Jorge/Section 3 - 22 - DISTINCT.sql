-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 3
-- 22 - DISTINCT



-- Rentals per month, Unique customer per month and a avg rentasl per customer per month

SELECT
 
  LEFT(r.rental_date, 7)                                as Rental_month,
  COUNT(r.rental_id)                                    as Rentals_per_month,
  COUNT(distinct r.customer_id)                         as Unique_customers,
  COUNT(r.rental_id) / COUNT(distinct r.customer_id)    as Avg_rentals_per_customer
 
FROM
  rental r
 
GROUP BY
  LEFT(r.rental_date, 7)
  ;