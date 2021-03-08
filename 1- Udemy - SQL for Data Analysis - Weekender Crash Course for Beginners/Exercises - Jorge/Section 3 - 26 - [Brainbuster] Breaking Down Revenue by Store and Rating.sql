-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 3
-- 26 - [Brainbuster] Breaking Down Revenue by Store and Rating

-- Revenue from store 1 where film is rated R or PG-13

SELECT
  i.store_id as Store,
  f.rating as Rating,
  SUM(p.amount) as Revenue
FROM
  payment p,
  rental r,
  inventory i,
  film f
WHERE
  p.rental_id = r.rental_id
  and r.inventory_id = i.inventory_id
  and i.film_id = f.film_id
  and r.rental_id = p.rental_id
  and f.rating IN ('R', 'PG-13')
  and i.store_id = 1
GROUP BY
  i.store_id,
  f.rating
  ;