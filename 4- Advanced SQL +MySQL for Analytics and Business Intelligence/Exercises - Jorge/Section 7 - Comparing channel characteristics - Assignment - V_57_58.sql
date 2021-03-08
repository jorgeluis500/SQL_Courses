-- SECTION 7
-- ANALYZING CHANNEL PORTFOLIOS

USE mavenfuzzyfactory;

-- Comparing channel characteristics - Assignment
-- Videos 57 and 58

-- learn more about bsearch nonbrand campaign.
-- pull the percentage of traffic coming on Mobile, and compare that to gsearch?
-- Feel free to dig around and share anything else you find interesting. 
-- Aggregate data since August 22nd is great, no need to show trending

SELECT 
	utm_source,
	COUNT(DISTINCT website_session_id ) AS sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id ) AS pct_mobile
FROM website_sessions
WHERE 
	created_at > '2012-08-22' AND
    created_at < '2012-11-30' AND
	utm_source IN ('gsearch', 'bsearch') AND
    utm_campaign = 'nonbrand'
GROUP BY 
	utm_source