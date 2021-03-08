-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 3
-- 19 - LEFT() MIN() AND MAX()


-- Min and Max rental date by title (and, in addition, number of rentals. Sorted by number of rentals)

SELECT
  f.film_id,
  f.title,
  MAX(r.rental_date) as MAX_DATE,
  MIN(r.rental_date) as MIN_DATE,
  COUNT (r.rental_id)
FROM
  rental r,
  film f,
  inventory i
WHERE
  r.inventory_id = i.inventory_id
  AND f.film_id = i.film_id
GROUP BY
  f.film_id,
  f.title
ORDER BY
  COUNT (r.rental_id) DESC;