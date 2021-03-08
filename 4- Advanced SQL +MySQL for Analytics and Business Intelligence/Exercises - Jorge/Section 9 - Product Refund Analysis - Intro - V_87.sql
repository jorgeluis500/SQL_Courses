-- SECTION 9 
-- PRODUCT ANALYSIS

USE mavenfuzzyfactory;

-- Product Refund Analysis
-- Intro 
-- Videos 87
-- Slide 154

SELECT 
*
FROM order_items
;

SELECT 
*
FROM order_item_refunds
;

-- Join between orders items and order items refunds.
-- With this join you see the orders that had refunds AND all the items in the order, whetther they were returned or not

SELECT 
*
FROM order_items oi
LEFT JOIN order_item_refunds oif
	ON oi.order_item_id = oif.order_item_id
WHERE oi.order_id IN (3489, 27061, 32049)
ORDER BY
	oi.order_id 
;


-- Join between orders and order items refunds.
-- With this join you see the orders that had refunds but not all the items in the order

SELECT 
*
FROM orders oi
LEFT JOIN order_item_refunds oif
	ON oi.order_id = oif.order_id
WHERE oi.order_id IN (3489, 27061, 32049)
ORDER BY
	oi.order_id;
