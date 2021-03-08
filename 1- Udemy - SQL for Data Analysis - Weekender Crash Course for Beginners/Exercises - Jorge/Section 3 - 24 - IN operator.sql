-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 3
-- 24 - IN operator

-- Number of Rentals in Comedy, Family and Sports



SELECT
 
c.name,
count(rental_id) as number_of_rentals
 
FROM
rental r, inventory i, film_category fc, category c
 
WHERE
r.inventory_id = i.inventory_id AND i.film_id = fc.film_id AND fc.category_id = c.category_id
AND c.name IN ('Comedy', 'Sports', 'Family')
 
GROUP BY
c.category_id
;