-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 3
-- 25 - Comparison Operators and HAVING

-- Customers with more than 16 rentals

SELECT
r.customer_id,
count(r.rental_id)
 
FROM
rental r
 
GROUP BY
r.customer_id
 
HAVING
count(r.rental_id)<16
 
ORDER BY 
count(r.rental_id) asc
;