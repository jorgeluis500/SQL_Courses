-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 4
-- Joins 2 - Brainbuster

-- All Reward users with phone (for those who are also active users)

-- Temporary tables don't seem to work in sqlsnack
-- These queries gives the same result as the one with temp tables

-- Option 1

SELECT
  au.customer_id,
  au.email,
  au.first_name
FROM
  (
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
  ) as au
  JOIN 
(
    SELECT
      r.customer_id,
      count(r.rental_id),
      MAX(r.rental_date)
    FROM
      rental r
    GROUP BY
      r.customer_id
    HAVING
      count(r.rental_id) >= 30
  ) as r 
    on au.customer_id = r.customer_id
GROUP BY
  au.customer_id;

  -- Option 2

  SELECT
  ru.customer_id,
  ct.email, 
  au.phone
  
FROM
-- Reward users 
 (
    SELECT
      r.customer_id,
      count(r.rental_id),
      MAX(r.rental_date)
    FROM
      rental r
    GROUP BY
      r.customer_id
    HAVING
      count(r.rental_id) >= 30
  ) 
  as ru
  
-- join it with customers  
  JOIN customer ct on ct.customer_id = ru.customer_id
 
-- and then left join it with Active Users to bring the phone numbers from them. This will produce some nulls for the people not active (but in the rewards table)
  LEFT JOIN
 
(
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
  ) 
  as au
   
  on au.customer_id = ru.customer_id
 
GROUP BY
  ru.customer_id;
-- very important step. If grouped by the users in Active Users, 4 records --out of the 5 with no phone number, dissapear
 
ORDER BY
au.phone 
 