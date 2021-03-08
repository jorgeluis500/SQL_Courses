-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 3
-- 17 - Arithmetic & Order By


-- FILMS THAT GIVE US THE MOST REVENUE

SELECT
  f.film_id,
  f.title,
  #--i.inventory_id
  #--i.film_id
  #--r.inventory_id
  count(r.rental_id) as Number_of_rentals,
  f.rental_rate,
  count(r.rental_id) * f.rental_rate as Revenue
FROM
  film f,
  rental r,
  inventory i
WHERE
  f.film_id = i.film_id
  AND i.inventory_id = r.inventory_id
GROUP BY
  f.film_id,
  f.title
ORDER BY 
Revenue DESC
;

-- BEST CUSTOMER AND AMOUNT

-- Option 1 - with Customer table

SELECT
  p.customer_id,
  c.first_name,
  c.last_name,
  SUM(p.amount) as Revenue
FROM
  payment p,
  customer c
WHERE
  p.customer_id = c.customer_id
  
GROUP BY
  p.customer_id,
  c.first_name,
  c.last_name
ORDER BY
  SUM(p.amount) DESC
  limit 0,1;

-- Option 2 - with Customer List table

SELECT
  p.customer_id,
  c.name,
    SUM(p.amount) as Revenue
FROM
  payment p,
  customer_list c
WHERE
  p.customer_id = c.ID
  
GROUP BY
  p.customer_id,
  c.name
ORDER BY
  SUM(p.amount) DESC
  limit 0,1;