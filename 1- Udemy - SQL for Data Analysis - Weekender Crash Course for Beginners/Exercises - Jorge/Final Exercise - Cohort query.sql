-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Final Exercise

-- Cohort data (done with nested queries)

SELECT  
  t.Cohort,
  ch.Cohort_size,
  t.Months_after_join,
  count(distinct t.customer_id) as Returning_customers,
  SUM(t.amount) as Month_revenue,
  SUM(t.amount) / count(distinct t.customer_id) as RPU

FROM
(
-- This section has all the data from rental, the first rental date and the join bring the rental amount
SELECT
  r.customer_id,
  r.rental_date,
  md.First_time,
    MID(md.First_time,6,2) as Joining_month,
    MID(r.rental_date,6,2) as Rental_month,
    PERIOD_DIFF(date_format(r.rental_date, '%y%m'), date_format(md.First_time, '%y%m')) as Months_after_join,
    LEFT(md.First_time,7) as Cohort, 
    p.amount
FROM
  rental r
  LEFT JOIN (
            -- This sections gives me the First rental date per customer
            SELECT
              r.customer_id,
              MIN(r.rental_date) as First_time
            FROM
              rental r
            GROUP BY
              r.customer_id
            ) as md 
  on md.customer_id = r.customer_id
  
  LEFT JOIN payment p on r.customer_id = p.customer_id and r.rental_id = p.rental_id
) as t

LEFT JOIN (
          -- This section creartes the cohorts and counts the unique number of customers in each cohort
          SELECT

          LEFT(md.Min_date,7) as Cohort,
          count(md.customer_id) as Cohort_size

          FROM
            ( -- this section calculates the first date per customer (Min_date)
            SELECT
            customer_id,
            MIN(rental_date) as Min_date
            FROM rental r1
            GROUP BY
            customer_id
            ) as md

          GROUP BY
          LEFT(md.Min_date,7) 
          ) as ch on ch.Cohort = t.Cohort

GROUP BY
t.Cohort,
ch.Cohort_size,
t.Months_after_join

ORDER BY 1,3