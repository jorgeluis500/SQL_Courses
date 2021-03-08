-- Maven fuzzy factory database. Probable website structure

USE mavenfuzzyfactory;

-- Quick view of the table

SELECT * FROM website_pageviews LIMIT 1000;

-- Query to guess the website structure
-- The first temporaty query gives me the rank of the pages inside each sesion

WITH pr AS (
	SELECT
		website_session_id,
		website_pageview_id,
		pageview_url,
		ROW_NUMBER() OVER (PARTITION BY website_session_id ORDER BY website_session_id, website_pageview_id) AS page_rank
	FROM website_pageviews
	GROUP BY
		website_session_id,
		website_pageview_id,
		pageview_url
	ORDER BY
		website_session_id,
		website_pageview_id
        )

-- This query then gives me the average position of each page in general

SELECT 
	pageview_url,
	AVG(page_rank) AS probable_page_order,
    COUNT(website_pageview_id) AS number_of_hits
FROM pr
GROUP BY
	pageview_url
ORDER BY
	AVG(page_rank)
;