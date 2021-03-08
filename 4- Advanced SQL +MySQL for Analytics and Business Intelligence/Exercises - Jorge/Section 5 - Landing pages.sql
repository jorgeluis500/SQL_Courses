-- Section 5 - Analyzing Website performance

USE mavenfuzzyfactory;

-- Videos 33
-- Analyzing Top Website page and Entry pages

SELECT * FROM website_pageviews
LIMIT 1000
;

-- Visits by pages, grouping homepages - not in the course

SELECT 
-- pageview_url,
	CASE 
		WHEN pageview_url = '/home' THEN 'home_pages'
		WHEN pageview_url LIKE '/lander%' THEN 'home_pages'
		ELSE pageview_url END as home_pages,
	COUNT(DISTINCT website_pageview_id) 
FROM  website_pageviews
GROUP BY
1
ORDER BY
COUNT(website_pageview_id) DESC
;


-- Landing pages using nested queries. Practice

SELECT 
	pageview_url,
	COUNT(website_pageview_id) as views
FROM website_pageviews  
	INNER JOIN (
		 SELECT   
		 website_session_id,   
		 MIN(website_pageview_id) AS min_pageview_id  
		 FROM website_pageviews  
		 WHERE website_pageview_id < 1000  
		 GROUP BY website_session_id  ) as tt     
	ON website_pageview_id = tt.min_pageview_id 
WHERE 
	website_pageview_id < 1000 -- If left join is used, we need this here to eliminate the subsequent pages: AND min_pageview_id IS NOT NULL
GROUP BY
	pageview_url
;

-- Landing pages with Temporary tables

 DROP TEMPORARY TABLE first_pageview;
 
 CREATE TEMPORARY TABLE first_pageview
SELECT   
	 website_session_id,   
	 MIN(website_pageview_id) AS min_pageview_id  
FROM website_pageviews  
WHERE website_pageview_id < 1000  
GROUP BY website_session_id; 

SELECT 
	wpv.pageview_url AS landing_page, -- aka 'entry'page'
	COUNT(fpv.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview fpv
	LEFT JOIN website_pageviews wpv
		ON fpv.min_pageview_id = wpv.website_pageview_id
GROUP BY
	wpv.pageview_url
;

-- Videos 34 and 35 - Assignment: Finding top website pages

SELECT
	pageview_url,
	COUNT(DISTINCT website_pageview_id) as pageviews
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY
	pageview_url
ORDER BY
	COUNT(DISTINCT website_pageview_id) DESC
;

-- Videos 36 and 37. Finding top entry pages

SELECT
* 
FROM website_pageviews
LIMIT 1000
;

-- Step 1: find the first pageview in each session

DROP TABLE first_page; -- in case I need to repeat the temporary table

CREATE TEMPORARY TABLE first_page
SELECT
	website_session_id,
	MIN(website_pageview_id) as min_page_id_in_session
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY
	website_session_id;

-- Step 2: Find the URL the customer saw on that first pageview

SELECT 
	wpv.pageview_url AS landing_page,
	COUNT(DISTINCT fp.website_session_id) AS sessions_hitting_this_lainding_page
FROM first_page fp
LEFT JOIN website_pageviews wpv
	ON wpv.website_pageview_id = fp.min_page_id_in_session
-- WHERE created_at < '2012-06-12' ---> not necesary becasue we filtered it in the temp table and we are using a left join
GROUP BY
	wpv.pageview_url;
    
  

