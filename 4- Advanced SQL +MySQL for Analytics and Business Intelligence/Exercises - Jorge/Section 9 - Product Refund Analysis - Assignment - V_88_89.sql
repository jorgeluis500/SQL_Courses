-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Product Refund Analysis
-- Assignment
-- Videos 88 and 89
-- Slide 157

/*
Our Mr. Fuzzy supplier had some quality issues which
weren’t corrected until September 2013. Then they had a
major problem where the bears’ arms were falling off in
Aug/Sep 2014. As a result, we replaced them with a new
supplier on September 16, 2014.

Can you please pull monthly product refund rates, by
product, and confirm our quality issues are now fixed?
*/


-- Exploration

SELECT 
*,
YEAR(oi.created_at) AS yr,
MONTH(oi.created_at) AS mo
FROM order_items oi
LEFT JOIN order_item_refunds oif
	ON oi.order_item_id = oif.order_item_id
;

-- Step 1
-- Check the metrics

SELECT 
	oi.product_id,
	YEAR(oi.created_at) AS yr,
	MONTH(oi.created_at) AS mo,
	COUNT(DISTINCT oi.order_id) as orders,
	COUNT(DISTINCT oif.order_item_id) / COUNT(DISTINCT oi.order_item_id) as refund_rt
FROM order_items oi
LEFT JOIN order_item_refunds oif
	ON oi.order_item_id = oif.order_item_id
WHERE oi.created_at < '2014-10-15'
GROUP BY
	oi.product_id,
    YEAR(oi.created_at),
	MONTH(oi.created_at)
;

-- Step 2
-- Create the additional metics and pivot them

SELECT 
	YEAR(oi.created_at) AS yr,
	MONTH(oi.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oi.order_id ELSE NULL END) AS p1_orders,
	COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oif.order_item_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oi.order_id ELSE NULL END) AS p1_refund_rt,
	
    	COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oi.order_id ELSE NULL END) AS p2_orders,
    COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oif.order_item_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oi.order_id ELSE NULL END) AS p2_refund_rt,
	
    	COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oi.order_id ELSE NULL END) AS p3_orders,
    COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oif.order_item_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oi.order_id ELSE NULL END) AS p3_refund_rt,
	COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN oif.order_item_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN oi.order_id ELSE NULL END) AS p4_refund_rt
FROM order_items oi
LEFT JOIN order_item_refunds oif
	ON oi.order_item_id = oif.order_item_id
WHERE oi.created_at < '2014-10-15'
GROUP BY
	YEAR(oi.created_at),
	MONTH(oi.created_at)
;
