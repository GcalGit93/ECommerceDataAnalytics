WITH dist_cust AS (
		SELECT DISTINCT customer_id, country
		FROM staging_orders
		WHERE customer_id IS NOT NULL
	),
	id_counts AS (
		SELECT customer_id, COUNT(*) as multiples
		FROM dist_cust 
		GROUP BY customer_id
	),	
	duplicate_customers AS (
		SELECT customer_id, multiples
		FROM id_counts
		WHERE multiples > 1 
	)

SELECT *
FROM dist_cust
WHERE customer_id IN (SELECT customer_id FROM duplicate_customers)
ORDER BY customer_id

/* 
SELECT *
FROM staging_orders
WHERE customer_id IN (SELECT * FROM duplicate_customers)
*/