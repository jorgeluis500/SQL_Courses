
-- SQL for Data Analysis: Weekender Crash Course for Beginners
-- Section 3
-- 13 - Connecting tables


-- What I need:

-- From film: film_id, title, language_id,

-- From film category: film id, category_id

-- From category: category_id, name

-- From Language: language_id,


SELECT
  film.film_id,
  film.title,
  #--film.language_id,
  #--film_category.category_id
  category.name as Category,
  language.name as Language
FROM
  film,
  film_category,
  category,
  language
WHERE
  film.film_id = film_category.film_id
  AND film_category.category_id = category.category_id
  AND film.language_id = language.language_id
ORDER BY
  film.film_id
  ;