WITH campaign_activity AS (
	SELECT
		customer_id,
		COUNT(DISTINCT invoice_no) AS total_orders
	FROM orders
	GROUP BY customer_id
)
/*
SELECT * 
FROM campaign_activity
WHERE total_orders < 1
*/

SELECT
	COUNT(*) FILTER (WHERE total_orders > 0)::FLOAT / COUNT(*) as conversion_rate
FROM campaign_activity;