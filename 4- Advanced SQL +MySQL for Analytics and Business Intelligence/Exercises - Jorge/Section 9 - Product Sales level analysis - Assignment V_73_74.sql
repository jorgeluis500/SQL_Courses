-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Product Sales level analysis
-- Assignment
-- Slide 132, Video 73 and 74

-- Pull monthly trends to date for number of sales, total revenue, and total margin generated 
-- Date of the request '2013-01-04'

SELECT 
	YEAR(created_at) AS yr,
	MONTH(created_at) AS mo,
	COUNT(DISTINCT order_id) AS number_of_sales,
	SUM(price_usd) AS revenue, 
	SUM(price_usd - cogs_usd) AS margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY
	YEAR(created_at),
	MONTH(created_at)